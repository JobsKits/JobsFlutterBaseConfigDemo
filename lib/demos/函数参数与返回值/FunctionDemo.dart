// 独立运行：flutter run -t "lib/demos/函数参数与返回值/FunctionDemo.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '函数参数与返回值');

typedef MyBlock<T, R> = R Function(T);

// 一个接受整数并返回整数的函数
int addOne(int x) {
  return x + 1;
}

// 一个接受字符串并返回其长度的函数
int stringLength(String s) {
  return s.length;
}

void legacyOriginalMain() {
  // 使用 MyBlock<int, int> 类型的函数
  MyBlock<int, int> increment = addOne;
  legacyLog(increment(5).toString()); // 输出: 6

  // 使用 MyBlock<String, int> 类型的函数
  MyBlock<String, int> lengthGetter = stringLength;
  legacyLog(lengthGetter("Hello").toString()); // 输出: 5
}

Widget buildLegacyDemo(BuildContext context) =>
    LegacyLaunchPage(action: legacyOriginalMain, title: 'FunctionDemo');
