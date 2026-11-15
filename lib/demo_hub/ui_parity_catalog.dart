import 'legacy_catalog.dart';
import '../demos/朋友圈浏览/入口.dart' as ui0;
import '../demos/个人资料编辑/入口.dart' as ui1;
import '../demos/发帖草稿/入口.dart' as ui2;
import '../demos/聊天与站内信/入口.dart' as ui3;
import '../demos/评论与回复/入口.dart' as ui4;
import '../demos/双风格认证/入口.dart' as ui5;
import '../demos/仪表盘/入口.dart' as ui6;
import '../demos/购物车步进/入口.dart' as ui7;
import '../demos/骨架与双球刷新/入口.dart' as ui8;
import '../demos/点赞与红包雨/入口.dart' as ui9;
import '../demos/导火索倒计时/入口.dart' as ui10;
import '../demos/马赛克涂抹/入口.dart' as ui11;
import '../demos/镂空遮罩/入口.dart' as ui12;
import '../demos/滑动卡片堆/入口.dart' as ui13;
import '../demos/区间拖动吸边/入口.dart' as ui14;
import '../demos/联动分类菜单/入口.dart' as ui15;
import '../demos/文字布局策略/入口.dart' as ui16;
import '../demos/交互富文本/入口.dart' as ui17;
import '../demos/控制事件与按钮布局/入口.dart' as ui18;
import '../demos/四向页面转场/入口.dart' as ui19;
import '../demos/侧滑多方向配置/入口.dart' as ui20;
import '../demos/弹出容器/入口.dart' as ui21;
import '../demos/综合选择器/入口.dart' as ui22;
import '../demos/国家地区区号/入口.dart' as ui23;
import '../demos/Markdown文档/入口.dart' as ui24;
import '../demos/Lottie动画/入口.dart' as ui25;
import '../demos/分组列表与网格/入口.dart' as ui26;
import '../demos/界面环境监听/入口.dart' as ui27;
import '../demos/图标字体实验/入口.dart' as ui28;
import '../demos/跑马灯文字/入口.dart' as ui29;
import '../demos/并发通知队列/入口.dart' as ui30;
import '../demos/数字标签与按钮动效/入口.dart' as ui31;
import '../demos/布局节点实验/入口.dart' as ui32;
import '../demos/播放器实验室/播放器实验室.dart' as ui33;

