import 'dart:convert';
import 'dart:typed_data';

String prettyJson(Object? value) {
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return '$value';
  }
}

Map<String, dynamic> asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, data) => MapEntry('$key', data));
  }
  return <String, dynamic>{};
}

List<dynamic> asList(Object? value) {
  if (value is List) {
    return value;
  }
  return const [];
}

Uint8List asBytes(Object? value) {
  if (value is Uint8List) {
    return value;
  }
  if (value is ByteBuffer) {
    return Uint8List.view(value);
  }
  if (value is ByteData) {
    return value.buffer.asUint8List();
  }
  if (value is List<int>) {
    return Uint8List.fromList(value);
  }
  return Uint8List(0);
}

Object? normalizeBody(Object? body) {
  if (body is Map<String, dynamic>) {
    return body;
  }
  if (body is Map) {
    return body.map((key, value) => MapEntry('$key', value));
  }
  if (body is List) {
    return body;
  }
  return body;
}
