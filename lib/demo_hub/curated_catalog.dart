import 'legacy_catalog.dart';
import '../demos/圆弧拖动进度/圆弧拖动进度.dart';
import '../demos/迟滞霓虹滑块/迟滞霓虹滑块.dart';
import '../demos/透视螺旋列表/透视螺旋列表.dart';
import '../demos/矩阵坐标实验/矩阵坐标实验.dart';
import '../demos/粒子形态实验/粒子形态实验.dart';
import '../demos/几何表面实验/几何表面实验.dart';
import '../demos/聊天阅读锚点/聊天阅读锚点.dart';
import '../demos/同轴滚动接力/同轴滚动接力.dart';
import '../demos/可拖面板吸顶列表/可拖面板吸顶列表.dart';
import '../demos/麦位互动与声浪/麦位互动与声浪.dart';
import '../demos/礼物双槽连击/礼物双槽连击.dart';
import '../demos/代码变更审阅/代码变更审阅.dart';
import '../demos/实时报价确认/实时报价确认.dart';
import '../demos/通知处理收件箱/通知处理收件箱.dart';
import '../demos/多来源额度归集/多来源额度归集.dart';
import '../demos/片段着色器实验室/片段着色器实验室.dart';
import '../demos/贝塞尔纸张翻页/贝塞尔纸张翻页.dart';
import '../demos/八向取景画廊/八向取景画廊.dart';

