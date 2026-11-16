/// 排序只保存稳定 ID；置顶是独立分组，取消后回到原分组原位置。
class HomeLayout {
  // 来源分组已并入功能分类，恢复时只清掉废组键。
  static const _retiredGroups = {'原有功能'};

  final List<String> groups = [];
  final List<String> entries = [];
  final List<String> pinned = [];
  final Set<String> collapsed = {};
  bool remember = true;

  void restore(Map<String, List<String>> value) {
    groups
      ..clear()
      ..addAll(
        (value['groups'] ?? [])
            .where((group) => !_retiredGroups.contains(group))
            .toSet(),
      );
    entries
      ..clear()
      ..addAll((value['entries'] ?? []).toSet());
    pinned
      ..clear()
      ..addAll((value['pinned'] ?? []).toSet());
    collapsed
      ..clear()
      ..addAll(
        (value['collapsed'] ?? []).where(
          (group) => !_retiredGroups.contains(group),
        ),
      );
  }

  Map<String, List<String>> get snapshot => {
    'groups': List.of(groups),
    'entries': List.of(entries),
    'pinned': List.of(pinned),
    'collapsed': collapsed.toList(),
  };

  List<String> ordered(Iterable<String> ids, List<String> preference) {
    final available = ids.toSet();
    return [
      ...preference.where(available.contains).toSet(),
      ...available.where((id) => !preference.contains(id)),
    ];
  }

  void reorder(List<String> visible, List<String> target, int from, int to) {
    if (to > from) to--;
    final next = List<String>.of(visible);
    next.insert(to, next.removeAt(from));
    // 未出现在当前筛选中的条目保留原相对位置。
    final visibleIds = visible.toSet();
    var index = 0;
    final normalized = ordered([...target, ...visible], target);
    final merged = [
      for (final id in normalized)
        if (visibleIds.contains(id)) next[index++] else id,
    ];
    target
      ..clear()
      ..addAll(merged);
  }
}
