/// 友盟应用标识；正式接入时应核对控制台中的包名与 Bundle ID。
abstract final class UmengDemoConfig {
  static const androidAppKey = '6ad70d586545637cd61a3706';
  static const iosAppKey = '6ad7114f6545637cd61a42df';
  static const harmonyAppKey = '6ad711c56545637cd61a4435';
  // Android Application 的预初始化使用相同渠道。
  static const channel = 'JobsFlutterDemo';
  static const appName = 'jobs_flutter_base_config';
  static const appVersion = '1.0.0+1';
  static const eventId = 'demo_button_click';
  static const pluginTimeout = Duration(seconds: 3);
}
