# JobsRustOCRByPub

![Jobs出品，必属精品](https://picsum.photos/1500/400)

<!-- jobs-toc:start -->
<!-- jobs-toc:source {"v":2,"token":"[toc]"} -->
<details>
<summary>📚 目录（点击展开 / 收起）</summary>

- [🔥 前言](#%E5%89%8D%E8%A8%80)
- [一、能力与调用](#api)
- [二、平台目录与依赖](#native)
- [三、Demo 与验证](#demo)

</details>
<!-- jobs-toc:end -->

---

## 🔥 <span id="前言">前言</span>

为 [**Flutter**](https://flutter.dev/) 提供共享 [**Rust**](https://www.rust-lang.org/) OCR 核心的原生桥接。识别在设备上执行，不请求服务器、不下载模型、不返回假文字。平台 SDK 和模型是否已随当前构建打包，会直接影响能力可用性。

## 一、<span id="api">能力与调用</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

```dart
const client = JobsRustOCR();
final version = await client.coreVersion();
final sample = await client.sampleImage();
final result = await client.recognize();
// 实际导入的 PNG/JPEG 等图像编码数据：client.recognize(image: bytes)
await client.cancel();
```

- `recognize()` 使用 SDK 预置样本；`recognize(image: bytes)` 使用调用者提供的图像数据。
- `JobsOCRResult` 返回真实 `text`、`lines`、图像像素尺寸、`elapsedMs` 与引擎标识。每行包含文字、`[x0,y0,x1,y1]` 像素边界和置信度。无文字是有效空结果。
- 原生错误通过 `PlatformException` 返回；无已注册插件为 `MissingPluginException`。结果结构无法解析时抛出 `FormatException`，不把它当成功。
- 取消交给原生核心；宿主仍需等待原调用结束，并抑制取消之后的迟到结果。Demo 已处理这一生命周期。
- 此插件不持久保存图片、文字或用户偏好。页面主题与语言由宿主 Foundation 管理。

## 二、<span id="native">平台目录与依赖</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

- `lib/` 为公开 Dart 协议与类型；`ios/Classes/`、`macos/Classes/` 为 `jobs/rust_ocr` MethodChannel 桥接。
- Apple 自包含 SDK 副本放在 `ios/JobsRustOCR/`、`macos/JobsRustOCR/`；模型与样本由 SDK 自身资源 bundle 管理，不重复宣告成 Flutter 网络资源。
- 工程 Podfile 在 SDK 的真实 `JobsRustOCR.podspec` 存在时，以相对路径注册本地 Pod。插件同步声明对应依赖；SDK 尚未准备时仍能构建其它 Demo，OCR 页面返回明确 `core_unavailable`。
- SDK 就绪后的构建必须运行宿主原有依赖准备流程，不能把条件编译可通过当作核心已接入。
- 当前插件登记 iOS／MacOS 平台。其它系统需要对应原生桥接和实际构建验证，不能把共享 Rust 源码直接等同于本插件已支持所有系统。
- 当前 Apple SDK 最低支持声明为 iOS15.1／macOS14.0，宿主与桥接插件已对齐；更旧系统尚未验证。
- 插件包装层为 MIT；所带核心、推理运行时与模型保持各自许可，模型使用不因本包装层而获得额外授权。

## 三、<span id="demo">Demo 与验证</span> <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

- 首页“媒体与设备 → 离线文字识别”，源码 `lib/demos/离线文字识别/离线文字识别.dart`，同文件提供独立 `main`。
- 页面包括预置样本、选图、识别、取消、行框、逐行置信度与复制；结果空态和错误均可重新加载。页面初次打开不自动执行识别。
- 独立自动验收入口 `lib/demos/离线文字识别/验收入口.dart` 复用同一页面与真实插件；同名 [MacOS 原生验收脚本包](test/【MacOS】🧪移动OCR验收.command/README.md) 支持 `--simulator`／`--device`、自动设备选择和实际样本 JSON 回执，编译成功不能代替通过。
- 宿主 `test/rust_ocr_test.dart` 覆盖协议解析、非法结果、十语、显式识别、取消晚回调及未接入平台。测试注入只用于测试，不进入生产识别路径。
- 当前验证及未验边界见[资产盘点](../../项目相关报告/Rust-OCR集成资产盘点.md)。Dart 测试不能替代 SDK 模型推理、构建、实际页面或真机验收。
- 2026-11-16已完成独立入口的官方iOS模拟器构建／启动和真实随包样本识别：35行、约645ms，模型／原始许可随App，新kernel含本轮run_id，989份Dart源码SHA未变。证据与冻结App从资产盘点进入；driver JSON是实际回调摘要，不含完整text／lines，真机与Flutter MacOS运行仍未验。

<a id="🔚" href="#前言">我是有底线的➤点我回到首页</a>
