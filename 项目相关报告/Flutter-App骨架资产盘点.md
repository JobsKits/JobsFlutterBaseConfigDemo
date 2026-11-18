# [**Flutter**](https://flutter.dev/) App 骨架资产盘点

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、范围与证据口径](#scope)
- [二、骨架资产总表](#asset-map)
- [三、启动、导航、菜单与搜索](#navigation-assets)
  - [3.1、启动与独占页面](#jobs-toc-heading-5)
  - [3.2、右上菜单与搜索契约](#jobs-toc-heading-6)
  - [3.3、侧栏呈现矩阵](#jobs-toc-heading-7)
- [四、目录折叠、拖放、置顶与记忆](#layout-assets)
  - [4.1、当前布局模型](#jobs-toc-heading-9)
  - [4.2、需要保留的验收缺口](#jobs-toc-heading-10)
- [五、首页悬浮控件](#floating-assets)
  - [5.1、世界时钟骨架新需求（2026-11-16）](#world-clock-contract)
- [六、设置、十语言、主题与持久化键](#settings-assets)
  - [6.1、设置资产](#jobs-toc-heading-14)
  - [6.2、实际键与默认值](#jobs-toc-heading-15)
  - [6.3、公共 Demo 主题与业务动作入口](#demo-actions)
- [七、三份刷新资产来源核查](#refresh-assets)
  - [7.1、现有封装与当前新增适配的差别](#jobs-toc-heading-18)
  - [7.2、当前自适应控件的边界](#jobs-toc-heading-19)
- [八、API 回退与生命周期边界](#api-lifecycle)
- [九、验证记录与后续对齐清单](#validation)
  - [9.1、已完成的限定验证](#jobs-toc-heading-22)
  - [9.2、依据盘点继续处理的顺序](#jobs-toc-heading-23)
- [十、中英混排核心与源码状态](#mixed-script-source-20261117)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

> 盘点对象是主应用骨架，不是功能 Demo 数量。基线核对日期：2026-11-15；本次增量更新：2026-11-16；已提交源码参照 `HEAD ecea172`，当前工作区保留本轮未提交改动。先查清已有资产、实际入口与缺口，再决定补齐范围。

本文将“原有基线”“当前实现”与“待验项目”分开。**源码存在、专项测试通过、实际设备交互通过是三个不同状态**；原生工程的对照结论见[统一对照表](./App骨架对照与补齐清单.md)所链接的四份原生盘点，不能用本文替代原生验收。本文所述骨架调整复用既有依赖，未修改SDK、原生第三方源码，也不包含提交或推送。

当前实测环境为 Flutter `3.50.0`、[**Dart**](https://dart.dev) `3.14.0`，引擎提交 `371f77202a73e8dff57a8b3bff75bca55c090aee`；[**FVM**](https://fvm.app) 绑定 `stable`。这里记录当次实际环境，不代表以后同一频道仍解析到相同版本。

2026-11-16后续功能批次：目录聚合追加18项精选至299个入口，保留既有分组默认顺序，仍共用本文的搜索／最近／设置骨架。功能、公共几何包、播放器增量与673项测试／Web和iOS构建验证归[四库蒸馏资产盘点](./四库功能与UI蒸馏盘点.md)，不将子页数量并入本文骨架资产数，也不扩写本批原生交互验收。

2026-11-16 Rust OCR 独立增量：共享核心插件位于 `JobsByPubs/JobsRustOCRByPub`，目录新增“离线文字识别”后当前为300入口；仍复用同一搜索、最近、源码定位、十语与三主题骨架。新增能力与 SDK／实际推理／设备验证分别记录在 [Rust OCR 集成资产盘点](./Rust-OCR集成资产盘点.md)，上面的299项冻结证据不自动覆盖新增能力。

## 一、<span id="scope">范围与证据口径</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `FL-S01` 至 `FL-S15` 是骨架资产编号；原十四项编号保留，追加公共 Demo 动作入口；按启动、导航、菜单／搜索、侧栏、目录组织、悬浮、设置、刷新、数据与生命周期分类，与原生报告按同义类别比较。
- “原有”指 `HEAD ecea172` 已存在的实现；“当前新增／调整”指本轮工作区改动，不能反写成任务开始前已经具备的资产。
- 路径以本文所在目录为基准；链接指向当前工作树。入口定位以文件和符号为准，避免后续增删行造成行号失效。
- 不统计 `lib/demos/` 子页、旧教学页与硬件实验页的功能覆盖；必要时仅说明它们调用哪个公共骨架接口。
- 未启动新的索引、安装依赖或升级 SDK。利用已有代码索引、当前源码、已提交版本差异及实际测试结果核查。

## 二、<span id="asset-map">骨架资产总表</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 当前目录存在全部基础承载层；原三UIKit工程的同义矩阵和新增SwiftUI骨架仍需按操作逐项验收，不能以“有 Widget”判定等价。

| 编号 | 骨架资产 | 原有基线 | 当前新增／调整 | 主要证据 |
| --- | --- | --- | --- | --- |
| FL-S01 | 启动与开屏 | 设置初始化后启动；2 秒开屏，可跳过或开始探索；替换导航移除开屏 | 开屏演示及其覆盖路由共用首页活动门禁，开屏在栈顶时首页浮钟隐藏、停计时且不可命中，真正返回首页后恢复 | [主入口](../lib/main.dart)、[DemoSplash](../lib/demo_hub/demo_hub_app.dart)、[开屏门禁测试](../test/splash_floating_gate_test.dart) |
| FL-S02 | 应用容器与导航 | `GetMaterialApp`、公共主题／语言；功能页使用导航栈；独立预览壳 | 首页 `visit()` 统一维护独占页面活动状态 | [DemoHubApp](../lib/demo_hub/demo_hub_app.dart)、[首页](../lib/demo_hub/home_page.dart)、[JobsDemoApp](../JobsByPubs/JobsDemoFoundationByPub/lib/src/demo_app.dart) |
| FL-S03 | 右上菜单与搜索 | 首页常驻搜索框；右上角齿轮直接进设置；搜索在首页状态内切换 | 圆形省略号触发下拉菜单；搜索／全部收缩展开／设置；搜索为独立路由，空态按可用宽度居中 | [首页与搜索页](../lib/demo_hub/home_page.dart)、[公共空态](../JobsByPubs/JobsDemoFoundationByPub/lib/src/empty_state.dart) |
| FL-S04 | 左侧菜单 | 左上按钮、边缘拖动、半宽／全宽覆盖、遮罩／返回关闭 | 独立增加 `overlay / push`，平移完整首页；宽度仍可半宽／全宽 | [JobsSideMenu](../JobsByPubs/JobsDemoFoundationByPub/lib/src/side_menu.dart) |
| FL-S05 | 分组组织 | 按注册分组展示标题与条目；分组不可折叠或移动 | 单组／全部折叠展开、数量与拖动柄；组头移动菜单移除。按 Swift 实际卡片参数统一圆角14、卡片H10/V8、组17/13、行17/12及最小行高56；保留稳定ID、置顶／拖排／最近／折叠 | [首页](../lib/demo_hub/home_page.dart)、[HomeLayout](../lib/demo_hub/home_layout.dart)、[真实几何测试](../test/demo_home_cards_test.dart) |
| FL-S06 | 行排序与置顶 | 收藏星标，不含实际置顶或拖动落点 | 组内拖动；置顶移入 `@pinned`，取消回原组；布局记忆开关及重置 | [HomeLayout](../lib/demo_hub/home_layout.dart)、[entryTile](../lib/demo_hub/home_page.dart) |
| FL-S07 | 收藏／最近／历史 | 收藏、本地最近 30 项、搜索历史 20 项；本地存储与偏好 PUT | 已移除侧栏收藏入口与行菜单收藏项，遗留收藏键保留但不读写；最近使用独立始终展开，按最近 ID 排列，不受分组折叠／置顶排序影响且不手工拖排；独立搜索共用最近与历史记录 | [首页与搜索页](../lib/demo_hub/home_page.dart) |
| FL-S08 | 首页悬浮层 | 主首页没有用户所述四种悬浮控件 | 时间、“按”、旋转秒数、Bug；全屏拖动吸边；独占／开屏／后台隐藏与暂停；时间按文字／字号／安全区自适应，短按世界页、长按拖动。原8项专项含80布局组合及世界页6项通过，新开屏门禁1项通过；历史界面证据不替代当前包实触 | [HomeFloatingControls](../lib/demo_hub/home_floating_controls.dart)、[开屏门禁测试](../test/splash_floating_gate_test.dart) |
| FL-S09 | 全局设置 | 跟随系统／白天／黑夜；十语言；侧栏宽度；独立预览设置面板 | 共用面板提供侧栏呈现、布局记忆／重置、时钟显隐、控件样式；刷新触觉／声音两个独立开关均默认开，本地持久化并纳入首页偏好PUT快照 | [JobsDemoSettings](../JobsByPubs/JobsDemoFoundationByPub/lib/src/demo_app.dart)、[首页设置与快照](../lib/demo_hub/home_page.dart) |
| FL-S10 | 刷新控件 | 主首页使用 Material `RefreshIndicator`；Foundation边缘协议与JobsRefreshByPub分页封装各自存在 | 两包现共用 `JobsEdgeRefreshController`：横纵／两端／reverse与RTL、两角色成功时间、互斥／无更多／重试；横向自然换行＋按可用高整体缩放，不省略完整时间。升级30＋兼容16共46项通过，真实SDK冷包两端ready、释放与原菜单限定实触通过；真机音震另验，详见[刷新合同](#refresh-assets) | [边缘模型与视图](../JobsByPubs/JobsDemoFoundationByPub/lib/jobs_edge_refresh.dart)、[适配器](../JobsByPubs/JobsDemoFoundationByPub/lib/src/adaptive_refresh.dart)、[分页包](../JobsByPubs/JobsRefreshByPub/lib/JobsRefresh.dart) |
| FL-S11 | 目录 API 与回退 | 随包目录立即显示；GET 排序、PUT 偏好；900ms 超时；失败保留本地 | 布局快照与新开关接偏好 PUT；重载有请求代次及布局修订保护 | [CatalogRepository](../lib/demo_hub/catalog_repository.dart)、[首页](../lib/demo_hub/home_page.dart) |
| FL-S12 | 资源与生命周期 | 开屏 Timer 取消；搜索／菜单控制器释放；公共包自有设置释放保护 | 悬浮时钟、动画、音频与摇动监听的前后台／页面活动治理；世界页仅前台当前路由计时，恢复立即校时 | [悬浮层](../lib/demo_hub/home_floating_controls.dart)、[世界页](../lib/demo_hub/world_clock_page.dart)、[公共壳](../JobsByPubs/JobsDemoFoundationByPub/lib/src/demo_app.dart) |
| FL-S13 | 源码定位与独立启动 | 原分离入口与实现、源码中间目录增加定位层级 | sourcePath／entryPath同指真实实现，头注给出运行命令，导入／part指令后为main；175个纯转发入口删除、46个实现入口按功能命名，175个源码目录的263文件上移；辅助文件不造main，ID／顺序／偏好与生命周期不变；本批验证见专项盘点 | [登记与源定位](../lib/demo_hub/legacy_catalog.dart)、[胶囊实际源码目标](../lib/demos/胶囊按钮切页/JobsSegmentTabs.dart)、[目录整理盘点](./Demo源码目录整理.md) |
| FL-S14 | 世界时钟与首页标识 | 无世界时钟骨架页；Flutter 首页仅主标题 | 时间按钮短按push世界时钟、长按拖动；当前时区与全球代表地区、日期星期和12／24小时开关；首页副标题项目来源；详见下文 | [模型](../lib/demo_hub/world_clock.dart)、[页面](../lib/demo_hub/world_clock_page.dart)、[十语](../lib/demo_hub/world_clock_strings.dart)；源码／全仓／构建通过，限定实际导航及开关已验 |
| FL-S15 | 公共Demo动作入口 | 各页自行创建AppBar或嵌套容器，主题入口不统一 | 每个已注册Demo仅一个可见右上动作入口：无业务动作直接切换明暗，有业务动作收进同一菜单并保留原回调／禁用态；嵌套Material／Cupertino／GetX和源码独立运行共用设置，提示显示下一行为 | [JobsDemoAppBar／Actions／Host](../JobsByPubs/JobsDemoFoundationByPub/lib/src/demo_app_bar.dart)、[全目录实际主题测试](../test/demo_toolbar_coverage_test.dart)；当前300 builder逐项通过，原299 ID基线保留，OCR仅验公共入口 |

## 三、<span id="navigation-assets">启动、导航、菜单与搜索</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### <span id="jobs-toc-heading-5" data-jobs-toc="v2">3.1、启动与独占页面 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

- `main()` 先等待 `JobsDemoSettings.init()`，再 `runApp`；设置读取在首帧之前完成。
- `DemoSplash` 默认 `2s`，`leave()` 用 `leaving` 防重复跳转，取消 Timer 后执行 `pushReplacement`；开屏销毁也取消 Timer。
- 首页通过 `visit()` 进入搜索、设置、世界时钟、开屏演示或功能页：先关菜单，把 `homeActive` 置为 `false`，返回时在 `finally` 恢复；悬浮层随之隐藏与暂停。
- 首页额外观察当前 `ModalRoute`；开屏演示及其上方覆盖路由存在时也保持浮控非活动，不依赖固定延迟。新增门禁用例实际覆盖开屏结束／路由返回后的恢复；对应新包真实触控另列。
- 搜索结果进入功能页使用搜索页自己的 `BuildContext` 推入导航栈；返回先回搜索，取消搜索才回原首页筛选上下文。
- 当前容器未建立多 Tab／多导航栈，也未统一处理外部深链、账户登录拦截或全局恢复导航栈；不能从功能子页的演示推断这些已成为骨架能力。

### <span id="jobs-toc-heading-6" data-jobs-toc="v2">3.2、右上菜单与搜索契约 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 项目 | 当前可核验行为 | 默认／限制 |
| --- | --- | --- |
| 首页右按钮 | `PopupMenuButton`，`CupertinoIcons.ellipsis_circle`，尺寸 32；菜单位置 `under` | 是本轮调整；形态和条目顺序仍需按原生截图验收 |
| 搜索入口 | 仅菜单“搜索Demo”进入 `_DemoSearchPage` | 首页不直接创建搜索输入框 |
| 搜索范围 | 译后标题、原始标题、组名、tags、源码路径的本地大小写无关包含匹配 | 搜索全部随包注册项，不受首页最近使用筛选限制；没有服务端检索 API |
| 历史 | 输入提交或打开结果时写入；最近在前、去重、上限 20；可逐条删除或清空 | 空输入展示历史；历史不是搜索建议服务 |
| 搜索空态 | 无历史和无结果均使用公共空态；占满可用宽度，图标／标题／说明／操作共用水平中心轴；无结果可清空搜索，取消返回原首页 | 键盘挤压或内容超出高度时可滚动；重新加载当前仅请求目录排序，搜索列表仍是传入的本地注册项 |
| 原有行附加动作 | 源码位置弹窗、复制独立运行命令 | 当前行菜单保留，未把这些动作混入首页全局菜单 |

### <span id="jobs-toc-heading-7" data-jobs-toc="v2">3.3、侧栏呈现矩阵 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 宽度 | 覆盖 `overlay` | 平移 `push` |
| --- | --- | --- |
| 半开 | 原有：菜单覆盖首页，首页保持原位 | 本轮：完整首页右移，菜单右边缘与首页左边缘同坐标 |
| 全开 | 原有：菜单覆盖整个视口 | 本轮：菜单占满视口，完整首页移到视口右侧 |

半开宽度为可用宽度 `0.5`，默认半开／平移（依据原生资产核查收口）；公共组件允许 `widthFactor` 在 `.35` 至 `.95` 范围。动效沿用 `260ms` 与 `easeOutCubic`。左侧 `24px` 边缘激发，遮罩点击、左拖、关闭按钮及系统返回收起。展开时首页语义／焦点排除，关闭时菜单语义／焦点排除；`ClipRect` 限制平移绘制范围。

当前侧栏保留“全部功能／最近使用”两种目录入口，以及设置和开屏演示；收藏入口已移除。行“更多”保留源码位置与复制运行命令，收藏动作已移除，置顶按钮继续使用独立布局状态。

## 四、<span id="layout-assets">目录折叠、拖放、置顶与记忆</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### <span id="jobs-toc-heading-9" data-jobs-toc="v2">4.1、当前布局模型 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

`HomeLayout` 保存稳定 ID，分别持有 `groups / entries / pinned / collapsed`；原始注册分组关系仍由本地条目决定，不因为拖动改变功能归属。

首页视觉依据 Swift UIKit 的 `RootFoldTableCell.swift` 实际参数：列表外侧16，卡片再留水平10／垂直8，圆角14；组头最小64、主副字17／13，内行最小56、主副字17／12，箭头与行内分隔形成层级，明暗底色分别为 `#F2F2F7 / #191B20`。`402`逻辑像素测试视口中卡片 `x=26 / width=350` 已按真实Widget几何断言，展开／收起均保留；这项证据不等于其它设备或本轮最新App截图已验。

- 全部功能目录中，组头点击切换收缩；右上菜单按当前可见组是否存在展开项，切换“全部收缩／全部展开”。最近使用不参加组折叠。
- 全部功能目录使用外层 `ReorderableListView` 排组；内层 `shrinkWrap + NeverScrollableScrollPhysics` 的可排序列表排当前组内条目。组头保留折叠入口、数量与拖动柄，删除提供“上移／下移”的三点菜单；组与条目仍可用拖动柄排序。功能条目行的源码位置／复制运行命令菜单保留；最近使用不显示组操作或拖动柄。
- 新置顶条目插入 `pinned[0]`，顶部组强制位于所有普通组之前，同时展开顶部组。取消置顶仅移出 `pinned`，回原分组已有顺序位置。
- 拖动只作用于当前可见集合；模型合并时保留未出现在当前筛选中的 ID 相对位置。当前 `reorder()` 已先对完整目标顺序去重并补足可见 ID，避免不完整旧偏好造成重复或丢项。
- 普通组不能越过固定顶部组；顶部组自身无拖动柄。置顶组内部可排序。
- 记忆默认开启。关闭后本次布局继续有效，但移除 `hub.layout.*` 本地键；重启不恢复这份自定义布局。首次与恢复默认只展开首组；记忆已保存 `collapsed=[]` 时保持全部展开。
- 最近使用独立为 `@recent` 列表，始终展开；按 `hub.recent` 的最近 ID 顺序显示，不按原分组拆开，不将置顶项提前，也不受服务端目录排序影响。最近列表中的置顶操作仍修改全部功能目录的布局，最近列表顺序保持按打开时间。
- 普通目录、搜索结果和最近列表共用 `open()`：稳定 ID 前插去重、最多 30 项并本地保存及 PUT；启动恢复忽略不再注册的 ID。打开功能后返回原目录或搜索来源；最近为空时使用公共完整空态与重新加载，重新加载请求目录，不制造浏览记录。

### <span id="jobs-toc-heading-10" data-jobs-toc="v2">4.2、需要保留的验收缺口 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

- **跨组拖动没有实现。** 当前是普通组排序、同组条目排序、置顶组三套局部顺序；不能宣传为把任意功能拖进其它组。
- **长组跨屏拖动需实测。** 内层列表不可滚动，外层才持有滚动控制器；条目拖到屏幕边缘时是否能带动外层自动滚动，尚无实际手势验收证据。
- 最近使用当前不提供手工拖排，原先写回 `recent` 的拖动路径已移除；以最近打开顺序为唯一排序依据。

来源中性迁移：119个功能目录去掉“旧例·”前缀，68项来源桶条目按显式稳定ID分入已有六组（基础31、数据16、交互9、媒体9、网络2、原生1），新增蒸馏三组保留；所有189个相关功能ID不变。`HomeLayout.restore` 仅从旧偏好的 `groups`／`collapsed` 过滤废组键 `原有功能`，保留其它功能组顺序、展开状态、条目顺序及置顶；当前读取只归一化内存，下次原有 `saveLayout` 正常写回，不主动清空布局或最近使用。目录迁移伴随三份生成part按原字节移动，未改生成内容。

源码头部入口与源定位已统一：前批迁移核查时300个主／独立运行文件包含175个实现源码、46个自身带实现的入口和79个独立或转发文件，不是300个首页功能；这是并行OCR新增独立main之前的历史基线，不能作为当前文件总数。当前目录整理已删除另175个纯兼容入口、将46个实现入口按功能命名，并上移175个源码目录的263文件；88个helper不补main、三份生成part保字节。头注给出项目相对运行命令，main位于导入／part指令之后。175个factory留在对应实际源码，首页登记直接import该实现，sourcePath／entryPath相同；`lib/JobsDemoTools`的旧包级转发改指新位置。公共主题动作、稳定ID／顺序、偏好键与页面生命周期保持，当前验证见[目录整理盘点](./Demo源码目录整理.md)，前批证据不代替本批验证。运行仍依赖当前工程pubspec、资源及辅助库，不声明脱离工程可直接运行。拖动手势的自由／水平／垂直安全实现合一，避免独立源码与首页行为分叉；最终整包验证另计。
- 置顶后自动滚到顶部；取消置顶回原组并展开。长列表中实际滚动与落点仍需按目标设备复核。
- **记忆与服务端排序有明确边界。** 当前先读取本地偏好，再请求服务；成功响应替换 `layout.entries` 的行排序，失败保留本地。组顺序、置顶与折叠不由 `api/demos` 返回。需要验收“有服务”与“无服务”两种重启结果，不能只测离线记忆。
- `restore()` 已对 `groups / entries / pinned` 去重；模型回归覆盖重复旧偏好与不完整旧顺序，不把损坏数据渲染成重复条目。

## 五、<span id="floating-assets">首页悬浮控件</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

> 以下四项均为当前工作区新增骨架，原首页基线没有这些控件；专项 Widget 测试不等于实体手机传感器、音频和触觉已验证。

| 控件 | 默认与操作 | 状态／资源 |
| --- | --- | --- |
| 悬浮时间 | 蓝底；真实字体／语言／缩放测量，左右16／上下10留白及2像素字形余量，受安全区限制；默认显示、每秒刷新；短按push世界时钟，长按进入拖动、释放吸边；设置显隐 | 自适应与新手势源码已实现；8项专项含80种尺寸组合通过；最终整包／实际界面另计；`showClock`键保留，旧长按隐藏语义 superseded |
| 左下“按” | 紫色 `50×50`；短按宿主列表顶／底切换、播放声音与轻触觉；长按放大到 `1.18`，显示 `1.2s` 导火索环进度 | 本地 `assets/Sounds/spin.mp3`；释放／取消归零，长按不会兼触发短按 |
| 右下旋转计时 | 橙色 `50×50`；默认旋转与秒数计时；点击同时暂停／继续；长按提示 | `Stopwatch` 表达活动经过时间；减少动态效果时停止旋转；非首页／后台暂停 |
| Bug 入口 | `50×50`，默认隐藏；控制器或 `shake` 事件恢复；长按隐藏；点击调试面板或宿主回调 | `assets/Images/JobsDebugPanelButton.png`，原生既有 Ant Design 资源；拖动位置在本次组件存活期间保留 |

此前固定 `166×66` 是历史实现，不能继续作为当前 Flutter 时钟尺寸合同。用户已确认同一自适应要求同步到 OC 新旧／Swift UIKit／SwiftUI；各端实现与最终构建／实际界面分别回填，不从 Flutter 结论外推。仅尺寸调整不新增偏好键，拖动位置仍不跨启动保存；世界页格式选择的新键另见下文。

### 5.1、<span id="world-clock-contract">世界时钟骨架新需求（2026-11-16）</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 适用 Flutter、OC 两工程、Swift UIKit、SwiftUI；SwiftUI 核查缺首页悬浮时间后须补齐。需求状态为用户已确认，本次按先登记、再实现、再验收执行；以下保留需求合同，当前源码及验证状态另列。
- 首页悬浮时间默认显示，按实际文字、语言、字号和安全区测量并留内边距。短按以普通导航栈 push“世界时钟”页，返回原首页及原布局；长按进入拖动，释放吸边，不兼触发短按。此前“短按提示／长按确认隐藏”由此替代，显隐仍由设置控制。
- 当前设备时区单列置顶，显示系统提供的时区名称／标识、UTC 偏移、当地完整日期、星期和默认24小时制时分秒；12小时制由下述开关切换。其余时区以同一瞬间的有效 UTC 偏移分组，每个偏移选一处知名城市或地区代表，巴黎、纽约优先；包含30／45分钟偏移，不用24个整数时区代替全量实际偏移，不重复罗列 IANA 别名。
- 使用 IANA／系统时区规则随日期计算夏令时；偏移、日期、星期都按该地区当地时间计算。每秒读取当前绝对时间后转换，不累加秒数；跨午夜、夏令时和系统时区变化后重算。该页是设备时间的本地派生展示，不伪造远程授时成功。
- 仅页面可见且 App 在前台时计时；后台、被其它页面覆盖或退出后停止，恢复时立即刷新。十语言与三主题沿用骨架设置；窄屏与大字可滚动；异常／空数据沿用完整空态与重载。
- 这是骨架路由，不加入 Demo 注册列表、不增加条目数、不写 Demo 最近记录。首页主标题五端统一“功能实验室”；原生保留项目来源副标题，Flutter 补 `JobsFlutterBaseConfigDemo`。
- 追加确认：世界页用“12小时制”开关切换并立即刷新全部时区行，关为默认24小时，开为12小时并明确显示大写 AM／PM；午夜为12 AM、中午为12 PM。世界页单独持久化该选择，首页浮钟保持原24小时；切换保持当前页面及滚动位置，Flutter 同步发送骨架偏好 PUT，离线保留本地选择。
- 验收分别记录时区覆盖／去重、纽约和巴黎冬夏令时、30／45分钟、跨日期星期、短按导航／长按拖动互斥、前后台计时和返回恢复、十语三主题与安全区尺寸；构建通过不能替代实际界面验收。

当前实现：既有 `timezone` 全量IANA数据按同一瞬间重算全球偏移，范围−12至+14；稀有偏移使用当地实际地区，`Australia/Lord_Howe` 覆盖季节性+10:30。当前设备区通过 `DateTime.toLocal()` 展示系统区名及偏移，不将CST等缩写猜成唯一IANA标识。世界页普通路由前台可见才计时；藏文日期用本地公历字段／星期，九语使用Intl；异常完整空态可重载。`hub.worldClock12Hour` 与宿主PUT已接通，读取完成前用户已操作时不以迟到旧偏好覆盖选择。默认24小时，12小时统一大写AM／PM。

四种控件都可在安全区域内全屏拖动，释放吸附距离最近的左／右／上／下边缘；时间按钮需先长按，另外三项沿用普通拖动。隐藏用保留状态方式，界面每秒刷新或短暂离开首页不会重建拖动位置；**拖动位置当前不写入永久偏好，重启会回初始位置**。

摇动监听单独使用 `shake.start / shake.stop`，不借用通用运动 Demo 的通道；串行派发避免快速切页时出现迟到的 start。当前 Widget 测试使用 mock 平台消息，真实 [**iOS**](https://developer.apple.com/ios/)／[**Android**](https://developer.android.com/) 加速度计、摇动阈值与音量设备仍需真机验收。

主设置已接入 `HomeFloatingController.showDebugEntry()`：点击“调试工具”恢复入口并返回首页，供无传感器的桌面／Web 与模拟器使用；摇动监听与通用 motion Demo 独立。

## 六、<span id="settings-assets">设置、十语言、主题与持久化键</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### <span id="jobs-toc-heading-14" data-jobs-toc="v2">6.1、设置资产 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

- `JobsDemoSettings` 是 `ChangeNotifier`，通过 `JobsDemoScope` 向主 App 和子路由传播。主 App 用 `GetMaterialApp` 响应设置，独立预览用 `JobsDemoApp`。
- 三主题是跟随系统／白天／黑夜，默认跟随系统；公共主题使用语义 `ColorScheme`，同时提供藏文字体回退资源。
- 十语为简体中文／繁体中文／藏文／英文／日文／法文／西班牙文／德文／俄文／韩文；默认简体中文。系统控件没有藏语本地化时使用英语回退，不等于系统控件已有完整藏文译本。
- 主设置页面嵌入 `JobsDemoSettingsPanel`；新增 `JobsControlStyleSettings` 统一提供“全局控件样式 → 下拉刷新 → Flutter 默认／Jobs 封装”。选项切换立即传播，并保存枚举名。
- 同一区域提供“刷新触觉／刷新声音”两个独立开关，均默认开启、立即生效；它们只控制公共刷新反馈，不改变请求是否执行，也不接管首页其它悬浮控件的音效。
- 首页新增文案在 `home_strings.dart`、悬浮文案在 `home_floating_strings.dart`、世界页文案与代表城市在 `world_clock_strings.dart`；公共刷新阶段、结果及时间记录在 Foundation `refresh_strings.dart`，由公共词库注册。每条均十列，术语译法仍需母语人员校对。

### <span id="jobs-toc-heading-15" data-jobs-toc="v2">6.2、实际键与默认值 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 存储键 | 内容／默认 | 写入与恢复 |
| --- | --- | --- |
| `jobs_demo_theme` | `ThemeMode` 索引；`system` | 公共设置本地保存与恢复 |
| `jobs_demo_locale` | 语言标签；`zh` | 公共设置本地保存与恢复；无效值回简体中文 |
| `jobs_demo_refresh_style` | `flutter / jobs`；`flutter` | 当前新增；非法枚举名回 `flutter` |
| `jobs_demo_refresh_haptics` | 公共刷新触觉；`true` | `JobsDemoSettings` 本地保存与恢复；首页快照转发 `refreshHaptics` PUT |
| `jobs_demo_refresh_sound` | 公共刷新声音；`true` | `JobsDemoSettings` 本地保存与恢复；首页快照转发 `refreshSound` PUT；关闭立即停止正在播放的提示音 |
| `jobs_refresh.<historyKey>.refresh / .load` | 上次成功刷新／加载的本地毫秒时间；首次无记录 | 各角色成功后独立写入；失败／取消／销毁后的迟到回调不推进。未传historyKey只保留当前实例记录；首页按 `demo-hub.<filter.name>` 隔离 |
| `hub.favorites` | 原有收藏 ID 列表；原默认空 | 当前收藏入口与动作已移除；遗留键不主动删除，也不再读取、写入或 PUT `favorites` |
| `hub.recent` | 最近 ID，最多 30；空 | 普通目录／搜索／最近列表打开功能统一前插去重，本地与 PUT；启动恢复忽略未注册 ID；顺序不受布局记忆开关影响 |
| `hub.history` | 查询词，最多 20；空 | 提交／打开结果时前插去重，本地与 PUT |
| `hub.fullMenu` | 全宽开关；`false` | 本地与 PUT |
| `hub.pushMenu` | 平移开关；`true` | 当前新增；本地与 PUT |
| `hub.showClock` | 时间按钮；`true` | 当前新增；本地与 PUT |
| `hub.worldClock12Hour` | 世界时钟12小时制；`false`表示24小时 | 世界页本地保存，首页宿主转发 `worldClock12Hour` PUT；切换立即刷新，首页浮钟格式不变 |
| `hub.rememberLayout` | 布局记忆；`true` | 当前新增；本地与 PUT |
| `hub.layout.groups / entries / pinned / collapsed` | 四份布局；无偏好默认原注册顺序、无置顶、只展开首组；已存空collapsed表示全部展开 | 当前新增；记忆开启才本地保存，关闭移除；同时 PUT `layout` 快照 |

**设置写入：**首页监听统一 `JobsDemoSettings` 的主题、语言、刷新样式及刷新音震开关，按变化字段转发偏好 PUT；离线仍保留本地状态。成功时间是刷新组件自身的本地记录，不冒充服务器授时或偏好同步。公共设置面板可独立预览，服务转发由主应用宿主负责。

### 6.3、<span id="demo-actions">公共 Demo 主题与业务动作入口</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

`JobsDemoAppBar / JobsDemoActions / JobsDemoActionHost` 在保留原导航配置的同时统一右上入口。没有业务动作时直接显示主题按钮；已有清空、重试、撤销、播放等动作时收进唯一菜单，主题项排首位，原有回调、禁用状态与泛型菜单值保持。标题和图标按当前实际明暗显示“切换到黑夜／切换到白天”，点击通过既有 `JobsDemoSettings.setThemeMode()` 保存；“跟随系统”仍由完整设置面板选择，不新增另一份主题偏好。

嵌套 MaterialApp／CupertinoApp／GetX 容器绑定同一设置；已有捕获壳或工厂工具栏时，内层把业务动作交给外壳而不再叠放按钮。注册随路由更新、销毁移除；同页弹出菜单暂时覆盖路由时保留已注册动作，避免菜单销毁后丢失回调。主目录push、兼容入口与实际源码头部main均复用这一公共层，第三方或所有权不明源码不直接迁改。

2026-11-16实际目录300个builder逐项进入并操作主题，验证每页唯一入口及实际Material工具栏／Cupertino页面brightness，1个测试用例内覆盖300项，140秒通过；另保留299个旧ID快照并核查唯一性／完整集合，新增OCR的业务识别不在此验收范围。公共API6项、源码main2项、首页几何1项及旧业务菜单80＋85项回归分别通过，不能合并宣称成同一全仓轮次。

## 七、<span id="refresh-assets">三份刷新资产来源核查</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### <span id="jobs-toc-heading-18" data-jobs-toc="v2">7.1、现有封装与当前新增适配的差别 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

| 资产 | 原有内容与真实实现 | 当前状态 |
| --- | --- | --- |
| [JobsRefreshByPub／JobsRefresh.dart](../JobsByPubs/JobsRefreshByPub/lib/JobsRefresh.dart) | 既有导出分页控制器与列表；此前内部使用Material刷新 | 当前增加对Foundation的本地包依赖，仍保留分页入口，但复用同一边缘状态机、指示器、时间记录和反馈，不再维持互相独立的刷新实现 |
| [JobsRefreshLoadList](../JobsByPubs/JobsRefreshByPub/lib/src/jobs_refresh_load_list.dart) | 分页数据、触底加载、分隔、斑马纹、空态与尾部 | 当前经 `JobsAdaptiveRefresh` 接线；横纵、reverse、手动刷新／加载及触底加载共用互斥控制器；失败不提交页码或清空成功数据，销毁忽略迟到响应 |
| [Foundation／JobsEdgeRefresh](../JobsByPubs/JobsDemoFoundationByPub/lib/jobs_edge_refresh.dart) | 原有横／纵、首／尾边缘协议；阈值默认 `64` | 当前统一idle／pulling／ready／running／finishing，结果区分成功／失败／无更多；按实际AxisDirection处理reverse／RTL，提供分别成功时间、可重试与反馈事件 |
| [Foundation／JobsAdaptiveRefresh](../JobsByPubs/JobsDemoFoundationByPub/lib/src/adaptive_refresh.dart) | 全局默认Material／Jobs双球样式选择入口 | 当前接 `axis / onLoadMore / historyKey / controller / hasMore / reverseRoles / indicatorBuilder`；横向及反向角色使用边缘实现，普通纵向默认保留Material头部；两分支共用有界物理与状态模型 |
| [Foundation／JobsRefreshScrollPhysics](../JobsByPubs/JobsDemoFoundationByPub/lib/src/adaptive_refresh.dart) | `BouncingScrollPhysics` 的阻尼与弹簧回弹，最大越界120逻辑像素；配合始终可滚动，使短列表同样能跟手下拉 | 默认接入首页与普通刷新适配；专门教学页显式指定的物理保持自身语义。本批源码／验证状态见[限定验证](#validation) |

来源结论仍保留：旧 `JobsRefresh.dart` 只作为导出入口，不能以包名推断原先自带双球或七种动画。当前实现将原来分离的分页包接入Foundation；全局样式由Foundation负责，分页状态由JobsRefreshByPub负责，不复制来源不明的MJRefresh音频或其它资源。跨端参考、合同和本轮范围见[刷新交互与Demo公共入口资产盘点](./刷新交互与Demo公共入口资产盘点.md)。

### <span id="jobs-toc-heading-19" data-jobs-toc="v2">7.2、当前自适应控件的边界 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

- API 保留 `JobsAdaptiveRefresh(onRefresh:, child:)` 并追加轴、加载、历史键、外借控制器及角色映射；默认纵向／leading刷新，trailing仅在提供加载回调时启用；没有scope仍按默认样式。借用controller不由控件dispose。
- 首页列表与公共适配器使用 `JobsRefreshScrollPhysics`，在两种刷新样式下都让列表随手势移动、逐渐增加阻尼，并将越界位移限制在最大120逻辑像素；松手后弹簧回到边界，短列表同样可下拉。Material 默认刷新圈和 Jobs 双球／阶段文案均保留。
- Jobs分支支持横向或纵向两端，由实际 `AxisDirection` 决定屏幕对应边，覆盖reverse与RTL；`reverseRoles`可互换刷新／加载角色。只接收当前轴、depth为0的通知，垂直嵌套横向列表不误触外层；阈值未满释放取消，阈值达到并松手才执行，刷新与加载互斥。
- 指示区分别显示“上次刷新／上次加载”成功时间，首次明确无记录；持久键与角色分离，失败不推进，错误可重试；无更多只阻止继续加载，成功刷新能重置分页状态。请求成功才提交页码和数据，过期或销毁后的响应不改界面。
- 执行时为内容保留纵向76／横向112逻辑像素的指示区，随字号测量、上限120；适配器及分页包完成态保留350ms，再以250ms收回。底层控制器默认完成停留为0，可由调用方配置。物理越界上限仍为120，不把指示区大小误当触发阈值。
- 横向达到阈值后的指示内容按实际已腾出宽度布局，不再在约84区固定112；状态与完整历史自然换行组成整体，以 `FittedBox.scaleDown` 按剩余高度收敛，不用横向ellipsis截掉时分秒。纵向保留原2／3行及Flexible语义，阈值以下仍逐渐揭示。8种真实有限拖动场景使用120高视口与28图标，在ready持有、继续300ms及release运行态逐字验证HH:mm:ss的selection box非空、本地高度不越界及变换后位于ClipRect内。最终真实SDK冷包在约87／79pt两端ready持有时已实看完整状态与时间；限定简中浅色模拟器场景，不外推全语言／RTL／设备矩阵。
- 有效手动开始、成功、失败各派发一次音震反馈，自动初载安静；两个全局开关独立控制，全部关闭时连替代 `onFeedback` sink也不派发。后台、被覆盖路由或销毁不播放且不补放，关闭声音立即stop；平台通道或音频设备失败不影响请求与视觉状态。
- 声音来自包内三份Jobs原创16-bit／22050Hz单声道WAV，分别为 `refresh_started.wav / refresh_succeeded.wav / refresh_failed.wav`；`AssetSource`配合包资源前缀、音量0.3，iOS为ambient并允许混音。当前缓存的Darwin音频插件不支持BytesSource，已使用受支持的本地资源URL，不沿用早期字节播放方案。WAV波形和真实触觉平台通道调用已有专项验证，模拟器不代表真机听感或手感通过。
- 复用 `GlobalKey` 子树在两种实现切换时保持列表状态与滚动位置；缩短动态效果时双球保持静态拉动进度。
- 当前主首页已经调用该适配。若其它页面继续直接调用 `RefreshIndicator` 或自有第三方组件，设置不会自动改变它们；专门教学某实现的示例也不能用全局替换破坏教学内容。
- 当前 `JobsRefreshByPub` 正向依赖Foundation，Foundation不依赖分页包；复用既有audioplayers依赖，未改第三方插件源码。其它教学页显式使用的专门控件仍保留自身教学语义。

2026-11-16用户确认的跟手合同取代此前“目录固定不动”的处理：旧 `AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics())` 策略标为 superseded。旧批连续下拉1200px的固定位置断言只保留历史来源，不能证明当前跟手、限幅或回弹已验收。后续音震／成功时间升级增加上表所列偏好和历史键，但不改变刷新样式默认值或布局记忆生命周期；分组头移除按钮后，重排仍由原拖动／记忆逻辑承担。

## 八、<span id="api-lifecycle">API 回退与生命周期边界</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 位置 | 已有／当前行为 | 限制或待验 |
| --- | --- | --- |
| 首屏目录 | 本地构造完整注册目录，当前先加载本地偏好再 GET `api/demos`；成功只排序认识的 ID | 不远程构造任意页面；服务成功不会删掉本地未返回条目 |
| 网络边界 | 基址来自 `DEMO_API_BASE`，默认 `http://localhost:8080/`；900ms 可配置超时；非 200／解析失败返回空结果 | 项目不包含该后台；手机 localhost 是手机自身，不能据本地预览宣称服务部署完成 |
| 偏好 PUT | `api/demo-preferences/{key}`，请求体 `{"value":...}`；离线保留本地效果，下次写仍请求 | 无服务偏好读取 API、无失败队列补发、无 PUT 结果合并；全局设置宿主转发见[存储表](#settings-assets) |
| 重载竞争 | 请求代次忽略旧 GET；布局修订改变时忽略发起于旧布局的响应 | 当前并非用户布局与服务排序的完整版本合并协议 |
| 路由离开 | `visit()` 关闭侧栏、暂停首页浮控；返回恢复 | 程序其它路径直接推路由是否也维护活动状态，需要继续排查实际入口 |
| 悬浮资源 | 非 resumed 或非活动首页时隐藏并停 Timer／Stopwatch／旋转／导火索／摇动；销毁取消监听与释放音频 | 不持久化控件位置；真实摇动、音频和触觉待设备验收 |
| 公共设置释放 | 自有设置被独立壳销毁后，迟到的 SharedPreferences 初始化不会通知已销毁对象 | 借用 settings 由调用方管理，主 App 当前不自行 dispose 外部传入对象 |

用户报告的 `Reported frame time is older than the last one; clamping` 属于本任务另一路排查。候选帧调度实验未取得有效 A/B 证据，已从生产源码与测试移除，仅以文本附件保留；主入口仍调用标准 `WidgetsFlutterBinding.ensureInitialized()`。完整来源、已证实机制与未验证结论见[专项排查](./Flutter-iOS帧时间错误排查.md)，不能宣称日志已解决。

## 九、<span id="validation">验证记录与后续对齐清单</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### <span id="jobs-toc-heading-22" data-jobs-toc="v2">9.1、已完成的限定验证 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

下表按代码批次保留证据；2026-11-16各阶段分别记账，其它行保留各自当时范围，不自动覆盖当前滚动物理或源码入口。

**当前升级快照（2026-11-16）：**横向补丁前冻结主工程701＋Foundation25＝726项通过、1项既有skip、0失败（约188.1秒），分析0error／0warning／682info；300个builder在1case内全验。该阶段guarded OCR包构建通过（Pod187.3／Xcode230.8秒），A3前包4项功能通过但截图暴露84区固定112裁字；首宽度包构建通过（Pod11.9／Xcode129.1秒），实际1case／0失败／64.863秒仍在75pt trailing缺时间，保留失败。第二轮自然排字／整体缩放／无ellipsis经严格字形红→绿，刷新30＋旧组合6＋适配10＝46项通过、0失败，分析0error／0warning／8info。最终真实OCR SDK主包已冷编、核Kernel／源SHA／Rust符号bundle／三WAV并冻结，无热注入、不用guarded。该新包A3模拟器真实触点1case／0失败／62.438秒，约87pt leading与79pt trailing的ready状态、完整HH:mm:ss均实看通过，2刷新／2加载、原菜单清空回调及默认恢复通过；冷启留新包首页。726全仓、46定向及这1case分别记账，不外推全部语言／RTL／设备或真机音震；更早662项／51.5秒继续保留历史。

| 范围 | 证据 | 实际结论 |
| --- | --- | --- |
| 侧栏公共组件首批 | [side_menu_test.dart](../JobsByPubs/JobsDemoFoundationByPub/test/side_menu_test.dart) | 当批9项通过：原覆盖行为、边缘手势、短拖、遮罩／返回、禁用、半／全宽 push 边界连续与整页尺寸保持 |
| 全局刷新首批 | [adaptive_refresh_test.dart](../JobsByPubs/JobsDemoFoundationByPub/test/adaptive_refresh_test.dart) | 当批6项通过：设置跨实例恢复、非法值回退、实际实现切换且保留滚动、两种物理短列表、去重／顶部限定、十语完整性；不代替下述跟手刷新阶段与最终验证 |
| 既有相关回归 | `legacy_extra_combinations_test.dart`、`ui_parity_test.dart`、`ui_parity_details_test.dart`、`settings_initialization_lifecycle_test.dart` | 本轮一次 102 项通过；覆盖原横纵边缘请求、UI主题／大字适配、初始化释放等，不计为 102 项骨架独立功能 |
| 悬浮层首批专项 | [home_floating_controls_test.dart](../test/home_floating_controls_test.dart) | 当批代理报告6项通过：拖动吸边、时钟隐藏、长按吞短按、旋转／后台、Bug消息恢复、十语；旧时钟长按隐藏语义已由世界页需求替代；平台通道为mock，当前8项另列 |
| 静态检查 | 公共变更文件限定 `flutter analyze --no-pub --no-fatal-infos` | 检查时无 error／warning，保留 SDK 导入弃用 info；末次距离类型修复已重新编译运行公共 15 项测试 |
| 首页综合回归 | [demo_hub_test.dart](../test/demo_hub_test.dart) | 此前骨架批次全仓 556 项通过，包含独占搜索、置顶、真实组拖动、记忆开关重启、设置 PUT、布局损坏保护与悬浮层专项；公共包另有 15 项通过，共 571 项，不覆盖下述本批调整 |
| 搜索空态居中增量 | [demo_hub_test.dart](../test/demo_hub_test.dart) | 本批首页 8 项回归通过；其中几何断言覆盖 `402×874＋键盘320`、`874×402＋键盘180＋文字1.6倍` 两种布局下的无历史／无结果空态：宽度等于可用页面宽，图标／标题／说明／操作按钮与页面中心轴一致，高度不足可滚到重新加载；不外推为本批重新全跑全仓或实体画面验收 |
| 2026-11-15最近使用／收藏移除／下拉边界旧批 | [demo_hub_test.dart](../test/demo_hub_test.dart)、[legacy_extra_combinations_test.dart](../test/legacy_extra_combinations_test.dart)、[adaptive_refresh_test.dart](../JobsByPubs/JobsDemoFoundationByPub/test/adaptive_refresh_test.dart) | 首页10项＋既有边缘组合6项、公共组件15项通过，共限定31项；连续下拉1200px断言当时iOS Material／Jobs目录固定不动，该物理策略已superseded；搜索打开后最近记录去重与重启、收藏入口／菜单项移除结果保留，不外推当前跟手或全仓重新验收 |
| 2026-11-15旧批 iOS 构建与启动 | 主入口 iOS Simulator debug | 构建通过（276.6秒），新版重新安装启动后已观察到首页；重连后AX确认侧栏无收藏、最近空态与重新加载、行菜单仅源码位置／复制运行命令。真实长下拉仍未验：多次输入返回 `noWindowsAvailable`，一次坐标动作返回成功但无法确认落到手机内容，不计为通过；不作为当前滚动物理的构建结果 |
| 2026-11-16跟手刷新与组头简化阶段 | 首页、公共刷新与其限定测试 | 首页10项＋既有边缘组合6项、公共组件19项，共35项通过；4文件限定分析无error／warning，8项info；iOS Simulator debug阶段构建通过（87.1秒）。组头无移动菜单、保留拖动；Material／Jobs列表跟手、最大120逻辑像素越界及松手回弹，拖动与惯性阶段均有限幅。当阶段尚未实触，后续补验见最终记录；随后追加功能语义与源码头部入口迁移，须另验最终包，不能沿用这35项或87.1秒阶段包。上方31项及276.6秒保留为旧物理策略历史批次 |
| 2026-11-16功能语义与源码头部迁移阶段 | 目录、catalog、实际main与兼容入口；[本轮验收记录](./验收记录/2026-11-16.json) | 源码与路径核查已落地，189 ID不变；300主／独立运行文件与175兼容入口分列，原main初始化语义、三份生成part保持。胶囊实际源码iOS目标构建49.0秒通过，安装启动后真实点击“7日内”使内容由1切到3；胶囊与拖动main专项2项通过。阶段中待补的全仓／整包已由下一行完成，不从胶囊实测外推其它独立目标全部实测 |
| 2026-11-16最终追加批次 | 全仓 `flutter test --no-pub`、`dart analyze lib test`、主入口iOS debug；[当前验收记录](./验收记录/2026-11-16.json) | 最终全仓662项通过、1项既有截图测试默认跳过；分析0error／0warning、619info；iOS Simulator debug构建51.5秒通过并重新安装启动。包含命名／源码头部入口、自适应浮钟、世界时钟与12h开关；悬浮专项8项含80布局组合，世界页6项覆盖DST／跨日星期／十语明暗大字／生命周期／格式记忆与滚动保留 |
| 最终包限定实际界面 | iPhone18Pro／iOS27.2，Device Hub AX与截图 | 首页“功能实验室＋来源副标题”、窄化浮钟实看；短按push世界页，本地区及跨日代表的UTC偏移／日期星期显示；开12h立即显示PM、返回重进保持开启、关闭恢复24h、返回保留首页与299项数量已验。随后原生触控验证补齐如下；完整语言主题画面与真机仍待验 |
| 最终包原生触控：浮钟与世界页 | 原应用未加探针，原生UI测试1项、0失败、14.506秒；[验收明细](./验收记录/2026-11-16.json) | 三次长按拖至右侧／底部／导航栏区域不误push；导航栏区域短按仍能打开世界页；12／24小时实际开关、返回位置与计时更新后位置保持，共7类有效动作；不把自动化断言数写成测试数 |
| 最终包原生触控：长拉与松手 | 同一默认Material样式，两次实际长拉持有／释放测试各1项、0失败，15.520秒与42.226秒；录像末帧逐张实看 | 自动断言对象为首个Demo行“侧滑菜单”的释放归位，未误称组头断言；录像显示收起组头在持有1.2秒时随列表下移约74逻辑像素，释放后归位，无原图大段空白。Jobs样式限幅／回弹由Widget覆盖，未另做实际触控 |
| 2026-11-16刷新升级专项 | [jobs_refresh_upgrade_test.dart](../test/jobs_refresh_upgrade_test.dart)、既有边缘组合及公共适配测试 | 新29项通过：横纵×reverse×RTL×两端共16实际手势组合、短列表／嵌套过滤／保留区／回弹、成功时间与持久化、失败重试／无更多／互斥／销毁、分页防竞争、反馈开关／后台、真实触觉平台通道调用、三WAV、十语明暗大字；既有6＋10项另轮通过。不把mock／sink或平台调用当作真实声音触觉验收 |
| 2026-11-16公共动作与当前目录 | [公共API测试](../JobsByPubs/JobsDemoFoundationByPub/test/demo_app_bar_test.dart)、[全目录测试](../test/demo_toolbar_coverage_test.dart)、[299ID基线](../test/fixtures/demo_toolbar_baseline_2026_11_16.json) | API6项通过，含原业务回调／禁用／泛型菜单、路由覆盖与返回、同页Popup动作存活、Cupertino及十语大字；最新目录300 builder在1case内逐项验证唯一入口、点击后的真实页面brightness与完整ID集合，140秒通过。OCR只验公共接线，识别能力归其owner盘点 |
| 2026-11-16首页与旧动作回归 | [首页卡片几何](../test/demo_home_cards_test.dart)、[源码main](../test/source_entry_test.dart)、现有业务测试 | 首页卡片1项与源码main2项通过；原业务菜单80＋85项分别通过，按实际“更多→业务动作”路径保留清空／重试／撤销等原断言；不等同于一轮全仓总数 |
| 2026-11-16开屏与浮钟生命周期 | [splash_floating_gate_test.dart](../test/splash_floating_gate_test.dart)、悬浮8项及世界页6项 | 新开屏路由门禁1项、原浮钟8项和世界页6项重新通过；覆盖开屏／覆盖路由隐藏与返回恢复。实际最新包开屏触控与完整设备矩阵待验 |
| 2026-11-16横向宽度补丁前冻结全仓 | 主工程 `flutter test --no-pub`、Foundation测试及 `dart analyze lib test` | 主工程701＋公共25＝726项通过、1项既有skip、0失败；主工程约188.1秒；分析0error／0warning／682info。包括当前目录300 builder的1case完整遍历；补丁后专项另列，OCR业务识别不因公共接线通过而视为完成 |
| 2026-11-16 A3前包实际功能 | 原生UI Runner，正常App真实触点，4case／0失败 | 首页卡片5.649秒、Jobs纵向拉动＋独占搜索21.157秒、横向两端＋唯一动作菜单34.577秒、偏好恢复9.296秒。横向ready约84区截图发现原固定112指示器裁字，虽功能断言通过，该帧视觉明确未过；不能把4项通过扩写为横向画面无问题 |
| 2026-11-16横向有限揭示宽回归 | [jobs_refresh_upgrade_test.dart](../test/jobs_refresh_upgrade_test.dart)，真实pointer分步拖动 | 补丁前复现112宽超出约79.14揭示区；首补丁后原29＋新增1case＝30项通过，两端×reverse×LTR／RTL8组合检查布局box在ClipRect内、结束归位；当轮分析0error／0warning／7info。只验box未能证明内部字形完整，后续120高真实场景已发现高度缺口，见下一轮 |
| 2026-11-16首个横向宽度包实触 | 冻结宽度包原生UI Runner，A3，1case／0失败／64.863秒 | 功能链通过，但实看leading约89pt ready完整、trailing约75pt只显示“上次加载／今天”，时分秒未绘制；明确不记视觉通过，继续保留两态真实帧及失败原因 |
| 2026-11-16横向完整字形回归 | 同一[升级测试](../test/jobs_refresh_upgrade_test.dart)，120高视口＋28图标，1case内8手势组合 | 先复现时间glyph bottom45.635超过Paragraph高35.5；自然排字后仍ellipsis时首时间glyph box为空，再改横向无ellipsis。最终逐字框／局部高／缩放后四边严格断言不放宽，30＋旧组合6＋适配10＝46项通过、0失败；分析0error／0warning／8info。真实SDK新包随后冷编及限定实际字形验收通过，见下两行 |
| 2026-11-16完整字形真实SDK冷包 | 官方 `--config-only` 10.5秒后，Xcode使用已缓存SourcePackages及jobs1；任务产物 `ios-height-true-sdk-cached-jobs1-build.log / flutter-height-final-package-proof.json` | BUILD SUCCEEDED并冻结 `flutter-final-height-true-sdk.app`。源App在 `build/ios/Debug-iphonesimulator/`；canonical `build/ios/iphonesimulator/`仍是宽度旧包，未用来验收。Kernel／责任源SHA已核且非热注入；Rust真实核心recognize／version符号、资源bundle在包，三WAV与既有解码证据一致；最低可用6.633GiB未触门禁 |
| 2026-11-16最终真实SDK新包限定实触 | A3，`HorizontalHeightTrueSDKFinal.xcresult`，1case／0失败／62.438秒 | 2刷新／2加载、释放归位及原菜单清空callback通过；约87pt leading／79pt trailing实际ready持有，分别实看“松开刷新／加载”与完整20:19:22／20:19:41，无卡片或高度裁字，未拿running帧替代。恢复Flutter默认样式／system主题／首组展开并冷启留新包首页。限简中浅色iPhone18Pro／iOS27.2模拟器，不代表全部RTL／语言／设备／真机矩阵 |

冷包构建失败历史保留：手动首轮漏传当前Flutter SDK所需 `-clonedSourcePackagesDirPath`，在远程SPM解析等待约15分钟后精确TERM、exit1；没有进入有效目标编译，不计成功。修正为工程缓存 `build/ios/SourcePackages` 后的jobs1冷编才是上述成功包，不能沿用canonical目录里的旧Kernel冒充当前产物。

原生触控的本机验收附件在任务产物目录 `adaptive-clock/flutter-physical/`：`clock-ui.log`、`pull-ui.log`、`pull-header-ui.log`、`pull-header-hold-full.mp4`，以及已实看的`pull-frame-42.3.png`／`pull-frame-43.3.png`。原始进程日志分场景保存，三份目标帧时间错误计数均为0；只证明这些有限动作没有复现，不能写成引擎问题已修复。用户清理模拟器后已按明确要求重建共享iPhone18Pro／iOS27.2，保留供后续使用。

设备交接补记：上段及早期完整触控属于旧609设备历史证据；该设备及沙盒随后被用户授权的其它任务清理。当前共享设备为新A3（`JobsDemoSharedFinal3`），本轮前包4case从新环境实际执行；旧偏好落盘、世界页和609截图不代表A3当前状态。当前目录为300，新增OCR只纳入公共骨架入口验证，其识别业务仍见独立OCR盘点。

搜索空态本批另完成公共组件15项回归（合计限定23项）、iOS Simulator debug构建（30.8秒），已安装到当前iPhone18Pro／iOS27.2模拟器并实看键盘上方无历史空态居中。限定分析无error／warning，保留2项SDK导入弃用info；不外推真机验收。结果追加到[验收记录](./验收记录/2026-11-15.json)的`searchEmptyAlignment`字段，先前全仓批次保留。

历史文档记录的 2026-11-14 全仓 545＋公共 5 项、Web／Android／iOS 构建属于**原有验收基线**，不自动覆盖本轮新增骨架。本轮主目标 iOS Simulator debug 与 Android debug APK 构建通过；iPhone18Pro／iOS27.2模拟器实测三项菜单、独占搜索／取消恢复、半屏平移连缝与全局刷新选择。实际输入关键词的UI工具未成功，匹配结果由Widget用例验证。半／全宽与刷新样式已恢复实测前偏好；最后返回首页动作遇Mac锁屏，未将该动作记为通过。真机摇动、音频／触觉、长组跨屏拖放与帧时间错误继续保留待验。

此前骨架批次限定结果见[验收记录](./验收记录/2026-11-15.json)：当批全仓静态分析无 error／warning，保留 819 项 info（主要为 SDK 导入弃用提示）；测试 556＋15 共 571 项通过。当批末次 UI 细化后重新构建 iOS 主入口；Android 构建包含原生独立 shake。2026-11-15最近使用、收藏移除和旧下拉边界另列限定31项回归、iOS构建与启动观察；2026-11-16组头简化与跟手刷新另计，实触结果见上方最终包记录，不沿用此前结果作为当前全批结论。

### <span id="jobs-toc-heading-23" data-jobs-toc="v2">9.2、依据盘点继续处理的顺序 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a></span><!-- jobs-toc:heading-end -->

- 对照三份原生资产，确定右上按钮／菜单项目、搜索页、侧栏联动、置顶和悬浮控件的实际共同合同。
- Foundation与分页包现已统一模型，后续仍按组件角色区分：继续验证真实音量／静音／触觉、横向两端与大字实际画面，不以29项专项或模拟器通道调用外推真机感受。
- 本轮已按盘点补齐设置服务写入、无传感器 Bug 手动恢复（设置点击后返回首页显示入口）和重复置顶偏好保护；最近使用本批收口为独立始终展开、只按打开时间排序，取消手工拖排，并移除收藏入口与动作。后续继续按统一对照表核查其它骨架资产。
- 在长组与真实触控中核对拖动自动滚屏、拖动最终落点、关闭记忆重启、服务恢复后的排序规则；置顶同时验收列表顶部位置与用户可见反馈。
- 运行最终整体分析／测试／目标平台编译，保留真实 iOS 触摸帧日志；实体摇动、声音与触觉按实际设备记录，未验证项保持明确状态。

本文作为盘点快照保留已有未提交实现和测试，不宣称全部补齐完成。

## 十、<span id="mixed-script-source-20261117">中英混排核心与源码状态</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

当前[iOS 随仓源码](<../JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/Source/JobsOCR>)和[MacOS 随仓源码](<../JobsByPubs/JobsRustOCRByPub/macos/JobsRustOCR/Source/JobsOCR>)已同步本机验收通过的中英混排路由，包含 `pipeline.rs`、`runtime.rs`、`lib.rs`、`routing.rs`、独立 E2E 测试和 `MixedScript` 夹具。核心常规测试 30 项、显式 E2E 1 项覆盖 8 张真实夹具（其中 4 张精确逐行控制）通过；范围与证据见[共享核心回归记录](<../../../OCR/项目相关报告/混排回归/README.md>)。

本状态确认核心本机回归及随仓源码一致；本宿主尚未使用此次新核心重编、运行，原有 35 行样本／界面／Workflow 记录仍限原批次。使用新核心前先运行[SDK 本地构建入口](<../JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/Scripts/BuildRustOCR.command>)，源码输入哈希变化会使旧库缓存失效；保留本地构建方式，不分发自建 `.a`。显式 E2E 需指定本机 ORT 与随 SDK 的模型目录。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
