# <span id="前言">jobs_runners</span>

本地使用的 [**Flutter**](https://flutter.dev/) Runner 小包，适合把任意页面快速包一层壳直接运行测试。

## 特性 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `JobsMaterialRunner`：Material 风格
- `JobsCupertinoRunner`：Cupertino 风格
- `JobsGetRunner`：GetX 风格
- 同时支持 `child` 和 `builder` 两种方式
- 统一内置 `ScreenUtilInit`
- 三种 Runner 均启用分屏缩放和 MediaQuery 变化刷新；页面 body 使用逐边 `SafeArea`，支持运行中窗口变化与不对称 inset。`builder` 的 context 位于该安全区内，不应把首次宽高缓存在 `initState`。
- 安全区只负责系统 UI，短窗口里的长内容仍由页面提供 `ListView` / `SingleChildScrollView`；不会为所有 Demo 强制添加滚动层，也不读取机型或固定屏幕尺寸。
- 保守适配不包含 iPhone Duo 原生保留区 / 铰链桥接；11 项窗口与安全区回归测试位于宿主的 `test/iphone_duo_layout_test.dart`，不代表 Duo 原生姿态已验收。

## 本地接入 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

在你的主项目 `pubspec.yaml` 里这样写：

```yaml
dependencies:
  jobs_runners:
    path: ./jobs_runners
```

## 使用示例 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```dart
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

void main() {
  runApp(
    const JobsMaterialRunner(
      Center(child: Text('Hello JobsRunners')),
      title: 'Demo',
    ),
  );
}
```

### builder 模式 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```dart
runApp(
  JobsMaterialRunner.builder(
    title: 'Builder Demo',
    builder: (context) => const Center(child: Text('builder')),
  ),
);
```

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
