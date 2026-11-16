import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';

/// 彩金免费领@1
class CategoryListPage1 extends StatefulWidget {
  final String title;
  final int index;

  const CategoryListPage1({
    super.key,
    required this.title,
    required this.index,
  });

  @override
  State<CategoryListPage1> createState() => _CategoryListPage1State();
}

class _CategoryListPage1State extends State<CategoryListPage1>
    with AutomaticKeepAliveClientMixin {
  final List<String> _items = List.generate(30, (i) => 'Item #$i');

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.separated(
      key: PageStorageKey('list-${widget.index}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemBuilder: (_, i) {
        return Container(
          height: 56,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: LegacyText(
            '${widget.title} - ${_items[i]}',
            style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: _items.length,
    );
  }
}
