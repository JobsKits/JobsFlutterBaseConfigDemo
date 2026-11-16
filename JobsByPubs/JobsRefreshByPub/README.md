# <span id="前言">jobs_refresh_load</span>

一个使用本仓公共基础包的[**Flutter**](https://flutter.dev/)分页组件，提供：

- `JobsRefreshLoadController<T>`：分页刷新 / 加载更多控制器
- `JobsRefreshLoadList<T>`：全局默认／Jobs样式、横纵刷新和加载、空态、首屏loading、footer、分隔符和主题斑马纹

本包随工程以本地 `path` 依赖使用，`publish_to: none` 与同类公共包一致；开源源码不依赖发布到 pub.dev。

`scrollDirection`默认纵向，横向传`Axis.horizontal`，支持`reverse`；横向条目默认宽220，可调`horizontalItemExtent`。默认达到边缘后继续拖动并松手加载，`autoLoadMore: true`可恢复距离尾部200像素的自动预取；自动预取不响音／触觉。刷新与加载共用互斥状态，失败不改变页码或原数据，重试仍请求同一页，销毁后不通知。

控制器可传`historyKey`独立保存上次刷新／加载时间，首次无记录、失败不推进；键和反馈机制复用[Foundation](../JobsDemoFoundationByPub/README.md)。`lastRefreshedAt`、`lastLoadedAt`、`error`及`edgeController`可供宿主观察。空列表保留完整空态／重载，普通footer始终提示状态和上次加载时间；无更多由返回条数与`pageSize`确定，刷新成功可重新启用加载。

## 安装 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 本地 path 依赖 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

在你的宿主项目 `pubspec.yaml` 里添加：

```yaml
dependencies:
  jobs_refresh_load:
    path: ./JobsByPubs/JobsRefreshByPub
```

然后执行：

```bash
flutter pub get
```

## 使用 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

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
      historyKey: 'example-products',
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
        scrollDirection: Axis.vertical,
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

## 发布到 pub 前建议 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a> <a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

1. 把 `homepage / repository / issue_tracker` 改成你的真实地址
2. 补 LICENSE
3. 跑一遍：
   ```bash
   flutter analyze
   flutter test
   dart pub publish --dry-run
   ```

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
