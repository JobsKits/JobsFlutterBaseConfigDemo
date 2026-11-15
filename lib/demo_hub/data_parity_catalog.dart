import 'legacy_catalog.dart';
import '../demos/身份证校验/身份证校验.dart';
import '../demos/二维码条形码/二维码条形码.dart';
import '../demos/字符串压缩/字符串压缩.dart';
import '../demos/图片加盐存储/图片加盐存储.dart';
import '../demos/对象数据存储/对象数据存储.dart';
import '../demos/安全模型解码/安全模型解码.dart';
import '../demos/随机数实验/随机数实验.dart';
import '../demos/运行时配置热更新/运行时配置热更新.dart';
import '../demos/协议扩展与模块化/协议扩展与模块化.dart';
import '../demos/多任务计时器/多任务计时器.dart';
import '../demos/双向网络通信/双向网络通信.dart';
import '../demos/调试环境面板/调试环境面板.dart';

import '../demos/微应用白名单桥接/微应用白名单桥接.dart';
import '../demos/微应用沙箱/微应用沙箱.dart';
import '../demos/微应用平台容器/微应用平台容器.dart';
import '../demos/PWA离线容器/PWA离线容器.dart';

final dataParityDemos = <LegacyDemoEntry>[
  LegacyDemoEntry(
    id: 'parity-micro-bridge',
    title: '微应用白名单桥接',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/微应用白名单桥接/微应用白名单桥接.dart',
    tags: const ['Bridge', 'JavaScript', 'capabilities'],
    builder: (_) => const MicroBridgeDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-sandbox',
    title: '微应用沙箱',
    group: '网络与存储',
    sourcePath: 'lib/demos/微应用沙箱/微应用沙箱.dart',
    tags: const ['Sandbox', 'namespace', 'traversal'],
    builder: (_) => const MicroSandboxDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-mpaas',
    title: '微应用平台容器',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/微应用平台容器/微应用平台容器.dart',
    tags: const ['mPaaS', 'manifest', 'registry'],
    builder: (_) => const MiniPlatformDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-pwa',
    title: 'PWA离线容器',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/PWA离线容器/PWA离线容器.dart',
    tags: const ['PWA', 'ServiceWorker', 'offline'],
    builder: (_) => const PWALabDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-cnid',
    title: '身份证校验',
    group: '数据与状态',
    sourcePath: 'lib/demos/身份证校验/身份证校验.dart',
    tags: const ['CNID', 'GB11643', 'checksum'],
    builder: (_) => const CNIDDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-barcode',
    title: '二维码条形码',
    group: '数据与状态',
    sourcePath: 'lib/demos/二维码条形码/二维码条形码.dart',
    tags: const ['QR', 'Code128', 'DataMatrix'],
    builder: (_) => const BarcodeDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-compression',
    title: '字符串压缩',
    group: '数据与状态',
    sourcePath: 'lib/demos/字符串压缩/字符串压缩.dart',
    tags: const ['gzip', 'base64'],
    builder: (_) => const CompressionDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-image-store',
    title: '图片加盐存储',
    group: '网络与存储',
    sourcePath: 'lib/demos/图片加盐存储/图片加盐存储.dart',
    tags: const ['AES-GCM', 'salt', 'image'],
    builder: (_) => const SaltedImageDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-object-store',
    title: '对象数据存储',
    group: '网络与存储',
    sourcePath: 'lib/demos/对象数据存储/对象数据存储.dart',
    tags: const ['ORM', 'CRUD', 'ObjectBox', 'Realm', 'WCDB'],
    builder: (_) => const ObjectStoreDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-safe-decode',
    title: '安全模型解码',
    group: '数据与状态',
    sourcePath: 'lib/demos/安全模型解码/安全模型解码.dart',
    tags: const ['SafeCodable', 'JSON'],
    builder: (_) => const SafeDecodeDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-random',
    title: '随机数实验',
    group: '数据与状态',
    sourcePath: 'lib/demos/随机数实验/随机数实验.dart',
    tags: const ['Random', 'seed', 'secure'],
    builder: (_) => const RandomLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-patch',
    title: '运行时配置热更新',
    group: '数据与状态',
    sourcePath: 'lib/demos/运行时配置热更新/运行时配置热更新.dart',
    tags: const ['Patch', 'rollback', 'runtime'],
    builder: (_) => const RuntimePatchDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-protocols',
    title: '协议扩展与模块化',
    group: '数据与状态',
    sourcePath: 'lib/demos/协议扩展与模块化/协议扩展与模块化.dart',
    tags: const ['SPM', 'Pub', 'ProtocolKit', 'PromiseKit', 'Future'],
    builder: (_) => const ProtocolModulesDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-multi-timer',
    title: '多任务计时器',
    group: '交互与动画',
    sourcePath: 'lib/demos/多任务计时器/多任务计时器.dart',
    tags: const ['TimerMgr', 'Stopwatch'],
    builder: (_) => const MultiTimerDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-websocket',
    title: '双向网络通信',
    group: '网络与存储',
    sourcePath: 'lib/demos/双向网络通信/双向网络通信.dart',
    tags: const ['WebSocket', 'echo'],
    builder: (_) => const WebSocketLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'parity-debug',
    title: '调试环境面板',
    group: '媒体与设备',
    sourcePath: 'lib/demos/调试环境面板/调试环境面板.dart',
    tags: const ['debug', 'FPS', 'environment'],
    builder: (_) => const DebugEnvironmentDemo(),
  ),
];
