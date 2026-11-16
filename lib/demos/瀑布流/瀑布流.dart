// 独立运行：flutter run -t "lib/demos/瀑布流/瀑布流.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

void main() => runApp(const JobsDemoApp(home: MasonryDemo()));

class MasonryDemo extends StatefulWidget {
  const MasonryDemo({super.key});
  @override
  State<MasonryDemo> createState() => _MasonryDemoState();
}

class _MasonryDemoState extends State<MasonryDemo> {
  int _count = 16;
  final Set<int> _favorites = {};
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(tr(context, '瀑布流'))),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 220).floor().clamp(2, 4);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                columns,
                (column) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        for (int i = column; i < _count; i += columns)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => setState(
                                  () => _favorites.contains(i)
                                      ? _favorites.remove(i)
                                      : _favorites.add(i),
                                ),
                                child: SizedBox(
                                  height: 120 + (i * 47 % 140).toDouble(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${tr(context, '条目')} ${i + 1}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ),
                                        const Spacer(),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Icon(
                                            _favorites.contains(i)
                                                ? Icons.favorite
                                                : Icons.favorite_outline,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
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
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => setState(() => _count += 12),
              child: Text(tr(context, '加载更多')),
            ),
          ],
        );
      },
    ),
  );
}
