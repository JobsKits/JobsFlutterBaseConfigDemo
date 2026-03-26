import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

void main() =>
    runApp(const JobsMaterialRunner(MyHomePage(), title: 'Intl Demo'));

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    // 当前日期时间
    DateTime now = DateTime.now();
    // 格式化日期
    String formattedDate = DateFormat.yMMMMd().format(now);
    // 格式化货币
    double price = 1234.56;
    String formattedPrice =
        NumberFormat.currency(locale: 'en_US', symbol: '\$').format(price);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intl Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Formatted Date:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Text(
              'Formatted Price:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              formattedPrice,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
