# Rust OCR 集成资产盘点

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、资产与行为](#assets)
- [二、验证与限制](#validation)
- [三、源码交付与本地编译](#source-delivery)
- [四、图片输入与结果交互改进](#ocr-interaction)
- [五、生产主入口实际验收](#production-ui)
- [六、中英混排核心与源码状态](#mixed-script-source-20261117)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

目标是使用同一 [**Rust**](https://www.rust-lang.org/) OCR 核心完成真实离线图片识别，独立 Demo 与首页入口复用同一页面。盘点更新：2026-11-17；本工程已有十语三主题、原生平台插件、图片选择依赖及独立运行容器，本轮不替换这些公共能力。

## 一、<span id="assets">资产与行为</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| 编号 | 资产／入口 | 行为与默认 | 持久化与生命周期 | 代码位置 | 当前状态 |
| --- | --- | --- | --- | --- | --- |
| OCR-F01 | JobsByPubs 公共插件 | 调用 Rust Apple SDK，返回文字、行框、置信度和耗时；不伪造结果 | 每次显式识别；离开时取消，回调受页面代次保护 | `JobsByPubs/JobsRustOCRByPub` | 协议测试与真实iOS模拟器样本通过 |
| OCR-F02 | 独立 Demo | 样本预览 → 样本／相册／拍照 → 紧凑开始／取消 → 状态 → 结果标题与快捷复制；单一整页滚动，全文自然展开；保留行框与逐行置信度 | 默认预览样本但不自动识别，图片与结果只存页面内存；取消选图／拍照保留已有图和结果 | `lib/demos/离线文字识别/离线文字识别.dart` | 本批Widget通过；新生产App由首页进入后真实识别35行／367ms，浅深、整页滚动与全文复制实屏通过；见第五节 |
| OCR-F03 | 首页入口 | 媒体与设备组，稳定 ID `rust-ocr`，支持搜索、最近使用及源码定位 | 复用首页原有偏好合同 | `lib/demo_hub/platform_catalog.dart` | 源码已注册，当前300项；旧299项证据保留 |
| OCR-F04 | 主题与十语 | 白天／黑夜／系统与十语言，嵌入宿主和独立运行均可切换 | 复用 JobsDemoSettings 的已有持久化 | 公共 Foundation 壳＋Demo 词典 | 词典完整性与十语×浅深Widget布局通过；生产App浅深切换及结果保留实屏通过，完整十语设备切换待验 |
| OCR-F05 | Apple 交付 | 插件内保存规范 Core／Support／Resource SDK 副本，Podfile 使用相对依赖 | 模型与原始许可随包，无运行时下载 | 插件 `ios/JobsRustOCR`、`macos/JobsRustOCR` | SDK已装配，双端Pod解析通过；iOS模拟器App实际推理通过；Flutter MacOS App未验 |
| OCR-F06 | 独立自动验收 | 原生zsh脚本自动发现模拟器／真机，默认官方Flutter构建独立入口；仅真实样本JSON符合本轮标识和文字锚点才通过 | 每次生成新报告；复用官方SPM缓存；显式DD覆盖受SDK源码审核门禁；临时配置受并发保护；App保留运行 | `lib/demos/离线文字识别/验收入口.dart`、[脚本包](../JobsByPubs/JobsRustOCRByPub/test/【MacOS】🧪移动OCR验收.command/README.md) | 默认官方模式已真实通过；DD覆盖仅命令合同静态检查 |
| OCR-F07 | 拍照与按钮对比 | 相册调用gallery、拍照调用camera；成功后等待手动识别，不自动上传；相机不可用／权限未开明确提示，可改选相册或样本 | 复用已有相机权限说明，读取不索取完整元数据；取消或失败不丢旧结果，离页代次阻止picker晚回调；明暗按钮使用成对ColorScheme背景／前景，禁用态仍清楚 | 同一页面＋`识别文案.dart` | picker协议、窄屏十语×浅深20组合通过；生产Simulator实际触发后置镜头不可用提示，关闭后原图／结果／Clipboard保留；物理拍照真机待验 |

## 二、<span id="validation">验证与限制</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

- 源码、静态分析、构建、实际 UI、真实 OCR 和真机验收分别记录，不能互相替代。
- 核心未接通前不使用任何假识别结果；平台或模型不可用时明确报错并保留重试。
- 已验证：新增源码 Dart 分析零问题；8项协议／页面测试通过，覆盖真实协议字段、非法几何、十语、显式识别、取消晚回调、自动验收等待真实回调／加载失败，以及未接入平台错误。测试注入不等于模型推理。
- 骨架增量回归：`demo_hub_test.dart` 与 `demo_home_cards_test.dart` 共12项通过，含目录加载、搜索／最近、设置、三主题／十语、拖动及服务回退；`demo_toolbar_coverage_test.dart` 遍历当前300个注册builder、唯一可用主题／动作入口的检查通过。该覆盖为Flutter Widget测试，不代替300项真实设备业务验收。
- SDK未打包时，Podfile与插件依赖均先检查真实podspec，原生桥通过条件导入返回 `core_unavailable`，避免影响其它Demo构建；不以该状态代替正常OCR验收。
- SDK规范包与模型、原始许可已clone到插件；iOS Pod解析通过（10依赖／17pods），macOS Pod解析通过（5依赖／6pods）。SDK当前最低版本为iOS15.1/macOS14.0，宿主工程、Podfile与插件声明已一致；这不是更旧系统的兼容承诺。
- 验收脚本 `zsh -n`、帮助、冲突参数与非交互确认保护通过；7项JSON回执契约检查覆盖旧轮次、原生失败、缺失锚点、无效尺寸、错误平台、缺失文本hash，不能误写通过。该检查使用合成JSON夹具，不是设备OCR验收。
- 2026-11-16 18:55 的只读设备查询返回0台iOS真机；对应 `RustOCR验收/运行-2026.11.16 18-55-18-38C709BD-2C63-45DC-A58F-486E86CE7745/evidence.json` 为 `not_run/list_only`。目前没有真机验收通过证据。
- 2026-11-16 20:21，默认官方Flutter构建51.4秒成功并更新canonical包，F831模拟器实际启动随包样本：35行、1653×2337、644.56ms，锚点和引擎符合，脚本退出0。[中央真实证据](../../../OCR/测试/报告与证据/iOS/Flutter/README.md)与[冻结App](../../../OCR/交付/iOS/Flutter/README.md)已归档；989份宿主／本地Pub Dart源码SHA未变，新kernel含本轮run_id，模型与原始许可在App内。
- 该JSON为 `driver-summary-of-real-native-result`，记录真实SDK回调的计数／摘要／开头片段，没有完整原生text／lines数组，不伪补全文或坐标。样本同SHA不是OCR准确率。
- 当前待执行：iOS真机、其它图片和完整设备交互回归；Flutter MacOS App运行仍未验，其它系统不能因Rust可编译或Pod解析而标为已验收。

## 三、<span id="source-delivery">源码交付与本地编译</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

2026-11-16 用户确认五个 Demo 全部交付自有源码；此前预编译包构建和设备结果保留为历史批次证据。当前交付改造先登记、后分发和验证。

| 资产 | 当前合同 | 默认／持久化／生命周期与验证 |
| --- | --- | --- |
| 自有核心源码 | SDK 的 `Source/JobsOCR` 包含 Cargo 清单、锁文件、src、C接口、测试与许可 | 不依赖开发机外部OCR目录；源码可直接研究修改；六SDK的21份Source／Scripts／忽略规则逐字节同源，自检与Cargo.lock可见性已验 |
| 构建入口 | [BuildRustOCR.command](<../JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/Scripts/BuildRustOCR.command>)；[参数及依赖](<../JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/Scripts/README.md>) | 先手动运行再执行原有pod install／构建；CI显式--non-interactive；源码变化后重新执行 |
| 本地产物 | `Frameworks/JobsOCRCore.xcframework` 的.a与 `.build-rust-ocr/` 缓存 | Git忽略；当前暂存中的自建.a精确移除并保留本地文件；不擅自重写历史 |
| 第三方与模型 | 锁定官方ONNX Runtime 1.24.2 ZIP并核对SHA；原模型／许可继续随资源bundle分发 | 自有Rust本地编译与第三方官方依赖下载分别声明；首次构建可能联网，准备完可显式离线 |
| 运行行为 | 既有入口、手动识别、取消、真实结果、错误重试、十语三主题 | 默认值、偏好和生命周期沿原合同，不新增假识别回退；本批实际构建及运行另记 |
| GitHub验收 | 五个Demo分别核对本批实际提交与全部必需workflow | 本地检查、远端运行和旧证据分别记账；未完成前不写通过 |

从本项目根目录构建核心：

```shell
/bin/zsh "JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/Scripts/BuildRustOCR.command" --yes
```


本批源码验证：共享包与Flutter iOS SDK副本均已实际用Rust1.95.0完成五Apple目标编译、组合XCFramework及原库保留；六SDK源码／脚本同源检查、自检、Cargo.lock不会被OC的*.lock误忽略、Git索引无自建.a均通过。21项核心测试与7组失败／迁移检查见共享OCR的源码交付报告；其它宿主本批UI改造后的构建及远端Workflow仍须各自验收，不外推上述构建。

## 四、<span id="ocr-interaction">图片输入与结果交互改进</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

2026-11-16 本批沿用宿主视觉与已有插件，补充拍照，修正浅色按钮背景、页面滚动和结果复制；不改原生SDK、真实识别协议、autoRecognize验收回调及旧设备证据。

- 页面整体由一个 `SingleChildScrollView` 滚动；结果 `SelectableText` 不限行、不设内部固定高度，禁用文字内部滚动；行框与逐行置信度仍可查看。
- 样本、相册、拍照与开始／取消分为两组可换行的自然宽按钮；开始按钮常规最小48逻辑像素，较高文字可自然撑开，不做大通栏。辅助按钮和主按钮显式配对背景／文字／边框token，明暗与禁用状态保持清楚。
- `ImagePicker` 调用真实camera／gallery源，取消保留旧图与结果，错误单独显示且保留恢复入口；新图读取成功后才清旧结果。离页或销毁后不回写picker结果；图与结果不跨启动持久化。
- 结果标题旁提供复制全文按钮，成功／失败有本地化反馈；新增拍照、相机不可用／权限与结果文案完整覆盖十语。
- 本批14项协议／页面回归通过，包含camera／gallery实传平台源、拍照取消／不可用／权限错误保留旧结果、picker离页晚回调、原生取消晚回调、autoRecognize原合同、长结果整页手势与实际剪贴板数据。320逻辑像素下十语×浅深20组合无布局异常；按钮正常／禁用前景背景对比均≥4.5，普通开始高度48，较高藏文字形自然增高。新增页面、词典与测试Dart分析零问题。
- 另以 `--dart-define=CAPTURE_OCR_UI=true` 显式执行截图用例，使用实际字体和随包样本图片输出[浅色输入](./截图/OCR交互/FlutterOCR-浅色-输入.png)、[浅色结果](./截图/OCR交互/FlutterOCR-浅色-结果.png)、[深色输入](./截图/OCR交互/FlutterOCR-深色-输入.png)、[深色结果](./截图/OCR交互/FlutterOCR-深色-结果.png)。结果文字是测试夹具注入，仅核验布局与对比，不冒充当前原生推理结果。默认测试跳过这项有文件产出的截图用例。
- 前批Web构建／全仓704项测试对应目录整理阶段，当前UI专项按本段单独记账；本批生产包实屏与相机边界见第五节，物理拍照仍须真机验收。
- UI与源码分发合入后的最终主工程全量复验：`flutter test --no-pub` 710项通过、2项有文件产出的截图测试按设置跳过；全工程 `flutter analyze --no-pub --no-fatal-infos` 退出0，0 error／0 warning、保留700兼容info。官方FVM iOS模拟器Debug无签名整包构建通过，Xcode394.4秒；新canonical App内有camera／copy键、OCR模型与样本，823份Dart源码与核心归档构建前后SHA一致。[最终构建清单与日志](./验收记录/2026-11-16-Flutter目录与OCR交互最终验证/manifest.json)保留该构建时点记录；随后实际安装同一新包完成第五节有限验收。

## 五、<span id="production-ui">生产主入口实际验收</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

2026-11-17，在iOS27.2模拟器 `JobsOCRSourceReview` 安装上述canonical生产App，从“更多 → 搜索Rust → 离线文字识别”进入，手动点击开始，未注入测试结果、未重建App。原生UI单项测试通过，1项／0失败、30.815秒；安装包与canonical包Kernel的SHA256均为 `a5b226e64c38b2b3e25c8c423ff2b8a45f13f6176cc32a55f4944144186137fd`。

| 实际操作 | 结果与证据边界 |
| --- | --- |
| 随包样本手动识别 | 当前生产页面显示35行、367ms，核心版本 `jobs-rust-ocr/0.1.0`；[浅色真实识别](./截图/OCR模拟器实屏/Flutter-浅色-真实识别.png) |
| 主题、按钮与滚动 | [浅色输入](./截图/OCR模拟器实屏/Flutter-浅色-输入.png)、[深色结果](./截图/OCR模拟器实屏/Flutter-深色-真实识别.png)已实看；主题切换保留结果；拖动结果时[整页位置一起变化](./截图/OCR模拟器实屏/Flutter-浅色-整页滚动.png)，紧凑开始按钮实际frame断言通过 |
| 复制全文与恢复 | 真实复制得到2936字节、1326字符、35行；相机操作前后两次Clipboard逐字节相同，SHA256为 `290a01ed34c536ea7f07bb220268fa814af767c3d796856d2b9048ef83005cdc`，最终AX含“文字已复制”反馈 |
| 实际camera入口 | `image_picker_ios 0.8.13+6` 在本机Simulator判断请求的后置镜头不可用，展示[原生“Camera not available.”提示](./截图/OCR模拟器实屏/Flutter-相机后置镜头不可用.png)；插件该分支返回null，无Flutter PlatformException code；关闭后[原图、结果及Clipboard保留](./截图/OCR模拟器实屏/Flutter-关闭相机提示后保留.png)。前一诊断轮实际处理了系统TCC允许弹窗，最终轮复用已授权状态；没有把相机picker未出现记为拍照通过 |

[本轮JSON摘要及原始证据](./验收记录/2026-11-17-Flutter生产OCR实屏/summary.json)含全文Clipboard、AX、原生UI日志、测试源码快照与截图指纹。该JSON是实际生产UI／Clipboard驱动摘要，不是原生完整lines／几何协议，未伪补坐标或置信度。本批物理相机取像、新图识别、真机权限与完整十语设备操作仍待验。验收结束已终止App并交还模拟器。

## 六、<span id="mixed-script-source-20261117">中英混排核心与源码状态</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

当前[iOS 随仓源码](<../JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/Source/JobsOCR>)和[MacOS 随仓源码](<../JobsByPubs/JobsRustOCRByPub/macos/JobsRustOCR/Source/JobsOCR>)已同步本机验收通过的中英混排路由，包含 `pipeline.rs`、`runtime.rs`、`lib.rs`、`routing.rs`、独立 E2E 测试和 `MixedScript` 夹具。核心常规测试 30 项、显式 E2E 1 项覆盖 8 张真实夹具（其中 4 张精确逐行控制）通过；范围与证据见[共享核心回归记录](<../../../OCR/项目相关报告/混排回归/README.md>)。

本状态确认核心本机回归及随仓源码一致；本宿主尚未使用此次新核心重编、运行，原有 35 行样本／界面／Workflow 记录仍限原批次。使用新核心前先运行[SDK 本地构建入口](<../JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/Scripts/BuildRustOCR.command>)，源码输入哈希变化会使旧库缓存失效；保留本地构建方式，不分发自建 `.a`。显式 E2E 需指定本机 ORT 与随 SDK 的模型目录。

<a id="🔚" href="#前言">我是有底线的➤点我回到首页</a>