/// 四个来源经去重后的独立实现；源仓库与私库不参与运行时依赖。
final curatedDemos = <LegacyDemoEntry>[
  LegacyDemoEntry(
    id: 'curated-arc',
    title: '圆弧拖动进度',
    group: '几何与粒子',
    sourcePath: 'lib/demos/圆弧拖动进度/圆弧拖动进度.dart',
    builder: (_) => const ArcProgressPage(),
    tags: ['arc', 'gesture', 'GSY'],
  ),
  LegacyDemoEntry(
    id: 'curated-hysteresis',
    title: '迟滞霓虹滑块',
    group: '几何与粒子',
    sourcePath: 'lib/demos/迟滞霓虹滑块/迟滞霓虹滑块.dart',
    builder: (_) => const HysteresisSliderPage(),
    tags: ['hysteresis', 'slider', 'GSY'],
  ),
  LegacyDemoEntry(
    id: 'curated-spiral',
    title: '透视螺旋列表',
    group: '几何与粒子',
    sourcePath: 'lib/demos/透视螺旋列表/透视螺旋列表.dart',
    builder: (_) => const PerspectiveSpiralPage(),
    tags: ['3D', 'perspective', 'GSY'],
  ),
  LegacyDemoEntry(
    id: 'curated-matrix',
    title: '矩阵坐标实验',
    group: '几何与粒子',
    sourcePath: 'lib/demos/矩阵坐标实验/矩阵坐标实验.dart',
    builder: (_) => const MatrixCoordinatesPage(),
    tags: ['matrix', 'inverse', 'canvas'],
  ),
  LegacyDemoEntry(
    id: 'curated-particles',
    title: '粒子形态实验',
    group: '几何与粒子',
    sourcePath: 'lib/demos/粒子形态实验/粒子形态实验.dart',
    builder: (_) => const ParticleShapesPage(),
    tags: ['particles', 'Fibonacci', 'Lorenz', 'Aizawa'],
  ),
  LegacyDemoEntry(
    id: 'curated-surfaces',
    title: '几何表面实验',
    group: '几何与粒子',
    sourcePath: 'lib/demos/几何表面实验/几何表面实验.dart',
    builder: (_) => const GeometrySurfacesPage(),
    tags: ['mesh', 'sphere', 'surface'],
  ),
  LegacyDemoEntry(
    id: 'curated-chat-anchor',
    title: '聊天阅读锚点',
    group: '交互与阅读',
    sourcePath: 'lib/demos/聊天阅读锚点/聊天阅读锚点.dart',
    builder: (_) => const ChatReadingAnchorDemo(),
    tags: ['chat', 'anchor', 'GSY'],
  ),
  LegacyDemoEntry(
    id: 'curated-scroll-handoff',
    title: '同轴滚动接力',
    group: '交互与阅读',
    sourcePath: 'lib/demos/同轴滚动接力/同轴滚动接力.dart',
    builder: (_) => const ScrollHandoffDemo(),
    tags: ['scroll', 'gesture', 'handoff'],
  ),
  LegacyDemoEntry(
    id: 'curated-sheet',
    title: '可拖面板吸顶列表',
    group: '交互与阅读',
    sourcePath: 'lib/demos/可拖面板吸顶列表/可拖面板吸顶列表.dart',
    builder: (_) => const DraggablePinnedSheetDemo(),
    tags: ['sheet', 'sliver', 'snap'],
  ),
  LegacyDemoEntry(
    id: 'curated-voice-seats',
    title: '麦位互动与声浪',
    group: '交互与阅读',
    sourcePath: 'lib/demos/麦位互动与声浪/麦位互动与声浪.dart',
    builder: (_) => const VoiceSeatDemo(),
    tags: ['voice', 'seats', 'Lym'],
  ),
  LegacyDemoEntry(
    id: 'curated-gift-combo',
    title: '礼物双槽连击',
    group: '交互与阅读',
    sourcePath: 'lib/demos/礼物双槽连击/礼物双槽连击.dart',
    builder: (_) => const GiftComboDemo(),
    tags: ['gift', 'queue', 'Lym'],
  ),
  LegacyDemoEntry(
    id: 'curated-shader',
    title: '片段着色器实验室',
    group: '交互与阅读',
    sourcePath: 'lib/demos/片段着色器实验室/片段着色器实验室.dart',
    builder: (_) => const FragmentShaderStudioPage(),
    tags: ['shader', 'GPU', 'GLSL', 'GSY'],
  ),
  LegacyDemoEntry(
    id: 'curated-book',
    title: '贝塞尔纸张翻页',
    group: '交互与阅读',
    sourcePath: 'lib/demos/贝塞尔纸张翻页/贝塞尔纸张翻页.dart',
    builder: (_) => const BezierPageTurnPage(),
    tags: ['Bézier', 'canvas', 'book'],
  ),
  LegacyDemoEntry(
    id: 'curated-gallery',
    title: '八向取景画廊',
    group: '交互与阅读',
    sourcePath: 'lib/demos/八向取景画廊/八向取景画廊.dart',
    builder: (_) => const EightDirectionGalleryPage(),
    tags: ['gallery', '8-way', 'GSY'],
  ),
  LegacyDemoEntry(
    id: 'curated-code-review',
    title: '代码变更审阅',
    group: '产品工作流',
    sourcePath: 'lib/demos/代码变更审阅/代码变更审阅.dart',
    builder: (_) => const CodeChangeReviewDemo(),
    tags: ['diff', 'review', 'GitHub', 'threads'],
  ),
  LegacyDemoEntry(
    id: 'curated-live-quote',
    title: '实时报价确认',
    group: '产品工作流',
    sourcePath: 'lib/demos/实时报价确认/实时报价确认.dart',
    builder: (_) => const LiveQuoteConfirmationDemo(),
    tags: ['quote', 'snapshot', 'SG'],
  ),
  LegacyDemoEntry(
    id: 'curated-notifications',
    title: '通知处理收件箱',
    group: '产品工作流',
    sourcePath: 'lib/demos/通知处理收件箱/通知处理收件箱.dart',
    builder: (_) => const NotificationInboxDemo(),
    tags: ['notifications', 'subscription', 'GitHub'],
  ),
  LegacyDemoEntry(
    id: 'curated-collection',
    title: '多来源额度归集',
    group: '产品工作流',
    sourcePath: 'lib/demos/多来源额度归集/多来源额度归集.dart',
    builder: (_) => const MultiSourceCollectionDemo(),
    tags: ['collection', 'idempotency', '51'],
  ),
];
