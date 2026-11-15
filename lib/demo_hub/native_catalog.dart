import '../demos/手写签名板/handwriting_demo.dart';
import '../demos/日历选择/calendar_demo.dart';
import '../demos/图形验证码/graphic_captcha_demo.dart';
import 'legacy_catalog.dart';
import '../demos/雪花编号/snowflake_demo.dart';
import '../demos/节流防抖/throttle_debounce_demo.dart';
import '../demos/任务依赖编排/task_dependency_demo.dart';
import '../demos/多会话隔离/session_isolation_demo.dart';

final nativeDemos = <LegacyDemoEntry>[
  LegacyDemoEntry(
    id: 'snowflake',
    title: '雪花ID',
    group: '数据与状态',
    sourcePath: 'lib/demos/雪花编号/snowflake_demo.dart',
    tags: const ['Snowflake', 'BigInt', '分布式编号'],
    builder: (_) => const SnowflakeDemo(),
  ),
  LegacyDemoEntry(
    id: 'throttle-debounce',
    title: '节流防抖',
    group: '数据与状态',
    sourcePath: 'lib/demos/节流防抖/throttle_debounce_demo.dart',
    tags: const ['Throttle', 'Debounce', 'Timer'],
    builder: (_) => const ThrottleDebounceDemo(),
  ),
  LegacyDemoEntry(
    id: 'task-dependencies',
    title: '任务依赖',
    group: '数据与状态',
    sourcePath: 'lib/demos/任务依赖编排/task_dependency_demo.dart',
    tags: const ['TaskCenter', 'Future', '取消重试'],
    builder: (_) => const TaskDependencyDemo(),
  ),
  LegacyDemoEntry(
    id: 'session-isolation',
    title: '多会话隔离',
    group: '网络与存储',
    sourcePath: 'lib/demos/多会话隔离/session_isolation_demo.dart',
    tags: const ['Session', '命名空间', 'SharedPreferences'],
    builder: (_) => const SessionIsolationDemo(),
  ),
  LegacyDemoEntry(
    id: 'handwriting',
    title: '手写签名板',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/手写签名板/handwriting_demo.dart',
    tags: const ['JobsHandwriting', '签名', 'Canvas'],
    builder: (_) => const HandwritingDemo(),
  ),
  LegacyDemoEntry(
    id: 'calendar',
    title: '日历选择',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/日历选择/calendar_demo.dart',
    tags: const ['Calendar', '日期', '月份'],
    builder: (_) => const CalendarDemo(),
  ),
  LegacyDemoEntry(
    id: 'graphic-captcha',
    title: '图形验证码',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/图形验证码/graphic_captcha_demo.dart',
    tags: const ['Captcha', 'Canvas', '校验'],
    builder: (_) => const GraphicCaptchaDemo(),
  ),
];
