// 独立运行：flutter run -t "lib/demos/单例模式示例二/MySingletonDemo2.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '单例模式示例二');

// 在 Dart 中，没有内置的方法可以显式销毁一个类的实例，包括单例。
// 这是因为 Dart 像许多现代编程语言一样，依赖垃圾回收来自动管理内存。
// 一旦没有对一个对象的引用，垃圾回收器最终会回收该内存。
class Singleton {
  // 私有构造函数
  Singleton._internal();
  // 静态私有实例
  // 单例对象要被重置为null，要求_instance不能被final修饰，因为不能直接赋值null
  static final Singleton _instance = Singleton._internal();
  // 工厂构造函数
  factory Singleton() {
    return _instance;
  }
  // 销毁单例对象的方法
  // static void destroyInstance() {
  //   _instance = null;
  //   legacyDebugPrint("该单例对象已经被销毁");
  // }

  // 其他方法
  void doSomething() {
    legacyDebugPrint("这是一个单例方法");
  }
}

void legacyOriginalMain() {
  // 获取单例实例
  var singleton1 = Singleton();
  var singleton2 = Singleton();

  // 验证两个实例是同一个对象
  legacyDebugPrint(singleton1.toString());
  legacyDebugPrint(singleton2.toString());
  legacyDebugPrint(identical(singleton1, singleton2).toString());
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'MySingletonDemo2');
