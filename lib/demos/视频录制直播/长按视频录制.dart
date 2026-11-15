import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';

import '长按视频文案.dart';

void main() => runApp(const JobsDemoApp(home: HoldVideoRecorderDemo()));

class HoldVideoRecorderDemo extends StatefulWidget {
  const HoldVideoRecorderDemo({super.key, this.recordingClock});

  @visibleForTesting
  final Stopwatch? recordingClock;

  @override
  State<HoldVideoRecorderDemo> createState() => _HoldVideoRecorderState();
}

class _HoldVideoRecorderState extends State<HoldVideoRecorderDemo>
    with WidgetsBindingObserver {
  static const minimum = Duration(seconds: 3);
  static const maximum = Duration(seconds: 60);
  static const filters = [
    'normal',
    'mono',
    'noir',
    'sepia',
    'chrome',
    'instant',
    'fade',
  ];

  CameraController? _camera;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0, _cameraEpoch = 0, _gestureEpoch = 0, _previewEpoch = 0;
  int? _pointer, _playerId;
  Offset? _pressOrigin;
  Offset _previewOffset = const Offset(12, 12);
  late final Stopwatch _clock = widget.recordingClock ?? Stopwatch();
  bool? _cameraHasAudio;
  bool _previewPlaced = false;
  Timer? _pressDelay, _progressTimer, _limitTimer;
  StreamSubscription<Map<String, dynamic>>? _events;
  Future<void>? _initialization,
      _startTask,
      _stopTask,
      _processingTask,
      _saveTask;
  Future<void> _suspension = Future<void>.value();

  bool _foreground = true, _closing = false;
  bool _fingerDown = false, _cancelTake = false, _recording = false;
  bool _initializing = false, _starting = false, _stopping = false;
  bool _processing = false,
      _saving = false,
      _switching = false,
      _discarding = false;
  bool _floating = true,
      _playerReady = false,
      _playerPlaying = false,
      _pipSupported = false;
  String _filter = 'normal', _status = '准备相机';
  String? _detail, _recordName, _recordPath, _savedName;
  XFile? _rawClip;
  Widget? _nativePlayer;
  Duration _elapsed = Duration.zero;

  bool get _hasClip => _rawClip != null || _recordName != null;
  bool get _busy =>
      _starting ||
      _stopping ||
      _processing ||
      _saving ||
      _switching ||
      _discarding;
  bool get _canConfigure => !_busy && !_fingerDown && !_recording && !_hasClip;
  bool get _usesCIFilter =>
      JobsPlatformLab.hasNativeBridge &&
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (JobsPlatformLab.hasNativeBridge) {
      _events = JobsPlatformLab.events('player').listen(
        _playerEvent,
        onError: (Object error) {
          if (!_closing && mounted && _hasClip) {
            _update(() {
              _status = '预览失败';
              _detail = error.toString();
            });
          }
        },
      );
    }
    unawaited(_ensureCamera());
  }

  void _update(VoidCallback change) {
    if (mounted && !_closing) setState(change);
  }

  bool _wanted(int token) =>
      !_closing &&
      mounted &&
      _foreground &&
      !_cancelTake &&
      _fingerDown &&
      token == _gestureEpoch;

  Future<void> _ensureCamera() async {
    if (_closing || !_foreground) return;
    final pending = _initialization;
    if (pending != null) {
      await pending;
      if (identical(_initialization, pending)) _initialization = null;
      if (!_closing &&
          _foreground &&
          _camera?.value.isInitialized == true &&
          _cameraHasAudio != !_hasClip) {
        await _ensureCamera();
      }
      return;
    }
    final audio = !_hasClip;
    if (_camera?.value.isInitialized == true &&
        _camera?.value.hasError == false &&
        _cameraHasAudio == audio)
      return;
    final task = _openCamera(_cameraEpoch, audio: audio);
    _initialization = task;
    try {
      await task;
    } finally {
      if (identical(_initialization, task)) _initialization = null;
    }
  }

  Future<void> _openCamera(int token, {required bool audio}) async {
    if (!JobsPlatformLab.hasNativeBridge) {
      _update(() => _status = '录像需要移动设备');
      return;
    }
    final previousStatus = _status;
    final preserveNotice = const {
      '录制至少3秒',
      '视频已丢弃',
      '视频已保存到相册',
    }.contains(previousStatus);
    _update(() {
      _initializing = true;
      _detail = null;
      _status = preserveNotice ? previousStatus : '准备相机';
    });
    CameraController? next;
    try {
      await _releaseCamera();
      if (_cameras.isEmpty) _cameras = await availableCameras();
      if (_closing || !_foreground || token != _cameraEpoch) return;
      if (_cameras.isEmpty) {
        _update(() => _status = '没有可用摄像头');
        return;
      }
      if (_closing || !_foreground || token != _cameraEpoch) return;
      _cameraIndex = _cameraIndex.clamp(0, _cameras.length - 1);
      // 录后预览只启用摄像头，不占用麦克风及播放器的音频会话。
      next = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: audio,
      );
      await next.initialize();
      if (_closing || !_foreground || token != _cameraEpoch) {
        await next.dispose();
        return;
      }
      _camera = next;
      _cameraHasAudio = audio;
      next.addListener(_cameraChanged);
      _update(() {
        if (!_hasClip && !preserveNotice) _status = '按住录制松手结束';
      });
    } catch (error) {
      if (next != null && !identical(next, _camera))
        await _disposeController(next);
      if (token == _cameraEpoch)
        _update(() {
          _status = '相机不可用';
          _detail = error.toString();
        });
    } finally {
      _update(() => _initializing = false);
    }
  }

  void _cameraChanged() {
    final camera = _camera;
    if (_closing || !mounted || camera == null || !camera.value.hasError)
      return;
    _update(() {
      _status = '相机不可用';
      _detail = camera.value.errorDescription;
    });
    if (_recording || _starting) unawaited(_endHold(discard: true));
  }

  Future<void> _disposeController(CameraController controller) async {
    controller.removeListener(_cameraChanged);
    try {
      await controller.dispose();
    } catch (_) {}
  }

  Future<void> _releaseCamera() async {
    final camera = _camera;
    _camera = null;
    _cameraHasAudio = null;
    if (camera != null) await _disposeController(camera);
  }

  void _pointerDown(PointerDownEvent event) {
    if (_pointer != null ||
        _busy ||
        _hasClip ||
        _recording ||
        !_foreground ||
        _closing)
      return;
    _pointer = event.pointer;
    _pressOrigin = event.position;
    _fingerDown = true;
    _cancelTake = false;
    final token = ++_gestureEpoch;
    _update(() => _status = '按住录制松手结束');
    _pressDelay = Timer(const Duration(milliseconds: 300), () {
      if (_wanted(token)) unawaited(_beginRecording(token));
    });
  }

  void _pointerMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _pressOrigin == null) return;
    if (_pressOrigin!.dy - event.position.dy >= 72 && !_cancelTake) {
      _cancelTake = true;
      _update(() => _status = '松手丢弃视频');
    }
  }

  void _pointerUp(PointerEvent event, {bool cancelled = false}) {
    if (event.pointer != _pointer) return;
    unawaited(_endHold(discard: cancelled || _cancelTake));
  }

  Future<void> _beginRecording(int token) async {
    if (!_wanted(token) || _starting || _recording) return;
    _update(() {
      _starting = true;
      _status = '正在启动录制';
    });
    final task = _startRecording(token);
    _startTask = task;
    try {
      await task;
    } finally {
      if (identical(_startTask, task)) _startTask = null;
      _update(() => _starting = false);
    }
  }

  Future<void> _startRecording(int token) async {
    try {
      await _ensureCamera();
      if (!_wanted(token)) return;
      final camera = _camera;
      if (camera == null ||
          !camera.value.isInitialized ||
          camera.value.hasError)
        return;
      await camera.startVideoRecording(enablePersistentRecording: false);
      _clock
        ..reset()
        ..start();
      _recording = true;
      // 权限和 start 的异步返回不能复活已松开的手指。
      if (!_wanted(token)) {
        await _finishTake(discard: true);
        return;
      }
      _update(() {
        _elapsed = Duration.zero;
        _status = _cancelTake ? '松手丢弃视频' : '录制中上滑取消';
      });
      _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        _update(() => _elapsed = _clock.elapsed);
      });
      _limitTimer = Timer(maximum, () {
        unawaited(_endHold());
      });
    } catch (error) {
      if (_camera?.value.isRecordingVideo == true)
        await _finishTake(discard: true);
      _update(() {
        _status = '录制失败';
        _detail = error.toString();
      });
    }
  }

  Future<void> _endHold({bool discard = false}) async {
    _pressDelay?.cancel();
    _fingerDown = false;
    _pointer = null;
    _pressOrigin = null;
    ++_gestureEpoch;
    _cancelTake = _cancelTake || discard;
    final starting = _startTask;
    if (starting != null) await starting;
    if (_recording || _camera?.value.isRecordingVideo == true)
      await _finishTake(discard: _cancelTake);
    _update(() {});
  }

  Future<void> _finishTake({bool discard = false}) async {
    _cancelTake = _cancelTake || discard;
    final pending = _stopTask;
    if (pending != null) {
      await pending;
      return;
    }
    final task = _stopRecording();
    _stopTask = task;
    try {
      await task;
    } finally {
      if (identical(_stopTask, task)) _stopTask = null;
    }
  }

  Future<void> _stopRecording() async {
    _progressTimer?.cancel();
    _limitTimer?.cancel();
    _clock.stop();
    final elapsed = _clock.elapsed;
    final camera = _camera;
    _update(() {
      _stopping = true;
      _elapsed = elapsed;
      _status = '正在结束录制';
    });
    try {
      if (camera == null || !camera.value.isRecordingVideo) return;
      final file = await camera.stopVideoRecording();
      _recording = false;
      final discard = _cancelTake || _closing || !_foreground;
      if (discard || elapsed < minimum) {
        await _discardFile(file);
        _update(() {
          _status = discard ? '视频已丢弃' : '录制至少3秒';
        });
        return;
      }
      _rawClip = file;
      await _releaseCamera();
      if (_closing || !_foreground || _cancelTake) {
        await _discardFile(file);
        _rawClip = null;
        return;
      }
      await _processClip(file);
    } catch (error) {
      _update(() {
        _status = '录制失败';
        _detail = error.toString();
      });
    } finally {
      _recording = false;
      _update(() => _stopping = false);
    }
  }

  Future<void> _processClip(XFile file) async {
    final token = ++_previewEpoch;
    final task = _importClip(file, token);
    _processingTask = task;
    try {
      await task;
    } finally {
      if (identical(_processingTask, task)) _processingTask = null;
    }
  }

  Future<void> _importClip(XFile file, int token) async {
    _update(() {
      _processing = true;
      _detail = null;
      _status = '正在处理视频';
    });
    String? imported;
    try {
      final value = await JobsPlatformLab.invoke<Map<Object?, Object?>>(
        'video.import',
        {'path': file.path, 'filter': _usesCIFilter ? _filter : 'normal'},
      );
      if (value == null || value['name'] is! String || value['path'] is! String)
        throw const FormatException('Invalid video.import response');
      imported = value['name'] as String;
      if (_closing || token != _previewEpoch || _discarding) {
        await _deleteRecord(imported);
        return;
      }
      final mediaDuration = value['duration'];
      if (mediaDuration is! num ||
          !mediaDuration.isFinite ||
          mediaDuration < minimum.inMilliseconds / 1000) {
        await _deleteRecord(imported);
        await _discardFile(file);
        _rawClip = null;
        _update(() => _status = '录制至少3秒');
        return;
      }
      _recordName = imported;
      _recordPath = value['path'] as String;
      _rawClip = null;
      _savedName = null;
      _floating = true;
      _previewPlaced = false;
      _playerReady = false;
      _nativePlayer = null;
      _playerId = null;
      await _discardFile(file);
      _update(() {
        _status = '预览录制结果';
        _elapsed = Duration(milliseconds: (mediaDuration * 1000).round());
      });
    } catch (error) {
      if (imported != null && imported != _recordName)
        await _deleteRecord(imported);
      if (!_closing && token == _previewEpoch)
        _update(() {
          _status = '处理失败可重试';
          _detail = error.toString();
        });
    } finally {
      _update(() => _processing = false);
      if (!_closing && _foreground && !_discarding) await _ensureCamera();
    }
  }

  Future<void> _discardFile(XFile? file) async {
    if (file == null || !JobsPlatformLab.hasNativeBridge) return;
    try {
      await JobsPlatformLab.invoke<Object?>('video.discard', {
        'path': file.path,
      });
    } catch (_) {}
  }

  Future<void> _deleteRecord(String? name) async {
    if (name == null || name == _savedName) return;
    try {
      await JobsPlatformLab.invoke<Object?>('video.delete', {'name': name});
    } catch (_) {}
  }

  Future<void> _playerCommand(String action) async {
    final id = _playerId;
    if (id == null) return;
    try {
      await JobsPlatformLab.invoke<Object?>('player.command', {
        'viewId': id,
        'action': action,
      });
    } catch (error) {
      _update(() {
        _status = '预览失败';
        _detail = error.toString();
      });
    }
  }

  void _playerEvent(Map<String, dynamic> event) {
    final raw = event['data'];
    if (raw is! Map || _closing || !mounted || raw['viewId'] != _playerId)
      return;
    _update(() {
      if (raw['isPlaying'] is bool) _playerPlaying = raw['isPlaying'] as bool;
      if (raw['event'] == 'ready') _playerReady = true;
      if (raw['event'] == 'error') {
        _status = '预览失败';
        _detail = raw['error']?.toString();
      }
    });
  }

  Future<void> _attachPlayer(int id, int token, String path) async {
    if (_closing || token != _previewEpoch) return;
    _playerId = id;
    try {
      final value = await JobsPlatformLab.invoke<Map<Object?, Object?>>(
        'player.command',
        {'viewId': id, 'action': 'load', 'path': path, 'autoplay': true},
      );
      if (token == _previewEpoch)
        _update(() => _pipSupported = value?['pipSupported'] == true);
    } catch (error) {
      if (token == _previewEpoch)
        _update(() {
          _status = '预览失败';
          _detail = error.toString();
        });
    }
  }

  Widget _playerView() {
    final path = _recordPath;
    if (path == null) return const SizedBox.shrink();
    final token = _previewEpoch;
    return _nativePlayer ??= defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            key: ValueKey('hold-player-$token'),
            viewType: 'jobs_platform_lab/player',
            layoutDirection: TextDirection.ltr,
            onPlatformViewCreated: (id) {
              unawaited(_attachPlayer(id, token, path));
            },
          )
        : AndroidView(
            key: ValueKey('hold-player-$token'),
            viewType: 'jobs_platform_lab/player',
            layoutDirection: TextDirection.ltr,
            onPlatformViewCreated: (id) {
              unawaited(_attachPlayer(id, token, path));
            },
          );
  }

  Future<void> _save() async {
    if (_saving || _recordName == null) return;
    final task = _saveClip(_recordName!, _previewEpoch);
    _saveTask = task;
    try {
      await task;
    } finally {
      if (identical(_saveTask, task)) _saveTask = null;
    }
  }

  Future<void> _saveClip(String name, int token) async {
    _update(() {
      _saving = true;
      _status = '正在保存视频';
      _detail = null;
    });
    try {
      final result = await JobsPlatformLab.invoke<Object?>(
        'video.saveToPhotos',
        {'name': name},
      );
      if (result != true)
        throw StateError('The photo library did not confirm the save');
      _savedName = name;
      if (!_closing && token == _previewEpoch) {
        await _resetPreview(keepRecord: true, waitForTasks: false);
        _update(() => _status = '视频已保存到相册');
      }
    } catch (error) {
      _update(() {
        _status = '保存失败可重试';
        _detail = error.toString();
      });
    } finally {
      _update(() => _saving = false);
    }
  }

  Future<void> _resetPreview({
    bool keepRecord = false,
    bool waitForTasks = true,
  }) async {
    ++_previewEpoch;
    _update(() {
      _discarding = true;
      _status = '正在丢弃视频';
    });
    if (waitForTasks) {
      await _processingTask;
      await _saveTask;
    }
    final id = _playerId;
    if (id != null) {
      try {
        await JobsPlatformLab.invoke<Object?>('player.command', {
          'viewId': id,
          'action': 'pause',
        });
      } catch (_) {}
    }
    final name = _recordName;
    final raw = _rawClip;
    _recordName = null;
    _recordPath = null;
    _rawClip = null;
    _nativePlayer = null;
    _playerId = null;
    _playerReady = false;
    _pipSupported = false;
    _update(() {});
    if (!keepRecord) await _deleteRecord(name);
    await _discardFile(raw);
    await _releaseCamera();
    _update(() {
      _discarding = false;
      _status = '按住录制松手结束';
      _elapsed = Duration.zero;
      _detail = null;
    });
    if (!_closing && _foreground) await _ensureCamera();
  }

  Future<void> _switchCamera() async {
    if (!_canConfigure || _cameras.length < 2) return;
    _update(() => _switching = true);
    ++_cameraEpoch;
    try {
      await _initialization;
      await _releaseCamera();
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      await _ensureCamera();
    } finally {
      _update(() => _switching = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_closing) return;
    if (state == AppLifecycleState.resumed) {
      _foreground = true;
      unawaited(_resumeCamera());
    } else if (_foreground) {
      _foreground = false;
      ++_cameraEpoch;
      _suspension = _suspendCamera();
    }
  }

  Future<void> _suspendCamera() async {
    await _endHold(discard: true);
    await _initialization;
    await _releaseCamera();
  }

  Future<void> _resumeCamera() async {
    await _suspension;
    if (!_closing && _foreground) await _ensureCamera();
  }

  Future<void> _shutdown() async {
    await _endHold(discard: true);
    await _initialization;
    await _processingTask;
    await _saveTask;
    await _deleteRecord(_recordName);
    await _discardFile(_rawClip);
    await _releaseCamera();
  }

  @override
  void dispose() {
    _closing = true;
    _foreground = false;
    ++_cameraEpoch;
    ++_previewEpoch;
    ++_gestureEpoch;
    _pressDelay?.cancel();
    _progressTimer?.cancel();
    _limitTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_events?.cancel());
    unawaited(_shutdown());
    super.dispose();
  }

  String _time(Duration value) =>
      '${value.inSeconds ~/ 60}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  Widget _cameraContent(BuildContext context) {
    final camera = _camera;
    if (camera != null &&
        camera.value.isInitialized &&
        !camera.value.hasError) {
      final size = camera.value.previewSize;
      final landscape =
          MediaQuery.orientationOf(context) == Orientation.landscape;
      final width = size == null
          ? 720.0
          : landscape
          ? size.width
          : size.height;
      final height = size == null
          ? 1280.0
          : landscape
          ? size.height
          : size.width;
      return ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: width,
              height: height,
              child: CameraPreview(camera),
            ),
          ),
        ),
      );
    }
    if (_initializing || _processing || _starting || _stopping || _switching)
      return const Center(child: CircularProgressIndicator());
    return JobsEmptyState(
      title: holdVideoText(context, _status),
      message: holdVideoText(context, '检查相机与麦克风权限'),
      onReload: _ensureCamera,
    );
  }

  Widget _preview(BuildContext context, BoxConstraints constraints) {
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final width = _floating
        ? math.min(180.0, constraints.maxWidth * .48)
        : constraints.maxWidth;
    final height = _floating
        ? math.min(230.0, math.max(64.0, constraints.maxHeight * .36))
        : math.max(64.0, constraints.maxHeight - topInset);
    final preferred = _previewPlaced
        ? _previewOffset
        : Offset(constraints.maxWidth - width - 12, topInset + 112);
    final offset = Offset(
      preferred.dx
          .clamp(0, math.max(0, constraints.maxWidth - width))
          .toDouble(),
      preferred.dy
          .clamp(topInset, math.max(topInset, constraints.maxHeight - height))
          .toDouble(),
    );
    return AnimatedPositioned(
      key: const ValueKey('hold-preview-shell'),
      duration: const Duration(milliseconds: 180),
      top: _floating ? offset.dy : topInset,
      left: _floating ? offset.dx : 0,
      width: width,
      height: height,
      child: Material(
        elevation: 12,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: _floating
                  ? (details) => _update(() {
                      _previewPlaced = true;
                      _previewOffset = offset + details.delta;
                    })
                  : null,
              child: Row(
                children: [
                  const Expanded(child: Icon(Icons.drag_handle, size: 20)),
                  IconButton(
                    tooltip: holdVideoText(
                      context,
                      _floating ? '展开预览' : '浮窗预览',
                    ),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _update(() => _floating = !_floating),
                    icon: Icon(
                      _floating ? Icons.open_in_full : Icons.close_fullscreen,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _playerView()),
          ],
        ),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          holdVideoText(context, _status),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          '${_time(_elapsed)} / 1:00 · 3–60s',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (_elapsed.inMilliseconds / maximum.inMilliseconds)
              .clamp(0, 1)
              .toDouble(),
          color: _cancelTake ? colors.error : colors.primary,
        ),
        if (_detail != null)
          Tooltip(
            message: _detail!,
            child: Text(
              holdVideoText(context, '操作失败请重试'),
              style: TextStyle(color: colors.error),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 8),
        if (_hasClip || _processing || _discarding)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _recordName != null && !_busy ? _save : null,
                icon: const Icon(Icons.save_alt),
                label: Text(holdVideoText(context, '保存到相册')),
              ),
              OutlinedButton(
                onPressed: _saving || _discarding
                    ? null
                    : () => _resetPreview(),
                child: Text(holdVideoText(context, '重拍丢弃')),
              ),
              if (_rawClip != null && !_busy)
                TextButton(
                  onPressed: () => _processClip(_rawClip!),
                  child: Text(holdVideoText(context, '重试处理')),
                ),
              IconButton(
                tooltip: holdVideoText(
                  context,
                  _playerPlaying ? '暂停预览' : '播放预览',
                ),
                onPressed: _playerReady && !_saving
                    ? () => _playerCommand(_playerPlaying ? 'pause' : 'play')
                    : null,
                icon: Icon(_playerPlaying ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                tooltip: holdVideoText(context, '系统画中画'),
                onPressed: _playerReady && _pipSupported && !_saving
                    ? () => _playerCommand('pip')
                    : null,
                icon: const Icon(Icons.picture_in_picture_alt),
              ),
            ],
          )
        else
          Listener(
            onPointerDown: _pointerDown,
            onPointerMove: _pointerMove,
            onPointerUp: _pointerUp,
            onPointerCancel: (event) => _pointerUp(event, cancelled: true),
            child: Semantics(
              button: true,
              label: holdVideoText(context, '按住录制松手结束'),
              child: AnimatedContainer(
                key: const ValueKey('hold-record-button'),
                duration: const Duration(milliseconds: 120),
                width: 88,
                height: 88,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _cancelTake
                      ? colors.errorContainer
                      : colors.primaryContainer,
                  border: Border.all(
                    color: _cancelTake ? colors.error : colors.primary,
                    width: _recording ? 7 : 3,
                  ),
                ),
                child: Icon(
                  _recording ? Icons.stop : Icons.videocam,
                  color: _cancelTake
                      ? colors.onErrorContainer
                      : colors.onPrimaryContainer,
                  size: 36,
                ),
              ),
            ),
          ),
        if (_recording)
          TextButton(
            onPressed: () => _endHold(),
            child: Text(holdVideoText(context, '结束录制')),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final options = _usesCIFilter ? filters : const ['normal'];
    final unavailable =
        (_camera == null || _camera!.value.hasError) &&
        !_initializing &&
        !_busy &&
        !_hasClip &&
        !_recording;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colors.surface.withValues(alpha: .96),
        foregroundColor: colors.onSurface,
        title: Text(holdVideoText(context, '长按录制视频')),
        actions: [
          IconButton(
            tooltip: holdVideoText(context, '切换摄像头'),
            onPressed: _canConfigure && _cameras.length > 1
                ? _switchCamera
                : null,
            icon: const Icon(Icons.flip_camera_ios_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: _cameraContent(context)),
            if (!unavailable)
              Positioned(
                top: MediaQuery.paddingOf(context).top + kToolbarHeight + 8,
                left: 12,
                right: 12,
                child: Material(
                  color: colors.surface.withValues(alpha: .96),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _filter,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: holdVideoText(context, '录制滤镜'),
                          ),
                          items: [
                            for (final filter in options)
                              DropdownMenuItem(
                                value: filter,
                                child: Text(
                                  holdVideoText(context, '滤镜$filter'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: _canConfigure && _usesCIFilter
                              ? (value) => _update(() => _filter = value!)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          holdVideoText(
                            context,
                            _usesCIFilter ? '滤镜录后写入视频' : '系统滤镜仅支持iOS',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_recordName != null && constraints.maxHeight >= 160)
              _preview(context, constraints),
            if (!unavailable)
              Positioned(
                left: 12,
                right: 12,
                bottom: MediaQuery.paddingOf(context).bottom + 12,
                child: Material(
                  color: colors.surface.withValues(alpha: .96),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: math.max(100.0, constraints.maxHeight * .55),
                      ),
                      child: SingleChildScrollView(child: _controls(context)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
