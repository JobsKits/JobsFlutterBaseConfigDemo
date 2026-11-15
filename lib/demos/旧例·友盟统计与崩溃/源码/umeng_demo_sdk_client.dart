/// 仅隔离平台能力，业务按钮仍调用官方 Flutter 插件。
abstract class UmengSdkClient {
  bool get isSupported;
  String get platformLabel;
  Future<void> initialize(void Function(Object, StackTrace?) onError);
  void trackEvent(String eventId, Map<String, Object> properties);
  void signIn(String userId);
  void signOut();
  void pageStart(String name);
  void pageEnd(String name);
  void captureException(Exception exception, StackTrace stack);
  void captureUnhandled(Object error, StackTrace stack);
}
