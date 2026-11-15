import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

/// 队长福利@4
class CategoryListPage4 extends StatefulWidget {
  final String title;
  final int index;

  const CategoryListPage4({
    super.key,
    required this.title,
    required this.index,
  });

  @override
  State<CategoryListPage4> createState() => _CategoryListPage4State();
}

class _CategoryListPage4State extends State<CategoryListPage4>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const LegacyText(
      "队长福利",
      style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
    );
  }
}
