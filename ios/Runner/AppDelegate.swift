//
//  AppDelegate.swift
//  Runner
//
//  Created by Jobs on 2026年10月21日，星期三.
//

import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureUmengApm()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func configureUmengApm() {
    // 此处只设置采集范围，正式初始化由 Flutter 页面的同意操作触发。
    let config = UMAPMConfig.default()
    config.crashAndBlockMonitorEnable = true
    config.launchMonitorEnable = false
    config.memMonitorEnable = false
    config.oomMonitorEnable = false
    config.networkEnable = false
    config.javaScriptBridgeEnable = false
    config.pageMonitorEnable = false
    config.logCollectEnable = false
    UMCrashConfigure.setAPMConfig(config)
  }
}
