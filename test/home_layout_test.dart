import 'package:flutter_test/flutter_test.dart';
import 'package:jobs_flutter_base_config/demo_hub/home_layout.dart';

void main() {
  test('重复布局偏好恢复为唯一稳定ID', () {
    final layout = HomeLayout();
    layout.restore({
      'pinned': ['a', 'a', 'b'],
      'groups': ['g', 'g'],
    });
    expect(layout.pinned, ['a', 'b']);
    expect(layout.groups, ['g']);
  });
  test('来源分组并入功能组后，恢复保留原功能组状态和稳定条目', () {
    final layout = HomeLayout();
    layout.restore({
      'groups': ['数据与状态', '原有功能', '基础与布局'],
      'collapsed': ['原有功能', '基础与布局'],
      'entries': ['legacy-complete-14', 'legacy-center'],
      'pinned': ['legacy-complete-14'],
    });
    expect(layout.groups, ['数据与状态', '基础与布局']);
    expect(layout.collapsed, {'基础与布局'});
    expect(layout.entries, ['legacy-complete-14', 'legacy-center']);
    expect(layout.pinned, ['legacy-complete-14']);
    final normalized = layout.snapshot;
    layout.restore(normalized);
    expect(layout.snapshot, normalized);
  });
  test('不完整/重复历史顺序不会丢失或复制条目，隐藏项保留相对位置', () {
    final layout = HomeLayout();
    final target = ['a', 'hidden', 'a'];
    layout.reorder(['a', 'b', 'c'], target, 0, 3);
    expect(target, ['b', 'hidden', 'c', 'a']);
    expect(target.toSet().length, target.length);
    layout.reorder(['b', 'c', 'a'], target, 2, 0);
    expect(target, ['a', 'hidden', 'b', 'c']);
  });
}
