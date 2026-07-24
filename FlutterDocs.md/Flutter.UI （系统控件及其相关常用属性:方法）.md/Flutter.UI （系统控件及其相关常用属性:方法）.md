# Flutter UI 系统控件与常用属性手册

![Jobs出品，必属精品](https://picsum.photos/1500/400)

[toc]

---

## 🔥 <font id=前言>前言</font>

> 本文按“应用入口 → 页面骨架 → 布局 → 输入 → 交互 → 滚动 → 导航 → 反馈 → 异步 → 适配”的顺序整理 [**Flutter**](https://flutter.dev/) 常用 UI 能力。示例以当前 Material 3 API 为主；具体属性仍应以项目锁定的 Flutter SDK 文档为准。

- 代码示例优先展示可复用的核心写法，不为每个 Widget 重复搭建完整 App。
- `Widget` 是不可变配置；需要持有控制器、焦点或局部可变状态时使用 `StatefulWidget`，并在 `dispose()` 中释放资源。
- 项目自定义图标优先从 [**iconfont**](https://www.iconfont.cn/) 选取并接入统一资源层；系统语义明确的通用图标可以使用 `Icons` 或 `CupertinoIcons`。

## 一、控件选型总览 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 1.1、按场景选择 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 场景 | 首选能力 | 说明 |
| --- | --- | --- |
| Material 应用入口 | `MaterialApp` / `MaterialApp.router` | 主题、路由、本地化与顶层 Navigator |
| iOS 视觉入口 | `CupertinoApp` / `CupertinoApp.router` | Cupertino 主题、滚动物理与路由过渡 |
| 标准页面骨架 | `Scaffold` | AppBar、主体、抽屉、底栏、FAB、BottomSheet |
| 单子节点装饰 | `Container` / `DecoratedBox` | 尺寸、约束、背景、边框、阴影、变换 |
| 线性布局 | `Row` / `Column` / `Flex` | 主轴与交叉轴排列 |
| 自动换行 | `Wrap` | 标签、按钮组等可换行内容 |
| 重叠布局 | `Stack` + `Positioned` | 浮层、角标、图片叠字 |
| 少量内容滚动 | `SingleChildScrollView` | 只有一个子节点，适合短表单或短页面 |
| 大量线性数据 | `ListView.builder` / `ListView.separated` | 按需构建列表项 |
| 大量网格数据 | `GridView.builder` | 按需构建网格项 |
| 混合滚动结构 | `CustomScrollView` + Sliver | SliverAppBar、列表、网格混排 |
| 响应式适配 | `LayoutBuilder` / `MediaQuery` | 按父约束或窗口信息布局 |
| 系统安全区 | `SafeArea` | 避开刘海、状态栏和系统手势区 |

### 1.2、布局约束核心 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- Flutter 布局遵循：**约束向下传递，尺寸向上传递，父节点决定位置**。
- `Container(width: 100)` 的宽度仍受父约束限制，并不是无条件得到 100。
- Flutter 没有给 `width` / `height` 直接传百分比的语法；比例尺寸通常通过 `FractionallySizedBox`、`LayoutBuilder` 或父约束计算。
- `Expanded` 只能放在 `Row`、`Column` 或 `Flex` 的后代链上；把它放进 `Stack`、`ListView` 等位置会触发 ParentData 错误。

## 二、应用入口与主题 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 2.1、`MaterialApp` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `MaterialApp` 是 Material Design 应用的便利入口，负责组装主题、本地化、顶层 Navigator、Hero 等常用能力。
- `title` 的类型是 `String?`，用于操作系统任务列表或 Web 页面标题；需要本地化标题时使用 `onGenerateTitle`，不能传 `Text`。
- 顶层路由匹配顺序为：`home` → `routes` → `onGenerateRoute` → `onUnknownRoute`。
- `onGenerateRoute`、`onUnknownRoute` 和 `navigatorObservers` 属于**路由管理能力**，不是应用生命周期回调。
- 使用声明式路由或深链体系时，优先考虑 `MaterialApp.router` 与 `RouterConfig`。

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const JobsApp());
}

class JobsApp extends StatelessWidget {
  const JobsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jobs Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(height: 1.5),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}
```

### 2.2、`ThemeData`、`ColorScheme` 与 `TextTheme` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- Material 3 已是当前默认方向。Material 组件主要从 `ThemeData.colorScheme` 和 `ThemeData.textTheme` 取得默认值。
- 全局颜色优先使用 `ColorScheme.fromSeed()` 或完整的 `ColorScheme`，不要继续依赖旧版 `accentColor`。
- 文本样式使用 `displayLarge`、`headlineMedium`、`titleLarge`、`bodyMedium`、`labelLarge` 等新命名，不再使用 `headline1`、`bodyText1` 等旧命名。
- 单类组件的全局样式使用对应 Theme，例如 `appBarTheme`、`filledButtonTheme`、`inputDecorationTheme`、`cardTheme`。
- 局部覆盖主题时，使用 `Theme(data: Theme.of(context).copyWith(...), child: ...)`，避免把临时样式写进全局主题。

```dart
final theme = Theme.of(context);
final colors = theme.colorScheme;

return Card(
  color: colors.surfaceContainer,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Text(
      '主题化内容',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colors.onSurface,
      ),
    ),
  ),
);
```

### 2.3、`CupertinoApp` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `CupertinoApp` 提供 iOS 风格的主题、滚动物理和路由过渡，但不是使用 Cupertino Widget 的强制前提。
- `home` 的类型是 `Widget?`，并非必填；如果 `home`、`routes`、`onGenerateRoute` 和 `onUnknownRoute` 都为空，则需要通过 `builder` 提供内容。
- 在 Android 上全量使用 `CupertinoApp` 会带来 iOS 式返回手势与弹性滚动，应确认这是否符合产品预期。

```dart
import 'package:flutter/cupertino.dart';

