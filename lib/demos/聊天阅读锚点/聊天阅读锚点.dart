// 独立运行：flutter run -t "lib/demos/聊天阅读锚点/聊天阅读锚点.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/interaction_strings.dart';
import '../../demo_hub/interaction_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: ChatReadingAnchorDemo(), title: '聊天阅读锚点'));

class AnchorMessage {
  const AnchorMessage(this.id, this.body, {this.mine = false});
  final int id;
  final String body;
  final bool mine;
  Map<String, Object> toJson() => {'id': id, 'body': body, 'mine': mine};
  static List<AnchorMessage>? decode(Object? value) {
    if (value is! List || value.length > 500) return null;
    final result = <AnchorMessage>[];
    final ids = <int>{};
    for (final row in value) {
      if (row is! Map ||
          row['id'] is! int ||
          row['body'] is! String ||
          row['mine'] is! bool ||
          !ids.add(row['id'] as int)) {
        return null;
      }
      result.add(
        AnchorMessage(
          row['id'] as int,
          row['body'] as String,
          mine: row['mine'] as bool,
        ),
      );
    }
    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }
}

/// History grows before a stable sliver center, so variable heights need no estimates.
class ChatReadingAnchorDemo extends StatefulWidget {
  const ChatReadingAnchorDemo({super.key, this.repository});
  final InteractionRepository? repository;
  @override
  State<ChatReadingAnchorDemo> createState() => _ChatReadingAnchorState();
}

class _ChatReadingAnchorState extends State<ChatReadingAnchorDemo> {
  late final repository = widget.repository ?? InteractionRepository();
  final scroll = ScrollController();
  final input = TextEditingController();
  final center = GlobalKey();
  List<AnchorMessage> messages = _seed();
  int unread = 0;
  int revision = 0;
  bool remote = false;
  bool following = false;
  int followEpoch = 0;

  static List<AnchorMessage> _seed() =>
      List.generate(18, (i) => AnchorMessage(i, '变高消息', mine: i % 3 == 0));
  bool get atBottom => scroll.hasClients && scroll.position.extentAfter <= 48;

  @override
  void initState() {
    super.initState();
    scroll.addListener(_onScroll);
    _reload();
    _latest(animate: false);
  }

  void _onScroll() {
    if (atBottom && unread > 0) setState(() => unread = 0);
  }

