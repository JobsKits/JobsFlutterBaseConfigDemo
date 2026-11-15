import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

/// Serial execution keeps one ATT operation pending per peripheral.
class JobsBleCommandQueue {
  Future<void> _tail = Future.value();
  int _generation = 0;
  Future<T> enqueue<T>(
    Future<T> Function() operation, {
    int retries = 0,
    Duration timeout = const Duration(seconds: 8),
  }) {
    final completion = Completer<T>();
    final generation = _generation;
    _tail = _tail.then((_) async {
      if (generation != _generation) {
        completion.completeError(StateError('Command queue cancelled'));
        return;
      }
      for (var attempt = 0; ; attempt++) {
        try {
          final value = await operation().timeout(timeout);
          completion.complete(value);
          return;
        } catch (error, stack) {
          if (attempt >= retries || generation != _generation) {
            completion.completeError(error, stack);
            return;
          }
        }
      }
    });
    return completion.future;
  }

  void cancelPending() => _generation++;
}

/// An explicit sample wire protocol: uint16 payload length + bytes + CRC16-CCITT.
/// Real devices must select a matching device profile instead of assuming this format.
class JobsBleCodec {
  static int crc16(List<int> bytes) {
    var crc = 0xffff;
    for (final byte in bytes) {
      crc ^= byte << 8;
      for (var bit = 0; bit < 8; bit++) {
        crc = ((crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1) & 0xffff;
      }
    }
    return crc;
  }

  static Uint8List encode(List<int> payload) {
    if (payload.length > 65535 || payload.any((b) => b < 0 || b > 255)) {
      throw const FormatException('Payload must be valid bytes <=65535');
    }
    final crc = crc16(payload);
    return Uint8List.fromList([
      payload.length >> 8,
      payload.length & 255,
      ...payload,
      crc >> 8,
      crc & 255,
    ]);
  }

  static Uint8List decode(List<int> frame) {
    if (frame.length < 4) throw const FormatException('Incomplete frame');
    final length = (frame[0] << 8) | frame[1];
    if (frame.length != length + 4) {
      throw const FormatException('Frame length mismatch');
    }
    final payload = Uint8List.fromList(frame.sublist(2, length + 2));
    if (crc16(payload) != ((frame[length + 2] << 8) | frame[length + 3])) {
      throw const FormatException('CRC mismatch');
    }
    return payload;
  }

  static List<Uint8List> fragments(List<int> bytes, int mtu) {
    if (mtu < 1) throw ArgumentError.value(mtu, 'mtu');
    return [
      for (var offset = 0; offset < bytes.length; offset += mtu)
        Uint8List.fromList(
          bytes.sublist(offset, (offset + mtu).clamp(0, bytes.length)),
        ),
    ];
  }
}

class JobsBleTrace {
  final events = <Map<String, dynamic>>[];
  void append(String operation, Object? value) {
    events.add({'operation': operation, 'value': value});
    if (events.length > 200) events.removeAt(0);
  }

  String export() => jsonEncode(events);
  void import(String source) {
    final value = jsonDecode(source);
    if (value is! List) throw const FormatException('Expected trace array');
    final parsed = value
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    if (parsed.any((e) => e['operation'] is! String)) {
      throw const FormatException('Missing operation');
    }
    events
      ..clear()
      ..addAll(parsed.take(200));
  }
}

/// Opt-in deterministic peripheral for protocol teaching; never masquerades as radio hardware.
class JobsMockBlePeripheral {
  static const id = 'MOCK-JOBS-PERIPHERAL';
  static const service = '12345678-1234-5678-1234-56789ABCDEF0';
  static const characteristic = '12345678-1234-5678-1234-56789ABCDEF1';
  bool connected = false;
  bool notifying = false;
  List<int> value = [0x4a, 0x6f, 0x62, 0x73];
  final void Function(Map<String, dynamic>) onEvent;
  JobsMockBlePeripheral({required this.onEvent});
  Map<String, dynamic> get device => {
    'id': id,
    'name': 'Jobs Mock BLE',
    'rssi': -42,
    'state': connected ? 2 : 0,
    'mock': true,
  };
  Future<dynamic> handle(String method, Map<String, dynamic> args) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    switch (method) {
      case 'ble.state':
        return {'state': 5, 'authorization': 3, 'mock': true};
      case 'ble.scan':
        onEvent({'event': 'discovered', 'device': device, 'mock': true});
        return true;
      case 'ble.stopScan':
        return true;
      case 'ble.devices':
        return [device];
      case 'ble.connect':
        connected = true;
        onEvent({'event': 'connected', 'device': device, 'mock': true});
        return device;
      case 'ble.disconnect':
        connected = false;
        onEvent({'event': 'disconnected', 'id': id, 'mock': true});
        return true;
    }
    if (!connected) throw StateError('Mock peripheral disconnected');
    switch (method) {
      case 'ble.discover':
        return [
          {
            'uuid': service,
            'characteristics': [
              {
                'uuid': characteristic,
                'read': true,
                'write': true,
                'notify': true,
                'properties': 26,
              },
            ],
          },
        ];
      case 'ble.read':
        return {'event': 'value', 'bytes': value, 'mock': true};
      case 'ble.write':
        value = List<int>.from(args['bytes'] as List);
        if (notifying) {
          onEvent({'event': 'value', 'bytes': value, 'mock': true});
        }
        return {'written': value.length, 'mock': true};
      case 'ble.notify':
        notifying = args['enabled'] == true;
        return true;
      case 'ble.requestMtu':
      case 'ble.mtu':
        return {'withResponse': 20, 'withoutResponse': 20, 'mock': true};
      case 'ble.rssi':
        onEvent({'event': 'rssi', 'device': device, 'mock': true});
        return true;
      case 'ble.descriptorRead':
        return {
          'uuid': '2901',
          'value': 'Jobs mock characteristic',
          'mock': true,
        };
      default:
        throw UnsupportedError(method);
    }
  }
}
