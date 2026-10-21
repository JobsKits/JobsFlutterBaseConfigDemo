import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'umeng_demo_config.dart';
import 'umeng_demo_sdk_client.dart';
import 'umeng_demo_sdk_stub.dart'
    if (dart.library.io) 'umeng_demo_sdk_native.dart' as platform;

class UmengDemoLog {
  UmengDemoLog(this.message, {this.isError = false}) : time = DateTime.now();
  final DateTime time;
  final String message;
  final bool isError;
}

class UmengDemoService extends ChangeNotifier with WidgetsBindingObserver {
  UmengDemoService({UmengSdkClient? client})
      : _client = client ?? platform.createUmengSdkClient();

  final UmengSdkClient _client;
  final List<UmengDemoLog> _logs = [];
  bool _isInitializing = false;
  bool _isInitialized = false;
  String _status = '尚未授权，SDK 未初始化';
  String? _userId;
  String? _visiblePage;
  String? _activePage;
  bool _foreground = true;
  bool _observingLifecycle = false;
  bool _notificationScheduled = false;
  bool _disposed = false;
  int _eventCount = 0;

  bool get isSupported => _client.isSupported;
  bool get isInitializing => _isInitializing;
  bool get isInitialized => _isInitialized;
  String get platformLabel => _client.platformLabel;
  String get status => _status;
  String? get userId => _userId;
  List<UmengDemoLog> get logs => List.unmodifiable(_logs);

  Future<void> initialize({required bool consent}) async {
    if (_disposed || _isInitializing || _isInitialized) {
      return;
    }
    if (!consent) {
      _record('未同意隐私说明，未调用 SDK', isError: true);
      return;
    }
    if (!isSupported) {
      _status = '当前平台仅预览界面，未调用 SDK';
      _record(_status, isError: true);
      return;
    }
    _isInitializing = true;
    _status = '检查原生插件并发起初始化…';
    _notifySafely();
    try {
      await _client.initialize(_onSdkError);
      if (_disposed) {
        return;
      }
      _isInitialized = true;
      _status = 'SDK 初始化已调用；后台接收状态待确认';
      if (!_observingLifecycle) {
        _foreground = WidgetsBinding.instance.lifecycleState == null ||
            WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
        WidgetsBinding.instance.addObserver(this);
        _observingLifecycle = true;
      }
      _record('已调用 Common 初始化与 U-APM 探针；上传受网络与采样配置影响');
      _synchronizePage();
    } catch (error) {
      _status = '初始化未完成，可重新尝试';
      _record('初始化失败：$error', isError: true);
    } finally {
      _isInitializing = false;
      _notifySafely();
    }
  }

  Future<void> trackEvent() => _perform('已调用事件 ${UmengDemoConfig.eventId}', () {
        _client.trackEvent(UmengDemoConfig.eventId, {
          'source': 'umeng_demo',
          'click_count': ++_eventCount,
          'channel': UmengDemoConfig.channel,
        });
      });

  Future<void> signIn(String userId) => _perform('已调用测试账号登录', () {
        final value = userId.trim();
        if (value.isEmpty || value.length > 64) {
          throw ArgumentError('测试账号需为 1～64 个字符');
        }
        _client.signIn(value);
        _userId = value;
      });

  Future<void> signOut() => _perform('已调用账号退出', () {
        _client.signOut();
        _userId = null;
      });

  Future<void> reportCaughtException() => _perform('已向 U-APM 提交捕获异常', () {
        try {
          throw const FormatException('Jobs Umeng Demo：已捕获的测试异常');
        } on Exception catch (error, stack) {
          _client.captureException(error, stack);
        }
      });

  void triggerFrameworkError() {
    if (!_requireInitialized()) {
      return;
    }
    _record('触发 FlutterError，由 U-APM 框架错误监听捕获');
    FlutterError.reportError(FlutterErrorDetails(
      exception: StateError('Jobs Umeng Demo：Flutter 框架测试错误'),
      stack: StackTrace.current,
      library: 'Jobs Umeng Demo',
      context: ErrorDescription('点击框架异常测试按钮'),
    ));
  }

