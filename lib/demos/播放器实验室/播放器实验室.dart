// 独立运行：flutter run -t "lib/demos/播放器实验室/播放器实验室.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

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
import '播放质量状态.dart';
import '播放质量文案.dart';

void main() =>
    runApp(const JobsDemoApp(home: PlayerLaboratoryDemo(), title: '播放器实验室'));

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
  final quality = PlayerQualityState();
  Timer? readinessDeadline;
  Completer<int?>? pendingNativeView;
  String? activeSource;
  PlayerCheckpoint? restoring;
  int failedGeneration = -1;
  static const loadTimeout = Duration(
    milliseconds: int.fromEnvironment(
      'PLAYER_LOAD_TIMEOUT_MS',
      defaultValue: 4000,
    ),
  );
  @override
  void initState() {
    super.initState();
    mode = widget.initialMode;
    if (widget.initialSource != null) {
      url.text = widget.initialSource!;
    } else {
      unawaited(preferences());
    }
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(start());
      });
    }
  }

  Future<void> preferences() async {
    final value = await UiDemoStore.read('player-preferences', {
      'url': initialURL,
    });
    if (mounted && value is Map && value['url'] is String) {
      url.text = value['url'] as String;
    }
  }

  @override
  void dispose() {
    generation++;
    readinessDeadline?.cancel();
    if (pendingNativeView?.isCompleted == false) {
      pendingNativeView!.complete(null);
    }
    quality.dispose();
    subscription?.cancel();
    webController?.dispose();
    url.dispose();
    super.dispose();
  }

  void rememberPosition() {
    if (ready &&
        activeSource != null &&
        (position > 0 || quality.checkpoint(activeSource!) == null)) {
      quality.remember(activeSource!, position, quality.intendedPlaying);
    }
  }

  Future<void> loadingFailed(int current) async {
    if (!mounted || current != generation || failedGeneration == current) {
      return;
    }
    failedGeneration = current;
    readinessDeadline?.cancel();
    rememberPosition();
    quality.failed();
    if (mode != 0 && !localFallback) {
      localFallback = true;
      quality.fellBack();
      await load();
    } else {
      setState(() {
        loading = false;
        ready = false;
        status = '失败';
      });
    }
  }

  Future<void> restoreNative(int current) async {
    final point = restoring;
    restoring = null;
    if (point == null) return;
    try {
      await command('seek', {'seconds': point.seekPosition(duration)});
      if (!mounted || current != generation) return;
      await command(point.playing ? 'play' : 'pause');
    } catch (_) {
      if (mounted && current == generation) {
        quality.failed();
        uiNotice(context, '失败');
      }
    }
  }

  void event(Map<String, dynamic> envelope) {
    final raw = envelope['data'];
    final data = raw is Map ? Map<String, dynamic>.from(raw) : envelope;
    if (!mounted || data['viewId'] != viewId) return;
    final kind = data['event'];
    final nextPosition = data['position'];
    final nextDuration = data['duration'];
    if (nextPosition is num && nextPosition.isFinite && nextPosition >= 0) {
      position = nextPosition.toDouble();
    }
    if (nextDuration is num && nextDuration.isFinite && nextDuration >= 0) {
      duration = nextDuration.toDouble();
    }
    if (data['isPlaying'] is bool) playing = data['isPlaying'] as bool;
    if (kind == 'error') {
      unawaited(loadingFailed(generation));
      return;
    }
    if (kind == 'ready') {
      readinessDeadline?.cancel();
      ready = true;
      loading = false;
      status = localFallback ? '本地视频回退' : '完成';
      unawaited(restoreNative(generation));
    }
    if (kind == 'progress' && ready) rememberPosition();
    quality.observe(
      position: position,
      playing: playing,
      ready: kind == 'ready',
    );
    setState(() {
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

  Future<void> start({bool resume = false}) async {
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
    rememberPosition();
    if (resume) quality.recovering();
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
          if (mounted) unawaited(loadingFailed(generation));
        },
      );
      await load(resume: resume);
    } else {
      await load(resume: resume);
    }
  }

  Future<int?> installNativeView(int current) {
    if (pendingNativeView?.isCompleted == false) {
      pendingNativeView!.complete(null);
    }
    final created = Completer<int?>();
    pendingNativeView = created;
    viewId = null;
    void receive(int id) {
      if (!created.isCompleted) created.complete(id);
    }

    // A fresh view ID is the existing native protocol's source-generation token.
    final key = ValueKey('native-player-attempt-$current');
    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            key: key,
            viewType: 'jobs_platform_lab/player',
            layoutDirection: TextDirection.ltr,
            onPlatformViewCreated: receive,
          )
        : AndroidView(
            key: key,
            viewType: 'jobs_platform_lab/player',
            layoutDirection: TextDirection.ltr,
            onPlatformViewCreated: receive,
          );
    setState(
      () => nativeView = KeyedSubtree(
        key: const ValueKey('native-player-view'),
        child: platformView,
      ),
    );
    return created.future.timeout(
      loadTimeout,
      onTimeout: () {
        if (!created.isCompleted) created.complete(null);
        return null;
      },
    );
  }

  Future<void> load({bool resume = false}) async {
    rememberPosition();
    final current = ++generation;
    readinessDeadline?.cancel();
    final local = mode == 0 || localFallback;
    activeSource = local ? 'asset:$localAsset' : 'url:${url.text.trim()}';
    restoring = resume ? quality.checkpoint(activeSource!) : null;
    quality.begin(
      activeSource!,
      reportsBuffering: !JobsPlatformLab.hasNativeBridge,
      restoring: restoring,
    );
    if (mounted) {
      setState(() {
        loading = true;
        ready = false;
        position = 0;
        duration = 0;
        status = localFallback ? '本地视频回退' : '等待';
      });
    }
    try {
      if (JobsPlatformLab.hasNativeBridge) {
        final payload = local
            ? {
                'bytes': (await rootBundle.load(localAsset)).buffer
                    .asUint8List(),
              }
            : {'url': url.text.trim()};
        if (!mounted || current != generation) return;
        final id = await installNativeView(current);
        if (!mounted || current != generation) return;
        if (id == null) {
          await loadingFailed(current);
          return;
        }
        viewId = id;
        readinessDeadline = Timer(loadTimeout, () {
          if (mounted && current == generation && loading) {
            unawaited(loadingFailed(current));
          }
        });
        final result = await command('load', {
          ...payload,
          'autoplay': restoring == null,
        }).timeout(loadTimeout);
        if (mounted && current == generation && result is Map) {
          setState(() => pipSupported = result['pipSupported'] == true);
        }
      } else {
        final next = local
            ? VideoPlayerController.asset(localAsset)
            : VideoPlayerController.networkUrl(Uri.parse(url.text.trim()));
        try {
          await next.initialize().timeout(loadTimeout);
          if (!mounted || current != generation) {
            await next.dispose();
            return;
          }
          final previous = webController;
          webController = next;
          next.addListener(webChanged);
          await previous?.dispose();
          if (!mounted || current != generation) return;
          final point = restoring;
          restoring = null;
          quality.observe(
            position: point?.position ?? 0,
            playing: false,
            ready: true,
          );
          if (point != null) {
            await next.seekTo(
              Duration(
                milliseconds:
                    (point.seekPosition(
                              next.value.duration.inMilliseconds / 1000,
                            ) *
                            1000)
                        .round(),
              ),
            );
          }
          if (!mounted || current != generation) return;
          if (point?.playing ?? true) {
            await next.play();
          } else {
            await next.pause();
          }
          if (mounted && current == generation) {
            setState(() {
              ready = true;
              loading = false;
              status = localFallback ? '本地视频回退' : '完成';
            });
          }
        } catch (_) {
          await next.dispose();
          rethrow;
        }
      }
    } catch (_) {
      await loadingFailed(current);
    }
  }

  void webChanged() {
    if (!mounted || webController == null) return;
    final value = webController!.value;
    if (value.hasError && ready) {
      unawaited(loadingFailed(generation));
      return;
    }
    quality.observe(
      position: value.position.inMilliseconds / 1000,
      playing: value.isPlaying,
      isBuffering: value.isBuffering,
    );
    setState(() {
      playing = value.isPlaying;
      position = value.position.inMilliseconds / 1000;
      duration = value.duration.inMilliseconds / 1000;
    });
  }

  Future<void> action(String name) async {
    if (name == 'play' || name == 'pause') quality.intent(name == 'play');
    try {
      if (JobsPlatformLab.hasNativeBridge) {
        final result = await command(name);
        if (mounted && name == 'traffic' && result is Map) {
          setState(() => traffic = Map<String, dynamic>.from(result));
        }
      } else if (name == 'play') {
        await webController?.play();
      } else if (name == 'pause') {
        await webController?.pause();
      } else if (name == 'fullScreen') {
        if (mounted) {
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: JobsDemoAppBar(title: Text(uiTr(context, '全屏'))),
                body: Center(
                  child: AspectRatio(
                    aspectRatio: webController!.value.aspectRatio,
                    child: VideoPlayer(webController!),
                  ),
                ),
              ),
            ),
          );
        }
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
      if (mounted && activeSource != null) {
        quality.remember(activeSource!, value, quality.intendedPlaying);
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
    if (webController != null && webController!.value.isInitialized) {
      return VideoPlayer(webController!);
    }
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

  Widget qualityPanel() => AnimatedBuilder(
    animation: quality,
    builder: (context, _) {
      String elapsed(Duration? value) => value == null
          ? qualityTr(context, '未收到测量事件')
          : '${value.inMilliseconds} ms';
      return Card(
        key: const ValueKey('player-quality-panel'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                qualityTr(context, '播放质量与恢复'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${qualityTr(context, '就绪耗时')}: ${elapsed(quality.readyLatency)}',
              ),
              Text(
                '${qualityTr(context, '首次进度推进耗时')}: ${elapsed(quality.firstProgressLatency)}',
              ),
              Text(
                '${qualityTr(context, '缓冲次数与时长')}: ${quality.bufferingReported ? '${quality.bufferingCount} / ${quality.bufferedDuration.inMilliseconds} ms' : qualityTr(context, '当前适配器未提供')}',
              ),
              Text(
                '${qualityTr(context, '错误次数')}: ${quality.errorCount} · ${qualityTr(context, '恢复尝试')}: ${quality.recoveryCount} · ${qualityTr(context, '本地回退次数')}: ${quality.fallbackCount}',
              ),
              const SizedBox(height: 6),
              Text(
                qualityTr(context, '就绪与进度不等于首帧或掉帧指标'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                qualityTr(context, '恢复检查点仅保留本页会话'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('player-recover'),
                onPressed: loading ? null : () => start(resume: true),
                icon: const Icon(Icons.replay),
                label: Text(qualityTr(context, '重试原地址并恢复进度')),
              ),
            ],
          ),
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '播放器实验室'))),
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
                  qualityPanel(),
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
