import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as cipher;
import 'package:shared_preferences/shared_preferences.dart';

/// 命名空间是安全边界；拒绝解码后的越界路径，不依赖宿主当前目录。
class JobsLabSandbox {
  JobsLabSandbox(this.namespace) {
    if (!RegExp(r'^[a-zA-Z0-9_-]{1,64}$').hasMatch(namespace)) {
      throw ArgumentError.value(namespace, 'namespace');
    }
  }
  final String namespace;
  static final Map<String, Future<void>> _queues = {};
  String get storageKey => 'jobs.lab.sandbox.$namespace';
  String validatePath(String path) {
    final decoded = Uri.decodeComponent(path);
    if (decoded.isEmpty ||
        decoded.startsWith('/') ||
        decoded.contains('\\') ||
        decoded.contains(':') ||
        decoded.contains('\u0000') ||
        decoded.split('/').any((p) => p.isEmpty || p == '.' || p == '..')) {
      throw ArgumentError.value(
        path,
        'path',
        'Path must stay inside the namespace',
      );
    }
    return decoded;
  }

  Future<Map<String, String>> entries() async {
    await (_queues[storageKey] ?? Future<void>.value());
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(storageKey);
    if (encoded == null) return {};
    final value = jsonDecode(encoded);
    return Map<String, String>.from(value as Map);
  }

  Future<void> write(String path, String value) =>
      _mutate((items) => items[validatePath(path)] = value);
  Future<void> remove(String path) =>
      _mutate((items) => items.remove(validatePath(path)));
  Future<void> clear() => _mutate((items) => items.clear());
  Future<String?> read(String path) async =>
      (await entries())[validatePath(path)];
  Future<void> _mutate(void Function(Map<String, String>) action) {
    final previous = _queues[storageKey] ?? Future<void>.value();
    final operation = previous.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(storageKey);
      final items = encoded == null
          ? <String, String>{}
          : Map<String, String>.from(jsonDecode(encoded) as Map);
      action(items);
      if (!await prefs.setString(storageKey, jsonEncode(items)))
        throw StateError('Storage write failed');
    });
    _queues[storageKey] = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return operation;
  }
}

typedef JobsLabCapability = FutureOr<Object?> Function(Map<String, dynamic>);

class JobsLabBridge {
  JobsLabBridge({
    required this.appId,
    required this.allowedMethods,
    required this.capabilities,
  });
  final String appId;
  final Set<String> allowedMethods;
  final Map<String, JobsLabCapability> capabilities;
  Future<Map<String, Object?>> dispatch(Object? raw) async {
    Object? id;
    try {
      final message = raw is String ? jsonDecode(raw) : raw;
      if (message is! Map) throw const FormatException('Object required');
      id = message['id'];
      if (message['appId'] != appId)
        throw StateError('Application identity rejected');
      final method = message['method'];
      if (method is! String ||
          !allowedMethods.contains(method) ||
          !capabilities.containsKey(method)) {
        throw StateError('Capability not granted');
      }
      final parameters = message['params'] ?? <String, dynamic>{};
      if (parameters is! Map)
        throw const FormatException('Parameters must be an object');
      final result = await capabilities[method]!(
        Map<String, dynamic>.from(parameters),
      );
      return {'id': id, 'ok': true, 'result': result};
    } catch (error) {
      return {'id': id, 'ok': false, 'error': error.toString()};
    }
  }
}

/// 配置热更新只替换显式登记的工厂；不会执行下载的任意 Dart 或原生代码。
class JobsLabPatchRegistry {
  final Map<String, Map<String, dynamic>> _defaults = {};
  final Map<String, Map<String, dynamic>> _patches = {};
  void register(String name, Map<String, dynamic> defaults) =>
      _defaults[name] = Map.of(defaults);
  Map<String, dynamic> resolve(String name) =>
      Map.unmodifiable({...?_defaults[name], ...?_patches[name]});
  void apply(String name, Map<String, dynamic> patch) {
    final original = _defaults[name];
    if (original == null || patch.keys.any((key) => !original.containsKey(key)))
      throw ArgumentError('Unknown patch target or field');
    for (final key in patch.keys) {
      if (patch[key].runtimeType != original[key].runtimeType)
        throw ArgumentError('Patch field type mismatch: $key');
    }
    _patches[name] = Map.of(patch);
  }

  void rollback(String name) => _patches.remove(name);
}

class JobsCNIDResult {
  const JobsCNIDResult(this.valid, this.checks);
  final bool valid;
  final Map<String, bool> checks;
}

