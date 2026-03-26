import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

/// 图片没有加载出来，有点问题
void main() => runApp(const JobsMaterialRunner(HomeScreen(), title: 'XXX'));

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// 显示小数点后2位
  String formatNumber(double number) {
    /// toStringAsFixed:把一个数字（double）转换为 保留 n 位小数 的字符串。
    /// truncateToDouble:返回一个去掉小数部分后的 double 类型值，即 向零截断（不是四舍五入）。
    return number.toStringAsFixed(number.truncateToDouble() == number ? 1 : 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextStyle 和 Image.asset 示例'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '加粗且红色的文字',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 3.0),
                borderRadius: BorderRadius.circular(15.0),

                /// 支持多个阴影重叠叠加
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/Images/Others/share_icon.png',
                color: Colors.red, // 设置你想要的颜色
                colorBlendMode: BlendMode.srcIn, // 设置混合模式
                fit: BoxFit.contain,
                // 当图片加载失败时，打印错误信息
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  debugPrint('图片加载失败: $exception');
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 60.0,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '默认样式的图片',
              style: TextStyle(fontSize: 20.0),
            ),
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3.0),
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/Images/Others/share_icon.png',
                fit: BoxFit.contain,
                // 当图片加载失败时，打印错误信息
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  debugPrint('图片加载失败: $exception');
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 60.0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
