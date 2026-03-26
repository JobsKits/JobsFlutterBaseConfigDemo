# jobs_refresh_load

一个可本地集成、后续也可直接发布到 pub 的 Flutter 小库，提供：

- `JobsRefreshLoadController<T>`：分页刷新 / 加载更多控制器
- `JobsRefreshLoadList<T>`：支持下拉刷新、上拉加载、空态、首屏 loading、底部 footer、自定义分隔符、斑马纹的列表组件

## 安装

### 本地 path 依赖

在你的宿主项目 `pubspec.yaml` 里添加：

```yaml
dependencies:
  jobs_refresh_load:
    path: ../jobs_refresh_load
```

然后执行：

```bash
flutter pub get
```

## 使用

```dart
import 'package:flutter/material.dart';
import 'package:jobs_refresh_load/jobs_refresh_load.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late final JobsRefreshLoadController<String> controller;

  @override
  void initState() {
    super.initState();
    controller = JobsRefreshLoadController<String>(
      pageSize: 20,
      fetchPage: (page, pageSize) async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (page > 3) return <String>[];
        return List.generate(
          pageSize,
          (index) => 'item ${(page - 1) * pageSize + index + 1}',
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('jobs_refresh_load demo')),
      body: JobsRefreshLoadList<String>(
        controller: controller,
        zebra: true,
        itemBuilder: (context, item, index) {
          return ListTile(title: Text(item));
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
      ),
    );
  }
}
```

## 发布到 pub 前建议

1. 把 `homepage / repository / issue_tracker` 改成你的真实地址
2. 补 LICENSE
3. 跑一遍：
   ```bash
   flutter analyze
   flutter test
   dart pub publish --dry-run
   ```