class JobsCupertinoApp extends StatelessWidget {
  const JobsCupertinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Jobs Cupertino Demo',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('首页'),
        ),
        child: SafeArea(
          child: Center(child: Text('Cupertino 内容')),
        ),
      ),
    );
  }
}
```

## 三、页面骨架与全局反馈 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 3.1、`Scaffold` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 属性 | 作用 |
| --- | --- |
| `appBar` | 顶部应用栏 |
| `body` | 页面主体 |
| `floatingActionButton` | 浮动操作按钮 |
| `bottomNavigationBar` | 底部导航或工具栏 |
| `drawer` / `endDrawer` | 左侧 / 右侧抽屉 |
| `bottomSheet` | 持久底部面板 |
| `resizeToAvoidBottomInset` | 键盘出现时是否调整主体尺寸 |

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter UI'),
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const SafeArea(
        child: Center(child: Text('页面主体')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已触发操作')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 3.2、`ScaffoldMessenger`、SnackBar 与 BottomSheet <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- SnackBar 使用 `ScaffoldMessenger.of(context).showSnackBar()`；旧的 `Scaffold.of(context).showSnackBar()` 写法不应继续使用。
- `ScaffoldMessengerState` 负责 SnackBar 和 MaterialBanner，不负责提供“删除当前 BottomSheet”的 API。
- 持久 BottomSheet 使用 `ScaffoldState.showBottomSheet()` 或 `Scaffold.bottomSheet`；模态 BottomSheet 使用 `showModalBottomSheet()`。
- `showBottomSheet()` 会返回 `PersistentBottomSheetController`，通过该控制器关闭或刷新面板。

```dart
Future<void> openActions(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: ListTile(
          leading: const Icon(Icons.share),
          title: const Text('分享'),
          onTap: () => Navigator.pop(context),
        ),
      );
    },
  );
}
```

### 3.3、抽屉 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- Material 3 优先考虑 `NavigationDrawer`；已有 Material 2 页面仍可继续使用 `Drawer`。
- 抽屉内容本质上是普通 Widget 树，没有 `drawerHeader`、`type`、`scrollController` 等 `Drawer` 构造属性；这些能力应在 `child` 内通过 `DrawerHeader`、`ListView` 和控制器实现。

## 四、尺寸、约束与布局 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 4.1、单子节点控件 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| Widget | 适用场景 | 关键属性 |
| --- | --- | --- |
| `SizedBox` | 固定尺寸或间距 | `width`、`height` |
| `Padding` | 内边距 | `padding` |
| `Align` | 对齐并可调尺寸因子 | `alignment`、`widthFactor`、`heightFactor` |
| `Center` | 居中 | `widthFactor`、`heightFactor` |
| `ConstrainedBox` | 追加尺寸约束 | `constraints` |
| `FractionallySizedBox` | 按父尺寸比例布局 | `widthFactor`、`heightFactor` |
| `AspectRatio` | 固定宽高比 | `aspectRatio` |
| `FittedBox` | 缩放并适配子节点 | `fit`、`alignment` |
| `DecoratedBox` | 只做装饰 | `decoration`、`position` |
| `Transform` | 绘制阶段变换 | `transform`、`alignment` |

### 4.2、`Container` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `Container` 是组合便利控件，常用于 `alignment`、`padding`、`color`、`decoration`、`constraints`、`margin` 和 `transform`。
- `color` 与 `decoration` 不能同时设置；需要复杂背景时，把颜色写进 `BoxDecoration.color`。
- `decoration` 绘制在 child 后方，`foregroundDecoration` 绘制在 child 前方。
- 需要轻量表达时优先使用更单一的 `SizedBox`、`Padding`、`ColoredBox` 或 `DecoratedBox`。

```dart
Container(
  constraints: const BoxConstraints(
    minWidth: 120,
    maxWidth: 320,
  ),
  margin: const EdgeInsets.all(16),
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  ),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainer,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(
        blurRadius: 12,
        color: Color(0x22000000),
      ),
    ],
  ),
  child: const Text('Container 内容'),
)
```

### 4.3、`Row`、`Column`、`Flex` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `Row` 的主轴是水平轴，`Column` 的主轴是垂直轴；`Flex` 通过 `direction` 自定义方向。
- `mainAxisAlignment` 控制主轴位置，`crossAxisAlignment` 控制交叉轴位置。
- `mainAxisSize` 决定是否尽量占满主轴。
- 使用 `CrossAxisAlignment.baseline` 时必须同时提供 `textBaseline`。

### 4.4、`Expanded`、`Flexible`、`Spacer` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `Expanded` 等价于 `Flexible(fit: FlexFit.tight)`，要求子节点填满分配到的剩余空间。
- `Flexible` 默认使用 `FlexFit.loose`，子节点可以小于分配空间。
- `flex` 表示剩余空间的分配权重，不是像素值。
- `Spacer` 是只占弹性空间的便利控件。

```dart
Row(
  children: [
    const SizedBox(width: 96, child: Text('固定区域')),
    Expanded(
      child: Container(
        height: 48,
        color: Colors.blue,
      ),
    ),
    const Spacer(),
    const Icon(Icons.chevron_right),
  ],
)
```

### 4.5、`Wrap` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `Wrap` 会在主轴空间不足时自动换行，适合标签、筛选项和按钮组。
- `spacing` 是同一行项目间距，`runSpacing` 是行与行之间的间距。

### 4.6、`Stack` 与 `Positioned` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `Stack` 按 children 顺序绘制，后面的 child 位于上层。
- 非定位子节点由 `alignment` 与 `fit` 布局；`Positioned` 子节点使用 `top`、`right`、`bottom`、`left` 或尺寸定位。
- 旧的 `overflow` 属性已经移除，使用 `clipBehavior`；默认值为 `Clip.hardEdge`。

```dart
Stack(
  clipBehavior: Clip.none,
  children: [
    const CircleAvatar(radius: 32),
    Positioned(
      right: -2,
      top: -2,
      child: Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    ),
  ],
)
```

### 4.7、`LayoutBuilder` 与响应式布局 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 720) {
      return const Row(
        children: [
          SizedBox(width: 240, child: Text('侧栏')),
          Expanded(child: Text('宽屏内容')),
        ],
      );
    }
    return const Column(
      children: [
        Text('窄屏标题'),
        Text('窄屏内容'),
      ],
    );
  },
)
```

