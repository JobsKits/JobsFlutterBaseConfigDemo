import 'package:flutter/material.dart';

import 'demo_app.dart';
import 'demo_strings.dart';

/// Demo的原导航配置保持不变，右侧统一为主题或页面动作入口。
class JobsDemoAppBar extends AppBar {
  JobsDemoAppBar({
    super.key,
    super.leading,
    super.automaticallyImplyLeading,
    super.title,
    List<Widget>? actions,
    bool actionHost = false,
    super.automaticallyImplyActions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.notificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    super.backgroundColor,
    super.foregroundColor,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary,
    super.centerTitle,
    super.excludeHeaderSemantics,
    super.titleSpacing,
    super.toolbarOpacity,
    super.bottomOpacity,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.systemOverlayStyle,
    super.forceMaterialTransparency,
    super.useDefaultSemanticsOrder,
    super.clipBehavior,
    super.actionsPadding,
    super.animateColor,
  }) : super(
         actions: [
           JobsDemoActions(
             actions: actions ?? const [],
             actionHost: actionHost,
           ),
         ],
       );
}

/// 旧入口捕获壳已有导航时，内层Demo把动作交给该壳，避免两排右按钮。
class JobsDemoActionHost extends StatefulWidget {
  const JobsDemoActionHost({super.key, required this.child});
  final Widget child;

  @override
  State<JobsDemoActionHost> createState() => _JobsDemoActionHostState();
}

class _JobsDemoActionHostState extends State<JobsDemoActionHost> {
  final registry = _ActionRegistry();

  @override
  void dispose() {
    registry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _ActionScope(registry: registry, child: widget.child);
}

class _ActionRegistry extends ChangeNotifier {
  final entries = <Object, List<Widget>>{};
  bool disposed = false;
  List<Widget> get actions => entries.values.lastOrNull ?? const [];

  void put(Object owner, List<Widget>? actions) {
    if (disposed) return;
    entries.remove(owner);
    if (actions != null) entries[owner] = actions;
    notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    entries.clear();
    super.dispose();
  }
}

class _ActionScope extends InheritedWidget {
  const _ActionScope({required this.registry, required super.child});
  final _ActionRegistry registry;

  @override
  bool updateShouldNotify(_ActionScope oldWidget) =>
      registry != oldWidget.registry;
}

/// Cupertino导航也可直接复用，所有业务动作保留回调和禁用状态。
class JobsDemoActions extends StatefulWidget {
  const JobsDemoActions({
    super.key,
    this.actions = const [],
    this.actionHost = false,
  });
  final List<Widget> actions;
  final bool actionHost;

