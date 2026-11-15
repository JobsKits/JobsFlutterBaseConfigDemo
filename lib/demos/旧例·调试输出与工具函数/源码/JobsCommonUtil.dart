import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_plugin_engagelab/flutter_plugin_engagelab.dart';

/// 用法
void legacyOriginalMain() {
  final mockData = {
    "status": "success",
    "code": 200,
    "meta": {"page": 1, "total": 3},
    "user": {
      "id": 123,
      "name": "Alice",
      "roles": ["admin", "editor", "user"],
      "settingsJson": '{"theme": "dark", "language": "en", "notifications": {"email": true, "sms": false}}', // JSON字符串
      "address": {
        "city": "Wonderland",
        "zip": "12345",
        "coords": [51.5074, 0.1278],
      },
    },
    "items": [
      {
        "id": 1,
        "name": "Item 1",
        "price": 10.5,
        "tagsJson": '["tag1", "tag2", {"nested": "value"}]', // JSON字符串
      },
      {
        "id": 2,
        "name": "Item 2",
        "price": 20.0,
        "details": {"weight": "1kg", "color": "red"},
      },
    ],
    "rawJson": '{"a":1,"b":[2,3,{"c":4}]}', // JSON字符串
  };

  final mockListData = [
    {
      "id": 1,
      "name": "First",
      "metaJson":
          '{"views": 100, "likes": 50, "tags": ["news", "sports"]}', // JSON字符串
      "details": {
        "category": "A",
        "attributes": [
          {"key": "color", "value": "red"},
          {"key": "size", "value": "M"},
        ],
      },
    },
    {
      "id": 2,
      "name": "Second",
      "metaJson":
          '{"views": 200, "likes": 120, "tags": ["tech", "gaming"]}', // JSON字符串
      "details": {
        "category": "B",
        "attributes": [
          {"key": "material", "value": "cotton"},
          {"key": "origin", "value": "USA"},
        ],
      },
    },
    '{"jsonStringRoot": true, "nested": {"a": 1, "b": [10, 20]}}', // 根List里的JSON字符串
  ];

  // 打印整个对象
  // po(mockData);
  // po(mockListData);
  // mockData.p
  // mockData.p.value
  // mockData.jobsee()
  // 打印指定路径
  // po(mockData, path: 'user.settingsJson');
  // po(mockListData, path: '[0]');
  // po(mockListData, path: '[0].details.attributes[1].value');

  JobsPrint(mockData);
  JobsPrint(mockListData);

  legacyDebugPrint("");
}

/// =============================== 控制台打印对象 ===============================
/// 命名po，延续iOS开发中打印对象的方法命名的传统
void po(
  dynamic input, {
  String? path, // 点语法: 't.actionCfg.gameType'
  int maxDepth = 6, // 最大展开层级
  int maxItems = 30, // 每层最多多少元素
  int maxString = 200, // 字符串显示最大长度
  bool showTypes = true,
}) {
  dynamic obj = input;

  if (path == null || path.trim().isEmpty) {
    JobsPrint(input);
    return;
  }

  final result = _resolvePath(input, path);
  JobsPrint(result);

  // 如果是类似 NetworkResponse/Response 且有 data 属性，默认先拿 data
  try {
    if (!(obj is Map || obj is List) && obj?.data != null) {
      obj = (obj as dynamic).data;
    }
  } catch (_) {}

  // 点路径（逐层时也会自动解码 JSON 字符串）
  if (path.isNotEmpty) {
    for (final k in path.split('.')) {
      obj = _decodeIfJsonString(obj);
      if (obj is Map && obj.containsKey(k)) {
        obj = obj[k];
      } else {
        legacyDebugPrint('<Key not found: $k>');
        return;
      }
    }
  }

  // 根也尝试一次解码
  obj = _decodeIfJsonString(obj);

  final seen = <int>{}; // 简单循环保护
  void walk(dynamic v, int depth, String indent, String? k) {
    final prefix = k == null ? '' : '$k: ';
    final type = showTypes ? ' <${v.runtimeType}>' : '';

    if (v == null) {
      legacyDebugPrint('$indent${prefix}null$type');
      return;
    }

    // 循环引用保护
    final id = identityHashCode(v);
    if (v is Map || v is List) {
      if (seen.contains(id)) {
        legacyDebugPrint('$indent$prefix<cyclic>$type');
        return;
      }
      seen.add(id);
    }

    // 字符串里包着 JSON，自动解一次
    if (v is String) {
      final decoded = _tryDecodeJson(v);
      if (decoded != null) {
        walk(decoded, depth, indent, k);
        return;
      }
    }

    if (v is Map) {
      final entries = v.entries.toList();
      legacyDebugPrint('$indent$prefix{${entries.length}}$type');
      if (depth >= maxDepth) {
        legacyDebugPrint('$indent  … <maxDepth>');
        return;
      }
      final limit = entries.length.clamp(0, maxItems);
      for (var i = 0; i < limit; i++) {
        final e = entries[i];
        walk(e.value, depth + 1, '$indent  ', e.key.toString());
      }
      if (entries.length > limit) {
        legacyDebugPrint('$indent  … and ${entries.length - limit} more');
      }
      return;
    }

    if (v is List) {
      legacyDebugPrint('$indent$prefix[${v.length}]$type');
      if (depth >= maxDepth) {
        legacyDebugPrint('$indent  … <maxDepth>');
        return;
      }
      final limit = v.length.clamp(0, maxItems);
      for (var i = 0; i < limit; i++) {
        walk(v[i], depth + 1, '$indent  ', '[$i]');
      }
      if (v.length > limit) {
        legacyDebugPrint('$indent  … and ${v.length - limit} more');
      }
      return;
    }

    // 普通值
    var s = v.toString();
    if (s.length > maxString) s = '${s.substring(0, maxString)}…';
    legacyDebugPrint('$indent$prefix$s$type');
  }

  walk(obj, 0, '', null);
}

