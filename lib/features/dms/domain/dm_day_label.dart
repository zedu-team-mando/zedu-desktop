const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Local calendar day (midnight) a DM message was sent on.
///
/// Falls back to [now] when `created_at` is missing or unparseable, matching
/// how the message bubble shows its time.
DateTime dmMessageDay(Map<String, dynamic> message, {required DateTime now}) {
  final createdAt =
      DateTime.tryParse(message['created_at']?.toString() ?? '')?.toLocal() ??
      now;
  return DateTime(createdAt.year, createdAt.month, createdAt.day);
}

/// Label for a day divider: "Today", "Yesterday", or a date like "12 Oct 2026".
String dmDayLabel(DateTime day, {required DateTime now}) {
  final target = DateTime(day.year, day.month, day.day);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);

  if (target == today) return 'Today';
  if (target == yesterday) return 'Yesterday';
  return '${target.day} ${_monthNames[target.month - 1]} ${target.year}';
}

/// Label of the day divider to show above `messages[index]`, or null if none.
///
/// [messages] is ordered newest first (index 0 is the newest), as in the
/// reversed DM message list. A divider goes above the oldest message of each
/// day, so the oldest loaded message always gets one.
String? dmDayDividerLabel(
  List<Map<String, dynamic>> messages,
  int index, {
  required DateTime now,
}) {
  final day = dmMessageDay(messages[index], now: now);
  final isOldestLoaded = index == messages.length - 1;
  if (!isOldestLoaded && dmMessageDay(messages[index + 1], now: now) == day) {
    return null;
  }
  return dmDayLabel(day, now: now);
}