## 五、文本、表单与焦点 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 5.1、文本控件 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| Widget | 用途 |
| --- | --- |
| `Text` | 普通文本 |
| `RichText` / `Text.rich` | 多样式文本片段 |
| `SelectableText` | 可选择、复制的文本 |
| `DefaultTextStyle` | 给子树提供默认文本样式 |

- 文本溢出常用 `maxLines`、`softWrap` 和 `overflow: TextOverflow.ellipsis`。
- 字体缩放应尊重 `MediaQuery.textScalerOf(context)`；不要为了视觉固定而全局禁用无障碍字号。

### 5.2、`TextField` 与 `TextFormField` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `TextField` 适合独立输入；`TextFormField` 适合和 `Form`、`validator` 组合。
- `TextEditingController`、`FocusNode` 等长期对象应由 `State` 持有并在 `dispose()` 中释放。
- 密码输入使用 `obscureText`，键盘类型使用 `keyboardType`，提交动作使用 `textInputAction`。
- 需要输入格式约束时使用 `inputFormatters`，不要只在提交时被动修正。

```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _accountFocusNode = FocusNode();

  @override
  void dispose() {
    _accountController.dispose();
    _accountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _accountController,
            focusNode: _accountFocusNode,
            decoration: const InputDecoration(
              labelText: '账号',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入账号';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                FocusScope.of(context).unfocus();
              }
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }
}
```

