import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

class InteractiveTextDemo extends StatefulWidget {
  const InteractiveTextDemo({super.key});
  @override
  State<InteractiveTextDemo> createState() => _InteractiveTextState();
}

class _InteractiveTextState extends State<InteractiveTextDemo> {
  late final tap = TapGestureRecognizer()
    ..onTap = () {
      setState(() => count++);
    };
  int count = 0;
  bool large = false;
  final highlighted = [false, false];
  Widget interactiveLabel(int index) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: RawGestureDetector(
      gestures: {
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (recognizer) => recognizer.onTap = () {
                setState(() => count++);
                HapticFeedback.lightImpact();
              },
            ),
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(
                duration: const Duration(milliseconds: 450),
              ),
              (recognizer) => recognizer.onLongPress = () {
                setState(() => highlighted[index] = !highlighted[index]);
                HapticFeedback.mediumImpact();
              },
            ),
      },
      child: Container(
        key: ValueKey('interactive-label-$index'),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          color: highlighted[index]
              ? Theme.of(context).colorScheme.tertiaryContainer
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: index == 0
              ? const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                )
              : BorderRadius.circular(10),
        ),
        child: Text(
          'Jobs • ${uiTr(context, '长按切换背景')}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: highlighted[index]
                ? Theme.of(context).colorScheme.onTertiaryContainer
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    ),
  );
  @override
  void dispose() {
    tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '交互富文本'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        interactiveLabel(0),
        interactiveLabel(1),
        SelectableText.rich(
          TextSpan(
            style: Theme.of(context).textTheme.bodyLarge,
            children: [
              const TextSpan(text: 'Flutter / '),
              TextSpan(
                text: 'Jobs',
                recognizer: tap,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: large ? 32 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' / Dart'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('${uiTr(context, '原始事件')}: $count'),
        SwitchListTile(
          title: Text(uiTr(context, '字号')),
          value: large,
          onChanged: (v) => setState(() => large = v),
        ),
        for (final text in [
          'Flutter framework and native platform integration',
          'Dart • Futures • Streams • Isolates',
          'UIKit / SwiftUI / Material',
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '•',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(text)),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Image.asset(
                JobsIconfontAsset.logo.localPath,
                width: 12,
                height: 12,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Flutter • UIKit • SwiftUI • Dart • ${uiTr(context, '自动换行')} • ${uiTr(context, '内容')}',
              ),
            ),
          ],
        ),
        const Divider(),
        InkWell(
          onTap: () {
            setState(() => count++);
          },
          onLongPress: () {
            Clipboard.setData(
              const ClipboardData(text: 'Flutter / Jobs / Dart'),
            );
            uiNotice(context, '已复制');
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Jobs • ${uiTr(context, '复制')}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ],
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: InteractiveTextDemo(), title: '交互富文本'));
