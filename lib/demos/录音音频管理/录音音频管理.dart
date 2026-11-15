import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/platform_support.dart';
import '../../demo_hub/platform_strings.dart';

void main() => runApp(const JobsDemoApp(home: AudioRecorderLabDemo()));

class AudioRecorderLabDemo extends StatefulWidget {
  const AudioRecorderLabDemo({super.key});
  @override
  State<AudioRecorderLabDemo> createState() => _AudioRecorderLabDemoState();
}

class _AudioRecorderLabDemoState extends State<AudioRecorderLabDemo> {
  final state = NativeLabState('audio');
  List<Map<String, dynamic>> files = [];
  bool longMode = false;
  bool recording = false;
  bool shortHeld = false;
  @override
  void initState() {
    super.initState();
    state.addListener(updateRecording);
    state.run('audio.status').then((value) {
      if (value is Map && value['recording'] == true && mounted) {
        setState(() {
          recording = true;
          longMode = true;
        });
      }
      if (mounted) reload();
    });
  }

  void updateRecording() {
    final value = state.value;
    if (value is Map && value['event'] == 'finished' && mounted) {
      setState(() => recording = false);
    }
  }

  Future<void> reload() async {
    final value = await state.run('audio.list');
    if (value is List && mounted) {
      setState(
        () => files = value
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
    }
  }

  Future<void> start() async {
    final value = await state.run('audio.start', {
      'maxSeconds': longMode ? 0 : 60,
      'notificationTitle': platformText(context, '录音与音频管理'),
      'notificationMessage': platformText(context, '停止并保存'),
    });
    if (value != null && mounted) setState(() => recording = true);
  }

  Future<void> stop({bool cancel = false}) async {
    await state.run(cancel ? 'audio.cancel' : 'audio.stop');
    if (mounted) setState(() => recording = false);
    await reload();
  }

  @override
  void dispose() {
    if (!longMode && JobsPlatformLab.hasNativeBridge) {
      unawaited(
        JobsPlatformLab.invoke<void>('audio.cancel').catchError((_) {}),
      );
    }
    state.removeListener(updateRecording);
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => NativeLabPanel(
    title: '录音与音频管理',
    state: state,
    children: [
      SwitchListTile(
        title: Text(platformText(context, '长录音')),
        value: longMode,
        onChanged: recording ? null : (v) => setState(() => longMode = v),
      ),
      if (longMode)
        FilledButton(
          onPressed: () => recording ? stop() : start(),
          child: Text(platformText(context, recording ? '停止并保存' : '开始录音')),
        )
      else
        GestureDetector(
          onLongPressStart: (_) async {
            shortHeld = true;
            await start();
            if (!shortHeld) await stop(cancel: true);
          },
          onLongPressEnd: (_) {
            shortHeld = false;
            if (recording) stop();
          },
          onLongPressCancel: () {
            shortHeld = false;
            if (recording) stop(cancel: true);
          },
          child: Container(
            padding: const EdgeInsets.all(32),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              platformText(context, '按住录音'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      Wrap(
        spacing: 8,
        children: [
          if (longMode && recording) ...[
            nativeButton(context, state, '暂停录音', 'audio.pause'),
            nativeButton(context, state, '继续录音', 'audio.resume'),
          ],
          nativeButton(context, state, '停止', 'audio.stopPlayback'),
          TextButton(
            onPressed: reload,
            child: Text(platformText(context, '重新加载')),
          ),
        ],
      ),
      if (files.isEmpty)
        JobsEmptyState(
          title: platformText(context, '暂无录音'),
          message: platformText(context, '按住录音'),
          onReload: reload,
        ),
      for (final file in files)
        ListTile(
          title: Text(file['name'].toString()),
          subtitle: Text('${file['bytes']} bytes'),
          trailing: Wrap(
            children: [
              IconButton(
                tooltip: platformText(context, '播放'),
                icon: const Icon(Icons.play_arrow),
                onPressed: () =>
                    state.run('audio.play', {'name': file['name']}),
              ),
              IconButton(
                tooltip: platformText(context, '删除'),
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await state.run('audio.delete', {'name': file['name']});
                  await reload();
                },
              ),
            ],
          ),
        ),
    ],
  );
}
