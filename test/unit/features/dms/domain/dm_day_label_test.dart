import 'package:zedu/features/features.dart';

import '../../../../helpers/helpers.dart';

Map<String, dynamic> _message(DateTime createdAt) => {
  'id': createdAt.toIso8601String(),
  'created_at': createdAt.toIso8601String(),
};

void main() {
  final now = DateTime(2026, 10, 19, 15, 30);

  group('dmDayLabel', () {
    test('returns Today for the current day', () {
      expect(dmDayLabel(DateTime(2026, 10, 19, 0, 5), now: now), 'Today');
    });

    test('returns Yesterday for the previous day', () {
      expect(dmDayLabel(DateTime(2026, 10, 18, 23, 59), now: now), 'Yesterday');
    });

    test('returns a date for older days', () {
      expect(dmDayLabel(DateTime(2026, 10, 12, 9), now: now), '12 Oct 2026');
    });

    test('handles yesterday across a year boundary', () {
      final newYear = DateTime(2027, 1, 1, 8);
      expect(dmDayLabel(DateTime(2026, 12, 31, 22), now: newYear), 'Yesterday');
      expect(
        dmDayLabel(DateTime(2026, 12, 30, 22), now: newYear),
        '30 Dec 2026',
      );
    });
  });

  group('dmDayDividerLabel', () {
    // Newest first, as in the reversed message list.
    final messages = [
      _message(DateTime(2026, 10, 19, 14)),
      _message(DateTime(2026, 10, 19, 9)),
      _message(DateTime(2026, 10, 18, 20)),
      _message(DateTime(2026, 10, 12, 11)),
    ];

    test('puts a divider above the oldest message of each day', () {
      expect(
        List.generate(
          messages.length,
          (i) => dmDayDividerLabel(messages, i, now: now),
        ),
        [null, 'Today', 'Yesterday', '12 Oct 2026'],
      );
    });

    test('moves the divider when an older page on the same day loads', () {
      final loaded = [...messages, _message(DateTime(2026, 10, 12, 8))];

      expect(dmDayDividerLabel(loaded, 3, now: now), isNull);
      expect(dmDayDividerLabel(loaded, 4, now: now), '12 Oct 2026');
    });
  });
}
