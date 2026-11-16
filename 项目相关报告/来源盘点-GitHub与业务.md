# GitHub 客户端与业务案例蒸馏盘点

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、运行边界与缺失依赖事实](#dependency)
- [二、GSY GitHub：可观察产品模块与数据链](#github)
- [三、51 与 SG：业务模式、真实边界与去耦](#business)
- [四、与目标现有能力的差集](#coverage)
- [五、建议独立重写的可验收方案](#proposal)
- [六、实现与验收约束](#implementation)
- [七、四项实际实现、资产与验证](#delivered)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

来源核对日期：2026-11-15；实现回填日期：2026-11-16。本文只读分析同一 GitHub 工作目录下的 `gsy_github_app_flutter`、`FlutterDemo/51`、`FlutterDemo/SG`，已在目标工程独立重写并加入“代码变更审阅、实时报价确认、通知处理收件箱、多来源额度归集”四项 Demo，实际入口与资产状态见[第七节](#delivered)。来源 App 的账户、商业后台、品牌、私有接口和整套依赖未迁移，也未运行来源 App。第五节保留最初候选与取舍，候选中的扩展点不自动等于已实现能力。

目标项目先使用现有 CodeGraph 定位目录与相关实现，再核对注册目录和页面；来源没有索引，使用文本与文件读取，没有初始化索引、运行依赖安装、升级来源 SDK 或修改来源源码。OAuth 材料只核对文件存在，没有读取内容；本报告不包含凭据或后台连接配置。

## 一、<span id="dependency">运行边界与缺失依赖事实</span> <a href="#前言">🔼</a>

| 来源 | 已核对事实 | 对蒸馏的影响 |
| --- | --- | --- |
| [GSY GitHub](../../../gsy_github_app_flutter/pubspec.yaml) | `environment.sdk >=3.13.0 <4.0.0`；[FVM](../../../gsy_github_app_flutter/.fvmrc) 为 `3.47.9`。两个 `vendor/flutter_performance_monitor/packages/` 本地包的 pubspec 都存在。`lib/common/config/ignoreConfig.dart` 存在，内容未读；[协作说明](../../../gsy_github_app_flutter/AGENTS.md) 明示 OAuth 依赖本地材料。仓库 [LICENSE](../../../gsy_github_app_flutter/LICENSE) 为 Apache-2.0。 | 没有依据把本地 telemetry 包称为“缺失私库”。真实授权、GraphQL/REST 与 App 能否完整启动，本轮未验证。独立 Demo 使用新写模型与样例，不复制 vendor、生成源码或 OAuth 配置。 |
| [51](../../../FlutterDemo/51/pubspec.yaml) | Dart `>=3.4.3 <4.0.0`；声明 `htprotect: path: ./plugins/htprotect`，该路径下 pubspec 不存在。[app_manager.dart](../../../FlutterDemo/51/lib/utils/app_manager.dart) 第15行实际 import 该包，不只是无关声明。 | 原工程不能被当作依赖完整、可直接复用的模块。缺失是本地包材料，不是业务交互无法独立实现的证明；不移除原依赖、不伪造插件、不修改来源。 |
| [SG](../../../FlutterDemo/SG/pubspec.yaml) | Dart `>=2.19.6 <3.0.0`；[FVM](../../../FlutterDemo/SG/.fvmrc) 为 `3.7.12`。`plugin/flutter_facebook_app_events/pubspec.yaml` 存在。 | 与目标 Dart3.14 不兼容的是来源约束及旧依赖体系，不能直接整包搬入。没有证据把已存在 Facebook 本地包称为“缺失私库”；也没有验证其完整原生功能。 |

来源中的接口层、租户配置、上传服务、推送、第三方游戏 / 赛事服务属于外部运行条件，不等于所有产品体验都必须依赖它们。目标保持已有 Flutter stable / Dart3.14 基线，本次不尝试通过更换来源 SDK 证明兼容。

## 二、<span id="github">GSY GitHub：可观察产品模块与数据链</span> <a href="#前言">🔼</a>

下表行号对应本次读取，使用实际导航方法和状态边界，不用 README 截图替代源码事实。

| 模块与进入路径 | 已观察到的实现 | 值得提取的模式与边界 |
| --- | --- | --- |
| 仓库详情 → 文件 tab → 文件 / 目录；`NavigatorUtils.goReposDetail` | [repository_file_list_page.dart](../../../gsy_github_app_flutter/lib/page/repos/repository_file_list_page.dart) 第37行用 Signals 保存文件和面包屑，第83行水平面包屑，第204行切分支后 `resetToRoot`，第247行 PopScope 优先返回上层目录。[repos_detail_provider.dart](../../../gsy_github_app_flutter/lib/page/repos/provider/repos_detail_provider.dart) 第60行起维护分支与用户主动选择标记；服务端默认分支不会覆盖手选分支。 | “仓库版本 → 路径 → 文件内容”联合上下文，而不是通用树组件。切分支时旧路径不保证存在，需原子重置 / 恢复策略。 |
| 仓库 README 的本地命中与远端更新 | [repos_repository.dart](../../../gsy_github_app_flutter/lib/common/repositories/repos_repository.dart) 第585–617行，缓存以仓库和 branch 为输入，命中后返回 `DataResult(..., next: next)` 再请求网络；[repos_detail_provider.dart](../../../gsy_github_app_flutter/lib/page/repos/provider/repos_detail_provider.dart) 消费初值和 next。 | 可以提取“快速旧快照 + 后续权威响应”的交互，但目标已经有 API 优先 / 演示回退，不能再建设第二套全局缓存框架。 |
| PR详情 → 变更文件；`goPullRequestFiles` 路由名 `pr-files/<owner>/<repo>/<number>` | [navigator_utils.dart](../../../gsy_github_app_flutter/lib/common/utils/navigator_utils.dart) 第302行；[pull_request_files_page.dart](../../../gsy_github_app_flutter/lib/page/issue/pull_request_files_page.dart) 第89行起 `Future.wait` 拉 files、REST comments、GraphQL threads，评论按 path 分组，再通过 comment databaseId 关联 thread ID / resolved 状态；翻页文件不重复拉评论。 | 文件、patch、行级讨论和线程状态的多数据源关联；线程请求失败不阻断已经取得的评论。是本次最有独立教学价值的闭环。 |
| 变更文件 → diff阅读 → 行评论折叠 / resolve | 同文件第168行 `_openDiff` 防止重复点击，异步生成 HTML 后检查来源 route 仍 current；旧评论 line=null 只在折叠区出现，不错误挂到当前代码行；[diff_html_renderer.dart](../../../gsy_github_app_flutter/lib/common/utils/diff_html_renderer.dart) 接收结构化 patch 与行评论。 | 新写原生 Dart diff / hunk 视图即可，无需复制第三方 HTML、高亮库或 WebView。手动行定位、过时线程、已解决 / 未解决切换，比现有 Markdown / 评论树多出明确语义。 |
| Issue / PR 时间线 | [issue_detail_page.dart](../../../gsy_github_app_flutter/lib/page/issue/issue_detail_page.dart) 第156–218行，评论与非commented事件合并、按时间排序，本地与 next 网络响应都装饰时间线，避免重复评论或刷新后事件消失。 | 时间线应保留稳定事件ID、未知事件兜底、空时间排序与幂等合并；适合并入审阅工作台，不需另做纯时间线壳。 |
| 抽屉 → 通知；`goNotifyPage` 路由名 `notify` | [notify_page.dart](../../../gsy_github_app_flutter/lib/page/notify/notify_page.dart) 第44–56行分别保存列表、页码、仓库与 reason 筛选；两筛选 AND 组合；第104行侧滑提供已读 / 订阅 / 归档；第376行成功后才移除已读项，失败保留。仓库 / reason 仅筛已经加载的数据，不假装服务端全量搜索。 | 值得独立“通知处理收件箱”：阅读状态、归档状态、订阅状态应分开，不把三种操作合成删除；筛选来源、加载范围和失败恢复可被看见。原代码注释对切tab保留 / 重置存在不一致，以第69行 effect 实际重置为准。 |
| 搜索 → 仓库 / 用户 / issue / code → 分页结果 | [search_bloc.dart](../../../gsy_github_app_flutter/lib/page/search/search_bloc.dart) 第13行 `SearchRequest` 保存提交时 query / type / sort / language / page；`forPage` 继承原请求，第80行成功第一页才保存历史。[search_history_repository.dart](../../../gsy_github_app_flutter/lib/common/repositories/search_history_repository.dart) 第29行去重前移、有界保留。 | 搜索的实质价值是请求快照与分页归属，不是再做历史标签。可以并入仓库浏览工作台，验证输入改动和晚响应不会污染旧结果。 |
| 宽屏列表 → 右列详情 → 子详情 → 返回 | [gsy_adaptive_shell.dart](../../../gsy_github_app_flutter/lib/common/style/gsy_adaptive_shell.dart) 第113–168行定义统一双栏判断、右列独立 Navigator、详情 pop Future 与全屏偏好；[navigator_utils.dart](../../../gsy_github_app_flutter/lib/common/utils/navigator_utils.dart) 第273行搜索与第302行PR files 都走同一适配出口。 | 可在审阅工作台实现单 / 双栏同义重组，保留左列表滚动和右侧独立返回栈，不复制来源复杂全局路由。目标首页侧栏不等同该详情导航。 |
| 用户资料 → 贡献日历 | [user_contribution_calendar.dart](../../../gsy_github_app_flutter/lib/page/user/widget/user_contribution_calendar.dart) 第23行 Riverpod async 分支，52周×7日格，横滚最新周，tap tooltip展示日期 / 数量；非静态SVG。[user_contribution_provider.dart](../../../gsy_github_app_flutter/lib/page/user/user_contribution_provider.dart) 提供结构化数据。 | 可用本地365日事件生成活动热图，但只有 tooltip 的版本价值偏低；如实施，应增加日 / 周统计、可访问选中、筛选与日期详情。列为后续项，不先占一个低交互入口。 |

不继承来源 Redux / Riverpod / Provider / Signals 混搭，也不在真实 GitHub 仓库造 issue、评论或 reaction。业务借鉴不需要登录源 App。

## 三、<span id="business">51 与 SG：业务模式、真实边界与去耦</span> <a href="#前言">🔼</a>

| 来源模块 / 路径 | 真实源码证据 | 提取判断 |
| --- | --- | --- |
| 51：`/find_balance` → 分类余额 → 回收 | [app_pages.dart](../../../FlutterDemo/51/lib/app/routes/app_pages.dart) 第303行注册 `FindBalanceView` / Controller；[find_balance_controller.dart](../../../FlutterDemo/51/lib/app/modules/user/controllers/find_balance_controller.dart) 第34行请求余额源列表，第47行按分类过滤，第138行主余额刷新，第158行拼当前列表正余额 playIds 后一次 `findMoney2`，返回整体 bool，再刷新列表和主余额。 | 分类 / 选定来源 / 主账户结果的闭环有价值。必须区分：原实现没有逐来源重试、取消或部分成功协议，不能把这些改良写成原能力。[find_balance_view.dart](../../../FlutterDemo/51/lib/app/modules/user/views/find_balance_view.dart) 第99行列表点击只打印，不可当作单项回收已实现。 |
| 51：`/funding_details` → 类型 / 时间筛选 → 流水分页 | [funding_details_controller.dart](../../../FlutterDemo/51/lib/app/modules/user/controllers/funding_details_controller.dart) 第26行一级类型、第40行二级类型、第77行时间段；第143行映射请求类型，第154行重置第一页，第162行按每页10项推断更多并追加。 | 可提取有维度语义的账目筛选 / 分页，但不能照搬硬编码“长度=10就是还有更多”作为通用契约。可并入额度归集结果账本，避免新增又一个列表页。 |
| 51：充值渠道驱动的动态字段 | [recharge_online_controller.dart](../../../FlutterDemo/51/lib/app/modules/wallet/controllers/recharge_online_controller.dart) 第60行币种，第66行渠道变化隐藏旧二维码，第106行请求配置，第119–138行分别处理 visible / required 字段矩阵。 | 动态表单目标已存在。只有加入“切渠道后无效二维码失效、字段依赖、提交快照、未完成凭证保留”的闭环才有新增价值。真实充值 / 上传 / 商户配置不迁移。 |
| 51：最近游戏 | [recent_games_util.dart](../../../FlutterDemo/51/lib/utils/recent_games_util.dart) 第6行把ID追加到 SharedPreferences 列表再转Set去重。 | 不能将其描述成完善的 LRU：没有显式容量上限，重复ID也未重新前移。目标已有搜索历史 / 最近访问，不另加该壳。 |
| 51：任务 / 活动 / VIP / 视频 / 代理 / 钱包域 | [app/modules](../../../FlutterDemo/51/lib/app/modules) 下实际存在相应 view / controller / data 分层；任务图标工具 [game_task_utils.dart](../../../FlutterDemo/51/lib/app/modules/activity/views/task/game_task_utils.dart) 依赖租户、游戏ID和远端图域。 | 目录存在只证明源码模块存在，不代表每个业务闭环已跑通。活动金额规则、游戏策略、会员收益和账户材料不迁移；通用登录、轮盘、媒体、表单已大量覆盖。 |
| SG：主菜单体育 / 注单 | [main/view.dart](../../../FlutterDemo/SG/lib/pages/main/view.dart) 第110行保存 `BettingPage` / `MessagePage`，第128行按 `MenuCode` 选择；另有 [routes.dart](../../../FlutterDemo/SG/lib/routes/routes.dart) 第342、375行注册相应页面。不能仅检查另一份 `app/routes/app_pages.dart` 就认定没有体育入口。 | 有效主线是“实时对象列表 → 选择 → 确认单 → 处理状态”，不是博彩品牌外壳。 |
| SG：实时赛事增量流与收藏筛选 | [sport/logic.dart](../../../FlutterDemo/SG/lib/pages/sport/logic.dart) 第152行20秒拉取、第161行1秒显示刷新；第167行监听 `sportData`，按分类把增量作用于滚动 / 热门 / 收藏 / 未来列表；第217行区分删除与更新；第237行销毁取消计时。 | 独立“实时列表合并”需要稳定ID、删除事件、筛选后状态一致与离屏清理，不能只滚动随机数字。可服务报价确认单的列表页。 |
| SG：实时报价 / 赔率接受策略 | [betting_sport_logic.dart](../../../FlutterDemo/SG/lib/pages/betting/sport/betting_sport_logic.dart) 第94行5秒更新；第395行三种接受策略；第731行按wid更新，比较旧新值；第762 / 768行按策略设置变化待确认。第808行统一检查报价、币种、暂停、数量、金额错误。 | 优先抽象成中性“实时报价确认单”。报价版本、已接受值与最新值分离；任意变化 / 仅有利变化 / 每次确认三策略可切换。确认结果只写本地样例记录，无投注、预测或盈利承诺。 |
| SG：有效性 / 币种 / 金额与销毁 | 同文件第128行币种变化要求更新最小值，第156行10项数量上限，第209行取消轮询，第225行 Decimal 汇总，第230行未开盘 / 暂停阻断；第778行更新 min/max。 | 可提取多条件提交门禁与快照；不照搬 Decimal 转 double 的金额路径，不把暂停项自动替换成有效项。Demo 使用整型最小单位或精确十进制，不涉及真实资金。 |

## 四、<span id="coverage">与目标现有能力的差集</span> <a href="#前言">🔼</a>

检查依据为 `lib/demo_hub/*catalog.dart` 的实际注册项，以及 CodeGraph 返回的相关页面源码。未见独立注册入口不等于全仓没有任一底层算法；以下判断限定为用户可操作的 Demo 闭环。

| 目标已有能力与代码 | 已覆盖范围 | 本次新增必须体现的差别 |
| --- | --- | --- |
| [Markdown文档](../lib/demos/Markdown文档/Markdown文档.dart)、[评论与回复](../lib/demos/评论与回复/评论与回复.dart) | 文档阅读，评论树、回复与点赞、API / 本地回退。 | PR审阅应有文件状态、patch新旧行号、行绑定讨论、过时线程和解决状态，不能重复嵌套评论或纯Markdown。 |
| [并发通知队列](../lib/demos/并发通知队列/并发通知队列.dart) | 定时到达、并发上限、排队、5秒展示、更新 / 取消。 | 通知收件箱是持久对象处理：未读 / 全部、仓库与原因组合筛选、已读 / 归档 / 订阅独立状态和失败保留，不是再画 Toast 队列。 |
| [钱包卡片](../lib/demos/钱包卡片/钱包卡片.dart) | `_index` 与切换卡片的视觉交互。 | 多来源额度归集需要来源分类、可选额、归集合并、结果账本；逐项重试 / 取消是目标体验补齐，非51既有事实。 |
| [任务依赖](../lib/demos/任务依赖编排/task_dependency_demo.dart) | A/B并发→C→D、失败开关、generation取消、持久化结果。 | 额度归集不另造通用任务调度器；重点是业务对象的幂等、重复点击、部分结果与只重试未完成项。 |
| [购物车步进](../lib/demos/购物车步进/购物车步进.dart)、元数据与动态表单注册项 | 数量 / 勾选 / 合计、字段配置与表单。 | 实时报价单必须覆盖提交前版本变化、报价接受策略、暂停 / 失效、金额下限改变，交互不同于普通购物车。 |
| 搜索历史、分组列表、侧滑菜单与日历选择 | 搜索词记忆、分组控件、目录导航、日期选择。 | 搜索请求快照、分支+路径浏览、双Navigator返回与贡献热图应分别有数据语义；不按控件名重复建设。 |

## 五、<span id="proposal">建议独立重写的可验收方案</span> <a href="#前言">🔼</a>

| 优先级 / 中文功能目录建议 | 首屏与用户任务 | 必须成立的实质交互 | 与后台 / 私库解耦方式 |
| --- | --- | --- | --- |
| P0 `代码变更审阅` | 左侧文件清单与改动统计，主区显示所选文件patch和行讨论；窄屏逐层进入。 | 文件筛选 / 搜索→hunk定位→展开行线程→标记解决 / 重开→查看过时评论；切文件保留选择；刷新只更新对应版本，返回后晚响应不打开新路由。缺patch、空文件、线程请求失败均可恢复。 | 新写 `ReviewFile / DiffHunk / ReviewThread` 与有限 patch 解析器；内置明确许可的自写示例patch，复用目标API存储边界；无需GitHub token / GraphQL客户端 / WebView / vendor高亮包。不要用含脚本的来源HTML做本地演示。 |
| P1 `实时报价确认` | 可选对象列表、确认单与当前报价 / 已接受报价并列。 | 模拟更新与暂停；三种接受策略；数量 / 最小单位校验；失效报价阻止提交；重新确认后记录“演示结果”；离屏停止更新。提交期间快照固定，币种 / 版本改变不会悄悄沿用旧授权。 | 使用中性样例商品 / 服务报价，确定性增量脚本与版本号，整数最小单位；读写正常请求Demo API，失败以独立本地演示记录继续，不接博彩后台 / 真实订单。 |
| P1 `通知处理收件箱` | 未读 / 全部目的地，原因chips与来源选择；列表保留对象上下文。 | 双维组合筛选、批量选择、已读 / 归档 / 订阅各自变化；结果失败保留原条目；分页不丢筛选；空结果有清条件 / 重载。撤销如加入需明确只针对本地演示状态。 | 新写持久通知模型和样例事件。真实API成功结果为准；演示归档 / 订阅不向真实GitHub发送，不继承账户材料。 |
| P1 `多来源额度归集` | 主额度、按来源分组的余额 / 状态、明确选中项与归集预览。 | 选来源→预览总额→执行→逐来源结果→仅失败项重试；已完成项不重复加主额度，取消保留已完成记录；分类切换不会改变在途请求对象。 | 用“样例额度”替代真实钱包，内置ID和结果序列；补齐原51缺少的局部失败语义；复用目标既有取消 / 请求代次思路，不引入游戏API、htprotect或租户配置。 |
| P2 `分支文件浏览` / `活动贡献热图` | 前者聚焦分支+路径+文件；后者聚焦日期统计而非装饰色块。 | 分支变更重置无效路径、面包屑 / 返回 / 缓存分支隔离；热图提供日选择、日期详情与可访问数量文本。 | 内置小型自写文件树与365日样例，必要时正常请求对应Demo API；可并入前述工作台，避免低价值独立页数量膨胀。 |

本轮已实现上述四个 P0/P1 功能目录，其当前行为以[第七节](#delivered)和对应源码为准。候选中的完整仓库导航、贡献热图、通知分页、独立 hunk 跳转和分离线程接口的局部失败展示没有因此一并交付；当前通知使用有界整份收件箱快照，审阅在文件内顺序显示解析后的 hunk。P2 继续保留为后续候选，不按来源目录数机械生成入口。

## 六、<span id="implementation">实现与验收约束</span> <a href="#前言">🔼</a>

- 仅新写 Jobs 维护的中文 Demo 目录；来源、供应商、生成代码和品牌素材只读。每项提供独立 main，主 App 复用同一个页面 Widget；通用数据 / 控件需要确有复用价值才放 `JobsByPubs`，业务 fixture 留在功能内。
- 复用 `JobsDemoApp` 的十语言、三主题和本地字体；正文、状态、操作、空态和错误需完整翻译，不只有目录标题。沿语义色和持续选中态组织列表 / 正文，涨跌、解决状态和暂停不可只靠红绿颜色。
- 复用 `UiDemoStore` 或目标等价数据边界，进入 / 刷新 / 写操作正常请求API；配置短超时，本地示例先绘制，成功响应覆盖。演示记录与真实资金、GitHub通知操作隔离；服务端提交未知不能回退成真实成功。
- 四项现用API key与缓存位置见第七节；具备正常请求实现不代表本轮部署了生产接口。使用自写本地文本、代码、图形或项目现有合法图标；若需额外实体Logo，按iconfont优先和可追溯本地资源规则另行获取，不照搬来源私有素材。
- 纯模型测试重点：patch行号和过时线程归属、报价接受策略与版本、金额精度、归集幂等、筛选请求快照、旧响应忽略、分页去重。页面测试重点：完整正常路径、空态 / 重试、取消 / 重开、语言主题切换、窄屏 / 宽屏与返回栈。
- 来源本轮未运行、未安装、未构建；“有源码”“本地包存在”“可独立重写”不能替代真实来源 App 验收。目标四项的静态分析、测试和渲染验证已完成，平台构建结果与未验证边界分别记录如下。

## 七、<span id="delivered">四项实际实现、资产与验证</span> <a href="#前言">🔼</a>

四项均为 Jobs 新写源码，各自的同名 Dart 文件包含独立 `main()`，使用 `JobsDemoApp`；主 App 从[功能注册表](../lib/demo_hub/curated_catalog.dart)复用同一个页面 Widget。未新增 GraphQL、OAuth、私有插件或来源状态管理依赖。页面复用绿色 Material 3 基座、十语言与白天 / 黑夜 / 跟随系统；按钮、复选框、菜单、搜索与可选文本保留原生焦点和键盘语义。

| 功能 / 真实代码 | 默认值与实际交互 | 持久化与生命周期 |
| --- | --- | --- |
| [代码变更审阅](../lib/demos/代码变更审阅/代码变更审阅.dart) · `CodeChangeReviewDemo`；[审阅模型](../lib/demos/代码变更审阅/审阅模型.dart) | revision=1，3个样例文件、4条讨论，默认选中 `lib/price.dart`。有界 unified patch 解析器验证 hunk 头和行数，保留旧 / 新行号；文件搜索与切换、旧侧 / 新侧行讨论、过时区、解决 / 重开均可操作。宽屏为文件 / diff 两区，窄屏折叠文件区。 | `workflow.workflow-review` 保存文件、patch、线程、解决状态与 revision；搜索词和当前文件只在本次页面保留。网络请求与异步解析分别使用递增代次，旧文件解析和关闭后的返回不更新页面；销毁释放搜索控制器及页面自有网络客户端。 |
| [实时报价确认](../lib/demos/实时报价确认/实时报价确认.dart) · `LiveQuoteConfirmationDemo`；[报价模型](../lib/demos/实时报价确认/报价模型.dart) | 3种普通商品，前2种选中，默认每次手动确认，版本1、合计40.00样例点数；自动更新默认开，每5秒推进，可关闭或手动推进。最新 / 已接受价格分离，三策略为任意变化 / 仅降价 / 每次确认；停用、最低数量、有效选择和版本参与提交门禁。提交须最终确认，服务端修正报价会回填并要求重审。 | `workflow.workflow-quotes` 保存对象选择、数量、最低数量、价格、接受值、可用性、策略与版本；`workflow.workflow-quote-order` 保存最近样例确认快照。自动更新开关与提示只在页面内保留。页面离屏或繁忙时跳过自动推进；销毁取消 Timer；晚响应不更新关闭的页面。没有真实支付或生产订单。 |
| [通知处理收件箱](../lib/demos/通知处理收件箱/通知处理收件箱.dart) · `NotificationInboxDemo`；[通知模型](../lib/demos/通知处理收件箱/通知模型.dart) | 5条样例通知，默认未读页、全部仓库 / 原因；按仓库 AND 原因筛选。有单项 / 批量已读、归档 / 恢复、切换订阅和上次操作撤销；读、归档、订阅是独立状态。切筛选只保留仍可见的选中项。显式下一次失败会保留原通知，空态提供清筛选与重新加载。 | `workflow.workflow-inbox` 保存完整通知及 revision；失败演示尝试使用独立 `workflow.workflow-inbox-failed-attempt`。tab、筛选、批量选择、失败开关与撤销前快照只在页面内保留；撤销通过正常Demo API写回目标记录，不接真实GitHub。代次与 mounted 检查隔离旧响应，销毁关闭页面自有客户端。 |
| [多来源额度归集](../lib/demos/多来源额度归集/多来源额度归集.dart) · `MultiSourceCollectionDemo`；[归集模型](../lib/demos/多来源额度归集/归集模型.dart) | 4来源默认全选，样例额度125.00 / 78.00 / 46.00 / 92.00，总341.00，初始已归集0。先预览并确认，最多2个来源并发；文档来源首次样例尝试失败，支持仅失败项重试。成功账本按稳定 token 幂等累计，取消保留已完成项，晚返回不再计入当前轮。与51一次 bool 返回明确不同。 | `workflow.workflow-collection` 保存来源选择、尝试次数、状态和成功账本；每个来源另用 `workflow.workflow-collection-source-<id>` 请求 / 缓存操作结果。每次状态推进串行保存本地 checkpoint，最终状态再请求聚合API；恢复时把残留 running 归为 cancelled。分类筛选只在页面内保留；销毁取消当前轮并保留已完成 checkpoint。完全使用样例额度，不转移真实资金。 |

[本组数据边界](../lib/demos/工作流共用/演示数据.dart)正常请求 `GET /api/ui-demos/<key>` 与 `PUT /api/ui-demos/<key>`，JSON形态为 `{"value": ...}`；上表 SharedPreferences 的 `workflow.` 前缀由此层添加。`DEMO_API_BASE` 默认 `http://localhost:8080/`，`WORKFLOW_API_TIMEOUT_MS` 默认800ms，实际夹紧50–5000ms。首帧先有样例，读取失败使用已校验本地快照，写入失败只完成明确标注的本地演示；后续成功且结构有效的响应覆盖本地。UTF-8解析、领域校验、每key请求代次和串行缓存写入防止无效 / 过期响应污染当前缓存。未部署后台时仍可演示完整闭环，不能据此宣称真实生产写入成功。

[共用视图](../lib/demos/工作流共用/共用视图.dart)提供同步 / 本地状态、重新加载空态及最终确认；[工作流文案](../lib/demo_hub/workflow_strings.dart)包含96条完整十语条目。各功能模型和业务 fixture 留在自己的目录，未借新增功能重构公共包或修改第三方。

实际验证：

- [workflow_curated_test.dart](../test/workflow_curated_test.dart)普通 `flutter test --no-pub` 全部19项通过（23秒）。覆盖 unified patch 的 CRLF / 零行数 / 省略行数 / 无换行标记 / 截断拒绝，线程侧别，三报价策略和有效性，通知筛选 / 独立状态 / 批量撤销，归集两并发 / 部分失败 / 仅失败重试 / 幂等 / 取消，以及 API 超时、损坏响应、恢复覆盖、过期缓存写入和四页关闭后晚响应。
- 对上述四目录、共用层、工作流文案和测试执行精准 `flutter analyze --no-pub`，输出 `No issues found`。最后订阅按钮文案调整后，单独重跑40种四页面×十语言的窗口 / 主题组合，全部通过（29秒）；该矩阵交替390×844 / 1440×1000并轮换三主题，不声称穷举每一种语言×窗口×主题笛卡尔积。
- 已查看四张1440×1000英文浅色 Widget 渲染图：[代码变更审阅](./截图/工作流蒸馏/代码变更审阅-浅色.png)、[实时报价确认](./截图/工作流蒸馏/实时报价确认-浅色.png)、[通知处理收件箱](./截图/工作流蒸馏/通知处理收件箱-浅色.png)、[多来源额度归集](./截图/工作流蒸馏/多来源额度归集-浅色.png)。测试显式加载现有 SDK Roboto / MaterialIcons 与项目藏文字体；测试的 monospace 别名用Roboto，实际App仍使用平台等宽字体。这是布局渲染证据，不是真机 / 浏览器字体与无障碍朗读验收。
- 最终冻结源码的 `flutter build web --release --no-pub` 通过（217.0秒、exit0），产物 `build/web`；`main.dart.js` 为 8282480字节，SHA-256为 `7757ebc8c4e0efa383b9b063369c97f9ed48ef27c9defa1ea01358beffce1128`。日志 `/tmp/jobs-curated-web-build.log`，产物记录 `/tmp/jobs-curated-web-final.json`。SDK默认Wasm dry-run仍提示既有 `audioplayers_web` 旧互操作不兼容；本次生成JavaScript产物，没有启用 `--wasm` 或修改第三方插件。
- 随后串行执行 `flutter build ios --simulator --debug --no-pub --no-codesign`，构建通过（Xcode阶段50.1秒、exit0），产物 `build/ios/iphonesimulator/Runner.app`；覆盖当前原生 / Dart 代码的模拟器编译。构建前可用8.02GiB，满足3GiB门槛，没有运行clean。日志 `/tmp/jobs-curated-ios-build.log`，结果记录 `/tmp/jobs-curated-ios-final.json`。现有部分插件的Swift Package Manager兼容警告未阻断当前构建。
- iOS仅构建，没有安装 / 启动模拟器App；播放器PlatformView的实际装载、音视频、系统权限、硬件设备、真实GitHub授权、来源App、商业后台、真实资金与生产发布仍未验收。上述成功结果只对应代码 / 资产编译及已列明的自动化交互，不扩大为真机或生产验证。

<a id="🔚" href="#前言">我是有底线的➤点我回到首页</a>