JobsCNIDResult validateCNID(String input, {DateTime? now}) {
  final text = input.trim().toUpperCase();
  final format = RegExp(r'^\d{17}[\dX]$').hasMatch(text);
  final checks = <String, bool>{
    'format': format,
    'province': false,
    'date': false,
    'sequence': false,
    'checksum': false,
  };
  if (!format) return JobsCNIDResult(false, checks);
  const provinces = {
    '11',
    '12',
    '13',
    '14',
    '15',
    '21',
    '22',
    '23',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '50',
    '51',
    '52',
    '53',
    '54',
    '61',
    '62',
    '63',
    '64',
    '65',
    '71',
    '81',
    '82',
  };
  checks['province'] = provinces.contains(text.substring(0, 2));
  final year = int.parse(text.substring(6, 10));
  final month = int.parse(text.substring(10, 12));
  final day = int.parse(text.substring(12, 14));
  final date = DateTime(year, month, day);
  checks['date'] =
      year >= 1800 &&
      date.year == year &&
      date.month == month &&
      date.day == day &&
      !date.isAfter(now ?? DateTime.now());
  checks['sequence'] = text.substring(14, 17) != '000';
  const weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
  final sum = List.generate(
    17,
    (i) => int.parse(text[i]) * weights[i],
  ).fold<int>(0, (a, b) => a + b);
  checks['checksum'] = '10X98765432'[sum % 11] == text[17];
  return JobsCNIDResult(checks.values.every((value) => value), checks);
}

class JobsLabCodec {
  static String compress(String text) =>
      base64Encode(GZipEncoder().encode(utf8.encode(text)));
  static String decompress(String encoded) =>
      utf8.decode(GZipDecoder().decodeBytes(base64Decode(encoded)));
  static String sealImage(Uint8List bytes, String passphrase) {
    if (passphrase.isEmpty) throw ArgumentError('Passphrase required');
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final key = cipher.Key(
      Uint8List.fromList(
        sha256.convert([...salt, ...utf8.encode(passphrase)]).bytes,
      ),
    );
    final iv = cipher.IV.fromSecureRandom(12);
    final encrypted = cipher.Encrypter(
      cipher.AES(key, mode: cipher.AESMode.gcm),
    ).encryptBytes(bytes, iv: iv);
    return jsonEncode({
      'v': 1,
      'salt': base64Encode(salt),
      'iv': iv.base64,
      'ciphertext': encrypted.base64,
    });
  }

  static Uint8List openImage(String encoded, String passphrase) {
    final envelope = jsonDecode(encoded) as Map;
    if (envelope['v'] != 1) throw const FormatException('Unsupported envelope');
    final salt = base64Decode(envelope['salt'] as String);
    final key = cipher.Key(
      Uint8List.fromList(
        sha256.convert([...salt, ...utf8.encode(passphrase)]).bytes,
      ),
    );
    return Uint8List.fromList(
      cipher.Encrypter(cipher.AES(key, mode: cipher.AESMode.gcm)).decryptBytes(
        cipher.Encrypted.fromBase64(envelope['ciphertext'] as String),
        iv: cipher.IV.fromBase64(envelope['iv'] as String),
      ),
    );
  }
}

class JobsLabRecordStore {
  JobsLabRecordStore(String database) : sandbox = JobsLabSandbox(database);
  final JobsLabSandbox sandbox;
  Future<List<Map<String, dynamic>>> query({String contains = ''}) async =>
      (await sandbox.entries()).entries
          .map(
            (item) => {
              ...jsonDecode(item.value) as Map<String, dynamic>,
              'id': item.key,
            },
          )
          .where(
            (item) => item.values
                .join(' ')
                .toLowerCase()
                .contains(contains.toLowerCase()),
          )
          .toList()
        ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  Future<void> put(String id, Map<String, dynamic> fields) =>
      sandbox.write(id, jsonEncode(fields));
  Future<void> delete(String id) => sandbox.remove(id);
}

class JobsLabTimer {
  JobsLabTimer(this.id, this.duration);
  final String id;
  final Duration duration;
  final Stopwatch watch = Stopwatch();
  bool get complete => watch.elapsed >= duration;
  double get progress =>
      (watch.elapsedMicroseconds / duration.inMicroseconds).clamp(0, 1);
  Duration get elapsed => complete ? duration : watch.elapsed;
}

class JobsLabTimerHub {
  final Map<String, JobsLabTimer> timers = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  Timer? _ticker;
  Stream<void> get changes => _changes.stream;
  void create(String id, Duration duration) {
    if (duration <= Duration.zero)
      throw ArgumentError('Duration must be positive');
    timers[id]?.watch.stop();
    timers[id] = JobsLabTimer(id, duration);
    _emit();
  }

  void start(String id) {
    final timer = timers[id]!;
    if (timer.complete) timer.watch.reset();
    timer.watch.start();
    _ticker ??= Timer.periodic(const Duration(milliseconds: 50), (_) {
      for (final timer in timers.values) {
        if (timer.complete) timer.watch.stop();
      }
      _emit();
      if (timers.values.every((item) => !item.watch.isRunning)) {
        _ticker?.cancel();
        _ticker = null;
      }
    });
    _emit();
  }

  void pause(String id) {
    timers[id]!.watch.stop();
    _emit();
  }

  void reset(String id) {
    timers[id]!.watch
      ..stop()
      ..reset();
    _emit();
  }

  void remove(String id) {
    timers.remove(id)?.watch.stop();
    _emit();
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(null);
  }

  void dispose() {
    _ticker?.cancel();
    for (final timer in timers.values) {
      timer.watch.stop();
    }
    _changes.close();
  }
}
