import '../demos/布局尺寸联动/布局尺寸联动.dart';
import '../demos/相册与照片滤镜/相册与照片滤镜.dart';
import 'legacy_catalog.dart';
import '../demos/球形点选/球形点选.dart';
import '../demos/模拟时钟/模拟时钟.dart';
import '../demos/四向进度/四向进度.dart';
import '../demos/任意冻结列表格/任意冻结列表格.dart';
import '../demos/农历与节气/农历与节气.dart';

final extraDemos = <LegacyDemoEntry>[
  LegacyDemoEntry(
    id: 'extra-layout',
    title: '布局尺寸联动',
    group: '基础与布局',
    sourcePath: 'lib/demos/布局尺寸联动/布局尺寸联动.dart',
    builder: (_) => const ResizeLayoutLabDemo(),
    tags: ['CXB', 'resize', 'fitTop', 'fitHor'],
  ),
  LegacyDemoEntry(
    id: 'extra-photo',
    title: '相册与照片滤镜',
    group: '媒体与设备',
    sourcePath: 'lib/demos/相册与照片滤镜/相册与照片滤镜.dart',
    builder: (_) => const PhotoFiltersLabDemo(),
    tags: ['Photo', 'filter', 'camera', 'PNG'],
  ),
  LegacyDemoEntry(
    id: 'extra-sphere',
    title: '球形点选',
    group: '交互与动画',
    sourcePath: 'lib/demos/球形点选/球形点选.dart',
    builder: (_) => const SphereLabDemo(),
    tags: ['Sphere', '3D', 'hit test'],
  ),
  LegacyDemoEntry(
    id: 'extra-clock',
    title: '模拟时钟',
    group: '交互与动画',
    sourcePath: 'lib/demos/模拟时钟/模拟时钟.dart',
    builder: (_) => const AnalogClockLabDemo(),
    tags: ['clock', 'rotation', 'reverse'],
  ),
  LegacyDemoEntry(
    id: 'extra-progress',
    title: '四向进度',
    group: '交互与动画',
    sourcePath: 'lib/demos/四向进度/四向进度.dart',
    builder: (_) => const DirectionalProgressLabDemo(),
    tags: ['progress', 'direction'],
  ),
  LegacyDemoEntry(
    id: 'extra-excel',
    title: '任意冻结列表格',
    group: '基础与布局',
    sourcePath: 'lib/demos/任意冻结列表格/任意冻结列表格.dart',
    builder: (_) => const FrozenTableLabDemo(),
    tags: ['Excel', 'freeze', 'ellipsis', 'wrap'],
  ),
  LegacyDemoEntry(
    id: 'extra-lunar',
    title: '农历与节气',
    group: '数据与状态',
    sourcePath: 'lib/demos/农历与节气/农历与节气.dart',
    builder: (_) => const LunarCalendarLabDemo(),
    tags: ['Lunar', 'calendar', '节气'],
  ),
];
