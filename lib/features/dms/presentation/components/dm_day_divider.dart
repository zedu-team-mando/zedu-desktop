import 'package:zedu/core/core.dart';

/// Horizontal rule with a centred day label ("Today", "Yesterday", a date)
/// shown between DM messages from different days.
class DmDayDivider extends StatelessWidget {
  final String label;

  const DmDayDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.divider, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Divider(color: colors.divider, height: 1)),
        ],
      ),
    );
  }
}
