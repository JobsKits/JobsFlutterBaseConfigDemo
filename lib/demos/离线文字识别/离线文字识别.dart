// 独立运行：flutter run -t "lib/demos/离线文字识别/离线文字识别.dart"
// 使用本工程的 JobsByPubs 原生插件与随包 Rust 模型。
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_rust_ocr/jobs_rust_ocr.dart';

import '识别文案.dart';

void main() {
  registerOCRTranslations();
  runApp(const JobsDemoApp(home: RustOCRDemo()));
}

class RustOCRDemo extends StatefulWidget {
  const RustOCRDemo({
    super.key,
    this.client = const JobsRustOCR(),
    this.autoRecognize = false,
    this.onResult,
    this.onFailure,
  });

  final JobsOCRClient client;
  final bool autoRecognize;
  final ValueChanged<JobsOCRResult>? onResult;
  final ValueChanged<Object>? onFailure;

  @override
  State<RustOCRDemo> createState() => _RustOCRDemoState();
}

class _RustOCRDemoState extends State<RustOCRDemo> {
  Uint8List? _image;
  String? _imageError;
  JobsOCRResult? _result;
  String? _error;
  String _version = '';
  String _status = '尚无识别结果';
  bool _sample = true;
  bool _busy = false;
  bool _loading = false;
  bool _boxes = true;
  bool _cancelled = false;
  int _generation = 0;
  bool _autoStarted = false;

  @override
  void initState() {
    super.initState();
    registerOCRTranslations();
    unawaited(_loadSample());
  }

