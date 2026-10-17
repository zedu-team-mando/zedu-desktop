import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class DmProfileCard extends StatelessWidget {
  final DmConversation conversation;

  const DmProfileCard({super.key, required this.conversation});

  String get _handle {
    final name = conversation.displayName.trim();
    if (name.isEmpty) return '@user';

    final nameParts = name.split(RegExp(r'\s+'));
    if (nameParts.length > 1) {
      return '@${nameParts.first}_${nameParts.last}';
    }
    return '@${nameParts.first}';
  }

  void _showProfileDialog(BuildContext context) {
    final colors = context.colors;
    final email = conversation.participantEmail ?? 'No email provided';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: colors.primary,
                      backgroundImage: conversation.effectiveAvatarUrl != null
                          ? NetworkImage(conversation.effectiveAvatarUrl!)
                          : null,
                      child: conversation.effectiveAvatarUrl == null
                          ? Text(
                              conversation.displayName.isNotEmpty
                                  ? conversation.displayName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.displayName,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _handle,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: Icon(Icons.close, color: colors.textHint),
                      splashRadius: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This conversation is just between you and $_handle.',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Email',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = conversation.displayName;
    final nameParts = name.trim().split(RegExp(r'\s+'));
    final handle = nameParts.length > 1
        ? '@${nameParts.first}_${nameParts.last}'
        : '@${nameParts.first}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 76, 40, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 39,
            backgroundColor: colors.primary,
            backgroundImage: conversation.effectiveAvatarUrl != null
                ? NetworkImage(conversation.effectiveAvatarUrl!)
                : null,
            child: conversation.effectiveAvatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
              children: [
                const TextSpan(
                  text: 'This conversation is just between you and ',
                ),
                TextSpan(
                  text: handle,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(
                  text: '. Check out their profile to learn about them.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _showProfileDialog(context),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: Text(
              'View Profile',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
