import 'package:zedu/core/core.dart';
import 'package:zedu/features/features.dart';

class DmSidebarList extends ConsumerStatefulWidget {
  const DmSidebarList({super.key});

  @override
  ConsumerState<DmSidebarList> createState() => _DmSidebarListState();
}

class _DmSidebarListState extends ConsumerState<DmSidebarList> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hintColor = colors.onPrimary.withValues(alpha: 0.9);

    return Container(
      width: 320,
      color: colors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WorkspaceSwitcherHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _query = value.trim().toLowerCase()),
                      cursorColor: colors.onPrimary,
                      style: TextStyle(color: colors.onPrimary, fontSize: 12),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Find a Conversation',
                        hintStyle: TextStyle(color: hintColor, fontSize: 12),
                        prefixIcon: Icon(
                          Icons.search,
                          color: hintColor,
                          size: 16,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 32,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            color: colors.onPrimary.withValues(alpha: 0.68),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(color: colors.onPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ref
                .watch(dmListProvider)
                .when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Failed to load DMs',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                  data: (conversations) {
                    if (conversations.isEmpty) {
                      return Center(
                        child: Text(
                          'No recent chats',
                          style: TextStyle(
                            color: colors.onPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }
                    final visible = _query.isEmpty
                        ? conversations
                        : conversations
                              .where(
                                (c) => c.displayName.toLowerCase().contains(
                                  _query,
                                ),
                              )
                              .toList();
                    if (visible.isEmpty) {
                      return Center(
                        child: Text(
                          'No conversations match',
                          style: TextStyle(
                            color: colors.onPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (_query.isEmpty &&
                            scrollInfo is ScrollEndNotification &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent * 0.85) {
                          final notifier = ref.read(dmListProvider.notifier);
                          if (notifier.hasMore) {
                            notifier.loadMore();
                          }
                        }
                        return false;
                      },
                      // Transparent Material so each row's hover and
                      // selected ink paints above the sidebar colour.
                      child: Material(
                        type: MaterialType.transparency,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            return DmListTile(conversation: visible[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
