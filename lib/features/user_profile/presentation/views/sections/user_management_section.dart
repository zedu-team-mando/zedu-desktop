import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

enum _UserManagementTab { members, invites }

class UserManagementSection extends StatefulWidget {
  const UserManagementSection({
    super.key,
    required this.members,
    required this.isSaving,
    required this.onInvite,
    required this.onUpdate,
    required this.onRemove,
    this.invitesCount = 0,
  });

  final List<TeamMember> members;
  final bool isSaving;
  final Future<void> Function({required String email, required String role})
  onInvite;
  final ValueChanged<TeamMember> onUpdate;
  final ValueChanged<String> onRemove;

  /// Number of outstanding invitations shown on the `Invites` tab badge.
  final int invitesCount;

  @override
  State<UserManagementSection> createState() => _UserManagementSectionState();
}

class _UserManagementSectionState extends State<UserManagementSection> {
  final _searchController = TextEditingController();
  String _roleFilter = 'All Roles';
  int _currentPage = 1;
  _UserManagementTab _tab = _UserManagementTab.members;
  static const int _pageSize = 10;

  void _selectTab(_UserManagementTab tab) {
    if (_tab == tab) return;
    setState(() {
      _tab = tab;
      _currentPage = 1;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final hasActiveFilter = query.isNotEmpty || _roleFilter != 'All Roles';
    final filtered = widget.members.where((member) {
      final matchesQuery =
          query.isEmpty ||
          member.email.toLowerCase().contains(query) ||
          (member.name?.toLowerCase().contains(query) ?? false);
      final matchesRole =
          _roleFilter == 'All Roles' || member.role == _roleFilter;
      return matchesQuery && matchesRole;
    }).toList();

    final totalPages = (filtered.length / _pageSize).ceil();
    final currentPage = totalPages == 0 ? 1 : _currentPage.clamp(1, totalPages);
    final startIndex = (currentPage - 1) * _pageSize;
    final paginatedMembers = filtered.skip(startIndex).take(_pageSize).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: 'Your Team',
          subtitle: 'Manage all members of your team.',
          trailing: AppButton(
            label: 'Invite People',
            expand: false,
            height: 44,
            loading: widget.isSaving,
            onPressed: () => _showInviteDialog(context, widget.onInvite),
          ),
        ),
        const SizedBox(height: 34),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _TabLabel(
              label: 'Members',
              count: widget.members.length,
              active: _tab == _UserManagementTab.members,
              onTap: () => _selectTab(_UserManagementTab.members),
            ),
            const SizedBox(width: 32),
            _TabLabel(
              label: 'Invites',
              count: widget.invitesCount,
              active: _tab == _UserManagementTab.invites,
              onTap: () => _selectTab(_UserManagementTab.invites),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ProfileCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {
                          _currentPage = 1;
                        }),
                        decoration: InputDecoration(
                          hintText: 'Search by name or email',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _roleFilter,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'All Roles',
                          child: Text('All Roles'),
                        ),
                        DropdownMenuItem(
                          value: 'Administrator',
                          child: Text('Administrator'),
                        ),
                        DropdownMenuItem(
                          value: 'Manager',
                          child: Text('Manager'),
                        ),
                        DropdownMenuItem(value: 'User', child: Text('User')),
                      ],
                      onChanged: (value) => setState(() {
                        _roleFilter = value ?? 'All Roles';
                        _currentPage = 1;
                      }),
                    ),
                  ],
                ),
              ),
              if (_tab == _UserManagementTab.invites)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 24,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: context.colors.divider,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mail_outline_rounded,
                            size: 28,
                            color: context.colors.textHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.invitesCount == 0
                              ? 'No pending invites.'
                              : '${widget.invitesCount} pending invite'
                                    '${widget.invitesCount == 1 ? '' : 's'}.',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 24,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: context.colors.divider,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasActiveFilter
                                ? Icons.search_off_rounded
                                : Icons.people_outline_rounded,
                            size: 28,
                            color: context.colors.textHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          hasActiveFilter
                              ? 'No members match your search.'
                              : 'No members found.',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hasActiveFilter
                              ? 'Try adjusting your search terms or role filters.'
                              : 'Invite people to your team to start collaborating.',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 880),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFFAFAFA),
                      ),
                      columns: const [
                        DataColumn(label: Text('Email Address')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Date Joined')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: paginatedMembers.map((member) {
                        return DataRow(
                          cells: [
                            DataCell(_MemberIdentity(email: member.email)),
                            DataCell(Text(member.role)),
                            DataCell(Text(member.dateJoined)),
                            DataCell(
                              ProfileStatusPill(status: member.status.name),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SquareIconButton(
                                    icon: Icons.edit_outlined,
                                    size: 28,
                                    onTap: () => _showMemberDialog(
                                      context,
                                      member,
                                      widget.onUpdate,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SquareIconButton(
                                    icon: Icons.delete_outline,
                                    size: 28,
                                    onTap: () => _confirmRemove(
                                      context,
                                      member.email,
                                      () async => widget.onRemove(member.id),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              if (_tab == _UserManagementTab.members && totalPages > 1) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AppButton.outlined(
                        label: 'Previous',
                        expand: false,
                        height: 36,
                        disabled: currentPage <= 1,
                        onPressed: currentPage > 1
                            ? () =>
                                  setState(() => _currentPage = currentPage - 1)
                            : null,
                      ),
                      const Spacer(),
                      Text(
                        '$currentPage',
                        key: const Key('user_management_page_number'),
                        style: context.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      AppButton.outlined(
                        label: 'Next',
                        expand: false,
                        height: 36,
                        disabled: currentPage >= totalPages,
                        onPressed: currentPage < totalPages
                            ? () =>
                                  setState(() => _currentPage = currentPage + 1)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showInviteDialog(
    BuildContext context,
    Future<void> Function({required String email, required String role})
    onInvite,
  ) => showInviteMemberDialog(context, onInvite);

  void _showMemberDialog(
    BuildContext context,
    TeamMember member,
    ValueChanged<TeamMember> onUpdate,
  ) => showEditMemberDialog(context, member, onUpdate);

  Future<void> _confirmRemove(
    BuildContext context,
    String email,
    Future<void> Function() onConfirm,
  ) => showProfileConfirmDialog(
    context,
    title: 'Remove team member?',
    message: '$email will lose access to this organization.',
    confirmLabel: 'Remove member',
    onConfirm: onConfirm,
    destructive: true,
  );
}

/// Fixed geometry shared by every tab so the labels, badges and active
/// indicator line up regardless of the label/badge text width.
class _TabMetrics {
  const _TabMetrics._();

  /// Gap between the label and its count badge.
  static const double labelToBadge = 8;

  /// Gap below the label row before the active underline.
  static const double labelToUnderline = 10;

  /// Total height reserved for the underline area so switching tabs and
  /// changing counts never shifts the table below the tab strip.
  static const double underlineHeight = 3;

  /// Minimum tab width. Both tabs share it, so the underline is the same
  /// size for each tab and switching never resizes the strip. It is wider than
  /// the widest realistic label+badge so the active (bolder) label cannot make
  /// the tab grow when the user switches tabs.
  static const double minTabWidth = 128;

  /// Fixed badge width so a changing count never resizes the tab strip.
  static const double badgeWidth = 34;

  /// Horizontal padding applied symmetrically to each tab.
  static const EdgeInsets tabPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 6,
  );
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.count,
    required this.active,
    this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = active
        ? context.colors.sidebar
        : const Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: _TabMetrics.minTabWidth),
        // IntrinsicWidth gives the tab a content-driven width; the stretched
        // underline below then spans exactly the same width as the tab. A
        // childless Container inside an unbounded Row would otherwise collapse
        // to zero width, which is what hid the previous underline.
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: _TabMetrics.tabPadding,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      key: Key('tab_label_$label'),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(width: _TabMetrics.labelToBadge),
                    // The badge keeps a constant line height and its content is
                    // centred so the pill always sits on the label's midline.
                    // Its width is fixed so count changes cannot resize the tab.
                    Container(
                      key: Key('tab_badge_$label'),
                      width: _TabMetrics.badgeWidth,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFFE9E9FF)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: labelColor,
                          fontSize: 10,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _TabMetrics.labelToUnderline),
              // Always reserve the underline height so switching tabs or
              // changing counts never shifts the strip. Only the active tab
              // paints the indicator, using the design system's primary colour
              // (the same token other selected indicators use).
              Container(
                key: Key('tab_underline_$label'),
                height: _TabMetrics.underlineHeight,
                decoration: BoxDecoration(
                  color: active ? context.colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    _TabMetrics.underlineHeight / 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberIdentity extends StatelessWidget {
  const _MemberIdentity({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFE9FBFA),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.person, size: 18, color: Color(0xFF17C9BD)),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            email,
            style: context.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
