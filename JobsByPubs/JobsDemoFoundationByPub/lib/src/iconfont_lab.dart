import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 与 JobsIconfont 原生目录对应，Unicode 和文件族名只在公共层维护。
enum JobsIconfontGlyph {
  switcher(0xe601),
  iPhone(0xe602),
  direction(0xe603),
  picture(0xe605),
  lodging(0xe606),
  sort(0xe607),
  previous(0xe608),
  next(0xe609),
  verified(0xe60a),
  component(0xe60c);

  const JobsIconfontGlyph(this.codePoint);
  final int codePoint;
  String get character => String.fromCharCode(codePoint);
  static const fontFamily = 'packages/jobs_demo_foundation/JobsIconfontSample';
  static const textFontFamily = 'packages/jobs_demo_foundation/JobsAlimamaText';
  Widget build({double size = 32, Color? color}) => Text(
    character,
    semanticsLabel: name,
    textAlign: TextAlign.center,
    style: TextStyle(fontFamily: fontFamily, fontSize: size, color: color),
  );

  Future<Uint8List> rasterize({
    double size = 96,
    double scale = 1,
    Color color = Colors.black,
  }) async {
    final logical = size.isFinite ? size.clamp(1, 1024).toDouble() : 96.0;
    final ratio = scale.isFinite ? scale.clamp(1, 3).toDouble() : 1.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(ratio);
    final painter = TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: logical * .72,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset((logical - painter.width) / 2, (logical - painter.height) / 2),
    );
    painter.dispose();
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (logical * ratio).ceil(),
      (logical * ratio).ceil(),
    );
    picture.dispose();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (data == null) throw StateError('PNG encoder returned no data');
    return data.buffer.asUint8List();
  }
}

enum JobsIconfontAsset {
  logo(
    'https://img.alicdn.com/imgextra/i4/O1CN01XZe8pH1USpiUNT1QN_!!6000000002517-2-tps-114-114.png',
    'logo.png',
    JobsIconfontGlyph.component,
  ),
  fontBanner(
    'https://img.alicdn.com/imgextra/i1/O1CN01vqHHzA1JvGYdLg5KV_!!6000000001090-2-tps-2280-452.png',
    'font-banner.png',
    JobsIconfontGlyph.switcher,
  ),
  usageGuide(
    'https://img.alicdn.com/tfscom/T1R3VxFuRnXXaCwpjX.png',
    'usage-guide.png',
    JobsIconfontGlyph.iPhone,
  ),
  invalidURL(
    'https://at.alicdn.com/t/jobs-iconfont-invalid-demo.png',
    'logo.png',
    JobsIconfontGlyph.picture,
  );

  const JobsIconfontAsset(this.url, this.localFile, this.fallbackGlyph);
  final String url, localFile;
  final JobsIconfontGlyph fallbackGlyph;
  String get localPath =>
      'packages/jobs_demo_foundation/assets/iconfont/$localFile';
}

enum JobsIconfontCacheSource { memory, disk, network }

class JobsIconfontImageResult {
  const JobsIconfontImageResult(this.bytes, this.source);
  final Uint8List bytes;
  final JobsIconfontCacheSource source;
}

class JobsIconfontCancelled implements Exception {
  const JobsIconfontCancelled();
}

class JobsIconfontImageRequest {
  JobsIconfontImageRequest._(this._client);
  final http.Client _client;
  late final Future<JobsIconfontImageResult> future;
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _client.close();
  }

  void _check() {
    if (_cancelled) throw const JobsIconfontCancelled();
  }
}

/// 类型化官方图片、内存／磁盘缓存、代际保护及逐请求取消；不影响其它业务缓存。
class JobsIconfontCache {
  JobsIconfontCache({http.Client Function()? clientFactory})
    : _clientFactory = clientFactory ?? http.Client.new;
  static final shared = JobsIconfontCache();
  final http.Client Function() _clientFactory;
  final _memory = <JobsIconfontAsset, Uint8List>{};
  final _requests = <JobsIconfontImageRequest>{};
  int _epoch = 0;
  Future<void> _diskMutation = Future<void>.value();
  Future<void> _mutateDisk(Future<void> Function() action) {
    final operation = _diskMutation.then((_) => action());
    _diskMutation = operation.then((_) {}, onError: (Object _) {});
    return operation;
  }

  JobsIconfontImageRequest load(
    JobsIconfontAsset asset, {
    bool forceRefresh = false,
  }) {
    final request = JobsIconfontImageRequest._(_clientFactory());
    _requests.add(request);
    request.future = _load(request, asset, forceRefresh, _epoch).whenComplete(
      () {
        _requests.remove(request);
        request._client.close();
      },
    );
    return request;
  }