  @override
  State<JobsDemoActions> createState() => _JobsDemoActionsState();
}

class _JobsDemoActionsState extends State<JobsDemoActions> {
  _ActionRegistry? registry;
  int revision = 0;
  bool opened = false;
  bool current = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = context
        .dependOnInheritedWidgetOfExactType<_ActionScope>()
        ?.registry;
    if (registry != next) {
      final previous = registry;
      if (previous != null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => previous.put(this, null),
        );
      }
      registry = next;
    }
    current = ModalRoute.of(context)?.isCurrent ?? true;
    publish();
  }

  @override
  void didUpdateWidget(JobsDemoActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    publish();
  }

  void publish() {
    final target = registry;
    if (target == null || widget.actionHost) return;
    final request = ++revision;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && request == revision && current) {
        // Popup覆盖同一路由时保留注册；新页面自行置顶，返回时旧页再接回。
        target.put(this, widget.actions);
      }
    });
  }

  @override
  void dispose() {
    revision++;
    final target = registry;
    if (target != null && !widget.actionHost) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => target.put(this, null),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (registry != null && !widget.actionHost) return const SizedBox.shrink();
    if (widget.actionHost && registry != null) {
      return ListenableBuilder(
        listenable: registry!,
        builder: (context, _) =>
            button([...widget.actions, ...registry!.actions]),
      );
    }
    return button(widget.actions);
  }

  Widget button(List<Widget> original) {
    JobsDemoStrings.registerTranslations(_actionTranslations);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final label = tr(context, dark ? '切换到白天' : '切换到黑夜');
    final icon = Icon(
      dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
    );
    void toggle() => JobsDemoScope.maybeOf(
      context,
    )?.setThemeMode(dark ? ThemeMode.light : ThemeMode.dark);
    final entries = menuEntries(original);
    if (entries.isEmpty) {
      return IconButton(
        key: const ValueKey('demo-theme-action'),
        tooltip: label,
        onPressed: toggle,
        icon: icon,
      );
    }
    return PopupMenuButton<VoidCallback>(
      key: const ValueKey('demo-actions-menu'),
      tooltip: tr(context, '更多'),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      icon: Icon(opened ? Icons.more_horiz : Icons.more_horiz_outlined),
      onOpened: () => setState(() => opened = true),
      onCanceled: () => setState(() => opened = false),
      onSelected: (action) {
        setState(() => opened = false);
        action();
      },
      itemBuilder: (_) => [
        PopupMenuItem<VoidCallback>(
          key: const ValueKey('demo-theme-menu-item'),
          value: toggle,
          child: Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Flexible(child: Text(label)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ...entries,
      ],
    );
  }

  List<PopupMenuEntry<VoidCallback>> menuEntries(List<Widget> actions) {
    final entries = <PopupMenuEntry<VoidCallback>>[];
    for (final action in actions) {
      if (action is IconButton) {
        final label = action.tooltip ?? iconLabel(action.icon);
        entries.add(
          PopupMenuItem<VoidCallback>(
            key: action.key,
            enabled: action.onPressed != null,
            value: action.onPressed,
            child: Row(
              children: [
                action.icon,
                const SizedBox(width: 12),
                Flexible(child: Text(label)),
              ],
            ),
          ),
        );
      } else if (action is ButtonStyleButton) {
        entries.add(
          PopupMenuItem<VoidCallback>(
            key: action.key,
            enabled: action.onPressed != null,
            value: action.onPressed,
            child: action.child ?? Text(tr(context, '页面操作')),
          ),
        );
      } else if (action is PopupMenuButton) {
        for (final item in action.itemBuilder(context)) {
          if (item is PopupMenuItem) {
            void select() {
              item.onTap?.call();
              // 泛型菜单的回调保留原类型，不能降为(dynamic)函数后读取。
              final Function? callback = (action as dynamic).onSelected;
              if (item.value != null && callback != null) {
                Function.apply(callback, [item.value]);
              }
            }

            entries.add(
              PopupMenuItem<VoidCallback>(
                key: item.key,
                enabled: action.enabled && item.enabled,
                height: item.height,
                padding: item.padding,
                value: select,
                child: item is CheckedPopupMenuItem
                    ? Row(
                        children: [
                          Icon(item.checked ? Icons.check : null),
                          const SizedBox(width: 12),
                          Flexible(child: item.child!),
                        ],
                      )
                    : item.child,
              ),
            );
          } else if (item is PopupMenuDivider) {
            entries.add(PopupMenuDivider(height: item.height));
          }
        }
      } else if (action is! SizedBox) {
        // 自定义工具维持原Widget，不猜测或模拟其业务事件。
        entries.add(PopupMenuItem<VoidCallback>(enabled: false, child: action));
      }
    }
    return entries;
  }

  String iconLabel(Widget widget) {
    if (widget is Icon) {
      if (widget.icon == Icons.language) return tr(context, '语言');
      if (widget.icon == Icons.brightness_6) return tr(context, '主题示例');
    }
    return tr(context, '页面操作');
  }
}

const _actionTranslations = <String, List<String>>{
  '切换到白天': [
    '切换到白天',
    '切換到白天',
    'ཉིན་མོའི་རྣམ་པར་བརྗེ་བ།',
    'Switch to light',
    'ライトに切り替え',
    'Passer au thème clair',
    'Cambiar a claro',
    'Zum hellen Design',
    'Светлая тема',
    '밝은 테마로 전환',
  ],
  '切换到黑夜': [
    '切换到黑夜',
    '切換到黑夜',
    'མཚན་མོའི་རྣམ་པར་བརྗེ་བ།',
    'Switch to dark',
    'ダークに切り替え',
    'Passer au thème sombre',
    'Cambiar a oscuro',
    'Zum dunklen Design',
    'Тёмная тема',
    '어두운 테마로 전환',
  ],
  '页面操作': [
    '页面操作',
    '頁面操作',
    'ཤོག་ངོས་ཀྱི་བྱ་བ།',
    'Page action',
    'ページ操作',
    'Action de la page',
    'Acción de página',
    'Seitenaktion',
    'Действие страницы',
    '페이지 작업',
  ],
  '主题示例': [
    '主题示例',
    '主題範例',
    'བརྗོད་བྱའི་དཔེ།',
    'Theme example',
    'テーマの例',
    'Exemple de thème',
    'Ejemplo de tema',
    'Designbeispiel',
    'Пример темы',
    '테마 예제',
  ],
};
