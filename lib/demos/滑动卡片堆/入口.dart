import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() => runApp(const JobsDemoApp(home: SwipeCardsDemo()));

class SwipeCardsDemo extends StatefulWidget {
  const SwipeCardsDemo({super.key});
  @override
  State<SwipeCardsDemo> createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<SwipeCardsDemo> {
  List<String> cards = ['Flutter', 'Dart', 'Jobs', 'iOS'];
  final dismissed = <String>[];
  Offset drag = Offset.zero;
  @override
  void initState() {
    super.initState();
    UiDemoStore.read('cards', cards).then((value) {
      if (mounted && value is List)
        setState(() => cards = value.cast<String>());
    });
  }

  void swipe() {
    if (cards.isEmpty) return;
    setState(() {
      dismissed.add(cards.removeAt(0));
      drag = Offset.zero;
    });
    UiDemoStore.write('cards', cards).then((result) {
      if (mounted && result is List)
        setState(() => cards = result.cast<String>());
    });
  }

  Widget card(int index, double width) => Positioned.fill(
    top: index * 10,
    bottom: index * 6,
    left: index * 8,
    right: index * 8,
    child: Transform.translate(
      offset: index == 0 ? drag : Offset.zero,
      child: Transform.rotate(
        angle: index == 0 ? drag.dx / 700 : 0,
        child: GestureDetector(
          onPanUpdate: index == 0
              ? (event) => setState(() => drag += event.delta)
              : null,
          onPanEnd: index == 0
              ? (_) {
                  if (drag.dx.abs() > width * .28) {
                    swipe();
                  } else {
                    setState(() => drag = Offset.zero);
                  }
                }
              : null,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    index.isEven
                        ? 'assets/Images/flower.png'
                        : 'assets/Images/CarouselAssets/slide1.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    cards[index],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(uiTr(context, '滑动卡片堆')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '撤销'),
          onPressed: dismissed.isEmpty
              ? null
              : () {
                  setState(() => cards.insert(0, dismissed.removeLast()));
                  UiDemoStore.write('cards', cards).then((result) {
                    if (mounted && result is List)
                      setState(() => cards = result.cast<String>());
                  });
                },
          icon: const Icon(Icons.undo),
        ),
      ],
    ),
    body: cards.isEmpty
        ? uiEmpty(context, () {
            setState(() => cards = ['Flutter', 'Dart', 'Jobs', 'iOS']);
            UiDemoStore.write('cards', cards).then((result) {
              if (mounted && result is List)
                setState(() => cards = result.cast<String>());
            });
          })
        : LayoutBuilder(
            builder: (context, constraints) => Center(
              child: SizedBox(
                width: constraints.maxWidth < 370
                    ? constraints.maxWidth - 40
                    : 330,
                height: constraints.maxHeight < 490
                    ? constraints.maxHeight - 30
                    : 460,
                child: Stack(
                  children: [
                    for (
                      var index = (cards.length > 3 ? 2 : cards.length - 1);
                      index >= 0;
                      index--
                    )
                      card(index, constraints.maxWidth),
                  ],
                ),
              ),
            ),
          ),
  );
}
