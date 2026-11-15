import 'package:flutter/foundation.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/MQTT/mqtt_demo1/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

// MQTT 管理类 (mqtt_manager.dart)：使用 ChangeNotifier 来管理 MQTT 服务，并与 Flutter 的状态管理集成。
class MqttManager with ChangeNotifier {
  late MqttService _mqttService;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  MqttManager(String server, String clientId) {
    _mqttService = MqttService(server, clientId);
    // 连接到 MQTT 代理，并订阅一个主题。
    _mqttService.connect().then((_) {
      _isConnected = true;
      notifyListeners();
      _mqttService.subscribe('test/topic');
      _mqttService.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        debugPrint('Received message: $pt from topic: ${c[0].topic}>');
      });
    });
  }
  // 发布消息到指定主题。
  void publish(String topic, String message) {
    if (_isConnected) {
      _mqttService.publish(topic, message);
    }
  }
}