  Future<JobsIconfontImageResult> _load(
    JobsIconfontImageRequest request,
    JobsIconfontAsset asset,
    bool force,
    int epoch,
  ) async {
    request._check();
    if (!force && _memory.containsKey(asset))
      return JobsIconfontImageResult(
        _memory[asset]!,
        JobsIconfontCacheSource.memory,
      );
    final prefs = await SharedPreferences.getInstance();
    await _diskMutation;
    request._check();
    final key = 'jobs.iconfont.${asset.name}';
    if (!force) {
      final encoded = prefs.getString(key);
      if (encoded != null) {
        try {
          final bytes = base64Decode(encoded);
          await _validate(bytes);
          request._check();
          if (epoch != _epoch) throw const JobsIconfontCancelled();
          _memory[asset] = bytes;
          return JobsIconfontImageResult(bytes, JobsIconfontCacheSource.disk);
        } on JobsIconfontCancelled {
          rethrow;
        } catch (_) {
          await prefs.remove(key);
        }
      }
    }
    final response = await request._client
        .get(Uri.parse(asset.url))
        .timeout(const Duration(seconds: 4));
    request._check();
    if (response.statusCode < 200 || response.statusCode >= 300)
      throw http.ClientException(
        'HTTP ${response.statusCode}',
        Uri.parse(asset.url),
      );
    final bytes = response.bodyBytes;
    await _validate(bytes);
    request._check();
    if (epoch != _epoch) throw const JobsIconfontCancelled();
    await _mutateDisk(() async {
      request._check();
      if (epoch != _epoch) throw const JobsIconfontCancelled();
      try {
        await prefs.setString(key, base64Encode(bytes));
      } catch (_) {}
    });
    request._check();
    if (epoch != _epoch) throw const JobsIconfontCancelled();
    _memory[asset] = bytes;
    return JobsIconfontImageResult(bytes, JobsIconfontCacheSource.network);
  }

  Future<void> _validate(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > 8 * 1024 * 1024)
      throw const FormatException('Invalid image byte count');
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
  }

  void clearMemory() => _memory.clear();
  Future<void> clear() async {
    _epoch++;
    for (final request in _requests.toList()) request.cancel();
    _memory.clear();
    await _mutateDisk(() async {
      final prefs = await SharedPreferences.getInstance();
      for (final asset in JobsIconfontAsset.values)
        await prefs.remove('jobs.iconfont.${asset.name}');
    });
  }
}

/// 首帧与失败均保留随包资源，列表复用后旧请求不能覆盖新图片。
class JobsIconfontImage extends StatefulWidget {
  const JobsIconfontImage({
    super.key,
    required this.asset,
    this.cache,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.onResult,
    this.onError,
    this.refreshToken = 0,
  });
  final JobsIconfontAsset asset;
  final JobsIconfontCache? cache;
  final double? width, height;
  final BoxFit fit;
  final ValueChanged<JobsIconfontCacheSource>? onResult;
  final VoidCallback? onError;
  final int refreshToken;
  @override
  State<JobsIconfontImage> createState() => _JobsIconfontImageState();
}

class _JobsIconfontImageState extends State<JobsIconfontImage> {
  JobsIconfontImageRequest? request;
  Uint8List? bytes;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(JobsIconfontImage old) {
    super.didUpdateWidget(old);
    if (old.asset != widget.asset ||
        old.cache != widget.cache ||
        old.refreshToken != widget.refreshToken)
      load();
  }

  void load() {
    request?.cancel();
    bytes = null;
    final current = (widget.cache ?? JobsIconfontCache.shared).load(
      widget.asset,
      forceRefresh: widget.refreshToken > 0,
    );
    request = current;
    current.future.then(
      (result) {
        if (!mounted || request != current || current.isCancelled) return;
        setState(() => bytes = result.bytes);
        widget.onResult?.call(result.source);
      },
      onError: (Object error) {
        if (!mounted || request != current || current.isCancelled) return;
        widget.onError?.call();
      },
    );
  }

  @override
  void dispose() {
    request?.cancel();
    super.dispose();
  }

  Widget fallback() => Image.asset(
    widget.asset.localPath,
    width: widget.width,
    height: widget.height,
    fit: widget.fit,
    errorBuilder: (_, __, ___) =>
        widget.asset.fallbackGlyph.build(size: widget.width ?? 40),
  );
  @override
  Widget build(BuildContext context) => bytes == null
      ? fallback()
      : Image.memory(
          bytes!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          gaplessPlayback: false,
          cacheWidth: widget.width == null
              ? null
              : (widget.width! * MediaQuery.devicePixelRatioOf(context))
                    .round()
                    .clamp(1, 2048),
          errorBuilder: (_, __, ___) => fallback(),
        );
}