  void _latest({bool animate = true}) {
    following = true;
    final epoch = ++followEpoch;
    // A later layout can refine a lazy sliver's maximum; recheck after layout.
    void align(int attempts, {bool first = false}) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            !scroll.hasClients ||
            !following ||
            epoch != followEpoch) {
          return;
        }
        final target = scroll.position.maxScrollExtent;
        if (animate && first && !MediaQuery.disableAnimationsOf(context)) {
          scroll
              .animateTo(
                target,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              )
              .then((_) {
                if (mounted && following && epoch == followEpoch) {
                  align(attempts - 1);
                }
              });
        } else {
          scroll.jumpTo(target);
          if (attempts > 0) {
            align(attempts - 1);
          } else {
            following = false;
          }
        }
      });
      WidgetsBinding.instance.scheduleFrame();
    }

    align(6, first: true);
    if (unread != 0) setState(() => unread = 0);
  }

  Future<void> _reload() async {
    final token = ++revision;
    if (messages.isEmpty) setState(() => messages = _seed());
    final value = await repository.read('chat-reading-anchor');
    final decoded = AnchorMessage.decode(value);
    if (!mounted || token != revision || decoded == null) return;
    final follow = atBottom;
    setState(() {
      messages = decoded;
      remote = true;
    });
    if (follow) _latest(animate: false);
  }

  Future<void> _save() async {
    final token = ++revision;
    final value = await repository.write(
      'chat-reading-anchor',
      messages.map((m) => m.toJson()).toList(),
    );
    final decoded = AnchorMessage.decode(value);
    if (!mounted || token != revision || decoded == null) return;
    final follow = atBottom;
    setState(() {
      messages = decoded;
      remote = true;
    });
    if (follow) _latest(animate: false);
  }

  void _history() {
    following = false;
    final first = messages.isEmpty ? 0 : messages.first.id.clamp(-1000000, 0);
    setState(() {
      messages.insertAll(
        0,
        List.generate(
          8,
          (i) => AnchorMessage(first - 8 + i, '变高消息', mine: i.isEven),
        ),
      );
      remote = false;
    });
    unawaited(_save());
  }

  void _append({bool mine = false}) {
    final text = mine ? input.text.trim() : '收到新消息';
    if (text.isEmpty) return;
    final follow = atBottom;
    setState(() {
      messages.add(
        AnchorMessage(
          messages.isEmpty ? 0 : messages.last.id + 1,
          text,
          mine: mine,
        ),
      );
      if (!follow) unread++;
      remote = false;
    });
    input.clear();
    if (follow) _latest();
    unawaited(_save());
  }

  Widget _message(AnchorMessage message) {
    final color = Theme.of(context).colorScheme;
    final body = interactionTr(context, message.body);
    // Translated text wraps naturally; differing row heights expose anchor errors.
    final repeat = 1 + message.id.abs() % 4;
    return Align(
      key: ValueKey('anchor-message-${message.id}'),
      alignment: message.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width.clamp(280, 900) * .73,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.mine
              ? color.primaryContainer
              : color.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          '#${message.id}\n${List.filled(repeat, body).join(' · ')}',
          style: TextStyle(
            color: message.mine ? color.onPrimaryContainer : color.onSurface,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final older = messages.where((m) => m.id < 0).toList().reversed.toList();
    final current = messages.where((m) => m.id >= 0).toList();
    return Scaffold(
      appBar: JobsDemoAppBar(
        title: Text(interactionTr(context, '聊天阅读锚点')),
        actions: [
          IconButton(
            key: const ValueKey('prepend-history'),
            tooltip: interactionTr(context, '加载历史'),
            onPressed: _history,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            key: const ValueKey('receive-message'),
            tooltip: interactionTr(context, '收到新消息'),
            onPressed: _append,
            icon: const Icon(Icons.mark_chat_unread_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          interactionStatus(
            context,
            remote: remote,
            reload: _reload,
            clear: () {
              setState(() {
                messages = [];
                unread = 0;
                remote = false;
              });
              unawaited(_save());
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              interactionTr(context, '前插历史保持当前位置'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? interactionEmpty(context, _reload)
                : NotificationListener<ScrollStartNotification>(
                    onNotification: (note) {
                      if (note.dragDetails != null) following = false;
                      return false;
                    },
                    child: CustomScrollView(
                      key: const ValueKey('anchor-scroll'),
                      controller: scroll,
                      center: center,
                      physics: const ClampingScrollPhysics(),
                      scrollCacheExtent: const ScrollCacheExtent.pixels(600),
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _message(older[index]),
                            childCount: older.length,
                          ),
                        ),
                        SliverList(
                          key: center,
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _message(current[index]),
                            childCount: current.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      ],
                    ),
                  ),
          ),
          if (unread > 0)
            FilledButton.tonalIcon(
              key: const ValueKey('unread-prompt'),
              onPressed: _latest,
              icon: const Icon(Icons.arrow_downward),
              label: Text(
                '$unread ${interactionTr(context, '新消息')} · ${interactionTr(context, '回到最新')}',
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      onSubmitted: (_) => _append(mine: true),
                      decoration: InputDecoration(
                        labelText: interactionTr(context, '消息'),
                        helperText: interactionTr(context, '只有靠近底部才自动跟随'),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: interactionTr(context, '发送'),
                    onPressed: () => _append(mine: true),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    revision++;
    following = false;
    scroll.removeListener(_onScroll);
    scroll.dispose();
    input.dispose();
    if (widget.repository == null) repository.dispose();
    super.dispose();
  }
}