## 六、按钮、图标与菜单 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 6.1、Material 3 按钮 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| Widget | 典型语义 |
| --- | --- |
| `FilledButton` | 主要操作 |
| `FilledButton.tonal` | 次要但需要强调的操作 |
| `ElevatedButton` | 需要抬升层次的按钮 |
| `OutlinedButton` | 中等强调操作 |
| `TextButton` | 低强调操作 |
| `IconButton` | 图标操作 |
| `FloatingActionButton` | 页面主要浮动操作 |

- `onPressed` / `onLongPress` 为 `null` 时按钮处于禁用状态。
- 旧 `MaterialButton` 已进入迁移路径，新代码使用上表按钮及其 Theme。
- 图标按钮应提供 `tooltip`，提升可发现性与无障碍体验。

### 6.2、菜单 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- Material 3 项目优先使用 `MenuAnchor`、`MenuItemButton` 和 `SubmenuButton`。
- `PopupMenuButton<T>` 仍可用，其 `itemBuilder` 签名是 `List<PopupMenuEntry<T>> Function(BuildContext context)`，没有索引参数。

```dart
PopupMenuButton<String>(
  tooltip: '更多操作',
  onSelected: (value) {},
  itemBuilder: (context) {
    return const [
      PopupMenuItem(
        value: 'edit',
        child: Text('编辑'),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Text('删除'),
      ),
    ];
  },
)
```

## 七、列表、网格与组合滚动 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 7.1、`SingleChildScrollView` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 只有一个 child，适合内容量可控的表单或说明页。
- 不适合直接承载大量动态子节点；`Column(children: hugeList)` 会一次性构建全部内容。
- 与 `Column` 组合时注意无界高度问题，不要在其内部随意放 `Expanded`。

### 7.2、`ListView` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 少量静态子节点可用默认构造；大量或无限数据使用 `ListView.builder`。
- 需要分割线时使用 `ListView.separated`。
- `itemExtent` 或 `prototypeItem` 能让框架提前知道列表项高度，适合等高列表优化。
- `cacheExtent` / 新版 `scrollCacheExtent` 描述的是视口前后的缓存区域，不是“预加载多少个子节点”。
- `addAutomaticKeepAlives` 只是允许后代通过 keep-alive 协议申请保活，并不等于所有列表项永久保留状态。
- `shrinkWrap: true` 会增加布局成本，应只在确实需要内容决定滚动轴尺寸时使用。

