import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_runners/jobs_runners.dart';
import 'package:screenshot/screenshot.dart'; // 公共测试器路径

// dependencies:
//   flutter:
//     sdk: flutter
//   screenshot: # 截屏操作
// 要在Flutter中监控截屏操作，确实需要在原生代码中进行一些改动
void main() => runApp(const JobsMaterialRunner(ScreenshotDemo(), title: 'XXX'));

class ScreenshotDemo extends StatefulWidget {
  const ScreenshotDemo({super.key});
  @override
  _ScreenshotDemoState createState() => _ScreenshotDemoState();
}

class _ScreenshotDemoState extends State<ScreenshotDemo> {
  ScreenshotController screenshotController = ScreenshotController();

  /// 通过 EventChannel 监听截屏事件，并在截屏时显示提示
  static const EventChannel _screenshotChannel =
      EventChannel('screenshot_channel');
  @override
  void initState() {
    super.initState();
    _screenshotChannel.receiveBroadcastStream().listen((event) {
      if (event == 'screenshot_taken') {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot taken!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screenshot Demo'),
      ),
      body: Screenshot(
        controller: screenshotController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('点击按钮进行截屏'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  screenshotController.capture().then((image) {
                    // handle captured image
                  }).catchError((onError) {
                    debugPrint(onError);
                  });
                },
                child: const Text('Take Screenshot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 在iOS中，通过监听 UIApplication.userDidTakeScreenshotNotification 通知来监控截屏操作。
// 🌹iOS.swift🌹
// import UIKit
// import Flutter

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
//     let eventChannel = FlutterEventChannel(name: "screenshot_channel",
//                                            binaryMessenger: controller.binaryMessenger)
//     eventChannel.setStreamHandler(ScreenshotStreamHandler())
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

// class ScreenshotStreamHandler: NSObject, FlutterStreamHandler {
//   private var eventSink: FlutterEventSink?

//   override init() {
//     super.init()
//     NotificationCenter.default.addObserver(self,
//                                            selector: #selector(userDidTakeScreenshot),
//                                            name: UIApplication.userDidTakeScreenshotNotification,
//                                            object: nil)
//   }

//   deinit {
//     NotificationCenter.default.removeObserver(self,
//                                               name: UIApplication.userDidTakeScreenshotNotification,
//                                               object: nil)
//   }

//   func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
//     self.eventSink = events
//     return nil
//   }

//   func onCancel(withArguments arguments: Any?) -> FlutterError? {
//     self.eventSink = nil
//     return nil
//   }

//   @objc private func userDidTakeScreenshot() {
//     eventSink?("screenshot_taken")
//   }
// }

// 🌹iOS.OC🌹
// #import "AppDelegate.h"
// #import "GeneratedPluginRegistrant.h"

// @interface ScreenshotStreamHandler : NSObject <FlutterStreamHandler>
// @property (nonatomic, copy) FlutterEventSink eventSink;
// @end

// @implementation ScreenshotStreamHandler

// - (instancetype)init {
//     self = [super init];
//     if (self) {
//         [[NSNotificationCenter defaultCenter] addObserver:self
//                                                  selector:@selector(userDidTakeScreenshot:)
//                                                      name:UIApplicationUserDidTakeScreenshotNotification
//                                                    object:nil];
//     }
//     return self;
// }

// - (void)dealloc {
//     [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                     name:UIApplicationUserDidTakeScreenshotNotification
//                                                   object:nil];
// }

// - (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
//     self.eventSink = events;
//     return nil;
// }

// - (FlutterError *)onCancelWithArguments:(id)arguments {
//     self.eventSink = nil;
//     return nil;
// }

// - (void)userDidTakeScreenshot:(NSNotification *)notification {
//     if (self.eventSink) {
//         self.eventSink(@"screenshot_taken");
//     }
// }

// @end

// @implementation AppDelegate

// - (BOOL)application:(UIApplication *)application
//     didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//   [GeneratedPluginRegistrant registerWithRegistry:self];

//   FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
//   FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:@"screenshot_channel"
//                                                                  binaryMessenger:controller.binaryMessenger];
//   ScreenshotStreamHandler* handler = [[ScreenshotStreamHandler alloc] init];
//   [eventChannel setStreamHandler:handler];

//   return [super application:application didFinishLaunchingWithOptions:launchOptions];
// }

// @end

// 在Android中，通过监听 MediaStore 内容变化来检测新截图文件。
// 🌹Android.java🌹
// package com.yourcompany.yourapp;

// import android.content.BroadcastReceiver;
// import android.content.Context;
// import android.content.Intent;
// import android.content.IntentFilter;
// import android.database.ContentObserver;
// import android.net.Uri;
// import android.os.Handler;
// import android.provider.MediaStore;
// import android.util.Log;

// import androidx.annotation.NonNull;
// import io.flutter.embedding.android.FlutterActivity;
// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.plugin.common.EventChannel;
// import io.flutter.plugins.GeneratedPluginRegistrant;

// public class MainActivity extends FlutterActivity {
//   private static final String SCREENSHOT_CHANNEL = "screenshot_channel";
//   private EventChannel.EventSink eventSink;

//   @Override
//   public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//     super.configureFlutterEngine(flutterEngine);
//     GeneratedPluginRegistrant.registerWith(flutterEngine);

//     new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), SCREENSHOT_CHANNEL)
//       .setStreamHandler(new ScreenshotStreamHandler(this));
//   }

//   class ScreenshotStreamHandler implements EventChannel.StreamHandler {
//     private final Context context;
//     private final ContentObserver observer;

//     ScreenshotStreamHandler(Context context) {
//       this.context = context;
//       this.observer = new ContentObserver(new Handler()) {
//         @Override
//         public void onChange(boolean selfChange, Uri uri) {
//           if (eventSink != null) {
//             eventSink.success("screenshot_taken");
//           }
//         }
//       };
//     }

//     @Override
//     public void onListen(Object arguments, EventChannel.EventSink events) {
//       eventSink = events;
//       context.getContentResolver().registerContentObserver(
//         MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
//         true,
//         observer
//       );
//     }

//     @Override
//     public void onCancel(Object arguments) {
//       eventSink = null;
//       context.getContentResolver().unregisterContentObserver(observer);
//     }
//   }
// }

// 🌹Android.kt🌹
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:screenshot/screenshot.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ScreenshotDemo(),
//     );
//   }
// }

// class ScreenshotDemo extends StatefulWidget {
//   @override
//   _ScreenshotDemoState createState() => _ScreenshotDemoState();
// }

// class _ScreenshotDemoState extends State<ScreenshotDemo> {
//   ScreenshotController screenshotController = ScreenshotController();
//   static const EventChannel _screenshotChannel = EventChannel('screenshot_channel');

//   @override
//   void initState() {
//     super.initState();
//     _screenshotChannel.receiveBroadcastStream().listen((event) {
//       if (event == 'screenshot_taken') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Screenshot taken!')),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Screenshot Demo'),
//       ),
//       body: Screenshot(
//         controller: screenshotController,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('Press the button to take a screenshot'),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   screenshotController.capture().then((image) {
//                     // handle captured image
//                   }).catchError((onError) {
//                     print(onError);
//                   });
//                 },
//                 child: Text('Take Screenshot'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
