import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart'; // 公共测试器路径

// 演示了类似于iOS.UITableView的效果： ListView + 自定义Cell + 点击Cell跳转到DetailPage
// 真机运行如果出现空白页面的解决方案：
// 方案1、在工程根目录下执行 flutter run --release 或者
// 方案2、通过 flutter devices 拿到设备id，然后 flutter run -d 设备ID
void legacyOriginalMain() => legacyCaptureApp(
  const JobsMaterialRunner(MyListView(), title: 'Flutter TableView'),
);

/// UITableView
class MyListView extends StatelessWidget {
  const MyListView({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 50, // 假设有50个项目
      itemBuilder: (BuildContext context, int index) {
        // 返回自定义的单元格
        return MyCell(
          index: index,
          onTap: () {
            // 点击单元格时，跳转到DetailPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailPage(index: index)),
            );
          },
        );
      },
    );
  }
}

/// UITableViewCell
class MyCell extends StatelessWidget {
  final int index;
  final VoidCallback onTap;
  const MyCell({super.key, required this.index, required this.onTap});
  @override
  Widget build(BuildContext context) {
    // 自定义单元格的高度
    double cellHeight = 100.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cellHeight,
        padding: const EdgeInsets.all(8.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LegacyText(
              'Item $index',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8.0),
            LegacyText(
              'Subtitle $index',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}

/// 子页面
class DetailPage extends StatelessWidget {
  final int index;
  const DetailPage({super.key, required this.index});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const LegacyText('Detail Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LegacyText(
              'Detail for Item $index',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // 点击返回按钮，返回到ListView页面
                Navigator.pop(context);
              },
              child: const LegacyText('Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '自定义列表单元格');
