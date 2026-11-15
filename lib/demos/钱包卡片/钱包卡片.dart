import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: WalletCardsDemo()));

class WalletCardsDemo extends StatefulWidget {
  const WalletCardsDemo({super.key});
  @override
  State<WalletCardsDemo> createState() => _WalletCardsDemoState();
}

class _WalletCardsDemoState extends State<WalletCardsDemo> {
  int _index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '钱包卡片'))),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 40).clamp(180.0, 440.0);
        final cardHeight =
            210 *
            (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(1.0, 2.0);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(
              height: cardHeight + 100,
              child: Center(
                child: SizedBox(
                  width: width,
                  height: cardHeight + 90,
                  child: Stack(
                    children: [
                      for (int position = 2; position >= 0; position--)
                        AnimatedPositioned(
                          key: ValueKey((_index + position) % 3),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          top: position * 30,
                          left: position * 10,
                          right: position * 10,
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _index = (_index + position) % 3,
                            ),
                            onHorizontalDragEnd: (_) =>
                                setState(() => _index = (_index + 1) % 3),
                            child: Card(
                              elevation: 6 - position.toDouble(),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: SizedBox(
                                height: cardHeight,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'JOBS / ${(_index + position) % 3 + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        tr(context, '余额'),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          '${[1200, 8400, 360][(_index + position) % 3]}.00',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '••••  ${[1688, 3366, 8899][(_index + position) % 3]}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Text('${_index + 1} / 3', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => setState(() => _index = (_index + 1) % 3),
              child: Text(tr(context, '切换卡片')),
            ),
          ],
        );
      },
    ),
  );
}
