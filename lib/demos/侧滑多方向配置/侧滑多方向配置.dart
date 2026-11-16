// 独立运行：flutter run -t "lib/demos/侧滑多方向配置/侧滑多方向配置.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() => runApp(
  const JobsDemoApp(home: DrawerConfigurationDemo(), title: '侧滑多方向配置'),
);

class DrawerConfigurationDemo extends StatefulWidget {
  const DrawerConfigurationDemo({super.key});
  @override
  State<DrawerConfigurationDemo> createState() => _DrawerConfigurationState();
}

class _DrawerConfigurationState extends State<DrawerConfigurationDemo> {
  int direction = 0;
  double ratio = .7, progress = 0;
  bool follow = false, dragging = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '侧滑菜单'))),
    body: Column(
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (var i = 0; i < 4; i++)
              ChoiceChip(
                label: Text(uiTr(context, ['左', '右', '上', '下'][i])),
                selected: direction == i,
                onSelected: (_) => setState(() => direction = i),
              ),
          ],
        ),
        Slider(
          value: ratio,
          min: .2,
          max: 1,
          divisions: 8,
          label: '${(ratio * 100).round()}%',
          onChanged: (v) => setState(() => ratio = v),
        ),
        SwitchListTile(
          title: Text(uiTr(context, '侧滑菜单')),
          subtitle: Text(uiTr(context, follow ? '跟随内容' : '覆盖内容')),
          value: follow,
          onChanged: (v) => setState(() => follow = v),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final horizontal = direction < 2;
              final extent = (horizontal ? c.maxWidth : c.maxHeight) * ratio;
              final sign = direction == 0 || direction == 2 ? 1.0 : -1.0;
              final delta = extent * progress * sign;
              final hidden = extent * (1 - progress) * -sign;
              return GestureDetector(
                onPanStart: (_) => setState(() => dragging = true),
                onPanUpdate: (e) => setState(
                  () => progress =
                      (progress +
                              (horizontal ? e.delta.dx : e.delta.dy) *
                                  sign /
                                  extent)
                          .clamp(0, 1),
                ),
                onPanEnd: (_) => setState(() {
                  dragging = false;
                  progress = progress > .5 ? 1 : 0;
                }),
                child: ClipRect(
                  child: Stack(
                    children: [
                      AnimatedContainer(
                        duration: dragging
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        transform: Matrix4.translationValues(
                          follow && horizontal ? delta : 0,
                          follow && !horizontal ? delta : 0,
                          0,
                        ),
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: Center(
                          child: FilledButton(
                            onPressed: () => setState(() => progress = 1),
                            child: Text(uiTr(context, '打开菜单')),
                          ),
                        ),
                      ),
                      if (progress > 0)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => setState(() => progress = 0),
                            child: ColoredBox(
                              color: Colors.black.withValues(
                                alpha: .3 * progress,
                              ),
                            ),
                          ),
                        ),
                      AnimatedPositioned(
                        duration: dragging
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
                        left: horizontal
                            ? (direction == 0
                                  ? hidden
                                  : c.maxWidth - extent + hidden)
                            : 0,
                        top: horizontal
                            ? 0
                            : direction == 2
                            ? hidden
                            : c.maxHeight - extent + hidden,
                        width: horizontal ? extent : c.maxWidth,
                        height: horizontal ? c.maxHeight : extent,
                        child: Material(
                          color: Theme.of(context).colorScheme.surface,
                          child: ListView(
                            children: [
                              ListTile(
                                title: Text(uiTr(context, '侧滑菜单')),
                                trailing: IconButton(
                                  onPressed: () => setState(() => progress = 0),
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                              for (final item in ['Flutter', 'Dart', 'Jobs'])
                                ListTile(
                                  title: Text(item),
                                  onTap: () {
                                    setState(() => progress = 0);
                                    uiNotice(context, '已选择');
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
