import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class PresentationContainersDemo extends StatelessWidget {
  const PresentationContainersDemo({super.key});
  void sheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .5,
        minChildSize: .35,
        maxChildSize: .9,
        snap: true,
        snapSizes: const [.5, .9],
        builder: (context, controller) =>
            _ContainerContent(scrollController: controller),
      ),
    );
  }

  void popover(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: uiTr(context, '取消'),
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(320.0, constraints.maxWidth - 24);
          final visibleBottom =
              constraints.maxHeight -
              MediaQuery.viewInsetsOf(context).bottom -
              12;
          final below = visibleBottom - anchor.bottom - 8;
          final above = anchor.top - 20;
          final showBelow = below >= 180 || below >= above;
          final available = math.max(80.0, showBelow ? below : above);
          final height = math.min(350.0, available);
          final left = anchor.left
              .clamp(12.0, math.max(12.0, constraints.maxWidth - width - 12))
              .toDouble();
          final top = (showBelow ? anchor.bottom + 8 : anchor.top - height - 8)
              .clamp(12.0, math.max(12.0, visibleBottom - height))
              .toDouble();
          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: width,
                height: height,
                child: Material(
                  key: const ValueKey('anchored-popover'),
                  elevation: 16,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(16),
                  child: const _ContainerContent(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '弹出容器'))),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FilledButton(
          key: const ValueKey('presentation-sheet'),
          onPressed: () => sheet(context),
          child: Text(uiTr(context, '半屏')),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          key: const ValueKey('presentation-fullscreen'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              fullscreenDialog: true,
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(uiTr(context, '全屏'))),
                body: const _ContainerContent(),
              ),
            ),
          ),
          child: Text(uiTr(context, '全屏')),
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (anchorContext) => OutlinedButton(
            key: const ValueKey('presentation-popover'),
            onPressed: () => popover(anchorContext),
            child: Text(uiTr(context, '气泡')),
          ),
        ),
      ],
    ),
  );
}

class _ContainerContent extends StatefulWidget {
  const _ContainerContent({this.scrollController});
  final ScrollController? scrollController;
  @override
  State<_ContainerContent> createState() => _ContainerState();
}

class _ContainerState extends State<_ContainerContent> {
  int count = 0;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      children: [
        Text('$count', style: Theme.of(context).textTheme.displayMedium),
        FilledButton(
          onPressed: () => setState(() => count++),
          child: Text(uiTr(context, '增加')),
        ),
        TextField(decoration: InputDecoration(labelText: uiTr(context, '内容'))),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(uiTr(context, '取消')),
        ),
      ],
    ),
  );
}

void main() => runApp(
  const JobsDemoApp(home: PresentationContainersDemo(), title: '弹出容器'),
);
