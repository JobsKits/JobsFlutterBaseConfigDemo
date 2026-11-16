// 独立运行：flutter run -t "lib/demos/双向网络通信/双向网络通信.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../demo_hub/lab_support.dart';

void main() =>
    runApp(const JobsDemoApp(home: WebSocketLabDemo(), title: '双向网络通信'));

class WebSocketLabDemo extends StatefulWidget {
  const WebSocketLabDemo({super.key});
  @override
  State<WebSocketLabDemo> createState() => _State();
}

class _State extends State<WebSocketLabDemo> {
  final address = TextEditingController(text: 'ws://localhost:18080/ws');
  final message = TextEditingController(text: 'Jobs Flutter');
  WebSocketChannel? channel;
  StreamSubscription<dynamic>? subscription;
  int generation = 0;
  bool online = false;
  bool connecting = false;
  final logs = <String>[];
  void log(String value) {
    if (mounted)
      setState(() {
        logs.insert(0, value);
        if (logs.length > 80) logs.removeLast();
      });
  }

  Future<void> connect() async {
    final token = ++generation;
    setState(() => connecting = true);
    await subscription?.cancel();
    await channel?.sink.close();
    channel = null;
    online = false;
    try {
      final url = Uri.parse(address.text.trim());
      if (!{'ws', 'wss'}.contains(url.scheme) ||
          url.host.isEmpty ||
          url.userInfo.isNotEmpty)
        throw const FormatException('WebSocket URL required');
      final socket = WebSocketChannel.connect(url);
      channel = socket;
      subscription = socket.stream.listen(
        (event) {
          if (generation == token) log('← server: $event');
        },
        onError: (Object error) {
          if (generation == token) {
            online = false;
            log('error: $error');
          }
        },
        onDone: () {
          if (generation == token) {
            online = false;
            log('closed: ${socket.closeCode}');
          }
        },
      );
      await socket.ready.timeout(const Duration(milliseconds: 900));
      if (token != generation) {
        await socket.sink.close();
        return;
      }
      online = true;
      log('connected: ${url.host}');
    } catch (error) {
      if (token == generation) {
        online = false;
        await channel?.sink.close();
        channel = null;
        log('offline: $error');
      }
    } finally {
      if (mounted && token == generation) setState(() => connecting = false);
    }
  }

  Future<void> send() async {
    if (!online) await connect();
    if (!mounted) return;
    final value = message.text;
    log('→ $value');
    if (online) {
      channel!.sink.add(value);
    } else {
      log('← local demo echo: $value');
    }
  }

  @override
  void dispose() {
    generation++;
    subscription?.cancel();
    channel?.sink.close();
    address.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LabFrame(
    title: '双向网络通信',
    children: [
      TextField(
        controller: address,
        decoration: const InputDecoration(labelText: 'WebSocket URL'),
      ),
      Wrap(
        spacing: 8,
        children: [
          labAction(context, '连接', connecting ? null : connect),
          labAction(context, '断开', () {
            generation++;
            subscription?.cancel();
            channel?.sink.close();
            channel = null;
            setState(() => online = false);
          }),
        ],
      ),
      Text('${online ? '●' : '○'} ${online ? 'server' : 'local demo'}'),
      TextField(
        controller: message,
        decoration: InputDecoration(labelText: labTr(context, '内容')),
      ),
      labAction(context, '发送', connecting ? null : send),
      if (logs.isEmpty) JobsEmptyState(title: '无数据', onReload: connect),
      for (final line in logs) SelectableText(line),
    ],
  );
}
