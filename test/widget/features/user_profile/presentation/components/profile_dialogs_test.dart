import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('showProfileConfirmDialog', () {
    testWidgets('destructive confirm button fills with the error token', (
      tester,
    ) async {
      late BuildContext hostContext;
      await tester.pumpWidget(
        buildTestMaterialApp(
          Builder(
            builder: (context) {
              hostContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final dialog = showProfileConfirmDialog(
        hostContext,
        title: 'Delete account',
        message: 'This cannot be undone.',
        confirmLabel: 'Delete',
        destructive: true,
        onConfirm: () async {},
      );
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final background = button.style?.backgroundColor?.resolve(
        <WidgetState>{},
      );

      expect(background, AppPalette.light.error);
      // The token holds the value the literal used to hardcode, so the
      // dialog still renders #EF4444.
      expect(background, const Color(0xFFEF4444));

      Navigator.of(hostContext).pop(false);
      await tester.pumpAndSettle();
      await dialog;
    });
  });
}
