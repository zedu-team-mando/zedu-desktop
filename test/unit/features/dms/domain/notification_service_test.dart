import 'package:zedu/features/features.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('dmNotificationPreview', () {
    test('strips HTML tags and decodes entities', () {
      expect(dmNotificationPreview('<p>hey</p>'), 'hey');
      expect(dmNotificationPreview('<strong>Fixed</strong> it'), 'Fixed it');
      expect(dmNotificationPreview('a &amp; b'), 'a & b');
      expect(dmNotificationPreview('<p>one</p><p>two</p>'), 'one two');
    });

    test('strips Markdown markers', () {
      expect(dmNotificationPreview('**Fixed** it'), 'Fixed it');
      expect(dmNotificationPreview('*italic* and **bold**'), 'italic and bold');
      expect(dmNotificationPreview('~~strikethrough~~'), 'strikethrough');
      expect(dmNotificationPreview('`inline code` here'), 'inline code here');
    });

    test('leaves short plain text unchanged', () {
      expect(dmNotificationPreview('hello world'), 'hello world');
      expect(dmNotificationPreview(''), '');
    });

    test('truncates long messages by Unicode character, keeping emojis whole', () {
      // 76 'A's + an emoji + trailing text: 85 runes total, over the 80 limit.
      final long = '${String.fromCharCodes(List.filled(76, 65))}🎉 trailing';
      final preview = dmNotificationPreview(long);

      expect(preview.length, greaterThan(0));
      expect(preview.endsWith('...'), isTrue);
      // The emoji must appear whole, never split into a replacement char.
      expect(preview, contains('🎉'));
      expect(preview, isNot(contains('\uFFFD')));
      // First 77 runes are kept: 76 'A's + the emoji.
      expect(preview.startsWith(String.fromCharCodes(List.filled(76, 65))),
          isTrue);
    });

    test('does not truncate messages at or under the limit', () {
      final under = 'A' * 80;
      expect(dmNotificationPreview(under), under);
    });
  });
}
