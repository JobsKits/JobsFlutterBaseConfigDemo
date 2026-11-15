import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';
import 'package:video_player/video_player.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

class PlayerLaboratoryDemo extends StatefulWidget {
  const PlayerLaboratoryDemo({
    super.key,
    this.initialMode = 0,
    this.autoStart = false,
    this.initialSource,
  });
  final int initialMode;
  final bool autoStart;
  final String? initialSource;
  @override
  State<PlayerLaboratoryDemo> createState() => _PlayerLaboratoryState();
}

class _PlayerLaboratoryState extends State<PlayerLaboratoryDemo> {
  static const localAsset =
      'assets/Video/AppLaunchAssets/appLaunch_welcome.mp4';
  static const initialURL =
      'https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4';
  final url = TextEditingController(text: initialURL);
  StreamSubscription<Map<String, dynamic>>? subscription;
  VideoPlayerController? webController;
  int? viewId;
  Widget? nativeView;
  int mode = 0, generation = 0;
  bool started = false,
      ready = false,
      playing = false,
      floating = false,
      loading = false,
      localFallback = false,
      pipSupported = false;
  double position = 0, duration = 0;
  Offset floatOffset = const Offset(12, 12);
  String status = '等待';
  Map<String, dynamic>? traffic;
  @override
  void initState() {
    super.initState();
    mode = widget.initialMode;
    if (widget.initialSource != null)
      url.text = widget.initialSource!;
    else
      unawaited(preferences());
    if (widget.autoStart)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(start());
      });
  }

  Future<void> preferences() async {
    final value = await UiDemoStore.read('player-preferences', {
      'url': initialURL,
    });
    if (mounted && value is Map && value['url'] is String)
      url.text = value['url'] as String;
  }

  @override
  void dispose() {
    generation++;
    subscription?.cancel();
    webController?.dispose();
    url.dispose();
    super.dispose();
  }

  void event(Map<String, dynamic> envelope) {
    final raw = envelope['data'];
    final data = raw is Map ? Map<String, dynamic>.from(raw) : envelope;
    if (!mounted || data['viewId'] != viewId) return;
    final kind = data['event'];
    if (kind == 'error') {
      if (mode != 0 && !localFallback) {
        localFallback = true;
        unawaited(load());
      } else
        setState(() {
          loading = false;
          ready = false;
          status = '失败';
        });
      return;
    }
    setState(() {
      if (data['position'] is num)
        position = (data['position'] as num).toDouble();
      if (data['duration'] is num)
        duration = (data['duration'] as num).toDouble();
      if (data['isPlaying'] is bool) playing = data['isPlaying'] as bool;
      if (kind == 'ready') {
        ready = true;
        loading = false;
        status = localFallback ? '本地视频回退' : '完成';
      }
      if (kind == 'traffic') traffic = Map<String, dynamic>.from(data);
      if (kind == 'pipStarted') status = '画中画已开启';
      if (kind == 'pipStopped') status = '画中画已结束';
    });
  }

  Future<Object?> command(
    String action, [
    Map<String, dynamic> arguments = const {},
  ]) async {
    final id = viewId;
    if (id == null) return null;
    return JobsPlatformLab.invoke<Object?>('player.command', {
      'viewId': id,
      'action': action,
      ...arguments,
    });
  }

  Future<void> start() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (mode != 0) {
      final parsed = Uri.tryParse(url.text.trim());
      if (parsed == null || parsed.scheme != 'https' || parsed.host.isEmpty) {
        uiNotice(context, '请输入HTTPS视频地址');
        return;
      }
      unawaited(
        UiDemoStore.write('player-preferences', {'url': url.text.trim()}),
      );
    }
    setState(() {
      started = true;
      if (mode == 3) floating = true;
      localFallback = false;
      status = '等待';
    });
    if (JobsPlatformLab.hasNativeBridge) {
      subscription ??= JobsPlatformLab.events('player').listen(
        event,
        onError: (_) {
          if (mounted) setState(() => status = '失败');
        },
      );
      if (nativeView == null) {
        void created(int id) {
          viewId = id;
          unawaited(load());
        }

        nativeView = defaultTargetPlatform == TargetPlatform.iOS
            ? UiKitView(
                key: const ValueKey('native-player-view'),
                viewType: 'jobs_platform_lab/player',
                layoutDirection: TextDirection.ltr,
                onPlatformViewCreated: created,
              )
            : AndroidView(
                key: const ValueKey('native-player-view'),
                viewType: 'jobs_platform_lab/player',
                layoutDirection: TextDirection.ltr,
                onPlatformViewCreated: created,
              );
        setState(() {});
      } else {
        await load();
      }
    } else {
      await load();
    }
  }

  Future<void> load() async {
    final current = ++generation;
    if (mounted)
      setState(() {
        loading = true;
        ready = false;
        position = 0;
        duration = 0;
        status = localFallback ? '本地视频回退' : '等待';
      });
    try {
      final local = mode == 0 || localFallback;
      if (JobsPlatformLab.hasNativeBridge) {
        final payload = local
            ? {
                'bytes': (await rootBundle.load(localAsset)).buffer
                    .asUint8List(),
              }
            : {'url': url.text.trim()};
        if (!mounted || current != generation) return;
        final result = await command('load', {...payload, 'autoplay': true});
        if (mounted && current == generation && result is Map)
          setState(() => pipSupported = result['pipSupported'] == true);
      } else {
        final next = local
            ? VideoPlayerController.asset(localAsset)
            : VideoPlayerController.networkUrl(Uri.parse(url.text.trim()));
        try {
          await next.initialize().timeout(const Duration(seconds: 6));
          if (!mounted || current != generation) {
            await next.dispose();
            return;
          }
          final previous = webController;
          webController = next;
          next.addListener(webChanged);
          await previous?.dispose();
          await next.play();
          if (mounted)
            setState(() {
              ready = true;
              loading = false;
              status = localFallback ? '本地视频回退' : '完成';
            });
        } catch (_) {
          await next.dispose();
          rethrow;
        }
      }
    } catch (_) {
      if (!mounted || current != generation) return;
      if (mode != 0 && !localFallback) {
        localFallback = true;
        await load();
      } else
        setState(() {
          loading = false;
          ready = false;
          status = '失败';
        });
    }
  }

  void webChanged() {
    if (!mounted || webController == null) return;
    final value = webController!.value;
    setState(() {
      playing = value.isPlaying;
      position = value.position.inMilliseconds / 1000;
      duration = value.duration.inMilliseconds / 1000;
    });
  }

  Future<void> action(String name) async {
    try {
      if (JobsPlatformLab.hasNativeBridge) {
        final result = await command(name);
        if (mounted && name == 'traffic' && result is Map)
          setState(() => traffic = Map<String, dynamic>.from(result));
      } else if (name == 'play') {
        await webController?.play();
      } else if (name == 'pause') {
        await webController?.pause();
      } else if (name == 'fullScreen') {
        if (mounted)
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(uiTr(context, '全屏'))),
                body: Center(
                  child: AspectRatio(
                    aspectRatio: webController!.value.aspectRatio,
                    child: VideoPlayer(webController!),
                  ),
                ),
              ),
            ),
          );
      } else if (mounted) {
        uiNotice(context, '当前平台不支持此能力');
      }
    } catch (_) {
      if (mounted) uiNotice(context, '失败');
    }
  }

  Future<void> seek(double value) async {
    try {
      if (JobsPlatformLab.hasNativeBridge) {
        await command('seek', {'seconds': value});
      } else {
        await webController?.seekTo(
          Duration(milliseconds: (value * 1000).round()),
        );
      }
    } catch (_) {
      if (mounted) uiNotice(context, '失败');
    }
  }

  String clock(double seconds) {
    final value = seconds.isFinite ? seconds.round().clamp(0, 999999) : 0;
    return '${value ~/ 60}:${(value % 60).toString().padLeft(2, '0')}';
  }

  Widget video() {
    if (nativeView != null) return nativeView!;
    if (webController != null && webController!.value.isInitialized)
      return VideoPlayer(webController!);
    return Center(
      child: loading
          ? const CircularProgressIndicator()
          : uiEmpty(context, start),
    );
  }

  Widget trafficPanel() {
    final value = traffic;
    if (value == null) return const SizedBox.shrink();
    final app = value['scope'] == 'app';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(uiTr(context, app ? '应用接收流量' : '播放器传输流量')),
            Text(
              '${value[app ? 'appReceivedBytes' : 'bytesTransferred'] ?? 0} B',
            ),
            if (value['observedBitrate'] is num)
              Text(
                '${uiTr(context, '实际码率')}: ${(value['observedBitrate'] as num).round()} bps',
              ),
            if (value['indicatedBitrate'] is num)
              Text(
                '${uiTr(context, '媒体码率')}: ${(value['indicatedBitrate'] as num).round()} bps',
              ),
            if (value['bufferPercent'] is num)
              Text('${uiTr(context, '缓冲')}: ${value['bufferPercent']}%'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '播放器实验室'))),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final regularHeight = math.min(240.0, constraints.maxHeight * .4);
        final smallWidth = math.min(220.0, constraints.maxWidth - 24);
        final smallHeight = smallWidth * 9 / 16 + 30;
        final offset = Offset(
          floatOffset.dx
              .clamp(0, math.max(0, constraints.maxWidth - smallWidth))
              .toDouble(),
          floatOffset.dy
              .clamp(0, math.max(0, constraints.maxHeight - smallHeight))
              .toDouble(),
        );
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (started && !floating) SizedBox(height: regularHeight + 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (var index = 0; index < 4; index++)
                      ChoiceChip(
                        label: Text(
                          uiTr(
                            context,
                            ['本地视频', '网络视频', '视频列表', '悬浮播放'][index],
                          ),
                        ),
                        selected: mode == index,
                        onSelected: (_) => setState(() => mode = index),
                      ),
                  ],
                ),
                if (mode != 0) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: url,
                    decoration: InputDecoration(
                      labelText: uiTr(context, '视频地址'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey('player-load'),
                  onPressed: loading ? null : start,
                  child: Text(uiTr(context, '开始')),
                ),
                Text(uiTr(context, status)),
                if (started) ...[
                  Text('${clock(position)} / ${clock(duration)}'),
                  Slider(
                    value: position.clamp(0, math.max(1, duration)),
                    max: math.max(1, duration),
                    onChanged: ready
                        ? (value) => setState(() => position = value)
                        : null,
                    onChangeEnd: ready ? seek : null,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      IconButton(
                        tooltip: uiTr(context, playing ? '暂停' : '开始'),
                        onPressed: ready
                            ? () => action(playing ? 'pause' : 'play')
                            : null,
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                      ),
                      OutlinedButton(
                        onPressed: ready ? () => action('fullScreen') : null,
                        child: Text(uiTr(context, '全屏')),
                      ),
                      OutlinedButton(
                        onPressed: ready && pipSupported
                            ? () => action('pip')
                            : null,
                        child: Text(uiTr(context, '画中画')),
                      ),
                      OutlinedButton(
                        onPressed: ready ? () => action('traffic') : null,
                        child: Text(uiTr(context, '流量监控')),
                      ),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          floating = !floating;
                          floatOffset = Offset(
                            12,
                            math.max(
                              12,
                              constraints.maxHeight - smallHeight - 16,
                            ),
                          );
                        }),
                        child: Text(uiTr(context, floating ? '恢复' : '悬浮播放')),
                      ),
                    ],
                  ),
                  trafficPanel(),
                ],
                if (mode == 2) ...[
                  const SizedBox(height: 16),
                  for (var index = 0; index < 6; index++)
                    ListTile(
                      leading: Image.asset(
                        'assets/Images/flower.png',
                        width: 64,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                      title: Text('${uiTr(context, '视频')} ${index + 1}'),
                      trailing: const Icon(Icons.play_circle_outline),
                      onTap: () async {
                        if (started) await action('pause');
                        if (!context.mounted) return;
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlayerLaboratoryDemo(
                              initialMode: 1,
                              autoStart: true,
                              initialSource: url.text.trim(),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ],
            ),
            if (started)
              AnimatedPositioned(
                key: const ValueKey('player-shell'),
                duration: const Duration(milliseconds: 220),
                left: floating ? offset.dx : 0,
                top: floating ? offset.dy : 0,
                width: floating ? smallWidth : constraints.maxWidth,
                height: floating ? smallHeight : regularHeight,
                child: Material(
                  elevation: floating ? 12 : 0,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(floating ? 12 : 0),
                  child: Column(
                    children: [
                      if (floating)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (details) =>
                              setState(() => floatOffset += details.delta),
                          child: ColoredBox(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Icon(Icons.drag_handle, size: 24),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 30,
                                    height: 30,
                                  ),
                                  tooltip: uiTr(context, '恢复'),
                                  onPressed: () =>
                                      setState(() => floating = false),
                                  icon: const Icon(
                                    Icons.open_in_full,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Expanded(child: video()),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: PlayerLaboratoryDemo(), title: '播放器实验室'));
