// 独立运行：flutter run -t "lib/demos/聊天与站内信/聊天与站内信.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: ChatInboxDemo(), title: '聊天与站内信'));

class ChatInboxDemo extends StatefulWidget {
  const ChatInboxDemo({super.key});
  @override
  State<ChatInboxDemo> createState() => _ChatInboxState();
}

class _ChatInboxState extends State<ChatInboxDemo> {
  final input = TextEditingController();
  final scroll = ScrollController();
  List<Map<String, dynamic>> messages = [
    {'id': 0, 'body': 'Flutter / iOS', 'mine': false, 'read': false},
  ];
  bool inbox = false;
  final Set<int> selection = {};
  @override
  void initState() {
    super.initState();
    reload();
  }

  Future<void> reload() async {
    final value = await UiDemoStore.read('chat', messages);
    if (mounted && value is List)
      setState(
        () => messages = value
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList(),
      );
  }

  Future<void> save() async {
    final result = await UiDemoStore.write('chat', messages);
    if (mounted && result is List && !identical(result, messages))
      setState(
        () => messages = result
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );
  }

  void send() {
    final value = input.text.trim();
    if (value.isEmpty) return;
    setState(
      () => messages.add({
        'id': DateTime.now().microsecondsSinceEpoch,
        'body': value,
        'mine': true,
        'read': true,
      }),
    );
    input.clear();
    save();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients)
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
    });
  }

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(
      title: Text(uiTr(context, '聊天与站内信')),
      actions: [
        IconButton(
          tooltip: uiTr(context, '消息'),
          onPressed: () => setState(() => inbox = !inbox),
          icon: Icon(inbox ? Icons.chat_bubble_outline : Icons.inbox),
        ),
        if (selection.isNotEmpty)
          IconButton(
            tooltip: uiTr(context, '删除'),
            onPressed: () {
              setState(() {
                messages.removeWhere((m) => selection.contains(m['id']));
                selection.clear();
              });
              save();
            },
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? uiEmpty(context, reload)
              : JobsAdaptiveRefresh(
                  historyKey: 'demo.chat-messages',
                  onRefresh: reload,
                  child: ListView.builder(
                    controller: scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      if (inbox)
                        return CheckboxListTile(
                          value: selection.contains(m['id']),
                          onChanged: (v) => setState(
                            () => v!
                                ? selection.add(m['id'] as int)
                                : selection.remove(m['id']),
                          ),
                          title: Text('${m['body']}'),
                          subtitle: Text(
                            uiTr(context, m['read'] == true ? '成功' : '未读'),
                          ),
                          secondary: IconButton(
                            onPressed: () {
                              setState(() => m['read'] = true);
                              save();
                            },
                            icon: const Icon(Icons.mark_email_read),
                          ),
                        );
                      return Align(
                        alignment: m['mine'] == true
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: () async {
                            final action = await showMenu<String>(
                              context: context,
                              position: const RelativeRect.fromLTRB(
                                100,
                                150,
                                30,
                                0,
                              ),
                              items: [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(uiTr(context, '删除')),
                                ),
                                PopupMenuItem(
                                  value: 'reply',
                                  child: Text(uiTr(context, '回复')),
                                ),
                              ],
                            );
                            if (!mounted) return;
                            if (action == 'delete') {
                              setState(() => messages.removeAt(i));
                              save();
                            }
                            if (action == 'reply') {
                              input.text = '↪ ${m['body']} ';
                            }
                          },
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * .78,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: m['mine'] == true
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                  : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('${m['body']}'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    onSubmitted: (_) => send(),
                    decoration: InputDecoration(labelText: uiTr(context, '消息')),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: uiTr(context, '发送'),
                  onPressed: send,
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