dynamic _resolvePath(Object? data, String path) {
  dynamic current = data;

  // 按 . 分割，再处理每段可能包含的 [index]
  final parts = path.split('.');
  for (var part in parts) {
    // 支持 foo[0][1] 连写
    final reg = RegExp(r'([^\[\]]+)|\[(\d+)\]');
    for (final match in reg.allMatches(part)) {
      if (match.group(1) != null) {
        // Map key
        if (current is String &&
            (current.trim().startsWith('{') ||
                current.trim().startsWith('['))) {
          current = json.decode(current);
        }
        if (current is Map) {
          current = current[match.group(1)];
        } else {
          throw '当前不是 Map，无法取 key ${match.group(1)}';
        }
      } else if (match.group(2) != null) {
        // List index
        final idx = int.parse(match.group(2)!);
        if (current is String &&
            (current.trim().startsWith('{') ||
                current.trim().startsWith('['))) {
          current = json.decode(current);
        }
        if (current is List) {
          if (idx >= 0 && idx < current.length) {
            current = current[idx];
          } else {
            throw 'List 下标越界: $idx';
          }
        } else {
          throw '当前不是 List，无法取下标 $idx';
        }
      }
    }
  }
  return current;
}

dynamic _decodeIfJsonString(dynamic v) {
  if (v is String) {
    final decoded = _tryDecodeJson(v);
    if (decoded != null) return decoded;
  }
  return v;
}

dynamic _tryDecodeJson(String s) {
  final trimmed = s.trimLeft();
  if (trimmed.isEmpty) return null;
  final firstChar = trimmed[0];
  if (!(firstChar == '{' || firstChar == '[')) return null;
  try {
    final d = jsonDecode(s);
    return (d is Map || d is List) ? d : null;
  } catch (_) {
    return null;
  }
}

class JobsPrinted<T> {
  final T value;
  JobsPrinted(this.value);

  @override
  String toString() {
    // VSCode 展开时，走我们自己的多行格式化
    final unwrapped = _unwrapForPretty(value, maxUnwrap: 3);
    return _messageToPrettyString(
      unwrapped,
      maxDepth: 6,
      maxItemsPerLevel: 200,
    );
  }
}

// 语法糖：任何对象上直接 .jobsee()
extension InspectX on Object? {
  /// 方法名前加前缀，避免与内置方法冲突
  void jobsee({
    String? path,
    int maxDepth = 6,
    int maxItems = 30,
    int maxString = 200,
    bool showTypes = true,
  }) => po(
    this,
    path: path,
    maxDepth: maxDepth,
    maxItems: maxItems,
    maxString: maxString,
    showTypes: showTypes,
  );

  /// 控制台打一份（美化），并返回包装器用于链式：resp.p.value
  JobsPrinted<Object?> get p {
    final unwrapped = _unwrapForPretty(this, maxUnwrap: 3);
    JobsPrint(unwrapped); // 只打一份美化后的
    return JobsPrinted(this); // 链式拿原对象：.p.value
  }
}

