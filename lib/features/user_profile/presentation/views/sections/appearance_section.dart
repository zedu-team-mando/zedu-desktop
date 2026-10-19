import 'package:zedu/core/core.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final secondaryTextColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF4B5563);
    final subtleTextColor = isDark
        ? const Color(0xFF6B7280)
        : const Color(0xFF6B7280);
    final dividerColor = isDark
        ? const Color(0xFF2B2E33)
        : const Color(0xFFE5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 24),
        Divider(height: 1, color: dividerColor),
        const SizedBox(height: 28),
        Text(
          'Appearance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose how Zedu looks to you. Select a single color mode, or sync with your computer\'s appearance.',
          style: TextStyle(fontSize: 14, color: secondaryTextColor),
        ),
        const SizedBox(height: 24),
        Text(
          'Color mode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Changing this only affects this device, just like Slack.',
          style: TextStyle(fontSize: 13, color: subtleTextColor),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _ModeOptionCard(
                title: 'Light',
                description: 'A bright look for daytime use.',
                isSelected: currentThemeMode == ThemeMode.light,
                isDark: isDark,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.light),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ModeOptionCard(
                title: 'Dark',
                description: 'A darker look that\'s easier on the eyes.',
                isSelected: currentThemeMode == ThemeMode.dark,
                isDark: isDark,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.dark),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ModeOptionCard(
                title: 'Auto',
                description: 'Match your computer\'s appearance.',
                isSelected: currentThemeMode == ThemeMode.system,
                isDark: isDark,
                onTap: () => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(ThemeMode.system),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _ThemePreviewCard(
              title: 'Light',
              isSelected: currentThemeMode == ThemeMode.light,
              isPreviewDark: false,
              isAppDark: isDark,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.light),
            ),
            const SizedBox(width: 20),
            _ThemePreviewCard(
              title: 'Dark',
              isSelected: currentThemeMode == ThemeMode.dark,
              isPreviewDark: true,
              isAppDark: isDark,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeOptionCard extends StatelessWidget {
  const _ModeOptionCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1C1E21) : Colors.white;
    final cardBorder = isSelected
        ? const Color(0xFF6458F5)
        : (isDark ? const Color(0xFF2B2E33) : const Color(0xFFE5E7EB));
    final titleColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final descColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cardBorder, width: isSelected ? 1.5 : 1),
          color: cardBg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                _RadioIndicator(isSelected: isSelected),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                description,
                style: TextStyle(fontSize: 12, color: descColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF6458F5) : const Color(0xFF6B7280),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6458F5),
                ),
              ),
            )
          : null,
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.title,
    required this.isSelected,
    required this.isPreviewDark,
    required this.isAppDark,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final bool isPreviewDark;
  final bool isAppDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final previewBorder = isSelected
        ? const Color(0xFF6458F5)
        : (isAppDark ? const Color(0xFF2B2E33) : const Color(0xFFE5E7EB));
    final labelColor = isAppDark ? Colors.white : const Color(0xFF1E1E1E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 250,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: previewBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Row(
                children: [
                  // Mock Sidebar (exact web purple color)
                  Container(
                    width: 75,
                    color: const Color(0xFF3E3E93),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 5,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 5,
                          width: 35,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Mock Main Chat/Content Area
                  Expanded(
                    child: Container(
                      color: isPreviewDark
                          ? const Color(0xFF1C1E21)
                          : Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6458F5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isPreviewDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6458F5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isPreviewDark
                                        ? const Color(0xFF374151)
                                        : const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
