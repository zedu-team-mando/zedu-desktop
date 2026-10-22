import 'package:zedu/features/features.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  group('Sidebar resize handle', () {
    testWidgets('is present with the default sidebar width', (tester) async {
      final width = ValueNotifier<double>(320);

      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: SizedBox(
              width: 320,
              height: 600,
              child: SidebarResizeHandle(
                key: const ValueKey('sidebar_resize_handle'),
                onDragUpdate: (details) {
                  width.value = (width.value + details.delta.dx)
                      .clamp(220, 700);
                },
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SidebarResizeHandle), findsOneWidget);
      expect(width.value, 320);
    });

    testWidgets('shrinks the pane when dragged left', (tester) async {
      final width = ValueNotifier<double>(320);

      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: SizedBox(
              width: 320,
              height: 600,
              child: SidebarResizeHandle(
                key: const ValueKey('sidebar_resize_handle'),
                onDragUpdate: (details) {
                  width.value = (width.value + details.delta.dx)
                      .clamp(220, 700);
                },
              ),
            ),
          ),
        ),
      );

      final handle = find.byType(SidebarResizeHandle);

      await tester.drag(handle, const Offset(-100, 0));

      expect(width.value, 220);
    });

    testWidgets('does not shrink below the minimum width', (tester) async {
      final width = ValueNotifier<double>(320);

      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: SizedBox(
              width: 320,
              height: 600,
              child: SidebarResizeHandle(
                key: const ValueKey('sidebar_resize_handle'),
                onDragUpdate: (details) {
                  width.value = (width.value + details.delta.dx)
                      .clamp(220, 700);
                },
              ),
            ),
          ),
        ),
      );

      final handle = find.byType(SidebarResizeHandle);

      await tester.drag(handle, const Offset(-2000, 0));

      expect(width.value, 220);
    });

    testWidgets('does not grow above the maximum width', (tester) async {
      final width = ValueNotifier<double>(320);

      await tester.pumpWidget(
        buildTestMaterialApp(
          Scaffold(
            body: SizedBox(
              width: 320,
              height: 600,
              child: SidebarResizeHandle(
                key: const ValueKey('sidebar_resize_handle'),
                onDragUpdate: (details) {
                  width.value = (width.value + details.delta.dx)
                      .clamp(220, 700);
                },
              ),
            ),
          ),
        ),
      );

      final handle = find.byType(SidebarResizeHandle);

      await tester.drag(handle, const Offset(2000, 0));

      expect(width.value, 700);
    });
  });
}