Object? _unwrapForPretty(Object? v, {int maxUnwrap = 2}) {
  var cur = v;
  for (int i = 0; i < maxUnwrap; i++) {
    final next = _unwrapKnown(cur);
    if (identical(next, cur)) break;
    cur = next;
  }
  return cur;
}

// 针对常见响应类型做 Duck Typing：有 data/body 就取出来；能 toJson 就用 toJson
Object? _unwrapKnown(Object? v) {
  if (v == null) return null;
  if (v is Map ||
      v is Iterable ||
      v is String ||
      v is num ||
      v is bool ||
      v is DateTime) {
    return v;
  }

  // 1) data
  try {
    final d = (v as dynamic).data;
    if (d != null) return d;
  } catch (_) {}

  // 2) body
  try {
    final b = (v as dynamic).body;
    if (b != null) return b;
  } catch (_) {}

  // 3) toJson
  try {
    final j = (v as dynamic).toJson();
    if (j is Map || j is List) return j;
  } catch (_) {}

  // 4) 最后一招：字符串里如果是 { ... } 或 [ ... ]，尝试 jsonDecode（不强制）
  final s = v.toString().trim();
  if ((s.startsWith('{') && s.endsWith('}')) ||
      (s.startsWith('[') && s.endsWith(']'))) {
    try {
      final j = jsonDecode(s);
      if (j is Map || j is List) return j;
    } catch (_) {
      /* 忽略 */
    }
  }

  return v; // 保持原样
}

/// =============================== 程序内打印 ==================================
void JobsPrint(
  Object? message, {
  int maxDepth = 6,
  int maxItemsPerLevel = 200,
}) {
  final String where = _captureCaller();
  final normalized = _unwrapForPretty(message, maxUnwrap: 3);
  final String text = _messageToPrettyString(
    normalized,
    maxDepth: maxDepth,
    maxItemsPerLevel: maxItemsPerLevel,
  );
  _emit('[$where]\n$text'); // 换行更清晰
}

/// 根据环境选择输出：优先插件，其次 debugPrint，兜底 print
void _emit(String s) {
  final bool onMobile = !kIsWeb && (GetPlatform.isAndroid || GetPlatform.isIOS);
  try {
    if (onMobile) {
      // 1) 原生插件
      try {
        FlutterPluginEngagelab.printMy(s);
      } catch (_) {
        // 忽略插件异常
      }
    }
    // 2) 一律也打到控制台（debugPrint 带节流；出问题再兜底 print）
    try {
      legacyDebugPrint(s);
    } catch (_) {
      // ignore: avoid_print
      print(s);
    }
  } catch (_) {
    // ignore: avoid_print
    print(s);
  }
}

/// 捕获调用方文件:行号
String _captureCaller() {
  final lines = StackTrace.current.toString().split('\n');
  for (var i = 1; i < lines.length && i < 5; i++) {
    final s = _formatStackTraceLine(lines[i]);
    if (s != null) return s;
  }
  return 'unknown:0';
}

String? _formatStackTraceLine(String line) {
  final re1 = RegExp(r'\(([^:()]+):(\d+)(?::\d+)?\)');
  final m1 = re1.firstMatch(line);
  if (m1 != null) return '${m1.group(1)}:${m1.group(2)}';

  final re2 = RegExp(r'(\S+\.dart)\s+(\d+)(?::\d+)?');
  final m2 = re2.firstMatch(line);
  if (m2 != null) return '${m2.group(1)}:${m2.group(2)}';

  return null;
}

/// 对象转字符串（带 JSON 识别 & 美化）
String _messageToPrettyString(
  Object? value, {
  int maxDepth = 6,
  int maxItemsPerLevel = 200,
}) {
  return _pretty(value, maxDepth, maxItemsPerLevel, 0);
}

