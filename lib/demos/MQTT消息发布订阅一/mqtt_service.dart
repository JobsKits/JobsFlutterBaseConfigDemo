import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// MQTT 服务类 (mqtt_service.dart)：处理 MQTT 连接、订阅和发布的实际逻辑。
class MqttService {
  final MqttServerClient _client;

  MqttService(String server, String clientId)
    : _client = MqttServerClient(server, clientId);
  // 连接到 MQTT 代理，并设置连接、断开连接、订阅和订阅失败的回调
  Future<void> connect() async {
    _client.logging(on: true);
    _client.onConnected = onConnected;
    _client.onDisconnected = onDisconnected;
    _client.onSubscribed = onSubscribed;
    _client.onSubscribeFail = onSubscribeFail;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } catch (e) {
      _client.disconnect();
      debugPrint('Exception: $e');
      rethrow;
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT client connected');
    } else {
      debugPrint(
        'ERROR: MQTT client connection failed - disconnecting, status is ${_client.connectionStatus}',
      );
      _client.disconnect();
    }
  }

  void onConnected() {
    debugPrint('Connected');
  }

  void onDisconnected() {
    debugPrint('Disconnected');
  }

  void onSubscribed(String topic) {
    debugPrint('Subscribed to $topic');
  }

  void onSubscribeFail(String topic) {
    debugPrint('Failed to subscribe $topic');
  }

  // 订阅指定的主题。
  void subscribe(String topic) {
    _client.subscribe(topic, MqttQos.atLeastOnce);
  }

  // 向指定的主题发布消息
  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  // 用于接收从代理收到的消息
  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates =>
      _client.updates;
}
