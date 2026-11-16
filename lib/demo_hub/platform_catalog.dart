import 'legacy_catalog.dart';
import '../demos/离线文字识别/离线文字识别.dart';
import '../demos/PDF文档浏览/PDF文档浏览.dart';
import '../demos/Unity引擎容器/Unity引擎容器.dart';
import '../demos/蓝牙实验室/蓝牙实验室.dart';
import '../demos/体感传感器/体感传感器.dart';
import '../demos/录音音频管理/录音音频管理.dart';
import '../demos/AR空间实验室/AR空间实验室.dart';
import '../demos/屏幕截图保护/屏幕截图保护.dart';
import '../demos/系统平台能力/系统平台能力.dart';
import '../demos/动态应用图标/动态应用图标.dart';
import '../demos/多窗口会话/多窗口会话.dart';
import '../demos/桌面小组件/桌面小组件.dart';
import '../demos/视频录制直播/视频录制直播.dart';
import '../demos/运行时类检查/运行时类检查.dart';

final platformDemos = <LegacyDemoEntry>[
  LegacyDemoEntry(
    id: 'rust-ocr',
    title: '离线文字识别',
    group: '媒体与设备',
    sourcePath: 'lib/demos/离线文字识别/离线文字识别.dart',
    tags: ['Rust', 'OCR', 'Indra', '离线', '文字识别'],
    builder: (_) => const RustOCRDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-runtime',
    title: '运行时类检查',
    group: '媒体与设备',
    sourcePath: 'lib/demos/运行时类检查/运行时类检查.dart',
    tags: [
      'Objective-C runtime',
      'class_addMethod',
      'Reflection',
      'IMP',
      '热更新',
      'HotRefresh',
      'Runtime Patch',
      '回滚',
    ],
    builder: (_) => const RuntimeClassLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-pdf',
    title: 'PDF文档浏览',
    group: '媒体与设备',
    sourcePath: 'lib/demos/PDF文档浏览/PDF文档浏览.dart',
    tags: ['PDFKit', 'PdfRenderer'],
    builder: (_) => const PDFDocumentLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-unity',
    title: 'Unity引擎容器',
    group: '媒体与设备',
    sourcePath: 'lib/demos/Unity引擎容器/Unity引擎容器.dart',
    tags: ['Unity', 'Engine', 'Message'],
    builder: (_) => const UnityEngineLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-bluetooth',
    title: '蓝牙实验室',
    group: '媒体与设备',
    sourcePath: 'lib/demos/蓝牙实验室/蓝牙实验室.dart',
    tags: ['CoreBluetooth', 'BLE', 'Read Write Notify', 'MTU'],
    builder: (_) => const BluetoothLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-motion',
    title: '传感器实验室',
    group: '媒体与设备',
    sourcePath: 'lib/demos/体感传感器/体感传感器.dart',
    tags: ['CoreMotion', 'Accelerometer', 'Gyroscope'],
    builder: (_) => const MotionLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-audio',
    title: '录音与音频管理',
    group: '媒体与设备',
    sourcePath: 'lib/demos/录音音频管理/录音音频管理.dart',
    tags: ['AVAudioRecorder', 'AVAudioPlayer'],
    builder: (_) => const AudioRecorderLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-ar',
    title: 'AR空间实验室',
    group: '媒体与设备',
    sourcePath: 'lib/demos/AR空间实验室/AR空间实验室.dart',
    tags: ['ARKit', 'SceneKit', 'raycast'],
    builder: (_) => const ARSpaceLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-screen',
    title: '屏幕保护与截图',
    group: '媒体与设备',
    sourcePath: 'lib/demos/屏幕截图保护/屏幕截图保护.dart',
    tags: ['Screenshot', 'Capture', 'Privacy'],
    builder: (_) => const ScreenProtectionLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-system',
    title: '系统能力实验室',
    group: '媒体与设备',
    sourcePath: 'lib/demos/系统平台能力/系统平台能力.dart',
    tags: ['Clipboard', 'URL', 'Security', 'Orientation', 'ShareLink', '系统分享'],
    builder: (_) => const SystemServicesLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-icons',
    title: '动态应用图标',
    group: '媒体与设备',
    sourcePath: 'lib/demos/动态应用图标/动态应用图标.dart',
    tags: ['Alternate app icon'],
    builder: (_) => const AlternateIconLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-scenes',
    title: '多窗口会话',
    group: '媒体与设备',
    sourcePath: 'lib/demos/多窗口会话/多窗口会话.dart',
    tags: ['UIScene', 'Window'],
    builder: (_) => const MultipleSceneLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-widget',
    title: '小组件共享数据',
    group: '媒体与设备',
    sourcePath: 'lib/demos/桌面小组件/桌面小组件.dart',
    tags: ['WidgetKit', 'App Group'],
    builder: (_) => const WidgetDataLabDemo(),
  ),
  LegacyDemoEntry(
    id: 'platform-video',
    title: '视频录制与直播',
    group: '媒体与设备',
    sourcePath: 'lib/demos/视频录制直播/视频录制直播.dart',
    tags: [
      'Video',
      'Photos',
      'RTMP H264 AAC',
      '长按录制',
      '滤镜成片',
      'JobsOCVideoRecorderVC',
      'HKLocalRecordVC',
    ],
    builder: (_) => const VideoCaptureLabDemo(),
  ),
];
