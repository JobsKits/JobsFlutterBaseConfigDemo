import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

/// 超值存送礼@2
class CategoryListPage2 extends StatefulWidget {
  final String title;
  final int index;

  const CategoryListPage2({
    super.key,
    required this.title,
    required this.index,
  });

  @override
  State<CategoryListPage2> createState() => _CategoryListPage2State();
}

class _CategoryListPage2State extends State<CategoryListPage2>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const LegacyText(
      "超值存送礼",
      style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
    );
  }
}
