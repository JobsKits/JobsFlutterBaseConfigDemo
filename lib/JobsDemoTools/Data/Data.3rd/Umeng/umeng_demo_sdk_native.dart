import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:umeng_apm_sdk/umeng_apm_sdk.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import 'umeng_demo_config.dart';
import 'umeng_demo_sdk_client.dart';

UmengSdkClient createUmengSdkClient() => _NativeUmengSdk();

class _NativeUmengSdk implements UmengSdkClient {
  UmengApmSdk? _apm;

  @override
  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  @override
  String get platformLabel => Platform.isAndroid
      ? 'Android'
      : Platform.isIOS
          ? 'iOS'
          : Platform.operatingSystem;

  @override
  Future<void> initialize(void Function(Object, StackTrace?) onError) async {
    if (!isSupported) {
      throw UnsupportedError('当前宿主未接入友盟 SDK');
    }
    // 官方 Common 的初始化成功分支不回传 result，不能 await initCommon。
    // 先用有回执的公开接口验证插件注册，避免无插件时仍显示可用。
    // iOS 1.3.0 的 platformVersion 会重复回执，改由下方 APM 版本查询探测；
    // Common 与 APM 均由 GeneratedPluginRegistrant 自动注册。
    if (Platform.isAndroid) {
      final version = await UmengCommonSdk.platformVersion
          .timeout(UmengDemoConfig.pluginTimeout);
      if (version == null || version.isEmpty) {
        throw StateError('友盟 Common 插件未返回平台信息');
      }
    }
    // APM 的版本查询有原生回执，先确认它也已注册，避免只装了统计插件。
    final apmVersion = await const MethodChannel('umeng_apm_sdk')
        .invokeMethod<String>('getSdkVersion')
        .timeout(UmengDemoConfig.pluginTimeout);
    if (apmVersion == null || apmVersion.isEmpty) {
      throw StateError('友盟 APM 插件未返回版本信息');
    }
    unawaited(UmengCommonSdk.initCommon(
      UmengDemoConfig.androidAppKey,
      UmengDemoConfig.iosAppKey,
      UmengDemoConfig.channel,
    ).catchError((Object error, StackTrace stack) {
      onError(error, stack);
      return null;
    }));
    UmengCommonSdk.setPageCollectionModeManual();

    // 延迟到授权后创建探针，复用已存在的 Binding，不再 runApp 或重建 Zone。
    // 此 Demo 仅采异常；不开启全局 HttpOverrides、FPS 和页面性能探针。
    _apm ??= UmengApmSdk(
      name: UmengDemoConfig.appName,
      bver: UmengDemoConfig.appVersion,
      env: kReleaseMode ? UmengApmEnv.Release : UmengApmEnv.Dev,
      enableLog: kDebugMode,
      enableTrackingApi: false,
      enableTrackingPageFps: false,
      enableTrackingPagePerf: false,
      initFlutterBinding: () => WidgetsBinding.instance,
      onError: (error, stack) {
        onError(error, stack is StackTrace ? stack : null);
      },
    )..init();
  }

  @override
  void trackEvent(String eventId, Map<String, Object> properties) {
    UmengCommonSdk.onEvent(eventId, properties);
  }

  @override
  void signIn(String userId) => UmengCommonSdk.onProfileSignIn(userId);
  @override
  void signOut() => UmengCommonSdk.onProfileSignOff();
  @override
  void pageStart(String name) => UmengCommonSdk.onPageStart(name);
  @override
  void pageEnd(String name) => UmengCommonSdk.onPageEnd(name);

  @override
  void captureException(Exception exception, StackTrace stack) {
    ExceptionTrace.captureException(
      exception: exception,
      stack: stack.toString(),
      extra: const {'scene': 'umeng_demo', 'source': 'caught'},
    );
  }

  @override
  void captureUnhandled(Object error, StackTrace stack) {
    ExceptionTrace.zonedGuardedErrorHandler(exception: error, stack: stack);
  }
}