```dart
ListView.separated(
  itemCount: 100,
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text('第 ${index + 1} 项'),
      onTap: () {},
    );
  },
)
```

### 7.3、`GridView` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `SliverGridDelegateWithFixedCrossAxisCount` 固定交叉轴数量。
- `SliverGridDelegateWithMaxCrossAxisExtent` 固定单元格最大交叉轴尺寸，更适合响应式宽度。
- 大量数据使用 `GridView.builder`，避免预先构建全部 children。

```dart
GridView.builder(
  padding: const EdgeInsets.all(16),
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 240,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.4,
  ),
  itemCount: 40,
  itemBuilder: (context, index) {
    return Card(
      child: Center(child: Text('Item $index')),
    );
  },
)
```

### 7.4、`CustomScrollView` 与 Sliver <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 同一滚动区域需要组合 AppBar、列表、网格时使用 `CustomScrollView`。
- 常用 Sliver：`SliverAppBar`、`SliverList`、`SliverGrid`、`SliverPadding`、`SliverToBoxAdapter`。
- 不要嵌套多个同方向滚动容器来模拟混合页面，优先统一到 Sliver。

### 7.5、刷新与分页 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 下拉刷新使用 `RefreshIndicator` 包裹可滚动组件。
- 分页加载通常监听 `ScrollController.position` 或使用业务层分页状态；控制器应在 `dispose()` 中释放。
- 列表状态至少区分：首次加载、空数据、加载成功、追加加载、失败重试。

## 八、导航、底栏与标签页 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 8.1、`Navigator` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `Navigator.push()` 将 Route 压栈，`Navigator.pop()` 弹出当前 Route。
- 页面返回值通过 `Navigator.pop(context, result)` 传出，调用方 `await Navigator.push<T>()` 接收。
- `BuildContext` 必须位于目标 Navigator 的下方；多 Navigator 场景要明确使用根导航还是局部导航。
- 返回拦截使用 `PopScope`，不要继续新增 `WillPopScope`。

```dart
final confirmed = await Navigator.of(context).push<bool>(
  MaterialPageRoute(
    builder: (context) => const DetailPage(),
  ),
);

if (confirmed == true && context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('操作成功')),
  );
}
```

### 8.2、命名路由与 Router <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 小型应用可以使用 `routes` 与 `onGenerateRoute`。
- Web 深链、状态恢复、复杂嵌套路由和多导航栈场景，优先使用 Router API 或成熟路由库。
- `navigatorKey` 允许脱离局部 context 操作顶层 Navigator，但不应成为绕过页面边界的全局业务入口。

### 8.3、`NavigationBar` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- Material 3 底部主导航优先使用 `NavigationBar` + `NavigationDestination`。
- `selectedIndex` 默认是 0，`onDestinationSelected` 返回新索引。
- `BottomNavigationBar` 仍可用于旧 Material 2 页面；其 `currentIndex` 也有默认值 0，并非必填属性。

### 8.4、`TabBar` 与 `TabBarView` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 两者必须共享同一个 `TabController`；简单页面可使用 `DefaultTabController`。
- Tab 数量必须与 `TabBarView.children` 数量一致。
- 自行持有 `TabController` 时，`State` 需要混入 `TickerProviderStateMixin` 或 `SingleTickerProviderStateMixin`，并在 `dispose()` 中释放控制器。

## 九、选择、弹窗与进度反馈 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 9.1、选择控件 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| Widget | 用途 |
| --- | --- |
| `Checkbox` / `CheckboxListTile` | 多选 |
| `Radio` / `RadioListTile` | 单选 |
| `Switch` / `SwitchListTile` | 开关状态 |
| `Slider` / `RangeSlider` | 连续值或范围 |
| `DropdownMenu` | 下拉选择 |
| `SegmentedButton` | Material 3 分段选择 |

- 受控选择组件的值来自状态，回调只负责更新状态。
- 禁用状态通过把回调设为 `null` 表达，不用额外拦截点击。

