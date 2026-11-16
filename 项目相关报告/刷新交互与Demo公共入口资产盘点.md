# <span id="前言">刷新交互与Demo公共入口资产盘点</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 前言

2026-11-16用户增量需求，先登记合同再修改源码。范围为[**Flutter**](https://flutter.dev/)公共刷新、全Demo公共动作入口，以及五端目录／世界时钟／设置与开屏骨架；不盘点各Demo内部业务功能。本文保留实现前事实，后续以各条实现和验证状态更新，不用旧662项或上一包交互结果代表新增实现。

## 一、<span id="requirements">确认需求与验收合同</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 编号 | 用户确认的行为 | 默认／持久化／生命周期 | 验收边界 |
| --- | --- | --- | --- |
| REF-01 | Jobs刷新／加载显示上次完成时间，首次无记录明确说明；刷新和加载分开 | 仅成功推进，失败保留旧时间；使用稳定业务键保存，返回／重启恢复，避免不同列表混用 | 成功／失败／首次／重启、不同列表、两角色分别核对 |
| REF-02 | 纵向下拉刷新／上拉加载，横向两端刷新／加载；参考Swift JobsByPods四边封装 | 首端刷新、末端加载；reverse／RTL按实际AxisDirection定位；可配置两端角色；无更多明确提示与刷新后复位 | 横纵、两端、短列表、reverse／RTL、嵌套列表、无更多与失败重试 |
| REF-03 | 达阈值松手开始，列表跟手、有阻尼、有界拉距、运行区可辨、结束平滑回弹 | 未达阈值松手或反向收手不请求；同列表互斥，执行中不重复；不靠固定目录或覆盖首行假装刷新 | 真实拖动／持有／松手、快速惯性、滚动落点与生命周期 |
| REF-04 | 刷新／加载有震动＋声音，状态完成／失败有清楚反馈 | 有效触发一次；不随每个拖动帧反复反馈；声音／触觉各有全局开关并记忆；后台／销毁不继续发声或通知 | 自动化核对真实通道调用与去重；模拟器画面、真机听感／触感分别记录 |
| DEMO-01 | Flutter每个Demo右上有唯一动作入口；通常切换白天／黑夜 | 纯主题页直接切换并提示下一动作；已有业务动作保留并纳入同一菜单；设置中的跟随系统继续可用 | 首页进入和源码独立main均覆盖；不重复右按钮，不吞掉业务动作或导航返回 |
| CLOCK-01 | OC新旧／Swift UIKit／SwiftUI当前时区仿Flutter顶部独立卡片 | 开关上方合同保留；卡片圆角、柔和强调底色、醒目当前时间，时区／IANA／偏移／日期／星期完整；沿用计时生命周期和滚动保持 | 明暗／系统、大字／窄屏及12／24小时完整文本 |
| CLOCK-02 | iOS世界页开关左侧显示当前时间制式 | ON显示12小时制，OFF显示24小时制，随持久化值即时更新；十语文案；不改12h AM／PM含义 | 开关两态、返回／重启恢复、其它行即时刷新 |
| HOME-01 | iOS设置增加返回首页时收缩分组开关 | ON从具体Demo返回自动收缩；OFF保留展开和滚动；默认沿用原收缩行为，独立保存；手动展开／收缩仍可用，不把设置／世界页返回误判Demo返回 | 两态、冷启、原回顶部刷新设置交叉组合、非Demo返回 |
| HOME-02 | 首页左上真实按钮能打开侧栏，当前优先排查Swift，OC回归核对 | 保留原侧栏半／全宽、覆盖／平移和关闭行为；修事件及命中链路，不造按钮外观替代真实交互 | 实际点击打开／关闭、导航栏浮钟不吞点击、布局变化后仍可点 |
| HOME-03 | 当前时间浮钟不得盖开屏，五端检查 | 开屏呈现期间隐藏并不接收触摸；开屏真正结束、首页可交互后按设置恢复；重播开屏也隐藏；不使用固定延迟 | 冷启／跳过／自动结束／重播、根容器切换与前后台 |
| HOME-04 | Swift UIKit首页目录为共同视觉参照，OC新旧／SwiftUI／Flutter向其靠齐 | 分组卡片、圆角／留白、行高、主副标题、展开箭头／分隔方式一致；保持各端目录内容、稳定ID、折叠／拖动／置顶／最近使用行为 | 先比实际Swift源码参数与界面；明暗／系统、窄屏大字、展开／收起及拖排入口可用 |

## 二、<span id="baseline">实现前资产与差异</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 资产 | 已有事实 | 当前缺口／不能混称 |
| --- | --- | --- |
| [Foundation边缘协议](../JobsByPubs/JobsDemoFoundationByPub/lib/jobs_edge_refresh.dart) | 横纵leading／trailing，阈值64，idle／pulling／ready／running，自定义指示器 | 无成功失败／无更多／时间／音震；浮层覆盖内容；未完整处理AxisDirection |
| [全局适配](../JobsByPubs/JobsDemoFoundationByPub/lib/src/adaptive_refresh.dart) | 全局Flutter／Jobs样式；已有有界Bouncing，最大越界120 | Jobs只Axis.vertical且末端禁用；只有双球状态，无历史时间 |
| [分页包](../JobsByPubs/JobsRefreshByPub/lib/src/jobs_refresh_load_list.dart)／[控制器](../JobsByPubs/JobsRefreshByPub/lib/src/jobs_refresh_load_controller.dart) | 另一个独立包，Material RefreshIndicator＋竖ListView，底部200像素自动加载 | 未接全局样式，未横向；refresh可与loadMore竞争，失败页码和销毁后通知边界待修；无音震／时间 |
| [横纵组合示例](../lib/demos/横纵刷新与加载组合/横纵刷新与加载组合.dart) | 现有横纵双端请求、七种教学动效、API短超时及本地回退 | 不等于普通Jobs适配和分页包已支持同等体验；原七动效保留 |
| [Demo应用壳](../JobsByPubs/JobsDemoFoundationByPub/lib/src/demo_app.dart) | 十语、白天／黑夜／系统持久设置；仅外层壳，页面内各自建AppBar | 无全Demo统一AppBar；已有业务actions须逐类保留，不能只加外层第二导航条 |
| 原生参考 | Swift JobsSwiftRefresher支持四边、角色配置、开始时本地Sound.wav及haptic、0.25秒inset动效；OC首页有触觉 | Swift时间只refresh／内存，部分失败结束也写时间；其RTL／角色热切换边界不可照搬为Flutter正确实现；第三方不修改 |

原生参考在Swift工程`JobsByPods/JobsSwiftRefresher@Pods/`，本机只读盘点附件为任务产物`jobs-refresh-upgrade/native-reference-audit.md`；Flutter使用面附件为`flutter-reference-audit.md`。既有`assets/Sounds/spin.mp3`未见刷新适用的来源／许可说明，不能拿转盘长音替代刷新短音。音频优先采用自有短提示，不引入来源不明资源。

## 三、<span id="status">实现与验证状态</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

2026-11-16登记快照：需求已确认／资产已定位，当时尚未认定新增实现完成。原生各工程先在自己的骨架表登记再改；中央入口见[五端对照](./App骨架对照与补齐清单.md)与[Flutter骨架表](./Flutter-App骨架资产盘点.md)。以下小节为后续当前实现与分阶段验收；不把模拟器代替真机声音／触感，不宣称帧时间错误已修复。

### 3.1、Demo公共入口与Flutter目录卡片

`DEMO-01`源码已接入：[JobsDemoAppBar／JobsDemoActions](../JobsByPubs/JobsDemoFoundationByPub/lib/src/demo_app_bar.dart)保留原导航参数，纯主题页直接切明暗并显示下一动作；有业务动作的页面将主题、IconButton／文字按钮及泛型PopupMenu选项汇入唯一菜单，保留原回调与禁用。读取有效亮度决定下一次动作，写回既有`JobsDemoSettings.themeMode`及`jobs_demo_theme`，跟随系统仍可从设置选择。临时菜单随路由销毁；动作host由入口持有并销毁，不增加持久键。

首轮AST精确迁移208文件／234处AppBar创建，不把该创建数当成目录覆盖数。随后299真实注册builder逐项验收发现嵌套滚动兼容入口缺导航，以及部分factory外Scaffold与实际页面内AppBar重复，已用[旧入口导航代理](../lib/demo_hub/legacy_launch.dart)及41个factory根的`JobsDemoActionHost`统一转交内层动作；Cupertino导航直接复用`JobsDemoActions`。未修改`lib/JobsDemoTools/`外源页面，嵌套滚动通过中文入口适配。300个实际源码main／175个兼容委托的组织保持，未重拆入口，生成part未编辑。

限定验证：[公共动作6项](../JobsByPubs/JobsDemoFoundationByPub/test/demo_app_bar_test.dart)通过；[全目录动作验收](../test/demo_toolbar_coverage_test.dart)是1个测试内部逐项检查299注册builder，实际打开唯一入口、切主题、核对Material AppBar与Cupertino页面实际亮度并销毁，首轮42秒通过；最后生命周期补丁后公共动作6项＋同一299遍历合计7项、78秒重新通过，硬件页仅Linux不支持分支；不能据此认定所有具体Demo业务或真机主题画面已验。另有首页11项及实际源码main两项回归通过。原泛型Popup回调类型异常、两处缺失／重复入口，以及同路由菜单覆盖时提前注销动作造成选项回调丢失，均由真实失败定位并修正。覆盖时保留原动作注册，仅当前页面更新优先级，dispose删除；新增回归验证选项仍执行，未放宽唯一性或原业务断言。

并行且另行授权的OCR任务新增`rust-ocr`后，当前目录为300项；此前299项与78秒阶段保留历史。覆盖夹具现按真实registry核对ID唯一、旧299 ID基线存在，以及实际完成交互的集合等于全部当前注册；基线见`test/fixtures/demo_toolbar_baseline_2026_11_16.json`。最新包含OCR的300个builder逐项执行唯一入口／实际Material或Cupertino亮度／销毁检查，1项测试、0失败、140秒通过；该文件限定分析0error／0warning、13info。此次只核对新增页的公共主题入口接线，OCR识别业务由其所属任务验收，未将其产品实现归本报告。

`HOME-04` Flutter参照Swift `RootFoldTableCell.swift`实际参数：圆角14、卡片自身左右10／上下8，配合列表16内边距使402逻辑像素页面卡片左边距26、宽350；组头至少64、主17／副13，条目至少56、主17／副12，展开内容上下10，分隔线放在条目内部；顶部统一居中标题与来源，明暗使用相应中性页面／卡片底色。Flutter因字号／长标题可增高，保留置顶、源码菜单和拖动柄。位置与ID、折叠／重排／记忆／最近行为仍由[原首页状态](../lib/demo_hub/home_page.dart)维护，保留刷新historyKey及音震设置的API同步。

[卡片几何与两主题折叠测试](../test/demo_home_cards_test.dart)通过，几何夹具显式关闭悬浮钟以隔离卡片点击；原首页11项还验证拖排落点、关闭记忆重启、置顶／取消与最近记录。实际设备新卡片画面、全十语三主题的实体截图仍由本轮后续构建／交互单独记录，不沿用上批51.5秒包。

### 3.2、四边刷新、分页与音震

`REF-01～04`已接同一[边缘控制器](../JobsByPubs/JobsDemoFoundationByPub/lib/jobs_edge_refresh.dart)及[全局适配器](../JobsByPubs/JobsDemoFoundationByPub/lib/src/adaptive_refresh.dart)。横纵两端均按实际AxisDirection定位，支持reverse、RTL和角色交换；idle／pulling／ready／running／finishing与成功／失败／无更多结果分开。阈值64，已有最大越界120逻辑像素约束保留；反向收手取消，松手触发、同列表互斥、完成留区后回弹。全局Jobs适配器完成留区350毫秒、回弹250毫秒，直接使用控制器时完成时长仍可配置、默认零；外借控制器不由视图dispose。

| 入口／代码 | 行为与默认 | 持久化／生命周期 |
| --- | --- | --- |
| `JobsEdgeRefreshController`／`jobsRefreshHistoryText` | 刷新与加载各记录成功完成时间；首次明确无记录，失败保留旧值，跨日显示实际日期 | `historyKey`非空时分别存`jobs_refresh.<key>.refresh`及`.load`毫秒值；无键只内存，异步恢复有revision门禁，销毁后不通知 |
| `JobsAdaptiveRefresh` | Flutter样式的普通纵向仍用原RefreshIndicator；Jobs及横向走四边协议，真正推动内容；正文和运行区共同布局，不覆盖首行 | 指示器随当前轴和角色显示方向、状态及时间；可见／前台才反馈，结束／销毁停止动画和音频 |
| [JobsRefreshByPub](../JobsByPubs/JobsRefreshByPub/README.md) | 复用上述协议，默认末端手拉加载，`autoLoadMore=true`显式恢复200像素静默预取；支持横向／reverse和完整空态／重载 | 刷新／加载互斥，成功才提交页码与条目，失败重试同页；无更多独立状态，刷新由业务结果恢复hasMore；兼容旧builder和颜色参数 |
| [全局设置](../JobsByPubs/JobsDemoFoundationByPub/lib/src/demo_app.dart) | “刷新触觉反馈”“刷新声音”独立开关，均默认开，十语文案 | `jobs_demo_refresh_haptics`／`jobs_demo_refresh_sound`持久化，宿主设置PUT转发对应值；两项关闭时也不发送测试替代通道 |
| [反馈适配](../JobsByPubs/JobsDemoFoundationByPub/lib/src/refresh_feedback.dart) | 用户实际开始／成功／失败各至多反馈一次，自动首屏与静默预取不响；lightImpact／selectionClick／mediumImpact及对应短提示音 | 复用audioplayers 5.2.1；iOS ambient＋mix尊重静音，后台／路由覆盖／关闭声音／销毁停止；异常不打断业务 |
| [自有音频](../JobsByPubs/JobsDemoFoundationByPub/assets/audio/README.md) | 三段Jobs自行生成的单声道16位PCM WAV，来源／频率／时长明确 | 通过包内AssetSource加载；现Darwin实现不支持setSourceBytes，因此没有使用字节接口或来源不明的长转盘音 |

首页按`demo-hub.<filter>`隔离历史；普通Demo与横纵组合／分页示例各用自己的稳定键。原七种教学动画保留，减少动态效果时抑制连续动画。刷新接口仍沿用各业务API与本地演示回退；没有加载业务的首页不虚构分页接口。使用方式见[Foundation README](../JobsByPubs/JobsDemoFoundationByPub/README.md)。

专项[29项](../test/jobs_refresh_upgrade_test.dart)已通过：16个真实Widget拖动组合覆盖横纵×reverse×RTL×两端，以及120限幅／运行留区／回弹、双历史持久与失败保持、角色切换／无更多／互斥／销毁／外借、分页竞争与失败同页、嵌套轴过滤、音震配置及实际Haptic通道、三音频格式与资源一致性、十语明暗1.8倍文字无溢出。原全局适配与七动效组合16项回归通过。原生AVFoundation对最终三个WAV实际解码／prepareToPlay的3项测试通过，未将此计作人耳听感或真机触觉验收。

### 3.3、原生骨架与设置保存位置

四原生`CLOCK-01／02`已实现独立当前区卡片、醒目时间、完整城市／IANA／UTC／日期／星期；格式开关左侧随实际状态显示12或24小时制，沿用原偏好键和AM／PM。秒刷新只更新可见内容，避免重建列表及跳动。OC当前区使用独立cell复用标识，修正滚出再返回时与普通世界行复用混淆。四端真实世界页各1项、合计4项零失败；实测开关两态、秒更新和滚出返回。另1项UIFont／生产格式器测试覆盖160组合，不能将测量替代全部大字AutoLayout实画。

`HOME-01～04`已落原生资产表：四端默认开的返回收缩开关仅处理具体Demo返回；关闭优先保留展开与滚动，旧返回刷新开关不能将其间接重置。Swift左菜单以factory显式注入真实drawer owner，OC入口同步实际回归。三个UIKit工程开屏呈现前隐藏浮钟、真实移除及首页可交互后恢复；首页时间Timer按owner实例唯一，销毁仅移除自身，保留全屏拖动。SwiftUI原本没有独立侧栏／开屏，本轮补现有组手动收缩和视觉。两OC与SwiftUI目录向Swift圆角14／H10V8、组17／13、条目17／12及最小56靠齐，保持原目录内容与交互。

Flutter浮钟也按当前路由、前台及完成的转场决定显示和计时；实际路由测试确认进入转场150毫秒时隐藏、完成后出现，重播开屏隐藏、返回位置保持。该门禁不依赖固定延时。

设置选项确实保存于各App的NSUserDefaults／UserDefaults；iOS文件位于**该App沙盒**`Library/Preferences/<bundleID>.plist`，路径由系统解析，项目不固化机器绝对路径。新增键如下：

| 工程／bundleID | 返回收缩键 | 缺值默认 |
| --- | --- | --- |
| OC新 `com.JobsOCBaseConfigDemo.byPods`／OC旧 `com.JobsOCBaseConfigDemo` | `com.BSports.JobsOCDemoListCollapseOnDemoReturn` | 开 |
| Swift `com.jobs.JobsSwiftBaseConfigDemo.JobsSwiftBaseConfigDemo` | `RootList.collapseOnDemoReturn` | 开 |
| SwiftUI `com.jobs.jobsswiftuibaseconfigdemo` | `JobsSwiftUIBaseConfigDemo.collapseOnDemoReturn` | 开 |

四端已实际切换、终止冷启读回，并只读核对上述key落盘；展开集合与浮钟坐标仍为视图状态，不声称全部偏好或页面状态均持久。该落盘证据属于原609模拟器；后来用户授权另一任务清理设备集，沙盒随之删除。新建A3为全新沙盒，没有把旧偏好复制回去或用历史值冒称当前保存。

### 3.4、当前验证快照与限制

最终协调版本：主工程701项通过＋1项既有字体截图跳过，Foundation25项通过，合计**726通过／1旧跳过／0失败**；300注册builder遍历属于其中1项。全域限定分析0错误／0警告／682条info。`ios-coordinated-final-build.log`记录pod解析187.3秒、Xcode230.8秒通过，冻结包`flutter-final-guarded-ocr.app`保留Kernel与三音频SHA；该包包含并行OCR任务的可编译guarded入口，不将其识别业务纳入骨架验收。旧675项失败阶段、并发OCR缺podspec构建失败等日志保留，未以最后成功掩盖历史。

原生四端首页返回设置完整链分别通过，三个UIKit开屏及Swift实际侧栏通过；四端世界卡片各1项通过。后续Timer实例ID：生产管理器真实对象隔离2项通过，Swift同源隔离普通包及A3新设备开屏1项通过；两OC最终final6普通增量构建通过，冻结包A3开屏短验2项零失败（新10.225秒、旧7.214秒），倒计时无钟、skip后可命中浮钟。A3三UIKit首次通知授权均选择不允许，不能说全部偏好原样。本任务Swift通过的是责任源码一致的隔离普通包，当时原workspace受既有嵌入Flutter SDK／锁不匹配阻塞；后续OCR协作任务已回报用本机离线pub get修正旧配置、原workspace完整构建及35行真实识别通过。后者为协作方验收，不冒称本任务独立重跑OCR；先前隔离阶段记录保留。

最终Flutter模拟器实际验收已确认：首页卡片收缩／展开、设置Flutter→Jobs且音震默认开、真实纵向两次拉动跟手／留区／回弹和上次刷新可见，横向右拉刷新与左拉加载真实计数推进，唯一菜单切明暗及清空回调保留。各测试结果、录屏帧和新设备恢复情况由本轮[机器验收记录](./验收记录/2026-11-16.json)继续收口，不把Widget拖动代替模拟器触控。

完整十语×三主题×设备／旋转／极端字体实画、多Scene窗口与开屏重播完整组合、真机声音／触觉仍待验。帧时间clamping日志尚无稳定复现和修复证据，状态仍为未解决；没有增加日志过滤或引擎规避。本轮磁盘压力后停止新大构建，跨任务按授权让出构建窗口，各自保留安装包及证据。

### 3.5、横向持有提示的最后修正

上述230.8秒包的真实触控另发现：ready阶段仅揭示约84逻辑像素时，指示器仍以112宽排版，状态／历史右侧被裁。功能计数通过未计为该帧视觉通过。已将横向指标宽度限制在实际揭示区内（阈值以下允许逐渐揭示），未改变阈值、拖距、请求、音震或时间记录。

新增1个回归case包含两端×reverse×LTR／RTL共8次真实有限拖动，先在旧实现复现越界，再验证ready持有、继续持有300毫秒、松手运行态的指示器与历史RenderParagraph均在ClipRect内，结束内容归位；原29项加新1项共30项全部通过，限定分析0error／0warning／7info。726项为这处局部补丁前的完整绿色基线，30项为补丁后的实际复跑，不能相加冒称新一次全仓727项。补丁后最终包与实际持有画面另列追加结果。

宽度修补包Pod11.9秒／Xcode129.1秒通过；实际定向功能1项零失败、64.863秒，两次刷新／两次加载、菜单原清空回调及默认恢复通过。但视频75像素ready帧仅显示“上次加载／今天”，第三行时分秒未绘制，因此该帧仍判视觉未通过；89像素leading帧完整，不能用它代替更窄trailing帧。原因是原状态／历史两个Flexible均分高度，120高容器加28图形时挤掉第三行；单纯Text存在和Paragraph框位于ClipRect内仍会漏报。

随后将同一8组合夹具改成真实120高／28图形，并逐字符检查时分秒的selection glyph box是否存在、在Paragraph本地高度内及变换后ClipRect内，先真实复现红灯。横向现用完整自然Column后按可用空间scaleDown，取消横向ellipsis，纵向原布局及行数语义保持。此阶段最终Dart与最新真实OCR SDK包的构建／实画继续按后续证据追加，不沿用前包功能通过作为视觉完成。

该补丁严格复跑：新刷新30＋旧组合6＋Foundation适配10，共46通过／0失败；三文件限定分析0error／0warning／8info。120高／28图形的8个有限拖动组合在ready、继续持有及release运行三态逐字符验证时间glyph，而非只查Text存在；宽度越界、高度截行及ellipsis提前终止的历史失败均保留。OCR任务随后已接入真实SDK与Pods，后续包使用当前集成，不回退guarded。原生最终包暂受共享磁盘余量约1～2GiB限制，已协调迁移该任务自身可重建缓存到核实的外卷，不清理其它任务／用户数据。

后续资源与冷包：NAS迁移经实测速度过慢，协作方停止迁移、保留原树，完成自身Swift整包后只回收其独占可重建缓存，释放Data约8GiB；临时外卷由该任务自行撤销，产品不依赖NAS。本任务官方Flutter `--config-only`完成（pod10.5秒），再以当前SDK的`-clonedSourcePackagesDirPath <项目>/build/ios/SourcePackages`和jobs1执行普通Xcode构建通过。首次手动漏该缓存参数而停在远程SPM解析，未进入编译，已精确终止自有进程并保留exit1日志，未改依赖或网络代理；修正后实际编译成功，监测最低6.633GiB，未触发1.2GiB门禁。

最后冷包冻为`flutter-final-height-true-sdk.app`：实际产物来自`build/ios/Debug-iphonesimulator/Runner.app`，已核对新Kernel与46项通过源码SHA，三个WAV与已解码字节一致；真实Rust资源bundle及`jobs_ocr_recognize_file／rgba／version`符号在包。直接Xcode构建不会替换此前Flutter命令留下的`build/ios/iphonesimulator/Runner.app`旧副本，未使用旧副本做最后验收。没有执行attach或热重启；最新冷包实际持有画面按下方最终结果收口。

**最终冷包限定UI通过**：A3／iPhone18Pro／iOS27.2，1项零失败、62.438秒。两次真实横向刷新与两次加载、原更多菜单的清空回调、Flutter默认样式／跟随系统／首组展开恢复及最后冷启首页通过。Root与UI代理均逐张实看ready持有原图：leading约87逻辑像素、显示完整20:19:22；trailing约79逻辑像素、显示完整20:19:41，状态为“松开刷新／松开加载”，不是用运行时112宽留区替代。状态及时间没有被首卡或自身高度裁掉，之前75像素缺字帧保留为失败历史。包与source／Kernel／音频SHA对应，热重启方案仅曾准备、未执行；设备保留新包首页，正常最近／搜索／刷新历史未清除。上述不代替全部reverse／RTL、语言／设备实画或真机音震矩阵。

<a id="🔚" href="#前言">返回首页</a>
