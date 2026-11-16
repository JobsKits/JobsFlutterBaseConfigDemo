# 移动 Rust OCR 验收

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <span id="前言">前言</span>

用 [**MacOS**](https://www.apple.com/macos/) 原生 [**zsh**](https://www.zsh.org/) 构建、安装并启动当前 [**Flutter**](https://flutter.dev/) 工程的独立 OCR Demo，收集同一 [**Rust**](https://www.rust-lang.org/) 核心的真实样本结果。默认直接使用官方Flutter构建流程，复用宿主现有输出与SwiftPM缓存。脚本不要求复制设备 UDID，不使用 Python／Node，不下载模型，也不把编译成功当作识别通过。

## 一、<span id="usage">运行方式</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

在本目录执行，也可将下列脚本参数替换成脚本的实际完整路径，从任意工作目录启动：

```zsh
./【MacOS】🧪移动OCR验收.command --simulator --auto
./【MacOS】🧪移动OCR验收.command --device --auto
./【MacOS】🧪移动OCR验收.command --device --list
```

- 先打印用途与影响；默认仅按回车继续，输入其它字符取消。自动化明确传 `--yes`，非交互环境没有该参数就拒绝构建。
- `--simulator` 仅选 iOS 模拟器，`--device` 仅选现有 iOS 真机。一个匹配设备直接使用；多个通过 `fzf` 上下选择，回车／空格确认、Esc 取消。也可用 `--name '设备显示名'` 精确筛选。不会创建或清除模拟器。
- `--auto` 表示执行自动样本验收。这个专用脚本始终构建自动验收入口，省略该参数也不会退回人工点击模式；普通交互入口仍默认不自动识别。
- `--project '工程路径'` 可覆盖自动向上寻找的宿主工程；复制单个脚本包后必须指向包含 `lib/demos/离线文字识别/验收入口.dart` 的实际工程。
- `--output '目录'` 改证据目录；默认在工程 `项目相关报告/RustOCR验收/运行-日期-唯一编号/`。`--timeout 180` 设置 App 启动后等待真实识别回执的秒数，范围 10～3600。
- 无隔离参数时直接执行官方 `flutter build ios`，由当前SDK管理workspace DerivedData、原生输出与SwiftPM预取，不另开冷DD，不改全局 `build-dir`。
- `--build-root '独立构建目录'` 或 `--derived-data '现有或独立DerivedData目录'` 显式进入经过核对的原生DD覆盖模式。前者默认取其 `DerivedData` 子目录，后者精确复用指定DD；必须先确认其它构建已停止，不复用不同工程的DD。
- DD覆盖模式仍先运行官方 `--config-only` 做真实SwiftPM预取，后续 `-clonedSourcePackagesDirPath` **始终指向当前Flutter构建目录的 `ios/SourcePackages`**，不随DD搬迁。`BUILD_DIR`也沿用官方当前输出；Dart中间文件仍可能写工程 `.dart_tool/flutter_build`，所以隔离参数不代表全部临时文件迁出。
- 原生DD覆盖模式锁定本次审计过的4份SDK参数流程源码SHA；SDK变化时会停止并提示去掉隔离参数，默认官方模式继续适用。JSON记录 `build_driver`、实际SPM缓存和显式DD，避免把宿主缓存误写成脚本私有产物。
- `--list` 仅查询并保存设备清单，写入 `not_run/list_only`，不执行依赖准备、编译、安装或启动。

## 二、<span id="prerequisites">工具链与构建影响</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

宿主需要现有可用 Flutter、Xcode Command Line Tools、CocoaPods、本地 SDK `JobsByPubs/JobsRustOCRByPub/ios/JobsRustOCR/JobsRustOCR.podspec` 和已准备好的依赖。优先使用工程 `.fvm/flutter_sdk/bin/flutter`，否则从当前 `PATH` 找 Flutter。脚本不安装／升级工具链，不改代理和系统配置，不运行 `flutter clean`。

真机需已连接、信任电脑、打开开发者模式，并在宿主 Xcode 工程配置有效的签名与开发团队。脚本沿用工程签名，失败写 `native_build_failed`，不会自动注册账户、修改团队或冒充真机通过。

默认构建执行官方 `flutter build ios --debug --no-pub`；SDK负责必要Pod准备、SwiftPM预取和真实Xcode参数。DD覆盖模式执行官方config-only、显式 `pod install --no-repo-update`，再使用相同SPM缓存／BUILD_DIR与 `xcodebuild -jobs 1`；按官方build流程的 `skipPackageValidation=false`，不手工加入跳过包签名／插件验证的参数，也不编造SDK没有生成的skip-updates选项。

安装覆盖所选设备上的本工程 App，不卸载、不清除 App 数据；不要与其它线程在同一宿主并发改Pods或生成配置。脚本不清理任何构建目录，宿主 `work/RustOCRValidation/.runner-lock` 阻止同工程脚本并发验收。指定的DD也应由本宿主独占。异常残留锁需先核对其中 `pid` 对应进程，脚本不会自动删除未知锁。

运行期间临时生成的 `Generated.xcconfig` 和 `flutter_export_environment.sh` 会精确备份到系统私有临时目录，退出时仅在文件仍等于本次生成版本时恢复，保留并发修改。备份不放进可分享报告；依赖解析本身会正常更新 Pods／lockfile，请按工程协作窗口运行。终端使用内嵌保护逻辑临时调整可可靠恢复的颜色，不支持时保持原状或纯文本。

## 三、<span id="evidence">通过条件与证据</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

独立入口直接调用实际 `JobsRustOCR` MethodChannel，加载 SDK 随包官方样本，在原生回调返回后打印本轮随机 `run_id` 的单次 JSON。脚本使用 `flutter run --use-application-binary` 安装、启动并采集运行日志；成功后发送 detach，保留 App 供人工查看。

| 结果 | 条件 | 含义 |
| --- | --- | --- |
| `passed` | 实际启动得到本轮回执，来源／引擎／iOS 平台匹配、尺寸和行数有效、文本 SHA-256 存在，且真实文字包含 `DIOCESE OF SEOUL` | 该设备这一次样本识别链路通过；不代表 OCR 准确率或所有图片通过 |
| `failed` | 配置、编译、签名、运行失败，超时，或回执校验不合格 | 需要检查对应日志；编译通过也可能是失败 |
| `not_run` | 没有匹配设备、仅列清单、SDK 缺失、未选择设备或输出被占用 | 此模式没有验收，不能记作通过 |

报告包括 `devices.json`、阶段日志、`run.log`、原生 `native-evidence.json` 和统一 `evidence.json`；模拟器回执后另尝试截图。`evidence.json` 中 `native.text_sha256` 用于本轮文本比对，`text_preview` 只保留开头片段。日志可能含本机路径、设备标识及样本文字，分享前自行脱敏。

退出码 `0` 表示该脚本实际通过，或 `--list` 成功结束（必须同时看 JSON 状态）；没有设备等未验收返回非零。真机无可用设备时明确保存 `not_run/no_matching_device`，不借模拟器或静态检查替代。失败后修复原因，再用相同命令重跑，会生成新证据目录，不覆盖旧回执。

## 四、<span id="manual">人工复核</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

查看 App 样本、行框和文字结果，试选自己的图片、取消、无文字图片空态、复制、十语及白天／黑夜／跟随系统。脚本只自动验证随包样本；这些交互与真机图像选择仍需分别记录。当前已验和待验状态统一见[集成资产盘点](../../../../项目相关报告/Rust-OCR集成资产盘点.md)。

<a id="🔚" href="#前言">我是有底线的➤点我回到首页</a>
