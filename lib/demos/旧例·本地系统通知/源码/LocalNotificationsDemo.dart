import 'package:flutter/foundation.dart';
import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';

// Android 配置
// 在 android/app/src/main/AndroidManifest.xml 文件中添加以下权限：
// <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
// 并在 <application> 标签内添加以下内容：
// <receiver
//     android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
//     android:exported="true">
//     <intent-filter>
//         <action android:name="android.intent.action.BOOT_COMPLETED"/>
//     </intent-filter>
// </receiver>
// <receiver
//     android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
//     android:exported="true"/>

// iOS 配置
// 在 ios/Runner/Info.plist 文件中添加以下内容：
// <key>UIBackgroundModes</key>
// <array>
//     <string>fetch</string>
//     <string>remote-notification</string>
// </array>

// 如果是 Swift，则配置AppDelegate.swift文件：
// import UIKit
// import Flutter
// import flutter_local_notifications
//
// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//       GeneratedPluginRegistrant.register(with: registry)
//     }
//     if #available(iOS 10.0, *) {
//       UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//     }
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

// 如果是 Objective-C，则配置AppDelegate.m文件：
// #import "AppDelegate.h"
// #import "GeneratedPluginRegistrant.h"
// #import "FlutterLocalNotificationsPlugin.h"
//
// @implementation AppDelegate
//
// - (BOOL)application:(UIApplication *)application
//     didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//   [GeneratedPluginRegistrant registerWithRegistry:self];
//   if (@available(iOS 10.0, *)) {
//     [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>)self;
//   }
//   [FlutterLocalNotificationsPlugin setPluginRegistrantCallback:^(FlutterPluginRegistry* registry) {
//     [GeneratedPluginRegistrant registerWithRegistry:registry];
//   }];
//   return [super application:application didFinishLaunchingWithOptions:launchOptions];
// }
//
// @end

void legacyOriginalMain() {
  legacyCaptureApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool initializing = true, ready = false, showing = false;
  Object? failure;

  @override
  void initState() {
    super.initState();
    initLocalNotifications();
  }

  Future<void> initLocalNotifications() async {
    setState(() {
      initializing = true;
      ready = false;
      failure = null;
    });
    try {
      const initializationSettingsAndroid = AndroidInitializationSettings(
        'ic_jobs_notification',
      );
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final initialized = await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );
      if (initialized != true)
        throw StateError('Notification initialization failed');
      final android = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final permission = await android?.requestNotificationsPermission();
      if (permission == false)
        throw StateError('Notification permission denied');
      if (mounted) setState(() => ready = true);
    } catch (error) {
      if (mounted) setState(() => failure = error);
    } finally {
      if (mounted) setState(() => initializing = false);
    }
  }

  // 处理通知响应
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      legacyDebugPrint('notification payload: ${response.payload}');
    }
    // 其他处理逻辑...
  }

  // 旧版本兼容 iOS 10 以下（几乎用不到了，但仍保留）
  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: LegacyText(title ?? '通知'),
        content: LegacyText(body ?? ''),
        actions: [
          CupertinoDialogAction(
            child: const LegacyText('OK'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showNotification() async {
    if (!ready || showing) return;
    setState(() => showing = true);
    try {
      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'high_importance_channel', // 必须唯一
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        groupAlertBehavior: GroupAlertBehavior.all,
        autoCancel: true,
        ongoing: false,
        icon: 'ic_jobs_notification',
        styleInformation: BigTextStyleInformation(
          legacyUiText(context, 'This is a local notification.'),
        ),
        color: Color(0xFF9D50DD),
        showWhen: true,
      );

      const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

      final platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        id: 0,
        title: legacyUiText(context, 'Hello'),
        body: legacyUiText(context, 'This is a local notification.'),
        notificationDetails: platformChannelSpecifics,
        payload: 'item id 123',
      );
    } catch (error) {
      if (mounted) setState(() => failure = error);
    } finally {
      if (mounted) setState(() => showing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LegacyAppBoundary(
      app: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const LegacyText('Local Notification Demo')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (initializing) const CircularProgressIndicator(),
                  if (failure != null) ...[
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    LegacyText('Error: $failure'),
                    TextButton(
                      onPressed: initializing ? null : initLocalNotifications,
                      child: const LegacyText('重试'),
                    ),
                  ],
                  ElevatedButton(
                    key: const ValueKey('show-legacy-notification'),
                    onPressed: ready && !initializing && !showing
                        ? _showNotification
                        : null,
                    child: const LegacyText('Show Notification'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 后台点击通知（可选）
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  legacyDebugPrint('通知后台点击: ${notificationResponse.payload}');
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(
  legacyOriginalMain,
  supportsWeb: false,
  supportedPlatforms: const [TargetPlatform.iOS, TargetPlatform.android],
  title: '旧例·本地系统通知',
);