  void triggerAsyncError() {
    if (!_requireInitialized()) {
      return;
    }
    _record('触发异步错误，由入口 runZonedGuarded 捕获');
    unawaited(Future<void>.delayed(Duration.zero, () {
      throw StateError('Jobs Umeng Demo：异步测试错误');
    }));
  }

  void handleUnhandled(Object error, StackTrace stack) {
    debugPrint('Jobs Umeng Demo: $error\n$stack');
    if (_isInitialized) {
      try {
        _client.captureUnhandled(error, stack);
        _record('已将 Zone 异步异常交给 U-APM：${error.runtimeType}');
      } catch (sdkError) {
        _record('U-APM 接收异步异常失败：$sdkError', isError: true);
      }
    }
  }

  void _onSdkError(Object error, StackTrace? stack) {
    _record('U-APM 捕获 / SDK 错误：${error.runtimeType} · $error', isError: true);
  }

  Future<void> _perform(String message, VoidCallback action) async {
    if (!_requireInitialized()) {
      return;
    }
    try {
      action();
      _record('$message；待友盟后台确认');
    } catch (error) {
      _record('调用失败：$error', isError: true);
    }
  }

  bool _requireInitialized() {
    if (_isInitialized) {
      return true;
    }
    _record('请先同意说明并初始化 SDK', isError: true);
    return false;
  }

  void setVisiblePage(String? page) {
    _visiblePage = page;
    _synchronizePage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _synchronizePage();
  }

  void _synchronizePage() {
    final target = _isInitialized && _foreground ? _visiblePage : null;
    if (target == _activePage) {
      return;
    }
    final previous = _activePage;
    _activePage = target;
    if (previous != null) {
      _pageAction('页面结束：$previous', () => _client.pageEnd(previous));
    }
    if (target != null) {
      _pageAction('页面开始：$target', () => _client.pageStart(target));
    }
  }

  void _pageAction(String message, VoidCallback action) {
    try {
      action();
      _record(message);
    } catch (error) {
      _record('$message 调用失败：$error', isError: true);
    }
  }

  void clearLogs() {
    _logs.clear();
    _notifySafely();
  }

  void _record(String message, {bool isError = false}) {
    if (_disposed) {
      return;
    }
    _logs.insert(0, UmengDemoLog(message, isError: isError));
    if (_logs.length > 80) {
      _logs.removeLast();
    }
    _notifySafely();
  }

  void _notifySafely() {
    if (_disposed) {
      return;
    }
    // 框架异常可能在 build 中触发；错误监听不能再同步触发一次 build 错误。
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (!_notificationScheduled) {
        _notificationScheduled = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _notificationScheduled = false;
          if (!_disposed) {
            notifyListeners();
          }
        });
      }
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_activePage != null) {
      _pageAction('页面结束：$_activePage', () => _client.pageEnd(_activePage!));
    }
    if (_observingLifecycle) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}

/// 手动统计只跟踪页面路由，弹窗不算新的页面访问。
class UmengDemoPageObserver extends NavigatorObserver {
  UmengDemoPageObserver(this.service);
  final UmengDemoService service;
  final List<PageRoute<dynamic>> _pages = [];

  void _update() => service.setVisiblePage(
      _pages.isEmpty ? null : (_pages.last.settings.name ?? '/umeng/unnamed'));

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute<dynamic>) {
      _pages.add(route);
      _update();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didRemove(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute<dynamic>) {
      _pages.remove(route);
      _update();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index =
        oldRoute is PageRoute<dynamic> ? _pages.indexOf(oldRoute) : -1;
    if (index >= 0) {
      _pages.removeAt(index);
      if (newRoute is PageRoute<dynamic>) {
        _pages.insert(index, newRoute);
      }
      _update();
    }
  }
}
