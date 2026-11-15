import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/foundation.dart';

// 带参数和返回值的 compute（推荐）
// 自动封装 Isolate 创建、端口通信
// 不用手动处理 ReceivePort 和 SendPort
// 适合大多数场景

// compute() 方法仅接受一个参数，如果你要传多个参数，可以用 Map 或封装类。
// 通信只能使用 SendPort/ReceivePort 或 IsolateChannel（第三方简化包）。
void legacyOriginalMain() async {
  int result = await compute(sumUpTo, 10000000);
  legacyDebugPrint('✅ 结果是：$result');
}

int sumUpTo(int n) {
  return List.generate(n + 1, (i) => i).reduce((a, b) => a + b);
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '旧例·隔离区任务计算');
