import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

class LinkedMenuDemo extends StatefulWidget {
  const LinkedMenuDemo({super.key});
  @override
  State<LinkedMenuDemo> createState() => _LinkedMenuState();
}

class _LinkedMenuState extends State<LinkedMenuDemo> {
  final scroll = ScrollController(), menuScroll = ScrollController();
  final sections = List.generate(8, (_) => GlobalKey()),
      menuKeys = List.generate(8, (_) => GlobalKey());
  final viewport = GlobalKey();
  int selected = 0, widthMode = 0;
  bool jumping = false, allGroups = true;
  String? callback;
  List<String> groups = List.generate(8, (i) => 'Flutter ${i + 1}');
  @override
  void initState() {
    super.initState();
    scroll.addListener(observe);
    reload();
  }

  Future<void> reload() async {
    final value = await UiDemoStore.read('linked-menu', groups);
    if (mounted && value is List)
      setState(() {
        groups = value.take(8).cast<String>().toList();
        selected = selected.clamp(0, math.max(0, groups.length - 1));
      });
  }

  void observe() {
    if (jumping || !allGroups) return;
    final root = viewport.currentContext?.findRenderObject() as RenderBox?;
    final threshold = (root?.localToGlobal(Offset.zero).dy ?? 0) + 8;
    var next = selected;
    for (var i = 0; i < groups.length; i++) {
      final box = sections[i].currentContext?.findRenderObject() as RenderBox?;
      if (box != null &&
          box.attached &&
          box.localToGlobal(Offset.zero).dy <= threshold)
        next = i;
    }
    if (next != selected) {
      setState(() => selected = next);
      final context = menuKeys[next].currentContext;
      if (context != null)
        unawaited(
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 180),
            alignment: .5,
          ),
        );
    }
  }

  Future<void> jump(int i) async {
    setState(() {
      selected = i;
      callback = null;
    });
    unawaited(UiDemoStore.write('linked-selection', {'index': i}));
    if (!allGroups) return;
    jumping = true;
    final target = sections[i].currentContext;
    if (target != null)
      await Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 300),
        alignment: 0,
      );
    jumping = false;
  }

  Widget section(int index) => Column(
    key: allGroups ? sections[index] : ValueKey('selected-$index'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          groups[index],
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      for (var row = 0; row < 5; row++)
        Card(
          child: ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text('Dart ${index + 1}.${row + 1}'),
            subtitle: Text(uiTr(context, '条目')),
            onTap: () => uiNotice(context, '已选择'),
          ),
        ),
    ],
  );
  @override
  void dispose() {
    scroll.dispose();
    menuScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '联动分类菜单'))),
    body: groups.isEmpty
        ? uiEmpty(context, reload)
        : Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 6,
                    children: [
                      for (var index = 0; index < 3; index++)
                        ChoiceChip(
                          label: Text(
                            uiTr(context, ['菜单固定宽', '内容固定宽', '比例宽度'][index]),
                          ),
                          selected: widthMode == index,
                          onSelected: (_) => setState(() => widthMode = index),
                        ),
                    ],
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(uiTr(context, '全部分组')),
                value: allGroups,
                onChanged: (value) => setState(() => allGroups = value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  callback == null
                      ? '${uiTr(context, '当前菜单')}: ${groups[selected]}'
                      : uiTr(context, callback!),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final left = switch (widthMode) {
                      0 => 96.0,
                      1 => math.max(72.0, constraints.maxWidth - 260),
                      _ => constraints.maxWidth * .26,
                    };
                    return Row(
                      children: [
                        SizedBox(
                          width: left.clamp(64, constraints.maxWidth - 100),
                          child: ListView(
                            controller: menuScroll,
                            children: [
                              for (
                                var index = 0;
                                index < groups.length;
                                index++
                              )
                                ListTile(
                                  key: menuKeys[index],
                                  minTileHeight: index == 4 ? 96 : 78,
                                  selected: index == selected,
                                  selectedColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  selectedTileColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  title: Text(groups[index]),
                                  onTap: () => jump(index),
                                ),
                              ListTile(
                                key: const ValueKey('menu-no-content'),
                                leading: const Icon(Icons.link),
                                title: Text(uiTr(context, '无内容菜单')),
                                onTap: () =>
                                    setState(() => callback = '无内容菜单已点击'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          key: viewport,
                          child: RefreshIndicator(
                            onRefresh: reload,
                            child: SingleChildScrollView(
                              controller: scroll,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: allGroups
                                  ? Column(
                                      children: [
                                        for (
                                          var index = 0;
                                          index < groups.length;
                                          index++
                                        )
                                          section(index),
                                      ],
                                    )
                                  : AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      child: section(selected),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: LinkedMenuDemo(), title: '联动分类菜单'));
