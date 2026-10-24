# <span id="前言">Flutter 窗口布局与 iOS CI</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

---

[`../workflows/flutter-window-layout.yml`](../workflows/flutter-window-layout.yml) 在 `main` 推送、Pull Request 和手动运行时执行。只读仓库权限、完整 SHA 固定的 Actions 和单次 60 分钟限时；任何依赖解析、分析、测试、完整构建或产物校验失败都会使任务失败。

## 一、<span id="coverage">执行范围</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 阶段 | 实际执行与通过条件 |
| --- | --- |
| 工具链 | [**GitHub**](https://github.com/) 的 `xcode-27` Apple Silicon runner，显式选择 `Xcode_27.1.app`；运行时核对 [**Xcode**](https://developer.apple.com/xcode/) 与 iOS Simulator SDK 均不低于 `27.1`。缺失时失败，不退回 runner 默认 `27.0` |
| Flutter | 使用 [**Flutter**](https://flutter.dev/) `3.47.7`，并与根目录 `.fvmrc` 和真实 `flutter --version --machine` 结果逐项匹配 |
| 依赖 | `flutter pub get --enforce-lockfile` 使用已提交 `pubspec.lock`，锁文件不得漂移。原生完整构建由 Flutter 在 runner 临时检出中正常解析 [**CocoaPods**](https://cocoapods.org/) 依赖 |
| 分析 | [`analyze-scope.txt`](./analyze-scope.txt) 列出 Runner、本次窗口适配源码、备用入口、友盟模块与两个测试文件。每项真实执行 `dart analyze --fatal-warnings`；error / warning 或文件缺失失败，info 原样保留日志 |
| 回归 | 明确运行 `test/iphone_duo_layout_test.dart` 的 11 项布局回归与 `test/umeng_demo_test.dart` 的 10 项服务 / 页面回归；不删除或改写既有测试 |
| iOS 构建 | 对默认 `lib/main.dart` 执行完整 `flutter build ios --simulator --debug --no-pub --no-codesign`，正常链接全部原生插件，不过滤编译失败 |
| 产物 | 核对固定 `Runner.app`、Bundle ID、真实可执行文件、Simulator 平台、构建 SDK≥27.1 与 arm64；全部成立才上传 `Runner.app.zip`，保存 7 天 |

这是明确范围的回归工作流，不代表全仓教学示例均通过分析或所有测试通过。既有 `test/widget_test.dart` 仍是与所导入 GetX 生命周期页面不匹配的计数器模板，不在本工作流的命名套件中；该文件保持原样。iOS 编译通过不代表已完成 Duo 半折姿态、保留区、键盘交互、原生统计上传、签名真机或上架截图验收。

## 二、<span id="commands">脚本入口与日志</span> <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

[`verify.zsh`](./verify.zsh) 按自身路径定位仓库。无参数仅显示帮助；需要已有匹配 SDK 和依赖配置，不自动安装开发工具。可在仓库根目录使用：

```shell
/bin/zsh .github/ci/verify.zsh --help
/bin/zsh .github/ci/verify.zsh analyze
/bin/zsh .github/ci/verify.zsh test
```

`toolchain` 只读取并核对 Flutter / Xcode / Simulator SDK / CocoaPods 版本；需显式设置有效的 `DEVELOPER_DIR`。`ios` 会解析原生依赖并构建，仅允许在 `GITHUB_ACTIONS=true` 的 runner 中运行。分析和测试复用已有 package configuration；测试会写入正常的构建缓存，不修改依赖声明。

日志默认写入系统临时目录的 `jobs-flutter-ci`；可以用 `JOBS_CI_LOG_DIR` 指定本次目录。CI 成功或失败都尝试上传 `*.log`：版本、工具链、依赖、逐项分析、完整测试、iOS 构建与产物身份。失败日志上传不改变前序失败状态；应用包仅在全部前序步骤通过后上传。

runner 来源：[Xcode 27 镜像发布说明](https://github.blog/changelog/2026-10-15-xcode-27-runner-image-generally-available/)、[当前软件清单](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md)。工作流成功必须以相同提交的真实运行结果为准，本地语法检查不能代替远端执行。

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