String _pretty(Object? value, int maxDepth, int maxItemsPerLevel, int depth) {
  if (depth > maxDepth) return '...';
  if (value == null) return 'null';

  if (value is String) {
    final s = value.trim();
    if ((s.startsWith('{') && s.endsWith('}')) ||
        (s.startsWith('[') && s.endsWith(']'))) {
      try {
        final decoded = json.decode(s);
        return _pretty(decoded, maxDepth, maxItemsPerLevel, depth + 1);
      } catch (_) {
        return value;
      }
    }
    return value;
  }

  if (value is num || value is bool || value is DateTime) {
    return value.toString();
  }

  if (value is Map) {
    final entries = value.entries.toList();
    final limited = entries.length > maxItemsPerLevel
        ? entries.sublist(0, maxItemsPerLevel)
        : entries;
    final b = StringBuffer()..writeln('{');
    for (var i = 0; i < limited.length; i++) {
      final e = limited[i];
      final v = _pretty(
        e.value,
        maxDepth,
        maxItemsPerLevel,
        depth + 1,
      ).replaceAll('\n', '\n  ');
      b.writeln('  ${e.key}: $v${i == limited.length - 1 ? '' : ','}');
    }
    if (entries.length > limited.length) {
      b.writeln('  ... (${entries.length - limited.length} more)');
    }
    b.write('}');
    return b.toString();
  }

  if (value is Iterable) {
    final list = value.toList();
    final limited = list.length > maxItemsPerLevel
        ? list.sublist(0, maxItemsPerLevel)
        : list;
    final b = StringBuffer()..writeln('[');
    for (var i = 0; i < limited.length; i++) {
      final v = _pretty(
        limited[i],
        maxDepth,
        maxItemsPerLevel,
        depth + 1,
      ).replaceAll('\n', '\n  ');
      b.writeln('  $v${i == limited.length - 1 ? '' : ','}');
    }
    if (list.length > limited.length) {
      b.writeln('  ... (${list.length - limited.length} more)');
    }
    b.write(']');
    return b.toString();
  }

  try {
    final dynamic jsonData = (value as dynamic).toJson();
    return _pretty(jsonData, maxDepth, maxItemsPerLevel, depth + 1);
  } catch (_) {
    return value.toString();
  }
}

/// 工具函数
bool compareVersion(String version1, String version2, [int length = 3]) {
  List<int> parse(String v) {
    final parts = v.split('.');
    final out = <int>[];
    for (var i = 0; i < length; i++) {
      out.add(
        i < parts.length && parts[i].isNotEmpty
            ? int.tryParse(parts[i]) ?? 0
            : 0,
      );
    }
    return out;
  }

  final a = parse(version1);
  final b = parse(version2);
  for (var i = 0; i < length; i++) {
    if (a[i] != b[i]) return a[i] > b[i];
  }
  return false;
}

String getNowTime() {
  final now = DateTime.now();
  final main = DateFormat('yyyy/MM/ddTHH:mm:ss.SSS').format(now);
  final ap = DateFormat('a').format(now);
  return '$main $ap';
}

bool isAlphabet(String text) => RegExp(r'^[a-zA-Z]+$').hasMatch(text);
bool containsAlphabetAndNumbers(String text) =>
    RegExp(r'^[a-zA-Z0-9]+$').hasMatch(text);
bool containsUppercase(String text) => RegExp(r'[A-Z]').hasMatch(text);
bool isEmail(String text) =>
    RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(text);
bool isNumber(String text) =>
    RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(text);
bool containsUppercaseAndLowercase(String text) =>
    RegExp(r'[A-Z]').hasMatch(text) && RegExp(r'[a-z]').hasMatch(text);
bool containsNumbers(String text) => RegExp(r'[0-9]').hasMatch(text);
bool numberContainsSpecialCharacters(String text) =>
    RegExp(r'[^\d]').hasMatch(text);
bool isStringOnlyWhitespace(String input) => input.trim().isEmpty;

DateTime getLocalDate(int utcTimestamp) {
  if (utcTimestamp < DateTime(1980).millisecondsSinceEpoch) {
    utcTimestamp *= 1000;
  }
  return DateTime.fromMillisecondsSinceEpoch(
    utcTimestamp,
    isUtc: true,
  ).toLocal();
}

int getMaxDays(int year, int month) =>
    (month < 1 || month > 12) ? 0 : DateTime(year, month + 1, 0).day;

bool isDateValid(int year, int month, int day) {
  try {
    final d = DateTime(year, month, day);
    return d.year == year && d.month == month && d.day == day;
  } catch (_) {
    return false;
  }
}

bool isOver18Years(int y, int m, int d) {
  final now = DateTime.now();
  var age = now.year - y;
  if (now.month < m || (now.month == m && now.day < d)) age--;
  return age >= 18;
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() =>
    launchLegacyStandalone(legacyOriginalMain, title: '旧例·调试输出与工具函数');