### 9.2、对话框与选择器 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 普通确认框使用 `showDialog()` + `AlertDialog`。
- iOS 风格对话框使用 `showCupertinoDialog()` + `CupertinoAlertDialog`。
- 日期与时间使用 `showDatePicker()`、`showTimePicker()`。
- 弹窗返回值与路由一致，通过 `Navigator.pop(context, result)` 返回。

### 9.3、进度与骨架状态 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 不确定进度使用 `CircularProgressIndicator` / `LinearProgressIndicator`。
- 已知进度传入 `value`，范围通常为 0～1。
- 长耗时任务要提供可理解的状态文案；只有转圈而没有业务状态，不利于错误恢复。

## 十、异步、图片与动态内容 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 10.1、`FutureBuilder` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `future` 应在 `initState()`、`didUpdateWidget()` 或状态管理层创建；不要在 `build()` 中每次重新创建同一个请求。
- 根据 `snapshot.connectionState`、`snapshot.hasError` 和 `snapshot.hasData` 明确渲染加载、失败、空态与成功态。

### 10.2、`StreamBuilder` <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 适合持续事件流；订阅对象变化时要保证旧 Stream 能正确释放。
- 页面只消费数据，不要在 `builder` 中执行写入、导航或网络请求等副作用。

### 10.3、图片 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| Widget / 构造 | 用途 |
| --- | --- |
| `Image.asset` | Flutter 资源图片 |
| `Image.network` | 网络图片 |
| `Image.file` | 本地文件图片 |
| `Image.memory` | 内存字节图片 |
| `FadeInImage` | 占位图淡入 |

- 资源图片需要在 `pubspec.yaml` 的 `flutter.assets` 中声明。
- 网络图片要处理 `loadingBuilder` / `frameBuilder` 与 `errorBuilder`。
- 大图应按展示尺寸解码，可结合 `cacheWidth` / `cacheHeight` 降低内存压力。
- `BoxFit.cover` 会裁剪，`BoxFit.contain` 会完整显示但可能留白。

## 十一、适配、无障碍与交互边界 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 11.1、屏幕与窗口信息 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- `MediaQuery.sizeOf(context)`：当前视图尺寸。
- `MediaQuery.paddingOf(context)`：系统遮挡区域。
- `MediaQuery.viewInsetsOf(context)`：键盘等完全遮挡区域。
- `MediaQuery.textScalerOf(context)`：文本缩放策略。
- 只依赖某一项数据时优先使用对应的 `...Of` 方法，避免订阅整个 `MediaQueryData`。

### 11.2、安全区与键盘 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 根页面常用 `SafeArea`，但不要在嵌套页面重复叠加相同方向的安全区。
- 点击空白收起键盘可以调用 `FocusManager.instance.primaryFocus?.unfocus()`。
- 表单被键盘遮挡时，结合 `Scaffold.resizeToAvoidBottomInset`、滚动容器和 `viewInsets` 处理，不能只靠硬编码底部间距。

### 11.3、无障碍 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 图标按钮提供 `tooltip`。
- 纯视觉图形使用 `Semantics` 补充 `label`、`button`、`selected` 等语义。
- 颜色不能成为表达状态的唯一方式，还应配合文字、图标或形状。
- 触控目标需要保留合理尺寸，避免为了视觉紧凑压缩到难以点击。

## 十二、性能与生命周期检查 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

### 12.1、构建性能 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 能使用 `const` 的不可变 Widget 使用 `const`，减少不必要的对象创建与对比工作。
- 拆小 Widget 是为了缩小重建边界和明确职责，不是机械追求文件数量。
- `build()` 应保持纯粹，不发请求、不改状态、不启动定时器。
- 大列表使用 builder 构造；避免在 `build()` 中执行大 JSON 解析或复杂同步计算。

