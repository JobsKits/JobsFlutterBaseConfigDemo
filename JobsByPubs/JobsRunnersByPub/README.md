# jobs_runners

本地使用的 Flutter Runner 小包，适合把任意页面快速包一层壳直接运行测试。

## 特性

- `JobsMaterialRunner`：Material 风格
- `JobsCupertinoRunner`：Cupertino 风格
- `JobsGetRunner`：GetX 风格
- 同时支持 `child` 和 `builder` 两种方式
- 统一内置 `ScreenUtilInit`

## 本地接入

在你的主项目 `pubspec.yaml` 里这样写：

```yaml
dependencies:
  jobs_runners:
    path: ./jobs_runners
```

## 使用示例

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

### builder 模式

```dart
runApp(
  JobsMaterialRunner.builder(
    title: 'Builder Demo',
    builder: (context) => const Center(child: Text('builder')),
  ),
);
```
