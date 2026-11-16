// 独立运行：flutter run -t "lib/demos/注解与元数据查询/AnnotationDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '注解与元数据查询');

// 定义一个自定义注解
// 注解是一种元数据，它们被用来为代码添加额外的信息。
// 这些信息在编译时或运行时可以被工具、框架或库所使用，以改变程序的行为或生成额外的代码。
// 但是，注解本身并不直接执行任何代码。
void legacyOriginalMain() {
  // 检查类是否有 MyAnnotation 注解
  var classAnnotation = getAnnotation<MyAnnotation>(MyClass);
  if (classAnnotation != null) {
    legacyDebugPrint("找到了类 MyClass 上的注解，消息是: ${classAnnotation.message}");
  }

  // 检查方法是否有 MyAnnotation 注解
  var methodAnnotation = getAnnotation<MyAnnotation>('MyClass.myMethod');
  if (methodAnnotation != null) {
    legacyDebugPrint("找到了方法 myMethod 上的注解，消息是: ${methodAnnotation.message}");
  }
}

// 用于获取类和方法上的注解的通用函数
// Flutter不支持dart:mirrors；显式注册表对应代码生成阶段能提供的元数据。
T? getAnnotation<T>(Object element) {
  final annotation = annotationRegistry[element];
  return annotation is T ? annotation as T : null;
}

const annotationRegistry = <Object, MyAnnotation>{
  MyClass: MyAnnotation('这是一个自定义注解的示例'),
  'MyClass.myMethod': MyAnnotation('这是一个方法上的自定义注解'),
};

class MyAnnotation {
  final String message;
  const MyAnnotation(this.message);
}

// 使用自定义注解的类
@MyAnnotation("这是一个自定义注解的示例")
class MyClass {
  // 在方法上应用注解
  @MyAnnotation("这是一个方法上的自定义注解")
  void myMethod() {
    legacyDebugPrint("执行了 myMethod");
  }
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'AnnotationDemo');