### 12.2、资源释放 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- 在 `dispose()` 中释放 `AnimationController`、`TabController`、`TextEditingController`、`FocusNode`、`ScrollController`、Stream 订阅和定时器。
- 异步回调更新页面前检查 `context.mounted` 或 `mounted`，同时优先从源头取消不再需要的任务。
- `setState()` 只能在 `State` 仍 mounted 时调用。

### 12.3、常见布局错误 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 现象 | 常见原因 | 处理方式 |
| --- | --- | --- |
| `RenderFlex overflowed` | Row / Column 子节点超出主轴 | 使用 `Expanded`、`Flexible`、换行或滚动 |
| `Vertical viewport was given unbounded height` | 纵向滚动组件处于无界高度 | 给明确约束，或统一到一个滚动容器 |
| `Incorrect use of ParentDataWidget` | `Expanded` / `Positioned` 放错父级 | 检查其要求的 `Flex` / `Stack` 祖先 |
| `setState() called after dispose()` | 异步回调未取消 | 释放订阅、取消任务并检查 mounted |
| 文本黄底红字 | 缺少 Material / DefaultTextStyle 祖先 | 使用 `MaterialApp`、`Scaffold` 或 `Material` |

## 十三、旧写法纠错表 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

| 旧表述或写法 | 当前建议 |
| --- | --- |
| `MaterialApp.title` 可以传 `Text` | `title` 是 `String?`；本地化使用 `onGenerateTitle` |
| `ThemeData.accentColor` | 使用 `ColorScheme.secondary` 或组件 Theme |
| `headline1`、`bodyText1` | 使用 `displayLarge`、`headline...`、`body...`、`label...` |
| `buttonTheme` 控制所有新按钮 | 使用 `filledButtonTheme`、`elevatedButtonTheme`、`outlinedButtonTheme`、`textButtonTheme` |
| `ThemeData.elevationTheme` / `ElevationThemeData` | 没有这组通用 Theme API；使用组件 Theme、`shadowColor`、`surfaceTintColor` 或 `BoxShadow` |
| `Stack.overflow` | 使用 `clipBehavior` |
| `Container` 宽高可直接传百分比 | 使用 `FractionallySizedBox` 或根据约束计算 |
| `Scaffold.of(context).showSnackBar()` | 使用 `ScaffoldMessenger.of(context).showSnackBar()` |
| `PopupMenuButton.itemBuilder` 接收 context 和 index | 只接收 `BuildContext` 并返回 `List<PopupMenuEntry<T>>` |
| `ListView.cacheExtent` 是预加载条目数 | 它描述缓存区域；按当前 SDK 关注 `scrollCacheExtent` 迁移 |
| `onGenerateRoute` 属于生命周期 | 它属于命名路由生成 |
| `CupertinoApp.home` 必填 | `home` 可空，但必须通过路由或 `builder` 提供有效内容 |
| `BottomNavigationBar.currentIndex` 必填 | 默认值为 0；Material 3 新页面优先 `NavigationBar` |
| `Drawer` 有 `type`、`drawerHeader` 等属性 | 这些内容需要在 `Drawer.child` 内自行组合 |

## 十四、官方资料 <a href="#前言" style="font-size:17px; color:green;"><b>🔼</b></a><a href="#🔚" style="font-size:17px; color:green;"><b>🔽</b></a>

- [**Flutter Widget 目录**](https://docs.flutter.dev/ui/widgets)
- [**MaterialApp API**](https://api.flutter.dev/flutter/material/MaterialApp-class.html)
- [**ThemeData API**](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [**ColorScheme API**](https://api.flutter.dev/flutter/material/ColorScheme-class.html)
- [**CupertinoApp API**](https://api.flutter.dev/flutter/cupertino/CupertinoApp-class.html)
- [**ListView API**](https://api.flutter.dev/flutter/widgets/ListView-class.html)
- [**Stack API**](https://api.flutter.dev/flutter/widgets/Stack-class.html)
- [**PopupMenuButton API**](https://api.flutter.dev/flutter/material/PopupMenuButton-class.html)

<a id="🔚" href="#前言" style="font-size:17px; color:green; font-weight:bold;">我是有底线的➤点我回到首页</a>
