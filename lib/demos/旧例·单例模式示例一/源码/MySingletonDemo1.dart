import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';

// 在 Dart 中，没有内置的方法可以显式销毁一个类的实例，包括单例。
// 这是因为 Dart 像许多现代编程语言一样，依赖垃圾回收来自动管理内存。
// 一旦没有对一个对象的引用，垃圾回收器最终会回收该内存。
class MySingleton {
  // 私有构造函数。只是提醒私有，外部还是可以被调用的。
  MySingleton._();
  // 单例对象
  // 不仅能保证 _instance 是唯一的，还能确保在其声明时就被初始化
  // 单例对象要被重置为null，要求_instance不能被final修饰，因为不能直接赋值null
  static final MySingleton _instance = MySingleton._();
  // 获取单例对象的方法
  static MySingleton get instance => _instance;
  // 销毁单例对象的方法
  // static void destroyInstance() {
  //   _instance = null;
  //   legacyDebugPrint("该单例对象已经被销毁");
  // }

  // 其他方法
  void doSomething() {
    legacyLog("Singleton is doing something.");
  }
}

// 使用示例
void legacyOriginalMain() {
  // 获取单例对象
  MySingleton singleton = MySingleton.instance;
  // 使用单例对象的方法
  singleton.doSomething();
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·单例模式示例一');
