import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

class MomentsBrowserDemo extends StatefulWidget {
  const MomentsBrowserDemo({super.key});
  @override
  State<MomentsBrowserDemo> createState() => _MomentsBrowserState();
}

class _MomentsBrowserState extends State<MomentsBrowserDemo> {
  List<Map<String, dynamic>> posts = List.generate(
    3,
    (i) => {
      'name': ['Jobs', 'Flutter', 'Dart'][i],
      'text': ['Flutter / iOS', 'Layout · Motion', 'Canvas / Images'][i],
      'likes': 0,
      'comments': <String>[],
    },
  );
  final pictures = [
    'assets/Images/flower.png',
    'assets/Images/CarouselAssets/slide1.png',
    'assets/Images/CarouselAssets/slide2.png',
  ];
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final value = await UiDemoStore.read('moments', posts);
    if (mounted && value is List)
      setState(
        () => posts = value
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
  }

  Future<void> save() async {
    final result = await UiDemoStore.write('moments', posts);
    if (mounted && result is List && !identical(result, posts))
      setState(
        () => posts = result
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(uiTr(context, '朋友圈浏览')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '清空列表'),
          onPressed: () {
            setState(posts.clear);
            save();
          },
          icon: const Icon(Icons.clear_all),
        ),
      ],
    ),
    body: posts.isEmpty
        ? uiEmpty(context, () {
            setState(
              () => posts = [
                {
                  'name': 'Jobs',
                  'text': 'Flutter / iOS',
                  'likes': 0,
                  'comments': <String>[],
                },
              ],
            );
            save();
            reload();
          })
        : RefreshIndicator(
            onRefresh: reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, i) {
                final p = posts[i];
                final comments = List<String>.from(p['comments'] as List);
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text('${p['name']}'[0])),
                        title: Text('${p['name']}'),
                        subtitle: Text('${p['text']}'),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => _PictureBrowser(
                              pictures: pictures,
                              start: i % pictures.length,
                            ),
                          ),
                        ),
                        child: Image.asset(
                          pictures[i % pictures.length],
                          height: 190,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(
                                () => p['likes'] =
                                    (p['likes'] as num).toInt() + 1,
                              );
                              save();
                            },
                            icon: const Icon(Icons.favorite_outline),
                            label: Text('${p['likes']}'),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final text = await uiInput(context, '回复');
                              if (text != null &&
                                  text.trim().isNotEmpty &&
                                  mounted) {
                                setState(
                                  () => p['comments'] = [
                                    ...comments,
                                    text.trim(),
                                  ],
                                );
                                save();
                              }
                            },
                            icon: const Icon(Icons.comment_outlined),
                            label: Text(uiTr(context, '回复')),
                          ),
                        ],
                      ),
                      for (final c in comments) Text(c),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        setState(
          () => posts.add({
            'name': 'Jobs',
            'text': 'Flutter ${posts.length + 1}',
            'likes': 0,
            'comments': <String>[],
          }),
        );
        save();
      },
      child: const Icon(Icons.add),
    ),
  );
}

class _PictureBrowser extends StatefulWidget {
  const _PictureBrowser({required this.pictures, required this.start});
  final List<String> pictures;
  final int start;
  @override
  State<_PictureBrowser> createState() => _PictureBrowserState();
}

class _PictureBrowserState extends State<_PictureBrowser> {
  late final page = PageController(initialPage: widget.start);
  late int current = widget.start;
  @override
  void dispose() {
    page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${current + 1}/${widget.pictures.length}')),
    body: PageView.builder(
      controller: page,
      itemCount: widget.pictures.length,
      onPageChanged: (i) => setState(() => current = i),
      itemBuilder: (_, i) => InteractiveViewer(
        minScale: .5,
        maxScale: 6,
        child: Center(child: Image.asset(widget.pictures[i])),
      ),
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: MomentsBrowserDemo(), title: '朋友圈浏览'));
