import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

/// 回归包赔@3
class CategoryListPage3 extends StatefulWidget {
  final String title;
  final int index;

  const CategoryListPage3({
    super.key,
    required this.title,
    required this.index,
  });

  @override
  State<CategoryListPage3> createState() => _CategoryListPage3State();
}

class _CategoryListPage3State extends State<CategoryListPage3>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const LegacyText(
      "回归包赔",
      style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
    );
  }
}