  Future<void> _loadSample() async {
    if (_busy) return;
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      _imageError = null;
      _result = null;
      _status = '尚无识别结果';
    });
    try {
      final values = await Future.wait<Object>([
        widget.client.sampleImage(),
        widget.client.coreVersion(),
      ]);
      if (!mounted || generation != _generation) return;
      setState(() {
        _image = values[0] as Uint8List;
        _version = values[1] as String;
        _sample = true;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _error = _errorDetails(error));
        widget.onFailure?.call(error);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
        if (widget.autoRecognize && !_autoStarted && _error == null) {
          _autoStarted = true;
          unawaited(_recognize());
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_busy || _loading) return;
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _imageError = null;
    });
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        requestFullMetadata: false,
      );
      if (file == null || !mounted || generation != _generation) return;
      final bytes = await file.readAsBytes();
      if (!mounted || generation != _generation) return;
      setState(() {
        _image = bytes;
        _sample = false;
        _result = null;
        _error = null;
        _status = '尚无识别结果';
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _imageError = _imageErrorKey(error, source));
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  String _imageErrorKey(Object error, ImageSource source) {
    if (source == ImageSource.camera) {
      if (error is PlatformException) {
        final code = error.code.toLowerCase();
        if (code.contains('access') || code.contains('permission')) {
          return '相机权限未开启，请在系统设置中允许访问';
        }
      }
      return '当前设备或模拟器无法拍照，请使用相册或样本';
    }
    return '图片读取失败，请检查权限后重试';
  }

  Future<void> _copyResult() async {
    final text = _result?.text;
    if (text == null || text.trim().isEmpty) return;
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ocrTr(context, '文字已复制'))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ocrTr(context, '复制失败，请重试'))));
    }
  }

  Future<void> _recognize() async {
    if (_busy || _loading || _image == null) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _cancelled = false;
      _error = null;
      _result = null;
      _status = '正在识别';
    });
    try {
      final result = await widget.client.recognize(
        image: _sample ? null : _image,
      );
      if (!mounted || generation != _generation || _cancelled) return;
      setState(() {
        _result = result;
        _status = result.text.trim().isEmpty ? '未发现可识别文字' : '识别完成';
      });
      widget.onResult?.call(result);
    } catch (error) {
      if (mounted && generation == _generation && !_cancelled) {
        setState(() {
          _error = _errorDetails(error);
          _status = '识别未完成';
        });
        widget.onFailure?.call(error);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _cancel() async {
    if (!_busy || _cancelled) return;
    setState(() {
      _cancelled = true;
      _status = '正在取消';
    });
    try {
      await widget.client.cancel();
      if (mounted) setState(() => _status = '已取消识别');
    } catch (error) {
      if (mounted) setState(() => _error = _errorDetails(error));
    }
  }

  String _errorDetails(Object error) => switch (error) {
    MissingPluginException() => 'platform_unavailable',
    PlatformException(:final code, :final message) => '$code: ${message ?? ''}',
    _ => error.toString(),
  };

  @override
  void dispose() {
    _generation++;
    unawaited(widget.client.cancel().catchError((Object _) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final inputStyle = OutlinedButton.styleFrom(
      foregroundColor: colors.onSurface,
      backgroundColor: colors.surfaceContainerHigh,
      disabledForegroundColor: colors.onSurfaceVariant,
      disabledBackgroundColor: colors.surfaceContainer,
      side: BorderSide(color: colors.outline),
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
    return Scaffold(
      appBar: JobsDemoAppBar(title: Text(ocrTr(context, '离线文字识别'))),
      body: SingleChildScrollView(
        key: const ValueKey('rust-ocr-page'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(ocrTr(context, '图片在设备上处理，无需网络。')),
            const SizedBox(height: 12),
            if (_image case final image?) ...[
              Semantics(
                label: ocrTr(context, _sample ? '预置样本' : '所选图片'),
                image: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: colors.surfaceContainerLow,
                    child: SizedBox(
                      height: 240,
                      child: LayoutBuilder(
                        builder: (context, size) => Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              image,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  Center(child: Text(ocrTr(context, '图片无法预览'))),
                            ),
                            if (_boxes && result != null)
                              IgnorePointer(
                                child: CustomPaint(
                                  painter: _LineBoxes(result, colors.primary),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('rust-ocr-sample'),
                  style: inputStyle,
                  onPressed: _busy || _loading ? null : _loadSample,
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: Text(ocrTr(context, '预置样本')),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('rust-ocr-gallery'),
                  style: inputStyle,
                  onPressed: _busy || _loading
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(ocrTr(context, '选择图片')),
                ),
                OutlinedButton.icon(
                  key: const ValueKey('rust-ocr-camera'),
                  style: inputStyle,
                  onPressed: _busy || _loading
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: Text(ocrTr(context, '拍照')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const ValueKey('rust-ocr-recognize'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    disabledBackgroundColor: colors.surfaceContainerHighest,
                    disabledForegroundColor: colors.onSurfaceVariant,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                  ),
                  onPressed: _busy || _loading || _image == null
                      ? null
                      : _recognize,
                  icon: const Icon(Icons.document_scanner_outlined, size: 20),
                  label: Text(ocrTr(context, '开始识别')),
                ),
                if (_busy)
                  OutlinedButton(
                    key: const ValueKey('rust-ocr-cancel'),
                    style: inputStyle,
                    onPressed: _cancelled ? null : _cancel,
                    child: Text(ocrTr(context, '取消识别')),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading || _busy) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            Semantics(
              liveRegion: true,
              child: Text(
                ocrTr(context, _status),
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (_imageError case final error?) ...[
              const SizedBox(height: 8),
              Text(
                ocrTr(context, error),
                key: const ValueKey('rust-ocr-image-error'),
                style: TextStyle(color: colors.error),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ocrTr(context, '识别未完成'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ocrTr(
                          context,
                          _error == 'platform_unavailable'
                              ? '当前平台尚未接入原生OCR插件'
                              : '请检查图片或模型，重新加载后重试',
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(_error!, style: theme.textTheme.bodySmall),
                      TextButton(
                        onPressed: _busy || _loading ? null : _loadSample,
                        child: Text(ocrTr(context, '重新加载')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (result != null) ...[
              const SizedBox(height: 8),
              Text(
                '${ocrTr(context, '识别行数')} ${result.lines.length} · '
                '${ocrTr(context, '耗时')} ${result.elapsedMs.toStringAsFixed(0)} ms',
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(ocrTr(context, '显示行框')),
                value: _boxes,
                onChanged: (value) => setState(() => _boxes = value),
              ),
            ],
            if (result != null && result.text.trim().isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ocrTr(context, '识别结果'),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    key: const ValueKey('rust-ocr-copy'),
                    onPressed: _copyResult,
                    icon: const Icon(Icons.copy),
                    label: Text(ocrTr(context, '复制文字')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                result.text,
                key: const ValueKey('rust-ocr-text'),
                scrollPhysics: const NeverScrollableScrollPhysics(),
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(ocrTr(context, '逐行结果')),
                children: [
                  for (final line in result.lines)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: SelectableText(line.text),
                      subtitle: Text(
                        '${ocrTr(context, '置信度')} '
                        '${(line.confidence * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                ],
              ),
            ] else if (!_busy && !_loading && _error == null)
              SizedBox(
                height: 240,
                child: JobsEmptyState(
                  title: _status,
                  message: '选择样本、相册或拍照后开始识别',
                  onReload: _image == null ? _loadSample : _recognize,
                ),
              ),
            if (_version.isNotEmpty) ...[
              const Divider(height: 28),
              Text(
                '${ocrTr(context, '核心版本')} $_version',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineBoxes extends CustomPainter {
  const _LineBoxes(this.result, this.color);
  final JobsOCRResult result;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fit = applyBoxFit(
      BoxFit.contain,
      Size(result.width.toDouble(), result.height.toDouble()),
      size,
    );
    final target = Alignment.center.inscribe(
      fit.destination,
      Offset.zero & size,
    );
    final sx = target.width / result.width;
    final sy = target.height / result.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final line in result.lines) {
      final b = line.bbox;
      canvas.drawRect(
        Rect.fromLTRB(
          target.left + b[0] * sx,
          target.top + b[1] * sy,
          target.left + b[2] * sx,
          target.top + b[3] * sy,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LineBoxes oldDelegate) =>
      oldDelegate.result != result || oldDelegate.color != color;
}