final uiParityDemos = <LegacyDemoEntry>[
  LegacyDemoEntry(
    id: 'ui-parity-0',
    title: '朋友圈浏览',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/朋友圈浏览/入口.dart',
    tags: const [
      "JobsSwiftParityMomentsPreviewDemoVC",
      "GKPhotoBrowserByUIKitDemoVC",
      "GKPhotoBrowserByTextureSwiftSupportDemoVC",
    ],
    builder: (_) => const ui0.MomentsBrowserDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-1',
    title: '个人资料编辑',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/个人资料编辑/入口.dart',
    tags: const ["LGOEditProfileDemoVC", "JobsSwiftParityEditProfileDemoVC"],
    builder: (_) => const ui1.ProfileEditorDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-2',
    title: '发帖草稿',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/发帖草稿/入口.dart',
    tags: const ["JobsPostDraftDemoVC", "JobsPostVC"],
    builder: (_) => const ui2.PostDraftDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-3',
    title: '聊天与站内信',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/聊天与站内信/入口.dart',
    tags: const [
      "LiveChatDemoVC",
      "JobsIMShowVC",
      "MessageListDemoVC",
      "UITableViewCellEditorVC",
    ],
    builder: (_) => const ui3.ChatInboxDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-4',
    title: '评论与回复',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/评论与回复/入口.dart',
    tags: const ["JobsSwiftCommentDemoVC", "JobsOCCommentDemoVC"],
    builder: (_) => const ui4.CommentsDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-5',
    title: '双风格认证',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/双风格认证/入口.dart',
    tags: const ["JobsAppDoorDemoVC", "JobsAppDoorDemoListVC"],
    builder: (_) => const ui5.AuthStylesDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-6',
    title: '仪表盘',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/仪表盘/入口.dart',
    tags: const ["FTDashboadDemoVC", "JobsSwiftParityDashboardDemoVC"],
    builder: (_) => const ui6.GaugeDashboardDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-7',
    title: '购物车步进',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/购物车步进/入口.dart',
    tags: const ["JobsOCNumberStepperDemoVC", "JobsSwiftNumberStepperDemoVC"],
    builder: (_) => const ui7.CartStepperDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-8',
    title: '骨架与双球刷新',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/骨架与双球刷新/入口.dart',
    tags: const [
      "SkeletonViewDemoVC",
      "JobsOCSkeletonViewDemoVC",
      "JobsDouyinRefreshDemoVC",
    ],
    builder: (_) => const ui8.SkeletonRefreshDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-9',
    title: '点赞与红包雨',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/点赞与红包雨/入口.dart',
    tags: const [
      "JobsLongPressLikeDemoVC",
      "JobsRedPacketRainDemoVC",
      "RedPacketRainDemoVC",
    ],
    builder: (_) => const ui9.LikeRainDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-10',
    title: '导火索倒计时',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/导火索倒计时/入口.dart',
    tags: const [
      "JobsCountdownLayerDemoVC",
      "JobsSysProgressDemoVC",
      "JobsProgressDemoVC",
    ],
    builder: (_) => const ui10.FuseCountdownDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-11',
    title: '马赛克涂抹',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/马赛克涂抹/入口.dart',
    tags: const ["JobsMosaicDemoListVC", "MosaicDemoListVC"],
    builder: (_) => const ui11.MosaicBrushDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-12',
    title: '镂空遮罩',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/镂空遮罩/入口.dart',
    tags: const ["TransparentRegionVC"],
    builder: (_) => const ui12.CutoutMaskDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-13',
    title: '滑动卡片堆',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/滑动卡片堆/入口.dart',
    tags: const ["JobsCardStackDemoVC", "GXCardViewDemoVC"],
    builder: (_) => const ui13.SwipeCardsDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-14',
    title: '区间拖动吸边',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/区间拖动吸边/入口.dart',
    tags: const ["JobsDockingScrollDemoVC", "JobsScrollViewVC"],
    builder: (_) => const ui14.BoundedDockDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-15',
    title: '联动分类菜单',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/联动分类菜单/入口.dart',
    tags: const ["JobsVerticalMenuMainVC", "JobsLinkageMenuViewDemoVC"],
    builder: (_) => const ui15.LinkedMenuDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-16',
    title: '文字布局策略',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/文字布局策略/入口.dart',
    tags: const [
      "UILabelScrollingDemoVC",
      "JobsLabelBehaviorDemoVC",
      "TestLabelVC",
      "JobsLabelRotationDemoVC",
      "UILabelWordRotatingVC",
    ],
    builder: (_) => const ui16.TextStrategiesDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-17',
    title: '交互富文本',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/交互富文本/入口.dart',
    tags: const [
      "JobsInteractiveLabelDemoVC",
      "TestBaseLabelVC",
      "JobsBulletTextDemoVC",
      "PointLabTestVC",
    ],
    builder: (_) => const ui17.InteractiveTextDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-18',
    title: '控制事件与按钮布局',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/控制事件与按钮布局/入口.dart',
    tags: const [
      "JobsControlEventsDemoVC",
      "JobsSwiftParityControlEventsDemoVC",
      "JobsButtonCoverCellDemoListVC",
      "CustomBtnVC",
      "UIButtonBackgroundColorDemoVC",
      "UIButtonDemoVC",
      "JobsButtonDemoVC",
      "ButtonMenuDemoView",
    ],
    builder: (_) => const ui18.ControlEventsDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-19',
    title: '四向页面转场',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/四向页面转场/入口.dart',
    tags: const [
      "JobsNavigationDemoVC",
      "JobsViewPushDemoVC",
      "SafetyPushDemoVC",
      "JobsPresentingVC",
      "DirectionalPushDemoView",
      "NavigationDemoView",
    ],
    builder: (_) => const ui19.DirectionalNavigationDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-20',
    title: '侧滑多方向配置',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/侧滑多方向配置/入口.dart',
    tags: const ["JobsSideDrawerDemoVC"],
    builder: (_) => const ui20.DrawerConfigurationDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-21',
    title: '弹出容器',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/弹出容器/入口.dart',
    tags: const [
      "FSPopoverDemoVC",
      "SwiftEntryKitDemoVC",
      "JXCategoryPopupVC",
      "PresentationDemoView",
      "AlertDialogDemoView",
    ],
    builder: (_) => const ui21.PresentationContainersDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-22',
    title: '综合选择器',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/综合选择器/入口.dart',
    tags: const ["BRPickerDemoVC", "PickersDemoView"],
    builder: (_) => const ui22.PickerLaboratoryDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-23',
    title: '国家地区区号',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/国家地区区号/入口.dart',
    tags: const ["JobsSwiftCountryCodeCtrlDemoVC", "JobsOCCountryCodeCtrl"],
    builder: (_) => const ui23.CountryCallingCodesDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-24',
    title: 'Markdown文档',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/Markdown文档/入口.dart',
    tags: const [
      "JobsMarkdownDocumentsDemoVC",
      "JobsOCMarkdownDocumentsDemoVC",
    ],
    builder: (_) => const ui24.MarkdownDocumentsDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-25',
    title: 'Lottie动画',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/Lottie动画/入口.dart',
    tags: const ["LottieDemoVC"],
    builder: (_) => const ui25.LottieAnimationDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-26',
    title: '分组列表与网格',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/分组列表与网格/入口.dart',
    tags: const [
      "EmptyTableViewDemoVC",
      "EmptyCollectionViewDemoVC",
      "UITableViewCellCornerDemoVC",
      "CustomTableViewCellVC",
      "ListFormDemoView",
      "LayoutDemoView",
    ],
    builder: (_) => const ui26.GroupedCollectionDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-27',
    title: '界面环境监听',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/界面环境监听/入口.dart',
    tags: const [
      "JobsSwiftParityTraitChangeDemoVC",
      "ControlValuesDemoView",
      "JobsSwiftUIDebugPanelDemoView",
    ],
    builder: (_) => const ui27.EnvironmentObserverDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-28',
    title: '图标字体实验',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/图标字体实验/入口.dart',
    tags: const ["JobsIconfontDemoListVC", "AsyncLinkShareDemoView"],
    builder: (_) => const ui28.IconFontLaboratoryDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-29',
    title: '跑马灯文字',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/跑马灯文字/入口.dart',
    tags: const ["JobsMarqueeDemoVC", "JobsMarqueeViewDemoVC"],
    builder: (_) => const ui29.MarqueeTextDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-30',
    title: '并发通知队列',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/并发通知队列/入口.dart',
    tags: const ["CoreTextLearningVC"],
    builder: (_) => const ui30.ConcurrentNotificationsDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-31',
    title: '数字标签与按钮动效',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/数字标签与按钮动效/入口.dart',
    tags: const [
      "JobsAnimatedNumberLabelDemoVC",
      "AnimationEffectLabelDemoVC",
      "AnimatedButtonNumberDemoVC",
      "JobsSwiftParityAnimatedButtonNumberDemoVC",
    ],
    builder: (_) => const ui31.AnimatedNumbersDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-32',
    title: '布局节点实验',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/布局节点实验/入口.dart',
    tags: const ["ComponentKitLikeKitchenSinkVC"],
    builder: (_) => const ui32.LayoutNodesDemo(),
  ),
  LegacyDemoEntry(
    id: 'ui-parity-33',
    title: '播放器实验室',
    group: '原生能力对齐',
    sourcePath: 'lib/demos/播放器实验室/播放器实验室.dart',
    tags: const ["BMPlayerDemoVC", "PNPlayerDemoVC", "JobsZFPlayerDemoListVC"],
    builder: (_) => const ui33.PlayerLaboratoryDemo(),
  ),
];
