# Jobs Demo Foundation

[**Flutter**](https://flutter.dev/) 演示基础包。公共能力下沉至本目录，具体功能页面位于宿主 `lib/demos/中文功能名/`；页面可以从首页进入，也可以作为独立目标启动。

## 一、组件入口

| API | 能力 |
| --- | --- |
| `JobsDemoApp(home:)` | 独立预览壳，包含十语设置和白天／黑夜／跟随系统 |
| `JobsDemoSettings`、`JobsDemoScope` | 主题与语言状态，使用 SharedPreferences 保存偏好 |
| `tr(context, key)` | 十语业务词库；中文键不存在时保留原文 |
| `JobsSideMenu`、`JobsSideMenuController` | 左边缘滑动、半开／全开、可配置宽度、遮罩／返回／向左拖动关闭 |
| `JobsEmptyState` | 图标、标题、说明及重新加载入口 |
| `JobsSnowflake`、`JobsDebouncer`、`JobsThrottle` | 本地教学算法；具体签名以公开源码为准 |

## 二、宿主接入

在宿主 `pubspec.yaml` 声明相对于该配置文件的依赖：

```yaml
dependencies:
  jobs_demo_foundation:
    path: ./JobsByPubs/JobsDemoFoundationByPub
```

独立 Demo 文件保留顶层入口，将实际页面 Widget 同时暴露给首页。不要在已经运行的应用中调用另一个文件的 `main()` 或 `runApp()`。

```dart
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: MyDemo()));

class MyDemo extends StatelessWidget {
  const MyDemo({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '功能实验室'))),
    body: const Center(child: Text('Jobs')),
  );
}
```

共享根应用可传入 `settings`，或者使用 `JobsDemoScope`、`jobsDemoTheme`、`jobsDemoLocales` 和 `jobsDemoLocalizationDelegates` 自行组装。

## 三、语言与兼容边界

业务文案支持简体中文、繁体中文、藏文、英文、日文、法文、西班牙文、德文、俄文和韩文。Flutter 暂无藏语 Material／Cupertino 内置控件词典，因此藏语下的系统控件提示采用英语，业务文案继续使用藏文。未知 Demo 文案没有自动翻译。

本包沿用宿主的 Flutter Material／Cupertino 类型。Flutter 3.50 已将这些入口标为弃用；宿主及既有插件尚未整体迁移到独立 UI 包时，不应局部替换而混用两套 Theme／Scaffold 类型。

菜单只接管左边缘 24 像素的开启手势；正文内部横向滚动保留。完整展开时仍有右上角关闭按钮。设置持久化属于本机演示偏好；解锁和验证码 Demo 均不构成生产认证方案。

## 四、验证

在本包目录运行：

```shell
flutter pub get
flutter test
flutter analyze --no-fatal-infos
```

交互测试验证边缘打开、短拖动回收、左滑关闭、全宽布局、遮罩及返回关闭。宿主 [原生能力测试](../../test/native_parity_demos_test.dart)另验证 ID 唯一性、节点位和节流防抖的时序边界。原生硬件能力需在宿主目标设备另验。

## 三、原生功能平行公共组件

- `UiDemoStore`：服务端优先的演示数据源，短超时回退并保留本地可操作状态，后续成功响应恢复真实数据。
- `JobsPointSphere`、`JobsAnalogClock`、`JobsFrozenTable`：透视球面点选、模拟时钟、任意数量冻结列与四种文字布局。
- `JobsScrollingText`、`JobsNotificationQueue`：文字滚动策略与有限并发的通知队列。
- `jobsIconfontSamples`、`JobsIconfontImage` 与图片缓存组件：沿用原生工程的 iconfont 字体和图标数据，资源来源说明见 `assets/fonts/README.md` 与 `assets/iconfont/README.md`。

跨端平台桥接独立位于 `../JobsPlatformLabByPub`；数据与微应用运行时位于 `../JobsLabRuntimeByPub`。
