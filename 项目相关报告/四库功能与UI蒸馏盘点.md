# 四库功能与 UI 蒸馏盘点

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [一、任务与范围](#jobs-toc-heading-1)
- [二、来源资产与兼容基线](#jobs-toc-heading-2)
- [三、当前 SDK 与目标基座](#jobs-toc-heading-3)
- [四、吸收清单与资产状态](#jobs-toc-heading-4)
  - [4.1、几何与粒子](#jobs-toc-heading-5)
  - [4.2、交互、阅读与渲染](#jobs-toc-heading-6)
  - [4.3、产品工作流](#jobs-toc-heading-7)
  - [4.4、已有播放器增量](#jobs-toc-heading-8)
  - [4.5、已有能力与明确取舍](#jobs-toc-heading-9)
- [五、验证与交付边界](#jobs-toc-heading-10)

</details>
<!-- jobs-toc:end -->

---

## <span id="jobs-toc-heading-1" data-jobs-toc="v2">一、任务与范围</span><!-- jobs-toc:heading-end -->

用户于 2026-11-15 要求分析 `gsy_flutter_demo`、`gsy_github_app_flutter`、`Flutter`、`FlutterDemo`，将有价值的功能和 UI 蒸馏到本工程，核实最新稳定 SDK，处理旧版本和私库缺失造成的移植障碍。先盘点再补齐，保留已有能力和未提交改动；来源仓库只读，目标实现由 Jobs 维护，不直接改第三方、供应商或生成代码。

本文区分来源实际存在、目标已有覆盖、确定吸收、平台／私库限制与真实验证；以当前源码为依据，既有 281 项等历史入口快照不作为当前数量或等价证明。App 骨架行为继续以 [Flutter 资产盘点](./Flutter-App骨架资产盘点.md)及[骨架对照清单](./App骨架对照与补齐清单.md)为准。

## <span id="jobs-toc-heading-2" data-jobs-toc="v2">二、来源资产与兼容基线</span><!-- jobs-toc:heading-end -->

路径均以共同的 `GitHub` 目录为基准，作为开发定位，不写进运行时依赖。以下版本为盘点时现有声明，不表示已为来源仓库安装或升级 SDK。

| 来源 | 当前源码提交／项目 | SDK／依赖事实 | 处理范围 |
| --- | --- | --- | --- |
| `gsy_flutter_demo` | `ac1ae70`，单个展示应用 | FVM `3.38.4`；包含复杂滚动、动画、绘制与 shader，Git 依赖 `zflutter` 固定提交 | 逐功能与本工程去重；优先评估公开 SDK 可独立复现的交互 |
| `gsy_github_app_flutter` | `f5e6565`，GitHub 客户端 | FVM `3.47.9`；包含实际分页、缓存、Markdown、GraphQL／REST、状态管理与监控代码 | 从完整业务闭环抽取可复用体验，私有凭据不进入本工程或报告 |
| `Flutter` | `5bdeac7`，Jobs 基础演示与本地包 | FVM `stable`；存在 `.codegraph`，分析已优先查询 | 核对基础组件和公共封装是否已被本工程吸收，避免重复入口 |
| `FlutterDemo/51` | `FlutterDemo` 父仓 `6debfed` | Dart `>=3.4.3 <4`；声明本地 `plugins/htprotect`，现有路径缺失 | 保留缺失证据，功能按现有源码独立重写，不生成假的私库替身冒充原功能 |
| `FlutterDemo/Lym_Flutter_Demo` | 同父仓 `6debfed` | FVM `3.19.6`，GetX 演示 | 提取有价值的交互与状态流，按当前 SDK 重新实现 |
| `FlutterDemo/SG` | 同父仓 `6debfed` | FVM `3.7.12`，Dart `<3`；与当前 Dart 3.14 约束直接冲突 | 逐模块分析 UI／可复用流程，不整份合并旧依赖和后台配置 |

GSY 两仓有独立 LICENSE；其余子项目按实际来源核对。借鉴功能和交互时保留源文件位置与采用方式，不因目录属于用户就机械改写上游版权文件。

## <span id="jobs-toc-heading-3" data-jobs-toc="v2">三、当前 SDK 与目标基座</span><!-- jobs-toc:heading-end -->

- 本工程 `.fvmrc` 保留 `stable` 动态稳定频道，编辑器和命令从 `.fvm/flutter_sdk` 解析。
- 实际 CLI 结果：Flutter `3.50.0`、Dart `3.14.0`，framework `ab2912035e160d9cad6306df307576da6128ebdb`。官方发布清单的 macOS x64／arm64 stable 均匹配该提交，发布日期 2026-11-11；依据[官方发布记录](https://docs.flutter.dev/release/release-notes)及[官方制品清单](https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json)。
- 本轮不改动原有动态跟进策略，不因 SDK 已是最新而宣称旧来源所有依赖均已兼容；真实新增代码仍须静态分析、功能回归及相应平台构建。
- 现有基座提供 `JobsDemoApp`、十语言、三主题、目录搜索／置顶／最近、API 优先与离线回退、独立预览入口，以及多个 `JobsByPubs` 包。吸收功能沿用这些能力，不另建一套全局 App 或状态体系。

## <span id="jobs-toc-heading-4" data-jobs-toc="v2">四、吸收清单与资产状态</span><!-- jobs-toc:heading-end -->

已新增 **18 个可独立运行的功能入口**，主目录当前合计 **299 个**；原有 281 个入口继续保留。注册与路径依据[精选注册表](../lib/demo_hub/curated_catalog.dart)、[首页聚合](../lib/demo_hub/home_page.dart)及自动化全表 ID 去重，不按文件名或来源路由数推算。原有播放器入口另作增量增强，不重复增加入口。

详细来源证据与逐项取舍：

- [GSY 视觉与交互](./来源盘点-GSY视觉.md)：126 个真实命名路由、172 个 Widget 文件及 Shader，区分已有覆盖、独立重写和保留候选。
- [GitHub 与业务流程](./来源盘点-GitHub与业务.md)：PR 文件／行讨论、通知状态、51 归集与 SG 报价快照，保留来源实际行为和目标主动补齐的区别。
- [基础工程与依赖](./来源盘点-基础工程与依赖.md)：本地包、缺失私库、旧 SDK、Lym 手势／麦位／礼物和播放器差集。

所有新入口均有 `main()`，主 App 直接复用相同 Widget；十语言、白天／黑夜／跟随系统沿用 `JobsDemoApp`。主题／语言使用已有宿主持久化，不在功能内重复建立全局配置。下表“会话”表示退出页面后重置，不能理解为持久化。

### <span id="jobs-toc-heading-5" data-jobs-toc="v2">4.1、几何与粒子</span><!-- jobs-toc:heading-end -->

六项将交互思想独立重写到 [JobsInteractiveGeometryByPub](../JobsByPubs/JobsInteractiveGeometryByPub/README.md) 和示例页，运行依赖仅 Flutter 与既有 `vector_math`；没有移入 GSY 的 zflutter、品牌、图片或原始实现。几何和粒子是本地数学计算，参数／生成结果留在会话内，不访问业务 API。

| 入口与代码 | 实际行为与默认值 | 生命周期／差异 | 验证 |
| --- | --- | --- | --- |
| [圆弧拖动进度](../lib/demos/圆弧拖动进度/圆弧拖动进度.dart) | 真圆弧命中与反解；默认35%、缺口120°、旋转90°；指针、键盘及无障碍增减共用规则。 | 输入时重绘；不重复已有普通环形进度条。 | 模型、窄宽屏、明暗、十语言、键盘。 |
| [迟滞霓虹滑块](../lib/demos/迟滞霓虹滑块/迟滞霓虹滑块.dart) | 默认34%，达到99%触发，严格低于90%才重新就绪；计数与700ms闪光真实联动。 | 只在闪光期间驱动 ticker；取消／后台停止，退出释放。 | 阈值往返、真实操作与语义断言。 |
| [透视螺旋列表](../lib/demos/透视螺旋列表/透视螺旋列表.dart) | 30项，默认第15项视角、半径100、间距90、扭转0.7、透视700；深度排序、四顶点透视与反序命中。 | 拖动／按钮更新；补齐来源未做的深度排序，非只给平面列表加旋转。 | 投影／深度／命中模型、选项按钮。 |
| [矩阵坐标实验](../lib/demos/矩阵坐标实验/矩阵坐标实验.dart) | 默认平移0、缩放1、旋转0；Canvas 应用正向矩阵绘制，点击用逆矩阵反解局部命中，并显示矩阵数值。 | 输入时重绘；逆矩阵保护无效输入；来源的逆Canvas／正Path多栏对照未一并实现。 | 矩阵往返、奇异变换与实际局部点击。 |
| [粒子形态实验](../lib/demos/粒子形态实验/粒子形态实验.dart) | 默认圆环、700点、seed42、速度0.4；球／立方体／圆环／心形、黄金角 Fibonacci、Lorenz／Aizawa 真方程。低／中／高200／700／1600。 | dt上限0.05秒、积分子步≤0.005秒，非有限值或绝对值>1000单粒子重置并计数；暂停、减弱动画、后台及 TickerMode 停帧，单步仍可用。 | 采样、方程、发散保护、切换与后台停止。 |
| [几何表面实验](../lib/demos/几何表面实验/几何表面实验.dart) | 默认波动网格，分辨率16、强度0.5；可切扰动面片球，网格n²、球2n²真实面片。 | 同一几何时钟；焦点／暂停／单步与销毁释放。 | 拓扑模型、网格／面片球切换与减弱动画。 |

### <span id="jobs-toc-heading-6" data-jobs-toc="v2">4.2、交互、阅读与渲染</span><!-- jobs-toc:heading-end -->

前五项使用[交互数据边界](../lib/demo_hub/interaction_support.dart)，进入／刷新／写操作正常请求 Demo API，默认650ms短超时、首帧本地样例、失败回退、有效成功响应覆盖。业务状态均为会话；无数据时有完整空态与重载。后续写入不会被较旧读取覆盖。

| 入口与代码 | 实际行为与默认值 | 持久化／生命周期／差异 | 验证 |
| --- | --- | --- | --- |
| [聊天阅读锚点](../lib/demos/聊天阅读锚点/聊天阅读锚点.dart) | 18条变高消息，每次前插8条历史；保留可见消息及局部偏移；距底≤48px跟随，否则累计未读。 | 会话；两侧 Sliver 与后帧收敛复核，退出释放滚动控制器；补齐已有聊天页的阅读位置语义。 | 前插几何、变高行、跟随／未读、退出。 |
| [同轴滚动接力](../lib/demos/同轴滚动接力/同轴滚动接力.dart) | 默认同轴24条、touch slop18px（可4–64）；父子 owner、边界剩余位移和正交对照。 | 会话；单识别器到阈值才接管、反向精确分配，结束即停，不宣称惯性接力。 | 65px剩余交接、35px反向、阈值、取消和正交。 |
| [可拖面板吸顶列表](../lib/demos/可拖面板吸顶列表/可拖面板吸顶列表.dart) | 32条，初始55%、最小25%、最大95%；snap25／55／95，共享官方 Sheet 列表控制器与吸顶头。 | 会话；同一 controller 完成拉伸→滚动→收回，非两个分离滚动位置的视觉模仿。 | 满高接力、真实列表滚动、收回和吸顶几何。 |
| [麦位互动与声浪](../lib/demos/麦位互动与声浪/麦位互动与声浪.dart) | 8席，初始Mia／Alex占位，声量65%；唯一Jobs上／下麦、静音与选择。 | 会话；1.8秒示意波形，后台／减弱动画／TickerMode停；不接真实RTC／麦克风，不把来源空服务类当成恢复完成。 | 占用、唯一用户、静音、后台、空态重载。 |
| [礼物双槽连击](../lib/demos/礼物双槽连击/礼物双槽连击.dart) | 默认空双槽、2.6秒超时；同giftID合并活跃／排队数量、FIFO、eventID去重最近256条、历史30条。 | 会话；重新连击延期，取消／退出停止Timer；重写来源双重forward调度，拒绝迟到响应。 | 双槽、排队合并、幂等、延期、取消、空态与乱序。 |
| [片段着色器实验室](../lib/demos/片段着色器实验室/片段着色器实验室.dart) | 独立[GLSL](../shaders/jobs_visual_effects.frag)：液态折射／扩散波纹／弹性拉伸／马赛克扫描；默认液态、强度0.7、半径0.32、混合1、速度1、中心0.5。每个可见控制项参与实际纹理采样。 | `ui.curated-shader`保存参数；GPU未就绪时显示自绘场景与明确回退／重试；静态液态及纯回退不持续ticker，动态效果遵守暂停／后台／减弱动画。纹理／Shader按加载代次替换并释放。 | 十语言／窄宽／明暗、手动时相、生命周期；真实编译后FragmentProgram四模式采样输出差异验证。 |
| [贝塞尔纸张翻页](../lib/demos/贝塞尔纸张翻页/贝塞尔纸张翻页.dart) | 三段自写本地化正文，默认第1页／右下角；半平面裁剪、折痕反射与二次贝塞尔背面，短拖回弹，按钮和无障碍翻页。 | `ui.curated-book`保存完整提交的页码；后台取消半页，不提交中途状态；完整正文可展开选择，非只做PageView过渡。 | 四角／退化／越界有限几何、按钮、回弹、后台取消及语义。 |
| [八向取景画廊](../lib/demos/八向取景画廊/八向取景画廊.dart) | 9幅 Jobs 自绘山水，默认中央取景；8向拖动／按钮／键盘、取景蒙版与缩略图共用边界。 | `ui.curated-gallery`缓存服务端场景清单，位置为会话；畸形响应保留可用画廊，有效空列表提供重载／恢复。二维取景窗独立接管拖动，避免父列表抢竖向分量。 | 斜向拖动、键盘、边界、响应校验、真实纹理绘制与销毁。 |

后三项使用 `UiDemoStore`：正常请求 `GET/PUT /api/ui-demos/<key>`，载荷 `{"value": ...}`，服务端成功结果覆盖本地；`UI_DEMO_API_TIMEOUT_MS` 默认900ms并夹紧50–5000ms。本轮修复旧GET／PUT交叠导致缓存回退的问题；本地缓存失效也不阻断API请求，临时内存状态保留操作并接受随后成功响应覆盖。场景素材全部自绘，无外部网络图片或未核来源素材。

### <span id="jobs-toc-heading-7" data-jobs-toc="v2">4.3、产品工作流</span><!-- jobs-toc:heading-end -->

四项业务 fixture 和领域模型留在各自目录，公共请求／状态条放在[工作流共用](../lib/demos/工作流共用/演示数据.dart)，没有引入 OAuth、GraphQL、来源租户配置或丢失的 htprotect。默认 API 超时800ms，`WORKFLOW_API_TIMEOUT_MS` 可调并限制50–5000ms；请求与缓存均有每key代次保护。

| 入口与代码 | 实际行为／默认值 | 持久化／生命周期／差异 | 验证 |
| --- | --- | --- | --- |
| [代码变更审阅](../lib/demos/代码变更审阅/代码变更审阅.dart) | 文件清单、有限 unified patch 解析、新旧行号、绑定行线程、解决／重开与过时讨论；默认自写样例。 | 保存审阅对象，搜索／选中文件为会话；请求快照／mounted保护，关闭客户端。未承诺生产GitHub请求或独立hunk跳转。 | patch边界、线程归属、真实展开和状态写入。 |
| [实时报价确认](../lib/demos/实时报价确认/实时报价确认.dart) | 中性商品／服务报价，数量与整数最小单位、版本快照、三种接受策略、暂停／失效校验。 | 保存已接受报价与演示结果；定时器离屏停止，提交返回权威快照若变化则要求重新确认。保留SG可复用流程，未接博彩后台或真实订单。 | 三策略、报价变化／有效性、提交快照修正。 |
| [通知处理收件箱](../lib/demos/通知处理收件箱/通知处理收件箱.dart) | 未读／全部／归档，仓库与原因组合筛选；已读、归档、订阅为独立状态；批量与撤销。 | 保存完整有界收件箱；筛选／选择／撤销前快照为会话，失败保留对象，晚响应拒绝。未交付生产分页与GitHub授权。 | 过滤、状态独立、批量、撤销、空态和失败。 |
| [多来源额度归集](../lib/demos/多来源额度归集/多来源额度归集.dart) | 4来源默认全选，总样例额度341.00；预览确认→两并发→逐项结果→仅失败重试；成功token幂等累计。 | 保存账本与每步checkpoint；取消保留完成项，恢复将running归为cancelled，退出取消当前轮。逐项失败／重试为目标主动补齐，51源实际仅聚合bool。 | 并发、部分失败、重试、幂等、取消和迟到结果。 |

### <span id="jobs-toc-heading-8" data-jobs-toc="v2">4.4、已有播放器增量</span><!-- jobs-toc:heading-end -->

[播放器实验室](../lib/demos/播放器实验室/播放器实验室.dart)继续使用原入口，新增[质量状态模型](../lib/demos/播放器实验室/播放质量状态.dart)与完整[十语诊断文案](../lib/demos/播放器实验室/播放质量文案.dart)。默认选择本地视频，进入不自动加载；加载就绪等待默认4000ms，可用 `PLAYER_LOAD_TIMEOUT_MS` 配置。

诊断面板区分实际就绪耗时、首次播放进度推进耗时、错误／恢复次数。Web／video_player仅按显式 `isBuffering` 记录缓冲次数和时长，当前原生协议未提供缓冲事件，明确显示未提供；没有把ready／progress伪称首个解码帧、卡顿率或掉帧率。

恢复检查点只在当前页面内存，按源隔离、最多12个。网络失败只回退本地一次，回退不会使用网络源位置；重试原源才恢复同源位置与播放／暂停意图，并按新时长限制seek。每次native加载生成独立PlatformView key／viewId，拒绝旧源迟到事件。退出取消watchdog、等待、订阅并释放播放器；原URL偏好继续正常请求API与本地保存。此处的原生协议回归使用替身，真实iOS／Android解码、弱网和PiP操作仍单独验收。

### <span id="jobs-toc-heading-9" data-jobs-toc="v2">4.5、已有能力与明确取舍</span><!-- jobs-toc:heading-end -->

普通列表、基础布局、全局菜单、常用动画、Markdown、评论、一般播放器／PiP、数据存储等已有覆盖，不重复加入一批同名入口。来源的首页外壳也不替换现有十语言／三主题功能实验室。

保留为候选的分支文件浏览／贡献热图、完整仓库导航、通知分页、来源火焰Shader、复杂3D私包及原生下载预取均有独立工作量或既有覆盖；没有用空壳按钮标成完成。缺失私库、旧商业后台、真实RTC、授权及原生字幕／音轨／首帧／掉帧事件不伪造恢复。播放器采用当前真实事件能支持的诊断与恢复增量，具体边界以[基础工程盘点](./来源盘点-基础工程与依赖.md)为准。

## <span id="jobs-toc-heading-10" data-jobs-toc="v2">五、验证与交付边界</span><!-- jobs-toc:heading-end -->

SDK 与原始依赖声明已核实。来源仓库的完整编译不作为移植前提；本轮没有修改或为来源安装依赖。目标工程只纳入可维护的实际实现。源码分析、自动化交互、平台构建与真机／外部服务验收分别记录，不把一个平台通过写成所有平台通过。

实际验证：

- 最终 `flutter test --no-pub test JobsByPubs/JobsDemoFoundationByPub/test JobsByPubs/JobsInteractiveGeometryByPub/test --reporter expanded`：**673项通过，1项显式截图测试按设计跳过**。含新几何模型8项／六页9项、工作流19项、交互30项、渲染9项、播放器6项、共享存储17项及全部原有主工程回归。保留旧分组默认顺序，新增分组追加；真实截图还检出霓虹主滑轨零宽，已修正并补320／1100宽度与实际拖动回归，最终完整重跑通过。
- `UI_DEMO_API_TIMEOUT_MS=1` 与 `=10000` 各额外2项验证通过，实际分别限制50／5000ms；缓存不可用、读写交叠、乱序、超时后恢复均有确定性夹具。
- 最终全工程 `flutter analyze --no-pub --no-fatal-infos`：**0 error／0 warning，835条info**。沿用宿主Material／Cupertino兼容入口，未局部迁移独立UI包导致GetX类型分裂；既有弃用／风格info不等于完整迁移完成。
- 已实际查看[互动五页明暗截图](./截图/互动蒸馏)、[几何六页](./截图/几何蒸馏)、[渲染三页](./截图/渲染蒸馏)及[工作流四页](./截图/工作流蒸馏)。使用实际字体加载的Flutter测试渲染器，不是Ahem方块；Shader图已断言真实 `FragmentProgram` 激活，翻页图为按住折角的中途几何。另有真实四种Shader采样输出差异测试，不能靠CPU兜底把GPU功能测绿。系统字体未打包进App。
- 包含霓虹主滑轨修正的最终完整 `flutter build web --release --no-pub` 成功（217.0秒），产物 `build/web`；随后 `flutter build ios --simulator --debug --no-pub --no-codesign` 成功（Xcode50.1秒），产物 `build/ios/iphonesimulator/Runner.app`，未安装／启动。默认 SDK 的 Wasm dry-run 提示既有 audioplayers_web 的 dart:html/js 限制，实际没有启用Wasm；iOS提示7个既有插件尚不支持Swift Package Manager，当前CocoaPods兼容构建通过，未来迁移未在本轮改第三方源码解决。浏览器自动化连接连续超时，未把构建成功写成浏览器操作验收。
- 20份受控文档的本地 `[toc]`、往返与幂等验证通过；新增四报告精确登记过滤器。业务源码差异检查通过。仓库既有Node入口因缺失动态库无法启动，验证使用已有VS Code捆绑Node的临时命令，不安装／升级或改全局Node配置；既有生成的 `.dart_tool/hooks_runner` 日志存在空白差异，未修改或清洗生成物。

尚未将当前源码记为Android／Windows／macOS真实操作或视频硬件解码验收；没有运行源App的私有后台、真实资金、OAuth、RTC／IM或发布流程。旧281入口的历史多平台构建不自动覆盖新增代码。

更新：2026-11-16。未提交、推送或改动远程仓库。
