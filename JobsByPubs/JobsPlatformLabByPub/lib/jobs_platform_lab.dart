library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

export 'src/ble_protocol.dart';

/// Typed channel boundary. Unsupported platforms fail explicitly rather than
/// reporting simulated device data as a successful native call.
class JobsPlatformLab {
  JobsPlatformLab._();
  static const methods = MethodChannel('jobs_platform_lab/methods');
  static const _events = EventChannel('jobs_platform_lab/events');
  static Stream<Map<String, dynamic>>? _stream;
  static bool get hasNativeBridge =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  static Stream<Map<String, dynamic>> get allEvents => _stream ??= _events
      .receiveBroadcastStream()
      .map((event) => Map<String, dynamic>.from(event as Map))
      .asBroadcastStream();
  static Stream<Map<String, dynamic>> events(String topic) =>
      allEvents.where((event) => event['topic'] == topic);
  static Future<T?> invoke<T>(
    String method, [
    Map<String, dynamic> arguments = const {},
  ]) {
    if (!hasNativeBridge) {
      return Future.error(
        UnsupportedError('Native bridge requires iOS or Android: $method'),
      );
    }
    return methods.invokeMethod<T>(method, arguments);
  }
}
