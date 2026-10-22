import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  final Map<String, DateTime> _lastNotificationTimes = {};

  NotificationService(this._ref);

  Future<void> init() async {
    await localNotifier.setup(
      appName: 'Zedu',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }

  /// Handles an incoming message and shows a desktop notification.
  ///
  /// When [forceShow] is `true` the focus-check and per-sender throttle are
  /// skipped so that test / manual notifications always fire.
  Future<void> handleIncomingMessage(
    Map<String, dynamic> message,
    String channelId,
    String senderName, {
    bool forceShow = false,
  }) async {
    final settings = _ref.read(notificationSettingsProvider);
    final authState = _ref.read(authNotifierProvider);
    final currentUserId = authState.user?.id ?? '';

    final senderId = (message['user_id'] ?? message['userId']).toString();

    // Never notify about our own messages (unless forced for testing).
    if (!forceShow && (senderId == currentUserId || senderId == 'me')) return;

    if (settings.isDndActive) return;
    if (settings.isMuted(senderId)) return;

    if (!forceShow) {
      final isFocused = await windowManager.isFocused();
      final selectedChannel = _ref.read(selectedDmProvider)?.channelId;

      if (isFocused && selectedChannel == channelId) {
        return;
      }

      final now = DateTime.now();
      final lastTime = _lastNotificationTimes[senderId];
      if (lastTime != null && now.difference(lastTime).inSeconds < 5) {
        return;
      }
      _lastNotificationTimes[senderId] = now;
    }

    String contentPreview;
    final rawContent = (message['content'] ?? '').toString();
    if (rawContent.isEmpty) {
      final media = message['media'] as List<dynamic>? ?? [];
      contentPreview = media.isNotEmpty ? 'Sent an attachment' : 'New message';
    } else {
      contentPreview = dmNotificationPreview(rawContent);
    }

    final notification = LocalNotification(
      title: 'New DM from $senderName',
      body: contentPreview,
    );

    notification.onClick = () async {
      await windowManager.show();
      await windowManager.focus();

      final router = locator<GoRouter>();
      router.go('/dms/$channelId');
    };

    await notification.show();
  }
}

/// Maximum Unicode characters in a notification preview before truncation.
const int _kNotificationPreviewMaxRunes = 80;

/// Number of Unicode characters kept when a preview is truncated.
const int _kNotificationPreviewTruncateRunes = 77;

/// Converts raw message content (HTML from web, Markdown from desktop) into
/// plain text safe for a desktop notification body. Long messages are
/// truncated by Unicode character (not UTF-16 unit) so emojis are never split
/// in half, e.g. a long message ending in an emoji ends with `…` not `�`.
String dmNotificationPreview(String content) {
  var text = HtmlUtils.toPlainText(content);
  text = text
      .replaceAll(RegExp(r'\*\*'), '') // bold
      .replaceAll(RegExp(r'~~'), '')   // strikethrough
      .replaceAll(RegExp(r'`'), '')    // inline code
      .replaceAll(RegExp(r'\*'), '');  // italic (remaining single asterisks)
  text = text.trim();

  if (text.runes.length > _kNotificationPreviewMaxRunes) {
    text = '${_truncateByRunes(text, _kNotificationPreviewTruncateRunes)}...';
  }
  return text;
}

/// Returns the first [maxRunes] Unicode characters of [text].
String _truncateByRunes(String text, int maxRunes) {
  final runes = text.runes.toList();
  if (runes.length <= maxRunes) return text;
  return String.fromCharCodes(runes.take(maxRunes));
}
