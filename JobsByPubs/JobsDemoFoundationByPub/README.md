# <span id="前言">Jobs Demo Foundation</span>

![Jobs出品，必属精品](https://picsum.photos/1500/400)

---

[**Flutter**](https://flutter.dev/) 演示基础包。公共能力下沉至本目录，具体功能页面位于宿主 `lib/demos/中文功能名/`；页面可以从首页进入，也可以作为独立目标启动。

## 一、组件入口 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

| API | 能力 |
| --- | --- |
| `JobsDemoApp(home:)` | 独立预览壳，包含十语设置和白天／黑夜／跟随系统 |
| `JobsDemoAppBar(title:, actions:)` | 保留原AppBar配置；右侧只有主题或包含全部页面动作的菜单 |
| `JobsDemoActions`、`JobsDemoActionHost` | Cupertino导航动作复用；已有外层导航的捕获入口集中代理内层动作，避免重复按钮 |
| `JobsDemoSettings`、`JobsDemoScope` | 主题与语言状态，使用 SharedPreferences 保存偏好 |
| `tr(context, key)` | 十语业务词库；中文键不存在时保留原文 |
| `JobsSideMenu`、`JobsSideMenuController` | 左边缘滑动、半开／全开、可配置宽度、遮罩／返回／向左拖动关闭 |
| `JobsEmptyState` | 图标、标题、说明及重新加载入口 |
| `JobsAdaptiveRefresh(onRefresh:, onLoadMore:, axis:, historyKey:, child:)` | 全局刷新样式、横纵双端、独立成功时间、运行留区与回弹；保留列表状态 |
| `JobsEdgeRefreshController`、`JobsEdgeRefreshView`、`JobsRefreshIndicator` | 四边状态／自定义教学动效、互斥、失败／无更多及两种角色历史 |
| `JobsRefreshScrollPhysics(maxOverscroll:, parent:)` | 基于 `BouncingScrollPhysics` 的跟手阻尼及弹簧回弹，默认将首尾越界限制在120逻辑像素 |
| `JobsSnowflake`、`JobsDebouncer`、`JobsThrottle` | 本地教学算法；具体签名以公开源码为准 |

## 二、宿主接入 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

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
    appBar: JobsDemoAppBar(title: Text(tr(context, '功能实验室'))),
    body: const Center(child: Text('Jobs')),
  );
}
```

共享根应用可传入 `settings`，或者使用 `JobsDemoScope`、`jobsDemoTheme`、`jobsDemoLocales` 和 `jobsDemoLocalizationDelegates` 自行组装。

Demo导航使用`JobsDemoAppBar`。没有业务动作时，右按钮直接切换白天／黑夜，图标和提示表达下一次点击的行为；已有`IconButton`、文字按钮或泛型`PopupMenuButton`动作时，主题和原动作共用一个下拉菜单，保留回调、禁用与选项。跟随系统仍在原设置中选择，快捷切换写回同一主题偏好。Cupertino导航可将`JobsDemoActions()`放入`trailing`；已有捕获外壳的入口通过`JobsDemoActionHost`和外层`actionHost: true`代理内层动作，不另添导航条。具体Demo和源码独立入口使用同一API。

普通列表通过 `JobsAdaptiveRefresh` 接入 `onRefresh`，可选 `onLoadMore` 和 `axis: Axis.horizontal`；它读取全局 `refreshStyle`，无scope时默认Flutter样式。纵向默认样式保留Material提示，横向使用Jobs四边协议。首端默认刷新、末端默认加载；`reverseRoles`交换角色，实际左右／上下位置与文案由列表的AxisDirection处理，支持reverse和RTL。未配置加载回调的首页不伪造加载更多。

Jobs效果达到64逻辑像素后松手触发，未达阈值或反向收手取消；刷新区随内容露出，运行时保留区域，结束状态展示350ms后用250ms曲线收回，双球只在运行且未减少动态效果时转动。拖动／惯性仍受120逻辑像素边界约束，短列表也可拉动，同一控制器刷新与加载互斥。`hasMore: false`阻止加载并展示无更多；业务恢复更多数据后可重新启用。抛错显示失败并允许重试，不丢原内容或时间。

传入稳定且列表独有的`historyKey`后，`jobs_refresh.<key>.refresh`和`.load`分别保存最近成功完成的时间；无键只保留控制器内存，不能用类名拼接导致不同列表串记录。首次明确无记录，今天／跨日时间按当前语言显示，失败不推进。正常完成的本地演示回退也属已完成操作，不表示服务同步成功。可传入外部`controller`，适配器借用而不销毁；调用方负责释放。示例：

```dart
JobsAdaptiveRefresh(
  historyKey: 'product-gallery',
  axis: Axis.horizontal,
  onRefresh: reload,
  onLoadMore: loadNextPage,
  hasMore: hasMore,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    physics: const JobsRefreshScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
    itemCount: items.length,
    itemBuilder: buildItem,
  ),
)
```

Jobs反馈在有效用户触发和完成／失败时各派发一次，自动首屏及自动预取保持安静；声音和触觉分别由`refreshSound`／`refreshHaptics`控制，默认开启并保存为`jobs_demo_refresh_sound`／`jobs_demo_refresh_haptics`。进入后台、覆盖路由或销毁后不补放；关闭声音立即停止当前提示。音频为[本包原创短WAV](./assets/audio/README.md)，以本地资源播放，iOS遵循静音与音量，不中断其它音乐。无硬件能力仍保留视觉状态，真实听感／触感与通道调用分开验收。

滚动物理从本包聚合入口公开导出。列表显式设置 `physics` 时，可使用 `const JobsRefreshScrollPhysics(parent: AlwaysScrollableScrollPhysics())`；`maxOverscroll` 默认120且必须大于0。拖动及惯性阶段均受限幅，边缘释放使用弹簧回到正常范围，不把内容固定在原位。适配器提供默认值，专门演示其它物理的页面仍可自行显式配置。该物理不新增偏好键，语言／主题和已选刷新样式沿用宿主设置。

## 三、语言与兼容边界 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

业务文案支持简体中文、繁体中文、藏文、英文、日文、法文、西班牙文、德文、俄文和韩文。Flutter 暂无藏语 Material／Cupertino 内置控件词典，因此藏语下的系统控件提示采用英语，业务文案继续使用藏文。未知 Demo 文案没有自动翻译。

本包沿用宿主的 Flutter Material／Cupertino 类型。Flutter 3.50 已将这些入口标为弃用；宿主及既有插件尚未整体迁移到独立 UI 包时，不应局部替换而混用两套 Theme／Scaffold 类型。

菜单只接管左边缘 24 像素的开启手势；正文内部横向滚动保留。完整展开时仍有右上角关闭按钮。设置持久化属于本机演示偏好；解锁和验证码 Demo 均不构成生产认证方案。

## 四、验证 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

在本包目录运行：

```shell
flutter pub get
flutter test
flutter analyze --no-fatal-infos
```

交互测试验证边缘打开、短拖动回收、左滑关闭、全宽布局、遮罩及返回关闭；刷新专项覆盖两种样式的实际内容位移、阻尼限幅、反向收手取消、松手回弹、惯性边缘回弹与请求去重。宿主 [原生能力测试](../../test/native_parity_demos_test.dart)另验证 ID 唯一性、节点位和节流防抖的时序边界。原生硬件能力需在宿主目标设备另验。

## 五、原生功能平行公共组件 <a href="#前言">🔼</a> <a href="#🔚">🔽</a>

- `UiDemoStore`：服务端优先的演示数据源，短超时回退并保留本地可操作状态，后续成功响应恢复真实数据。
- `JobsPointSphere`、`JobsAnalogClock`、`JobsFrozenTable`：透视球面点选、模拟时钟、任意数量冻结列与四种文字布局。
- `JobsScrollingText`、`JobsNotificationQueue`：文字滚动策略与有限并发的通知队列。
- `jobsIconfontSamples`、`JobsIconfontImage` 与图片缓存组件：沿用原生工程的 iconfont 字体和图标数据，资源来源说明见 `assets/fonts/README.md` 与 `assets/iconfont/README.md`。

跨端平台桥接独立位于 `../JobsPlatformLabByPub`；数据与微应用运行时位于 `../JobsLabRuntimeByPub`。

<a id="🔚" href="#前言">返回首页</a>
