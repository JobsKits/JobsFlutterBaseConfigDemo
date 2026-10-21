import 'umeng_demo_sdk_client.dart';

UmengSdkClient createUmengSdkClient() => _UnsupportedUmengSdk();

class _UnsupportedUmengSdk implements UmengSdkClient {
  @override
  bool get isSupported => false;
  @override
  String get platformLabel => 'Web / 未适配平台';
  @override
  Future<void> initialize(void Function(Object, StackTrace?) onError) async {
    throw UnsupportedError('友盟演示目前仅在 Android / iOS 宿主接入 SDK');
  }

  @override
  void trackEvent(String eventId, Map<String, Object> properties) {}
  @override
  void signIn(String userId) {}
  @override
  void signOut() {}
  @override
  void pageStart(String name) {}
  @override
  void pageEnd(String name) {}
  @override
  void captureException(Exception exception, StackTrace stack) {}
  @override
  void captureUnhandled(Object error, StackTrace stack) {}
}
