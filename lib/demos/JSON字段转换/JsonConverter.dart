import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

/// ======================== 基础：对象 或 JSON 字符串 -> T ========================
class MapOrStringJsonConverter<T> implements JsonConverter<T?, Object?> {
  const MapOrStringJsonConverter(this.fromJsonT, {this.toJsonT});

  final T Function(Map<String, dynamic>) fromJsonT;
  final Object? Function(T value)? toJsonT;

  @override
  T? fromJson(Object? json) {
    if (json == null) return null;

    if (json is Map<String, dynamic>) return fromJsonT(json);

    if (json is String && json.isNotEmpty) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map<String, dynamic>) return fromJsonT(decoded);
      } catch (_) {}
    }
    throw FormatException('期望 Map 或 JSON 字符串，实际 ${json.runtimeType}');
  }

  @override
  Object? toJson(T? object) {
    if (object == null) return null;
    if (toJsonT != null) return toJsonT!(object);
    final dyn = object as dynamic;
    try {
      return dyn.toJson();
    } catch (_) {
      return object;
    }
  }
}

/// ======================== 基础：列表 或 字符串 -> `List<T>` ========================
class MapOrStringListJsonConverter<T>
    implements JsonConverter<List<T>?, Object?> {
  const MapOrStringListJsonConverter(this.fromJsonT, {this.toJsonT});

  final T Function(Map<String, dynamic>) fromJsonT;
  final Object? Function(T value)? toJsonT;

  @override
  List<T>? fromJson(Object? json) {
    if (json == null) return null;

    List<dynamic>? raw;
    if (json is List) {
      raw = json;
    } else if (json is String && json.isNotEmpty) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is List) raw = decoded;
      } catch (_) {}
    }
    if (raw == null) {
      throw FormatException('期望 List 或 JSON 字符串(数组)，实际 ${json.runtimeType}');
    }

    return raw
        .map<T>((e) {
          if (e is Map<String, dynamic>) return fromJsonT(e);
          throw FormatException('列表元素期望 Map，实际 ${e.runtimeType}');
        })
        .toList(growable: false);
  }

  @override
  Object? toJson(List<T>? objects) {
    if (objects == null) return null;
    return objects
        .map((e) {
          if (toJsonT != null) return toJsonT!(e);
          final dyn = e as dynamic;
          try {
            return dyn.toJson();
          } catch (_) {
            return e;
          }
        })
        .toList(growable: false);
  }
}

/// ======================== 字典：`Map<String, T>` ========================
class MapOrStringMapJsonConverter<T>
    implements JsonConverter<Map<String, T>?, Object?> {
  const MapOrStringMapJsonConverter(this.fromJsonT, {this.toJsonT});

  final T Function(Map<String, dynamic>) fromJsonT;
  final Object? Function(T value)? toJsonT;

  @override
  Map<String, T>? fromJson(Object? json) {
    if (json == null) return null;

    Map<String, dynamic>? raw;
    if (json is Map) {
      raw = json.map((k, v) => MapEntry(k.toString(), v));
    } else if (json is String && json.isNotEmpty) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          raw = decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }
    if (raw == null) {
      throw FormatException('期望 Map 或 JSON 字符串(对象)，实际 ${json.runtimeType}');
    }

    final result = <String, T>{};
    raw.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        result[key] = fromJsonT(val);
      } else {
        throw FormatException(
          'Map 值期望 Map<String,dynamic>，key=$key 实际 ${val.runtimeType}',
        );
      }
    });
    return result;
  }

  @override
  Object? toJson(Map<String, T>? map) {
    if (map == null) return null;
    final out = <String, dynamic>{};
    map.forEach((k, v) {
      if (toJsonT != null) {
        out[k] = toJsonT!(v);
      } else {
        final dyn = v as dynamic;
        try {
          out[k] = dyn.toJson();
        } catch (_) {
          out[k] = v;
        }
      }
    });
    return out;
  }
}
