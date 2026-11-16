# GSY 视觉与交互功能来源盘点

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [一、依据与读取边界](#jobs-toc-heading-1)
- [二、实际菜单与容器机制](#jobs-toc-heading-2)
- [三、五个源码分组的实际价值](#jobs-toc-heading-3)
- [四、可落地候选与优先级](#jobs-toc-heading-4)
- [五、统一实现合同与来源不能直接带入的内容](#jobs-toc-heading-5)
- [六、验证与验收建议](#jobs-toc-heading-6)
- [七、完整菜单映射](#jobs-toc-heading-7)
- [八、辅助与备用 Widget 文件](#jobs-toc-heading-8)
- [九、本轮实际采用与实现边界（2026-11-16）](#jobs-toc-heading-9)

</details>
<!-- jobs-toc:end -->

<span id="前言"></span>

---

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">一、依据与读取边界</span><!-- jobs-toc:heading-end -->

本报告用于选择需要实际落入 Jobs Flutter Demo 的能力，不以复制页面数为目标。来源为本机 `gsy_flutter_demo`，HEAD `ac1ae703914ecd4e1beb0e3cdb3c0a03e33a0b0e`，盘点时间 2026-11-15。源码、第三方、SDK 与依赖均只读；本报告未运行来源 App、业务请求或登录，也未改变来源工程。目标对应实现先经现有 CodeGraph 查询，再核对菜单与实际页面代码。结论为静态源码证据，不冒充实机帧率、跨端 Shader 兼容或完整视觉验收。

本轮读取层次为：完整命名路由映射、全部 Widget 文件的 import／核心 API／交互扫描、重点绘制与滚动实现复核、目标对应页面正文对照。末尾附完整路由清单，以及其余 Widget 源码清单；单纯按文件名推测的条目不进入优先候选。

| 项目 | 当前依据与口径 |
| --- | --- |
| 来源入口 | [main.dart](../../../gsy_flutter_demo/lib/main.dart) → [DemoHomePage](../../../gsy_flutter_demo/lib/home/demo_home_page.dart) → [demoRoutes](../../../gsy_flutter_demo/lib/routes/demo_routes.dart) → deferred `loadLibrary` → 真实页面构造器 |
| 入口数 | 126 个 `demoRoutes` 命名路由；多路由可以共用一个文件，不等于 126 个独立实现。以当前路由 Map 的顶层键统计。 |
| Widget 源码 | 172 个 `lib/widget/**/*.dart`：basic 60、scroll 48、animation 32、canvas 14、visual 18；含 helper／备用页。按本机目录物理文件统计，排除构建与依赖目录。 |
| 导入可达性 | 从 `lib/main.dart` 递归解析本包 import／export／part，168 个 Widget 文件可达，4 个未在该导入图中到达；不把“未直接进菜单”误判成无用。 |
| 绘制密度 | 47 个文件包含 `CustomPainter`，5 个包含 `CustomClipper`，53 个包含 `TickerProviderStateMixin`，13 个包含 `RenderSliver`，5 个包含 `FragmentProgram`。这是源码关键字命中文件数，不是去重功能数。 |
| Shader | [pubspec.yaml](../../../gsy_flutter_demo/pubspec.yaml) 声明 6 个 `.frag`：liquid_glass、liquid_glass2、shockwave、elastic、mosaic_wave、fire。 |
| 来源 SDK | pubspec 的 Dart 范围为 `>=3.0.0 <4.0.0`，不是来源已经通过最新 SDK 构建的证明。目标按本任务已核验的 Flutter stable 3.50.0／Dart 3.14 实现，保留目标 `.fvmrc` 的 stable 策略。 |
| 所有权 | [来源 LICENSE](../../../gsy_flutter_demo/LICENSE) 为 MIT，版权 Shuyu Guo。借鉴交互思想后独立编写 Jobs 代码；若复制实质源码需完整保留对应授权。源内另注 Wonderous、其他组件／CodePen 来源的实现与素材，仍需逐项核验，不能仅凭根许可证推定所有图片与字体可直接再分发。 |

## <span id="jobs-toc-heading-2" data-jobs-toc="v2">二、实际菜单与容器机制</span><!-- jobs-toc:heading-end -->

来源首页具有搜索、五类筛选、分组计数与 Web hash 命名路由。分类并不取 Widget 所在目录，而由 [DemoCategoryMatcher](../../../gsy_flutter_demo/lib/home/demo_category_config.dart) 按标题关键词依次匹配 scroll → visual → canvas → animation，最后归 basic。因规则先后关系，不能用物理目录的数量替代首页类别数量。

每个页面通过 `ContainerAsyncRouterPage` 延迟加载。它为没有标题的 Scaffold 补路由名标题，加载时显示转圈，失败只展示错误文字。目标已有可搜索分组、最近访问、排序／置顶、独立预览、十语言与三主题，因此不再移植来源首页外壳，也不照搬其失败页。来源当前只有中英切换、固定浅色首页；新演示应消费目标 `JobsDemoApp`、`JobsDemoScope`、`JobsDemoStrings`，不得另套 MaterialApp。

## <span id="jobs-toc-heading-3" data-jobs-toc="v2">三、五个源码分组的实际价值</span><!-- jobs-toc:heading-end -->

| 分组 | 实际功能与证据 | 目标已有覆盖 | 应吸收的差异 |
| --- | --- | --- | --- |
| basic（60 文件） | Controller、键盘顶起、富文本、气泡、验证码、自定义多子布局／词云、卡片堆、聊天前后插入；[chat_list_scroll_demo_page_2.dart](../../../gsy_flutter_demo/lib/widget/basic/chat_list_scroll_demo_page_2.dart) 使用 `CustomScrollView.center` 与两侧 Sliver | 输入、富文本、布局代理、手势解锁、滑动解锁、卡片堆、聊天、空态均已有真实页面 | 重点是变高消息的阅读锚点，而非又建一个聊天壳；词云可作为自定义布局策略补充。验证码／普通刷新／普通卡堆不重复造入口。 |
| scroll（48 文件） | 同轴 ScrollPosition.drag 接力、touchSlop 对照、吸顶展开、Viewport 绘制／命中顺序、联动 BottomSheet、DraggableSheet、螺旋列表 | `嵌套滚动与分页` 是官方 NestedScrollView + SliverAppBar + TabBarView；`联动分类菜单` 是双列表与 ensureVisible，已有主动跳转抑制回调机制 | 新增手势仲裁、拖动面板与列表边界交接、3D 螺旋参数实验；渲染层级应包含可点击重叠区域来验证，而非仅截图。 |
| animation（32 文件） | 贝塞尔仿真书页、圆弧 SeekBar、满值迟滞霓虹滑块、粒子四形态变形、四吸引子、Fibonacci 球、文字撕裂、提示／按钮状态动画 | Tween、AnimatedContainer、数字动效、按钮布局、球形点选、点赞／红包雨、Lottie 等已有 | 优先弧形直接操控、阈值状态机、连续形态映射、带参数的可复现实验；不以“都使用 AnimationController”判定重复。 |
| canvas（14 文件） | 矩阵正／逆变换对照、Shader Path 图片填充、模糊玻璃、液态玻璃、径向射线、下颌几何动画与火焰 Shader | 手写签名、抽奖轮盘、马赛克涂抹、镂空遮罩、图片滤镜已覆盖基本 Canvas／路径使用 | 新增坐标变换实验与运行时 Shader 管线；液态折射不是 BackdropFilter 的简单同义项。下颌可吸收成“多部件联动绘制”，不必保留品牌或解剖主题。 |
| visual（18 文件） | Matrix4 透视卡片、ZFlutter 立体模型、八向画廊、3D QR 粒子、空间网格、Disco 面片球、黑洞／星云／太极／锦鲤 | 球形点选为 36 个标签 + 自动旋转／点击；翻页浏览为 PageView 卡片分页 | 源的 6000 点四形态变形、网格深度波动、八向取景遮罩与真实 QR 模块散聚均有实质差异。Logo／Dash 品牌模型与纯自动重循环场景优先级较低。 |

## <span id="jobs-toc-heading-4" data-jobs-toc="v2">四、可落地候选与优先级</span><!-- jobs-toc:heading-end -->

P0 指本轮适合独立实现的能力缺口；P1 是在 P0 共用渲染／控制基础上补齐；P2 是源码有价值但不值得立即引入的依赖或重负载场景。下表的 API 为建议 Jobs 公开接口，不冒充来源已有签名。

| 优先级／候选 | 已核对的来源行为与文件 | 目标差异与采用方式 | 可复用接口／必须演示的状态 | 外部依赖与重写边界 |
| --- | --- | --- | --- | --- |
| P0 圆弧拖动进度 | [arc_seek_bar_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/arc_seek_bar_demo_page.dart)：`atan2` 换算触点角度，旋转 90°、缺口 120°，PathMetric 求滑块位置 | 目标环形进度可显示／调值，但没有源这种弧形轨道直接操控。独立实验页，展示缺口、旋转、步进与触点吸附 | `value/onChanged/openAngle/rotationAngle/strokeWidth`；触点经过 0°、缺口两侧、0/100%、父尺寸变化；同时有原生 Slider／键盘替代操作 | 纯 Flutter 可重写，移除来源 `dart:io` 平台分支；来源固定 300×300、3.14 近似 π 不照搬。 |
| P0 满值迟滞霓虹滑块 | [neon_slider_page.dart](../../../gsy_flutter_demo/lib/widget/animation/neon_slider_page.dart)：≥0.99 触发一次 700ms 高亮，<0.90 才重新就绪 | 目标数字动画／进度不是这个状态机。应显示触发次数与 armed 状态，让用户拖到 100%后在边界抖动验证 | `value/onChanged/triggerThreshold/resetThreshold/onReached`；0.98↔1.0 不重复、降到0.89后可重触发；缩减动效保留完成状态 | 纯 Flutter；来源 GestureDetector 需补 Semantics 与键盘／点击步进，不直接复制只能拖的控件。 |
| P0 聊天阅读锚点 | [chat_list_scroll_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/chat_list_scroll_demo_page.dart)、[chat_list_scroll_demo_page_2.dart](../../../gsy_flutter_demo/lib/widget/basic/chat_list_scroll_demo_page_2.dart)：两侧 Sliver 与 `centerKey`，extentAfter 区分离底部状态 | 目标 [聊天与站内信](../lib/demos/聊天与站内信/聊天与站内信.dart) send 后直接滚到底部，没有历史前插阅读锚点；补“短／长消息、首插、尾插、滚到底部”实验而非替代旧聊天业务 | `prepend/append/nearBottomThreshold/anchorId`；首可见消息与局部偏移保持、新消息计数入口、回到底部后清计数，保留空态与重载 | 纯 Flutter；来源递归 firstScrollToBottom／固定 Future.delayed 只作思路，不照搬时序与 mounted 风险。 |
| P0 同轴滚动与手势仲裁 | [vp_list_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/vp_list_demo_page.dart)：touchSlop 50 与内列表 kTouchSlop 对照，同轴 `ScrollPosition.drag` 接力 | 目标 NestedScrollView + TabBarView 基本页不等同于四种组合；做横页纵列／纵页纵列／纵列纵页／双纵列对照 | `axis/handoffAtBoundary/touchSlop`；显示当前 drag owner、边界接力、斜拖对照、取消恢复；不要全 App 修改 MediaQuery 手势阈值 | 纯 Flutter 可重写；源码同轴接力涉及 RenderBox 坐标与 controller.hasClients，需要稳定布局后判断及严格 dispose。 |
| P0 可拖面板与吸顶列表 | [demo_draggable_sheet_stick_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/demo_draggable_sheet_stick_page.dart)、[list_link_bottomsheet_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/list_link_bottomsheet_demo_page.dart)：Sheet builder 的 ScrollController 传到内部 CustomScrollView，吸顶抓手与 controller.animateTo(1) | 与目标普通弹出容器不同：展示拖到最大后列表接管、列表回顶再缩小、预设高度 | `minExtent/initialExtent/maxExtent/snapSizes/controller`；实际 extent/scroll offset 可见，窄屏／横屏／键盘状态可用 | 优先官方 DraggableScrollableSheet 重写；源注有 solid_bottom_sheet 外部来源，不批量复制其旧实现。 |
| P0 3D 螺旋列表 | [tornado_scroll_demo.dart](../../../gsy_flutter_demo/lib/widget/scroll/tornado_scroll_demo.dart)：拖动更新 offset，半径=150×twist，圆柱映射与 Matrix4 透视，twist可调0..1.5 | 目标滚轮列表只是官方 ListWheel；新增半径／间距／透视／扭曲度，0扭曲回直线列表 | `items/radius/pitch/perspective/twist/scrollOffset/onSelected`；深度排序、离屏裁剪、前后卡片真实命中、重置／步进替代拖动 | 只有 Flutter + vector_math；可脱私有库。源明确未做 Z-sort、只手势模拟没有惯性，重写需补真实深度排序并标为我们补齐。 |
| P0 矩阵画布对照 | [matrix_custom_painter_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/matrix_custom_painter_page.dart)：原路径、逆矩阵 Canvas、正矩阵 Path 三种绘制并列 | 目标缩放手势只变换 Widget。新页展示矩阵数值与坐标系，还可补逆变换命中；命中是我们新增，不是源已实现 | `matrix/onMatrixChanged/minScale/maxScale`；缩放／旋转／平移分别开关、reset、变换后点击选择形状、不可逆矩阵拒绝 | 用标准手势或 InteractiveViewer／TransformationController 重写，避免新增 matrix_gesture_detector 旧依赖。 |
| P0 粒子四形态变形 | [particle_morphing_page.dart](../../../gsy_flutter_demo/lib/widget/animation/particle_morphing_page.dart)：6000点，球／立方体／圆环／心形，PageController连续插值，切换有序／随机分布，形变时暂停自转但保留角度 | 目标球形点选仅36标签，不能视为覆盖。用同一批粒子索引映射四形，真实可操作而非替换标题 | `shape/progress/count/distribution/rotation/speed/seed`；形态按钮、手动进度、随机种子重建、暂停、质量档、reduced motion；保留投影与深度明暗 | 纯 Flutter 自写数学模型；源每 tick 固定+0.02依赖帧率，应改 elapsed/delta 时间，CPU随机坐标不要每帧生成。 |
| P1 Fibonacci 球与混沌吸引子 | [fibonacci_sphere_page.dart](../../../gsy_flutter_demo/lib/widget/animation/fibonacci_sphere_page.dart) 有点数100..5000、速度、摆动、点径、拖尾；[attractor_page.dart](../../../gsy_flutter_demo/lib/widget/animation/attractor_page.dart) 切 Halvorsen／Lorenz／Aizawa／SprottB | 作为粒子实验页的第二组算法，避免每个相近自动场景各建一个入口 | `algorithm/dt/particleCount/seed/trailLength`；参数立即影响真实轨迹、稳定重置、数值发散保护；标明是视觉数值演示，不是经物理验证的仿真 | 纯 Flutter；源Fibonacci `controller.value`每秒归零而角度=time×speed，非整周期speed会跳相，采用连续elapsed。 |
| P1 八向取景画廊 | [photo_gallery_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/photo_gallery_demo_page.dart)：EightWaySwipeDetector阈值30，网格移动，PathOperation.difference 镂空取景窗，横竖屏布局 | 目标翻页浏览是 PageView + 上下页按钮，没有二维八向空间与遮罩联动；可做本地资源矩阵画廊 | `images/gridSize/currentCell/swipeThreshold/onChanged`；八方向、边界、横竖屏、箭头替代手势、图像错误本地兜底 | flutter_animate 可由原生Tween替代；源注来自 Wonderous。采用目标已追溯本地图像，不能复制未知网图或抹去二次来源。 |
| P1 运行时 Shader 图像实验 | [liquid_glass_demo2.dart](../../../gsy_flutter_demo/lib/widget/canvas/liquid_glass_demo2.dart)、[shock_wave_chat_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/shock_wave_chat_page.dart)、[mosaic_scanner_page.dart](../../../gsy_flutter_demo/lib/widget/visual/mosaic_scanner_page.dart) | 目标马赛克涂抹是CPU采像素块，镂空是Path；没有纹理折射、波前位移。统一 Shader 状态机页供选择玻璃／波纹／弹性／波浪马赛克 | `effect/center/progress/force/radius/texture`；uniform参数面板、按压/释放、采样缩放、loading/error/retry、fallback图层、坐标可视化 | 使用Flutter FragmentProgram公开API，资产与GLSL独立写；无需私有库。着色器不受支持时保留静态本地图像和可说明的降级，不假装Shader已运行。 |
| P1 贝塞尔仿真书页 | [book_page.dart](../../../gsy_flutter_demo/lib/widget/animation/book_page/book_page.dart) 与 [cal_point.dart](../../../gsy_flutter_demo/lib/widget/animation/book_page/cal_point.dart)：右上／右下／左区触点样式，拖动纸页路径、松手回弹 | 目标翻页浏览无纸张折角与背面阴影，属于独立绘制交互 | `dragPoint/pageSize/corner/settleCurve`；手动拖拽、下一页／取消按钮、角点/边界稳定、长文布局；不要搬来源内整段文学内容 | 纯 Flutter可重写；来源含dart:io平台绘制分支及固定文本，需去除跨端阻碍并用自有文案。 |
| P1 空间网格／面片球 | [spatial_grid_page.dart](../../../gsy_flutter_demo/lib/widget/visual/spatial_grid_page.dart)60×60网格、触点滞后、动态光束；[disco_sphere_page.dart](../../../gsy_flutter_demo/lib/widget/visual/disco_sphere_page.dart)面片投影、悬停局部扰动与模式切换 | 可复用粒子/投影基础，但网格连接与四边形深度排序不是点云同义项；合并为几何表面实验页 | `rows/cols/radius/disturbance/pointer/theme`；mouse hover/touch均有、参数与暂停真实生效、无输入恢复 | 纯 Flutter；源_time+=0.016和每tick固定阻尼应改delta时间，避免不同刷新率速度不同。 |
| P2 QR 模块散聚 | [notion_qrcode_page.dart](../../../gsy_flutter_demo/lib/widget/visual/notion_qrcode_page.dart)：用户输入→QrCode.fromData自动版本→模块粒子→有序／散开与旋转 | 目标二维码条形码已有数据生成与识别，建议只补“真实模块→3D散聚”的视觉模式，不再新增一套无关联二维码业务 | `payload/ecc/scatterProgress/rotation`；静止有序时应仍可扫码、过长内容错误、散开说明不可扫、减少动效 | 需qr编码器；可复用目标已声明QR能力，勿用随机黑白块伪装真实二维码。 |
| P2 品牌立体模型与重负载自动场景 | ZFlutter Dash／掘金Logo、RiveLogo、黑洞12000粒子、星云／太极／锦鲤、火焰raymarch | 几何表现可取，但多数只有自动播放，教育／复用价值弱于上面的可控实验。先不搬品牌模型、未经核验素材、私有fork或整页纯循环 | 将来吸收须有质量档、参数、暂停、可验证的几何状态；不为增加数量放相同控件包一个名字 | zflutter为Git固定fork，不引入；Rive 0.13.20等版本不抄到目标。fire.frag性能需单列端设备实测。 |

## <span id="jobs-toc-heading-5" data-jobs-toc="v2">五、统一实现合同与来源不能直接带入的内容</span><!-- jobs-toc:heading-end -->

1、每项候选至少具有真实绘制区、参数区、重置／必要暂停、当前状态输出；使用 `LayoutBuilder` 计算可用空间，不用来源固定350/500像素画布撑爆小屏。场景画布可以是暗色视觉区域，但页面导航、参数标签与状态提示必须随白天／黑夜／系统主题保持可读。

2、独立入口继续复用目标 `JobsDemoApp`，十种语言完整注册。重绘以 Painter repaint／局部 Listenable 驱动，静态控件不随每个粒子 tick 重建。`TickerMode`、页面生命周期与 `MediaQuery.disableAnimations` 均有行为；减少动效时保留手动参数与结果可理解性。点数默认从低／中档起，源的6000/12000不是目标默认性能预算。

3、交互不只支持拖动：弧进度与矩阵有 Slider／步进／重置，螺旋与画廊有前后／方向按钮，状态改变有 Semantics。列表型演示仍提供无数据占位与重新加载。需要持久化参数或动态样本时复用 `UiDemoStore` 的短超时服务端优先与本地回退，不临时创造只有本地的业务模式。

4、来源有几项明确不能原样带入：Tornado 缺深度排序；Fibonacci 使用归零的1秒控制器驱动非整周期角度；SpatialGrid固定每tick累加0.016；部分Shader加载后缺mounted检查，图片／codec／FragmentShader需完整释放；Shader中心 normalize 零向量要数值保护；聊天的固定延时滚到底和若干controller缺释放要按目标重写。

5、来源采用 `scroll_to_index 3.0.1`、`another_transformer_page_view 2.0.0`、`simple_animations 5.0.2`、`supercharged 2.1.1`、`matrix_gesture_detector 0.2.0-nullsafety.1`、`flutter_swiper_view 1.1.8`、`animated_text_kit 4.2.1`、`rive 0.13.20`、`animations 2.0.4`、`flutter_animate ^1.0.0`、`polygon ^0.1.0`、`qr ^3.0.1`、`vector_math:any`，以及固定提交的 Git zflutter。它们是来源依赖事实，不是建议目标使用这些版本。首批候选都可用Flutter公开API／目标既有依赖独立实现；不复制 `flutter_swiper_view/src` 这类非公开导入。

6、来源卡堆存在百度跳转图片；若吸收交互，只复用目标已经可追溯的打包资源。项目图像／字体授权独立核查，不把源码 MIT 当成任意网络图片的授权。

## <span id="jobs-toc-heading-6" data-jobs-toc="v2">六、验证与验收建议</span><!-- jobs-toc:heading-end -->

- 几何：0尺寸／极窄画布不异常，角度跨0、缺口、投影近面、逆矩阵不可逆时有边界；粒子形变端点对应正确形态，seed可复现。
- 状态：霓虹满值只触发一次且reset threshold后恢复；聊天在历史前插后锚点不跳，离底部不强拉；Sheet／同轴滚动边界与取消后owner恢复。
- 渲染：Shader分别验证目标支持的渲染后端、DPR与窗口缩放；编译通过不等于实际Shader效果运行。loading/error/retry/fallback均能检查。
- 生命周期：切页、返回、主题语言改变、前后台、连续打开关闭后没有ticker／监听／ui.Image残留。基于当前渲染帧耗时而不是来源粒子数声明性能。
- 交付：目录注册可到达实际页面，独立入口可预览；至少小屏与大屏、明暗、十语言长文本、减少动效验收；不交付只有说明与按钮名字的壳。

## <span id="jobs-toc-heading-7" data-jobs-toc="v2">七、完整菜单映射</span><!-- jobs-toc:heading-end -->

下面逐项由 `demoRoutes` 的实际 `loadLibrary()` 解析到源文件，并扫描对应正文中的关键API／外部依赖。API列为证据索引，不把关键词本身当成独立功能。物理源码分组与首页标题匹配类别不同。

| 序号 | 真实菜单标题 | 源码分组／文件 | 正文API证据 | 直接外部依赖 |
| --- | --- | --- | --- | --- |
| 1 | 文本输入框简单的 Controller | [basic/controller_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/controller_demo_page.dart) | `ListView` | 无直接外部包 |
| 2 | 实现控件圆角不同组合 | [basic/clip_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/clip_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 3 | 列表滑动监听 | [scroll/scroll_listener_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/scroll_listener_demo_page.dart) | `ListView` | 无直接外部包 |
| 4 | 滑动到指定位置 | [scroll/scroll_to_index_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/scroll_to_index_demo_page.dart) | `ScrollPosition`、`ListView` | `scroll_to_index` |
| 5 | 滑动到指定位置2 | [scroll/scroll_to_index_demo_page2.dart](../../../gsy_flutter_demo/lib/widget/scroll/scroll_to_index_demo_page2.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 6 | 展示渐变带边框的文本 | [basic/gradient_text_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/gradient_text_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 7 | Transform 效果展示 | [basic/transform_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/transform_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 8 | 计算另类文本行间距展示 | [basic/text_line_height_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/text_line_height_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 9 | 简单上下刷新 | [basic/refresh_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/refresh_demo_page.dart) | `ListView` | 无直接外部包 |
| 10 | 简单上下刷新2 | [basic/refresh_demo_page2.dart](../../../gsy_flutter_demo/lib/widget/basic/refresh_demo_page2.dart) | `CustomScrollView` | 无直接外部包 |
| 11 | 简单上下刷新3 | [scroll/custom_pull/refresh_demo_page3.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_pull/refresh_demo_page3.dart) | `CustomScrollView` | 无直接外部包 |
| 12 | 通过绝对定位布局 | [basic/positioned_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/positioned_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 13 | 气泡提示框 | [basic/bubble/bubble_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/bubble/bubble_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 14 | Tag效果展示 | [basic/tag_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/tag_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 15 | 共享元素跳转效果 | [basic/honor_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/honor_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 16 | 滑动验证 | [scroll/slider_verify_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/slider_verify_page.dart) | `GestureDetector`、`Ticker`、`AnimationController` | 无直接外部包 |
| 17 | warpContent实现 | [basic/wrap_content_page.dart](../../../gsy_flutter_demo/lib/widget/basic/wrap_content_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 18 | 状态栏颜色修改（仅 App） | [basic/statusbar_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/statusbar_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 19 | 键盘弹出与监听（仅 App） | [basic/keyboard_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/keyboard_demo_page.dart) | `GestureDetector` | 无直接外部包 |
| 20 | 控件动画组合展示（旋转加放大圆） | [animation/anima_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/anima_demo_page.dart) | `CustomPainter`、`Ticker`、`AnimationController` | 无直接外部包 |
| 21 | 控件展开动画效果 | [animation/anima_demo_page2.dart](../../../gsy_flutter_demo/lib/widget/animation/anima_demo_page2.dart) | `CustomClipper`、`Ticker`、`AnimationController` | 无直接外部包 |
| 22 | 全局悬浮按键效果 | [basic/floating_touch_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/floating_touch_demo_page.dart) | `OverlayEntry`、`GestureDetector` | 无直接外部包 |
| 23 | 全局设置字体大小 | [basic/text_size_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/text_size_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 24 | 旧版实现富文本 | [basic/rich_text_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/rich_text_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 25 | 官方实现富文本 | [basic/rich_text_demo_page2.dart](../../../gsy_flutter_demo/lib/widget/basic/rich_text_demo_page2.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 26 | 第三方 viewpager 封装实现 | [scroll/viewpager_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/viewpager_demo_page.dart) | `Matrix4`、`PageView` | `another_transformer_page_view`、`vector_math` |
| 27 | 列表滑动过程控件停靠效果 | [scroll/sliver_list_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/sliver_list_demo_page.dart) | `SliverPersistentHeader`、`CustomScrollView`、`Ticker`、`AnimationController` | 无直接外部包 |
| 28 | 验证码输入框 | [basic/verification_code_input_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/verification_code_input_demo_page.dart) | `GestureDetector` | 无直接外部包 |
| 29 | 验证码输入框2 | [basic/verification_code_input_demo_page2.dart](../../../gsy_flutter_demo/lib/widget/basic/verification_code_input_demo_page2.dart) | `GestureDetector` | 无直接外部包 |
| 30 | 自定义布局展示效果 | [basic/custom_multi_render_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/custom_multi_render_demo_page.dart) | `CustomMultiChildLayout` | 无直接外部包 |
| 31 | 自定义布局实现云词图展示 | [basic/cloud/cloud_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/cloud/cloud_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 32 | 列表滑动停靠 （Stick） | [scroll/stick/stick_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/stick/stick_demo_page.dart) | `ListView` | 无直接外部包 |
| 33 | 列表滑动停靠 （Stick）+ 展开收回 | [scroll/stick/stick_demo_page2.dart](../../../gsy_flutter_demo/lib/widget/scroll/stick/stick_demo_page2.dart) | `ListView` | 无直接外部包 |
| 34 | 列表滑动停靠效果2 （Stick | [scroll/sliver_stick_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/sliver_stick_demo_page.dart) | `SliverPersistentHeader`、`CustomScrollView`、`Ticker`、`AnimationController` | 无直接外部包 |
| 35 | 键盘顶起展示（仅 App） | [basic/input_bottom_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/input_bottom_demo_page.dart) | `GestureDetector` | 无直接外部包 |
| 36 | Blur 高斯模糊效果 | [canvas/blur_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/blur_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 37 | 控件动画变形效果 | [animation/animation_container_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/animation_container_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 38 | 时钟动画绘制展示 | [canvas/tick_click_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/tick_click_demo_page.dart) | `CustomPainter`、`Ticker`、`AnimationController` | 无直接外部包 |
| 39 | 按键切换动画效果 | [animation/anima_demo_page4.dart](../../../gsy_flutter_demo/lib/widget/animation/anima_demo_page4.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 40 | 列表滑动过程 item 停靠动画效果 | [scroll/list_anim/list_anim_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/list_anim/list_anim_demo_page.dart) | `ListView` | 无直接外部包 |
| 41 | 列表滑动过程 item 停靠动画效果2 | [scroll/list_anim_2/list_anim_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/list_anim_2/list_anim_demo_page.dart) | `ListView` | 无直接外部包 |
| 42 | 下弹筛选展示效果 | [basic/drop_select_menu/drop_select_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_demo_page.dart) | `ListView` | 无直接外部包 |
| 43 | 文本弹出动画效果 | [animation/anima_demo_page5.dart](../../../gsy_flutter_demo/lib/widget/animation/anima_demo_page5.dart) | `Ticker`、`AnimationController` | 无直接外部包 |
| 44 | 强大的自定义滑动与停靠结合展示 | [scroll/custom_sliver/scroll_header_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_sliver/scroll_header_demo_page.dart) | `CustomScrollView`、`Ticker` | 无直接外部包 |
| 45 | 自定义列表内sliver渲染顺序 | [scroll/custom_viewport/custom_viewport_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_viewport/custom_viewport_page.dart) | `RenderSliver` | 无直接外部包 |
| 46 | 点击弹出动画提示 | [animation/anim_tip_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_tip_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 47 | 列表停靠展开+回到当前头部 | [scroll/stick_sliver_list_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/stick_sliver_list_demo_page.dart) | `RenderSliver`、`CustomScrollView` | 无直接外部包 |
| 48 | 使用 overflow 处理图片 | [basic/overflow_image_page.dart](../../../gsy_flutter_demo/lib/widget/basic/overflow_image_page.dart) | `ListView` | 无直接外部包 |
| 49 | 展示 Align 排布控件 | [basic/align_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/align_demo_page.dart) | `Ticker` | 无直接外部包 |
| 50 | 通过不同尺寸计算方式展示比例 | [basic/card_item_page.dart](../../../gsy_flutter_demo/lib/widget/basic/card_item_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 51 | 多列表+顶部Tab效果展示 | [scroll/sliver_tab_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/sliver_tab_demo_page.dart) | `SliverPersistentHeader`、`CustomScrollView`、`Ticker`、`AnimationController` | 无直接外部包 |
| 52 | 多列表+顶部Tab效果展示2 | [scroll/sliver_tab_demo_page2.dart](../../../gsy_flutter_demo/lib/widget/scroll/sliver_tab_demo_page2.dart) | `SliverPersistentHeader`、`CustomScrollView`、`PageView`、`Ticker`、`AnimationController` | 无直接外部包 |
| 53 | 多列表+顶部Tab效果展示3 | [scroll/sliver_tab/sliver_tab_demo_page3.dart](../../../gsy_flutter_demo/lib/widget/scroll/sliver_tab/sliver_tab_demo_page3.dart) | `SliverPersistentHeader`、`PageView`、`Ticker`、`AnimationController` | 无直接外部包 |
| 54 | 仿真书本翻页动画（仅APP） | [animation/book_page/book_page.dart](../../../gsy_flutter_demo/lib/widget/animation/book_page/book_page.dart) | `GestureDetector`、`Ticker`、`AnimationController` | 无直接外部包 |
| 55 | 粒子动画效果 | [animation/particle/particle_page.dart](../../../gsy_flutter_demo/lib/widget/animation/particle/particle_page.dart) | Flutter布局／状态组合 | `simple_animations`、`supercharged` |
| 56 | 动画背景效果 | [animation/anim_bg_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_bg_demo_page.dart) | `CustomPainter` | `simple_animations`、`supercharged` |
| 57 | 手势效果 | [canvas/matrix_custom_painter_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/matrix_custom_painter_page.dart) | `CustomPainter`、`Matrix4`、`GestureDetector`、`ValueNotifier` | `matrix_gesture_detector` |
| 58 | 一个有趣的底部跟随和停靠例子 | [scroll/scroll_inner_content_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/scroll_inner_content_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 59 | 一个有趣的圆形选择器 | [basic/bottom_anim_nav_page.dart](../../../gsy_flutter_demo/lib/widget/basic/bottom_anim_nav_page.dart) | `CustomPainter`、`GestureDetector`、`Ticker`、`AnimationController` | `flutter_swiper_view` |
| 60 | 一个类似探探堆叠卡片例子 | [basic/index_stack_drag_card_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/index_stack_drag_card_demo_page.dart) | `GestureDetector` | 无直接外部包 |
| 61 | 一个类似探探堆叠卡片例子2 | [basic/index_stack_drag_card_demo_page2.dart](../../../gsy_flutter_demo/lib/widget/basic/index_stack_drag_card_demo_page2.dart) | `GestureDetector`、`Ticker`、`AnimationController` | 无直接外部包 |
| 62 | 动画按键例子 | [animation/anim_button/anim_button_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_button/anim_button_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 63 | 类似QQ发送图片的动画 | [animation/anim_progress_img_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_progress_img_demo_page.dart) | `CustomPainter`、`Ticker`、`AnimationController` | 无直接外部包 |
| 64 | 类似探探扫描的动画效果 | [animation/anim_scan_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_scan_demo_page.dart) | `CustomPainter`、`Ticker`、`AnimationController` | 无直接外部包 |
| 65 | 圆弧形的 SeekBar（仅APP） | [animation/arc_seek_bar_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/arc_seek_bar_demo_page.dart) | `CustomPainter`、`PathMetric`、`GestureDetector`、`Ticker` | 无直接外部包 |
| 66 | 一个国外友人很惊艳的动画效果 | [animation/anim_bubble_gum.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_bubble_gum.dart) | `CustomPainter` | 无直接外部包 |
| 67 | 纯 Canvas 绘制闹钟 | [canvas/canvas_click_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/canvas_click_demo_page.dart) | `CustomPainter`、`Matrix4`、`Ticker`、`AnimationController` | 无直接外部包 |
| 68 | 类似 boss 直聘我的页面联动效果 | [scroll/link_sliver/link_sliver_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/link_sliver/link_sliver_demo_page.dart) | `CustomScrollView` | 无直接外部包 |
| 69 | 结合 Matrix 的拖拽 | [canvas/drag_img_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/drag_img_demo_page.dart) | `Matrix4`、`GestureDetector` | `matrix_gesture_detector` |
| 70 | 彩色进度条 | [basic/color_progress_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/color_progress_demo_page.dart) | `CustomPainter`、`Ticker`、`AnimationController` | 无直接外部包 |
| 71 | 第三方的动画字体 | [animation/anim_text_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_text_demo_page.dart) | `ListView` | `animated_text_kit` |
| 72 | 首尾添加数据不会抖动 | [basic/chat_list_scroll_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/chat_list_scroll_demo_page.dart) | `CustomScrollView` | 无直接外部包 |
| 73 | 首尾添加数据不会抖动2 | [basic/chat_list_scroll_demo_page_2.dart](../../../gsy_flutter_demo/lib/widget/basic/chat_list_scroll_demo_page_2.dart) | `CustomScrollView` | 无直接外部包 |
| 74 | 测试路由嵌套 | [basic/route_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/route_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 75 | 测试 canvas 阴影 | [canvas/shader_canvas_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/shader_canvas_demo_page.dart) | `CustomPainter` | 无直接外部包 |
| 76 | 控件动画切换效果 | [animation/anim_switch_layout_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_switch_layout_demo_page.dart) | `Ticker` | 无直接外部包 |
| 77 | ListView 嵌套 ViewPager 解决斜着滑动问题 | [scroll/vp_list_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/vp_list_demo_page.dart) | `GestureDetector`、`RawGestureDetector`、`ListView`、`PageView` | 无直接外部包 |
| 78 | 垂直  ViewPager 嵌套垂直 ListView | [scroll/vp_list_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/vp_list_demo_page.dart) | `GestureDetector`、`RawGestureDetector`、`ListView`、`PageView` | 无直接外部包 |
| 79 | 垂直  ListView 嵌套垂直  ViewPager | [scroll/vp_list_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/vp_list_demo_page.dart) | `GestureDetector`、`RawGestureDetector`、`ListView`、`PageView` | 无直接外部包 |
| 80 | 垂直  ListView 联动  ListView | [scroll/vp_list_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/vp_list_demo_page.dart) | `GestureDetector`、`RawGestureDetector`、`ListView`、`PageView` | 无直接外部包 |
| 81 | 3D 透视卡片 | [visual/card_perspective_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/card_perspective_demo_page.dart) | `Matrix4`、`GestureDetector` | 无直接外部包 |
| 82 | 3D 卡片旋转 | [visual/card_3d_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/card_3d_demo_page.dart) | `Matrix4`、`GestureDetector` | 无直接外部包 |
| 83 | 硬核 3D 卡片旋转 | [visual/card_real_3d_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/card_real_3d_demo_page.dart) | `Matrix4` | `zflutter` |
| 84 | 3D Dash | [visual/dash_3d_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/dash_3d_demo_page.dart) | `Ticker`、`AnimationController` | `zflutter` |
| 85 | 展示 canvas transform | [canvas/transform_canvas_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/transform_canvas_demo_page.dart) | `CustomPainter`、`Matrix4` | 无直接外部包 |
| 86 | rive 掘金 logo | [visual/anim_juejin_logo_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/anim_juejin_logo_demo_page.dart) | Flutter布局／状态组合 | `rive` |
| 87 | 掘金 3d logo | [visual/juejin_3d_logo_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/juejin_3d_logo_demo_page.dart) | Flutter布局／状态组合 | `zflutter` |
| 88 | 掘金更 3d logo | [visual/juejin_3d_box_logo_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/juejin_3d_box_logo_demo_page.dart) | Flutter布局／状态组合 | `zflutter` |
| 89 | png shadow | [basic/png_shadow_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/png_shadow_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 90 | path 路径 png 效果 | [canvas/custom_shader_path_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/custom_shader_path_demo_page.dart) | `CustomPainter`、`Matrix4` | 无直接外部包 |
| 91 | 列表联动 BottomSheet 效果 | [scroll/list_link_bottomsheet_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/list_link_bottomsheet_demo_page.dart) | `GestureDetector`、`RawGestureDetector`、`ListView`、`PageView`、`ValueNotifier` | 无直接外部包 |
| 92 | DraggableSheet 的 stick 效果 | [scroll/demo_draggable_sheet_stick_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/demo_draggable_sheet_stick_page.dart) | `SliverPersistentHeader`、`DraggableScrollableSheet`、`ScrollPosition`、`CustomScrollView`、`ListView`、`Ticker`、`AnimationController` | 无直接外部包 |
| 93 | 异步调用的顺序执行 | [basic/async_to_sync_call_page.dart](../../../gsy_flutter_demo/lib/widget/basic/async_to_sync_call_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 94 | 点击爆炸的五角星（ChatGPT 生成代码） | [scroll/star_bomb_button_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/star_bomb_button_page.dart) | `CustomPainter`、`GestureDetector`、`Ticker`、`AnimationController` | 无直接外部包 |
| 95 | 有趣画廊 | [visual/photo_gallery_demo_page.dart](../../../gsy_flutter_demo/lib/widget/visual/photo_gallery_demo_page.dart) | `CustomPainter`、`CustomClipper`、`GestureDetector` | `flutter_animate` |
| 96 | 有趣的文本撕裂动画 | [animation/tear_text_demo_page.dart](../../../gsy_flutter_demo/lib/widget/animation/tear_text_demo_page.dart) | `CustomClipper`、`Matrix4` | `polygon` |
| 97 | 自适应横竖列表 | [scroll/unbounded_listview.dart](../../../gsy_flutter_demo/lib/widget/scroll/unbounded_listview.dart) | `RenderSliver`、`RenderViewport`、`ListView` | 无直接外部包 |
| 98 | PageView嵌套PageView | [scroll/pageview_in_pageview_demo_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/pageview_in_pageview_demo_page.dart) | `PageView` | 无直接外部包 |
| 99 | 手势密码 | [basic/gesture_password/gesture_password_demo_page.dart](../../../gsy_flutter_demo/lib/widget/basic/gesture_password/gesture_password_demo_page.dart) | Flutter布局／状态组合 | 无直接外部包 |
| 100 | link scroll | [scroll/link_scroll_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/link_scroll_page.dart) | `GestureDetector`、`ListView` | 无直接外部包 |
| 101 | glass | [canvas/glass_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/glass_demo_page.dart) | `GestureDetector`、`ListView`、`Ticker`、`AnimationController` | 无直接外部包 |
| 102 | liquid glass | [canvas/liquid_glass_demo.dart](../../../gsy_flutter_demo/lib/widget/canvas/liquid_glass_demo.dart) | `CustomPainter`、`FragmentProgram`、`GestureDetector`、`ValueNotifier` | 无直接外部包 |
| 103 | liquid glass 2 | [canvas/liquid_glass_demo2.dart](../../../gsy_flutter_demo/lib/widget/canvas/liquid_glass_demo2.dart) | `CustomPainter`、`FragmentProgram`、`GestureDetector`、`ValueNotifier` | 无直接外部包 |
| 104 | 粒子动画 | [animation/attractor_page.dart](../../../gsy_flutter_demo/lib/widget/animation/attractor_page.dart) | `CustomPainter`、`Ticker` | 无直接外部包 |
| 105 | 斐波那契球体动画 | [animation/fibonacci_sphere_page.dart](../../../gsy_flutter_demo/lib/widget/animation/fibonacci_sphere_page.dart) | `CustomPainter`、`Slider`、`Ticker`、`AnimationController` | 无直接外部包 |
| 106 | 星云动画 | [visual/galaxy_scene_page.dart](../../../gsy_flutter_demo/lib/widget/visual/galaxy_scene_page.dart) | `CustomPainter`、`Matrix4`、`Ticker` | `vector_math` |
| 107 | 霓虹滑块，100%高亮 | [animation/neon_slider_page.dart](../../../gsy_flutter_demo/lib/widget/animation/neon_slider_page.dart) | `CustomPainter`、`GestureDetector`、`Slider`、`Ticker`、`AnimationController` | 无直接外部包 |
| 108 | Radial lines | [canvas/radial_lines_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/radial_lines_page.dart) | `CustomPainter`、`Matrix4`、`Ticker` | `vector_math` |
| 109 | 炫酷爆炸粒子 | [animation/boom_particle_page.dart](../../../gsy_flutter_demo/lib/widget/animation/boom_particle_page.dart) | `CustomPainter`、`GestureDetector`、`Ticker` | 无直接外部包 |
| 110 | Black hole | [visual/black_hole_simulation_page.dart](../../../gsy_flutter_demo/lib/widget/visual/black_hole_simulation_page.dart) | `CustomPainter`、`RepaintBoundary`、`Ticker` | 无直接外部包 |
| 111 | 流体太极 | [visual/stream_taichi_page.dart](../../../gsy_flutter_demo/lib/widget/visual/stream_taichi_page.dart) | `CustomPainter`、`RepaintBoundary`、`Ticker` | 无直接外部包 |
| 112 | 黑洞流体 | [visual/black_hole_page.dart](../../../gsy_flutter_demo/lib/widget/visual/black_hole_page.dart) | `CustomPainter`、`GestureDetector`、`Ticker` | 无直接外部包 |
| 113 | 太极粒子 | [visual/taichi_page.dart](../../../gsy_flutter_demo/lib/widget/visual/taichi_page.dart) | `CustomPainter`、`Ticker` | 无直接外部包 |
| 114 | 破坏杀·罗针 | [basic/akaza_page.dart](../../../gsy_flutter_demo/lib/widget/basic/akaza_page.dart) | `CustomPainter`、`Matrix4`、`Ticker`、`AnimationController` | `vector_math` |
| 115 | 骚气滑动列表 | [scroll/tornado_scroll_demo.dart](../../../gsy_flutter_demo/lib/widget/scroll/tornado_scroll_demo.dart) | `Matrix4`、`GestureDetector`、`Slider`、`Ticker` | `vector_math` |
| 116 | 骚气粒子效果 | [animation/particle_morphing_page.dart](../../../gsy_flutter_demo/lib/widget/animation/particle_morphing_page.dart) | `CustomPainter`、`PageView`、`Ticker` | 无直接外部包 |
| 117 | 炫酷圣诞树 | [animation/combined_scene_page.dart](../../../gsy_flutter_demo/lib/widget/animation/combined_scene_page.dart) | `CustomPainter`、`GestureDetector`、`Ticker`、`AnimationController` | `vector_math` |
| 118 | 炫酷二维码 | [visual/notion_qrcode_page.dart](../../../gsy_flutter_demo/lib/widget/visual/notion_qrcode_page.dart) | `CustomPainter`、`GestureDetector`、`Ticker`、`AnimationController` | `qr` |
| 119 | Cool Disco Sphere | [visual/disco_sphere_page.dart](../../../gsy_flutter_demo/lib/widget/visual/disco_sphere_page.dart) | `CustomPainter`、`GestureDetector`、`Ticker` | 无直接外部包 |
| 120 | Cool Spatial Grid | [visual/spatial_grid_page.dart](../../../gsy_flutter_demo/lib/widget/visual/spatial_grid_page.dart) | `CustomPainter`、`GestureDetector`、`Ticker`、`AnimationController` | 无直接外部包 |
| 121 | Shock Wave Chat | [scroll/shock_wave_chat_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/shock_wave_chat_page.dart) | `CustomPainter`、`FragmentProgram`、`RepaintBoundary`、`OverlayEntry`、`ListView`、`Ticker`、`ValueNotifier`、`AnimationController` | 无直接外部包 |
| 122 | Particle Effect | [animation/particle_effect_screen.dart](../../../gsy_flutter_demo/lib/widget/animation/particle_effect_screen.dart) | `CustomPainter`、`Ticker`、`AnimationController` | 无直接外部包 |
| 123 | Mosaic Scanner | [visual/mosaic_scanner_page.dart](../../../gsy_flutter_demo/lib/widget/visual/mosaic_scanner_page.dart) | `CustomPainter`、`FragmentProgram`、`Ticker`、`AnimationController` | 无直接外部包 |
| 124 | Koi Fish | [visual/koi_fish_animation.dart](../../../gsy_flutter_demo/lib/widget/visual/koi_fish_animation.dart) | `CustomPainter`、`Ticker` | 无直接外部包 |
| 125 | Jaw Control | [canvas/dynamic_jaw_control_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/dynamic_jaw_control_page.dart) | `CustomPainter`、`Slider`、`Ticker`、`AnimationController` | 无直接外部包 |
| 126 | Fire Shader | [canvas/fire_shader_demo_page.dart](../../../gsy_flutter_demo/lib/widget/canvas/fire_shader_demo_page.dart) | `CustomPainter`、`FragmentProgram`、`Ticker` | 无直接外部包 |

## <span id="jobs-toc-heading-8" data-jobs-toc="v2">八、辅助与备用 Widget 文件</span><!-- jobs-toc:heading-end -->

这些文件没有直接作为上述命名路由的加载目标，仍需按导入调用链判断用途。逐项列出可防止只盘点入口文件而漏掉 RenderSliver、裁剪、模型与控制器。

| 文件 | 正文类型／职责证据 | API／直接依赖 |
| --- | --- | --- |
| [animation/anim_button/loading_anim_button.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_button/loading_anim_button.dart) | `LoadingAnimButton`、`_LoadingAnimButtonState`、`LoadingButtonPainter` | `CustomPainter`、`PathMetric`、`Ticker`、`AnimationController` |
| [animation/anim_button/play_anim_button.dart](../../../gsy_flutter_demo/lib/widget/animation/anim_button/play_anim_button.dart) | `PlayAnimButton`、`_PlayAnimButtonState`、`PlayButtonPainter` | `CustomPainter`、`PathMetric`、`Ticker`、`AnimationController` |
| [animation/book_page/book_painter.dart](../../../gsy_flutter_demo/lib/widget/animation/book_page/book_painter.dart) | `BookPainter` | `CustomPainter`、`Matrix4` |
| [animation/book_page/book_text_clip.dart](../../../gsy_flutter_demo/lib/widget/animation/book_page/book_text_clip.dart) | `BookTextClip` | `CustomClipper` |
| [animation/book_page/cal_point.dart](../../../gsy_flutter_demo/lib/widget/animation/book_page/cal_point.dart) | `CalPoint` |  |
| [animation/particle/particle_model.dart](../../../gsy_flutter_demo/lib/widget/animation/particle/particle_model.dart) | `ParticleModel` | `simple_animations`、`supercharged` |
| [animation/particle/particle_painter.dart](../../../gsy_flutter_demo/lib/widget/animation/particle/particle_painter.dart) | `ParticlePainter` | `CustomPainter`、`simple_animations` |
| [animation/particle/particle_widget.dart](../../../gsy_flutter_demo/lib/widget/animation/particle/particle_widget.dart) | `ParticlesWidget`、`_ParticlesWidgetState` | `simple_animations`、`supercharged` |
| [basic/bubble/bubble_painter.dart](../../../gsy_flutter_demo/lib/widget/basic/bubble/bubble_painter.dart) | `BubblePainter`、`BubbleBuilder` | `CustomPainter` |
| [basic/bubble/bubble_tip_widget.dart](../../../gsy_flutter_demo/lib/widget/basic/bubble/bubble_tip_widget.dart) | `BubbleTipWidget`、`_BubbleTipWidgetState` | `GestureDetector`、`Ticker`、`AnimationController` |
| [basic/cloud/cloud_render.dart](../../../gsy_flutter_demo/lib/widget/basic/cloud/cloud_render.dart) | `RenderCloudWidget`、`RenderCloudParentData` |  |
| [basic/cloud/cloud_widget.dart](../../../gsy_flutter_demo/lib/widget/basic/cloud/cloud_widget.dart) | `CloudWidget` |  |
| [basic/demo_navigator_new.dart](../../../gsy_flutter_demo/lib/widget/basic/demo_navigator_new.dart) | `Book`、`BooksApp`、`_BooksAppState`、`BookRouteInformationParser`、`BookRouterDelegate` | `ListView` |
| [basic/drop_select_menu/drop_rect_tween.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_rect_tween.dart) | `DropRectTween` |  |
| [basic/drop_select_menu/drop_select_controller.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_controller.dart) | `DropSelectController` |  |
| [basic/drop_select_menu/drop_select_demo_data.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_demo_data.dart) |  |  |
| [basic/drop_select_menu/drop_select_expanded_menu.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_expanded_menu.dart) | `DropSelectExpandedListMenu`、`_MenuListExpandedState` | `ListView` |
| [basic/drop_select_menu/drop_select_grid_menu.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_grid_menu.dart) | `DropSelectGridListMenu`、`_MenuListGridState` | `ListView` |
| [basic/drop_select_menu/drop_select_header.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_header.dart) | `DropSelectHeader`、`_DropSelectHeaderState` | `GestureDetector` |
| [basic/drop_select_menu/drop_select_list_menu.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_list_menu.dart) | `DropSelectListMenu`、`_MenuListState` | `GestureDetector`、`ListView` |
| [basic/drop_select_menu/drop_select_menu.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_menu.dart) | `DropSelectMenu`、`_DropSelectAnimation`、`SizeClipper`、`_DropSelectMenuState` | `CustomClipper`、`GestureDetector`、`Ticker`、`AnimationController` |
| [basic/drop_select_menu/drop_select_object.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_object.dart) | `DropSelectObject` |  |
| [basic/drop_select_menu/drop_select_widget.dart](../../../gsy_flutter_demo/lib/widget/basic/drop_select_menu/drop_select_widget.dart) | `DropSelectWidget`、`DropSelectState`、`DropSelectMenuContainer`、`_DropSelectMenuContainerState`、`_DropSelectMenuInherited` | `Ticker` |
| [basic/expand/expand_widget.dart](../../../gsy_flutter_demo/lib/widget/basic/expand/expand_widget.dart) | `ExpandableNotifier`、`_ExpandableNotifierState`、`_ExpandableInheritedNotifier`、`ExpandableController`、`Expandable` | `ValueNotifier` |
| [basic/gesture_password/gesture_password_view.dart](../../../gsy_flutter_demo/lib/widget/basic/gesture_password/gesture_password_view.dart) | `GesturePasswordView`、`_GesturePasswordState` |  |
| [basic/gesture_password/src/gesture_view_controller.dart](../../../gsy_flutter_demo/lib/widget/basic/gesture_password/src/gesture_view_controller.dart) | `GestureViewController` |  |
| [basic/gesture_password/src/gesture_view_model.dart](../../../gsy_flutter_demo/lib/widget/basic/gesture_password/src/gesture_view_model.dart) | `GesturePasswordPointModel` |  |
| [basic/gesture_password/src/gesture_view_path.dart](../../../gsy_flutter_demo/lib/widget/basic/gesture_password/src/gesture_view_path.dart) | `GestureViewPathWidget`、`_PathPainter` | `CustomPainter`、`GestureDetector` |
| [basic/gesture_password/src/gesture_view_point.dart](../../../gsy_flutter_demo/lib/widget/basic/gesture_password/src/gesture_view_point.dart) | `GestureDotsPanelWidget`、`GestureViewPoint`、`LinePainter` | `CustomPainter` |
| [basic/rich/real_rich_text.dart](../../../gsy_flutter_demo/lib/widget/basic/rich/real_rich_text.dart) | `RealRichText`、`ImageSpan`、`ImageResolver`、`_RichTextWrapper`、`_RealRichRenderParagraph` |  |
| [scroll/custom_pull/gsy_refresh_sliver.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_pull/gsy_refresh_sliver.dart) | `_CupertinoSliverRefresh`、`_RenderCupertinoSliverRefresh`、`CupertinoSliverRefreshControl`、`CupertinoSliverRefreshControlState` | `RenderSliver`、`Matrix4`、`CustomScrollView` |
| [scroll/custom_sliver/custom_sliver.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_sliver/custom_sliver.dart) | `_CustomSliver`、`_RenderCustomSliver`、`CustomSliver`、`CustomSliverState` | `RenderSliver`、`Matrix4` |
| [scroll/custom_viewport/custom_viewport.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_viewport/custom_viewport.dart) | `CustomViewport`、`_RenderExpandedViewport` | `RenderSliver`、`RenderViewport` |
| [scroll/custom_viewport/first_tab_bar.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_viewport/first_tab_bar.dart) | `FirstTabBar` |  |
| [scroll/custom_viewport/first_tab_bar_render_sliver.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_viewport/first_tab_bar_render_sliver.dart) | `FirstTabBarRenderSliver` | `RenderSliver` |
| [scroll/custom_viewport/first_tab_bar_sliver_widget.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_viewport/first_tab_bar_sliver_widget.dart) | `FirstTabBarSliverWidget` | `RenderSliver` |
| [scroll/custom_viewport/secondary_tab_bar.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_viewport/secondary_tab_bar.dart) | `SecondaryTabBar` |  |
| [scroll/custom_viewport/secondary_tab_bar_render_sliver.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_viewport/secondary_tab_bar_render_sliver.dart) | `SecondaryTabBarRenderSliver` | `RenderSliver` |
| [scroll/custom_viewport/secondary_tab_bar_sliver_widget.dart](../../../gsy_flutter_demo/lib/widget/scroll/custom_viewport/secondary_tab_bar_sliver_widget.dart) | `SecondaryTabBarSliverWidget` | `RenderSliver` |
| [scroll/link_sliver/link_flexible_space_bar.dart](../../../gsy_flutter_demo/lib/widget/scroll/link_sliver/link_flexible_space_bar.dart) | `LinkFlexibleSpaceBar`、`_LinkFlexibleSpaceBarState` | `Matrix4` |
| [scroll/link_sliver/link_sliver_header.dart](../../../gsy_flutter_demo/lib/widget/scroll/link_sliver/link_sliver_header.dart) | `_LinkSliverHeader`、`_RenderCustomSliver`、`LinkSliverHeader`、`LinkSliverHeaderState` | `RenderSliver`、`Matrix4` |
| [scroll/list_anim/header_appbar.dart](../../../gsy_flutter_demo/lib/widget/scroll/list_anim/header_appbar.dart) | `HeaderAppBar` |  |
| [scroll/list_anim_2/header_appbar.dart](../../../gsy_flutter_demo/lib/widget/scroll/list_anim_2/header_appbar.dart) | `HeaderAppBar2` |  |
| [scroll/sliver_tab/sliver_tab_child_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/sliver_tab/sliver_tab_child_page.dart) | `SliverTabChildPage`、`SliverTabChildPageState` | `CustomScrollView` |
| [scroll/sliver_tab/sliver_tab_sliver.dart](../../../gsy_flutter_demo/lib/widget/scroll/sliver_tab/sliver_tab_sliver.dart) | `_SliverTabSliver`、`_RenderCustomSliver`、`SliverTabSliver`、`SliverTabSliverState` | `RenderSliver`、`Matrix4` |
| [scroll/stick/stick_render.dart](../../../gsy_flutter_demo/lib/widget/scroll/stick/stick_render.dart) | `StickRender`、`StickParentData` | `RepaintBoundary` |
| [scroll/stick/stick_widget.dart](../../../gsy_flutter_demo/lib/widget/scroll/stick/stick_widget.dart) | `StickWidget` |  |
| [scroll/test_center_sliver/test_center_sliver.dart](../../../gsy_flutter_demo/lib/widget/scroll/test_center_sliver/test_center_sliver.dart) | `_TestCenterSliver`、`_RenderCustomSliver`、`TestCenterSliver`、`TestCenterSliverState` | `RenderSliver`、`Matrix4` |
| [scroll/test_center_sliver/test_center_sliver_page.dart](../../../gsy_flutter_demo/lib/widget/scroll/test_center_sliver/test_center_sliver_page.dart) | `TestCenterSliverPage`、`TestCenterSliverPageState` | `CustomScrollView` |

从当前 main 导入图未到达的4项为 `scroll/test_center_sliver/test_center_sliver.dart`、`scroll/test_center_sliver/test_center_sliver_page.dart`、`basic/demo_navigator_new.dart`、`animation/book_page/book_text_clip.dart`；这仅是本轮静态导入分析，不能据此删除来源文件。

## <span id="jobs-toc-heading-9" data-jobs-toc="v2">九、本轮实际采用与实现边界（2026-11-16）</span><!-- jobs-toc:heading-end -->

本轮从上述 GSY 候选中实际落地 **12 个独立入口**：几何与粒子 6 项、渲染 3 项、聊天／滚动／Sheet 3 项。它们属于本轮新增 18 项的一部分，完整入口、默认值、持久化、生命周期和验证见[四库功能与 UI 蒸馏总盘点](./四库功能与UI蒸馏盘点.md)及[精选注册表](../lib/demo_hub/curated_catalog.dart)。本节是采用结果；前面来源菜单、172 文件清单、依赖事实与未采用候选继续保留，不能据此推断来源已被整仓移植或升级。

| Jobs 实际入口 | 对应来源能力 | 已落地的具体差异与边界 |
| --- | --- | --- |
| [圆弧拖动进度](../lib/demos/圆弧拖动进度/圆弧拖动进度.dart) | `arc_seek_bar_demo_page.dart` | 圆弧角度反解、可调缺口／旋转、缺口端点吸附；指针、原生参数滑块、键盘及无障碍增减共用 0..1 状态。 |
| [迟滞霓虹滑块](../lib/demos/迟滞霓虹滑块/迟滞霓虹滑块.dart) | `neon_slider_page.dart` | ≥99% 单次触发，严格低于90%才复位；700ms 闪光与触发计数真实联动，减少动态效果时仍保留阈值状态与按钮操作。 |
| [透视螺旋列表](../lib/demos/透视螺旋列表/透视螺旋列表.dart) | `tornado_scroll_demo.dart` | 四顶点透视、深度排序、按反绘制顺序命中、半径／间距／扭曲度与选项步进；未宣称惯性滚动。 |
| [矩阵坐标实验](../lib/demos/矩阵坐标实验/矩阵坐标实验.dart) | `matrix_custom_painter_page.dart` | Canvas 应用正向矩阵绘制，点击用逆矩阵反解局部坐标并命中形状，同时展示矩阵数值；没有冒充来源的三栏 Canvas／Path 对照。 |
| [粒子形态实验](../lib/demos/粒子形态实验/粒子形态实验.dart) | `particle_morphing_page.dart`、`fibonacci_sphere_page.dart`、`attractor_page.dart` | 同页提供球／立方体／圆环／心形、固定黄金角 Fibonacci、Lorenz／Aizawa 真方程；200／700／1600 质量档、固定 seed、手动变形、暂停／单步与发散保护。没有搬入全部四种来源吸引子或拖尾。 |
| [几何表面实验](../lib/demos/几何表面实验/几何表面实验.dart) | `spatial_grid_page.dart`、`disco_sphere_page.dart` | 可控波动网格与扰动面片球，真实拓扑／投影／深度排序，焦点、分辨率和强度直接改变几何；按实际 delta 推进。 |
| [片段着色器实验室](../lib/demos/片段着色器实验室/片段着色器实验室.dart) | 液态玻璃、波纹、弹性与马赛克 Shader 候选 | 独立 [GLSL](../shaders/jobs_visual_effects.frag) 和 Flutter FragmentProgram 管线；可见参数参与采样，静态玻璃及回退预览不持续驱动 ticker；加载失败可重试，旧资源按代次替换并释放。 |
| [贝塞尔纸张翻页](../lib/demos/贝塞尔纸张翻页/贝塞尔纸张翻页.dart) | `book_page.dart`／`cal_point.dart` | 半平面裁剪、折痕反射与二次贝塞尔背面，短拖回弹、四角边界及按钮／无障碍翻页；正文为 Jobs 自写十语言内容，后台不提交半页。 |
| [八向取景画廊](../lib/demos/八向取景画廊/八向取景画廊.dart) | `photo_gallery_demo_page.dart` 的二维取景交互 | 九幅 Jobs 自绘山水，八向手势、方向按钮、键盘、蒙版与缩略图共用边界；保留服务端空列表语义及重载／恢复入口，没有引入来源网络图片。 |
| [聊天阅读锚点](../lib/demos/聊天阅读锚点/聊天阅读锚点.dart) | 两个 `chat_list_scroll_demo_page` | 变高消息前插后保持可见消息与局部偏移；近底跟随、远离底部累计未读、返回底部清计数，保留已有聊天业务入口。 |
| [同轴滚动接力](../lib/demos/同轴滚动接力/同轴滚动接力.dart) | `vp_list_demo_page.dart` | 阈值后单一 owner、父子边界剩余位移分配与反向交接、正交对照、取消归位；没有把两个独立位移变化冒充接力或惯性。 |
| [可拖面板吸顶列表](../lib/demos/可拖面板吸顶列表/可拖面板吸顶列表.dart) | `demo_draggable_sheet_stick_page.dart`／`list_link_bottomsheet_demo_page.dart` | 官方 DraggableScrollableSheet 共享列表 controller，25／55／95% 预设与 snap，拉伸→列表接管→回顶收回和吸顶头真实联动。 |

六项几何模型与通用控件归入 Jobs 自有包 [JobsInteractiveGeometryByPub](../JobsByPubs/JobsInteractiveGeometryByPub/README.md)，只依赖 Flutter 与目标已有 `vector_math`。本轮采用方式是交互思想和标准数学的独立重写，没有直接拷入 GSY 代码、品牌、私有 Git 包、原文学正文、图片或字体，也没有修改来源仓库。几何六页的参数只保留于当前会话；主题和十语言切换复用宿主配置。Shader 参数、完整提交的书页页码及画廊场景清单通过目标既有 `UiDemoStore` 管理，画廊选中位置仍是会话状态。

已完成的限定验证包括几何 **17 项**模型／Widget 测试（含窄／宽屏霓虹主画布实际宽度与真实拖动回归）、渲染 **9 项**测试，以及互动组 **30 项**测试。Shader 测试包含真实 FragmentProgram 加载及四模式采样输出差异，不以静态回退成功替代 Shader 管线验收。共享 `UiDemoStore` 另有 **17 项**异步竞态、缓存失效与超时恢复测试：缓存不可用仍正常请求 API，旧 GET／PUT 不覆盖新状态，`UI_DEMO_API_TIMEOUT_MS` 默认900ms、限制50..5000ms；1和10000配置另分别运行真实超时验证。上述测试证明对应行为与当前宿主测试后端，不宣称全部设备性能或全部渲染后端均已实测。

<a id="🔚" href="#前言">返回前言</a>
