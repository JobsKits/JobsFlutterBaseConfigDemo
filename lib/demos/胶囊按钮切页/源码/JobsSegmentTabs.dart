import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Utils/Extensions/WidgetExtensions/onWidgets.dart';
import 'package:oktoast/oktoast.dart';

void legacyOriginalMain() => legacyCaptureApp(
  LegacyAppBoundary(
    app: const MaterialApp(debugShowCheckedModeBanner: false, home: View()),
  ),
);

class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    const titles = ['今天', '昨天', '7日内', '本月', '自定义'];

    var pages = [
      const LegacyText(
        "1",
        style: TextStyle(color: Colors.white, fontSize: 80),
      ).center(),
      const LegacyText(
        "2",
        style: TextStyle(color: Colors.white, fontSize: 80),
      ).center(),
      const LegacyText(
        "3",
        style: TextStyle(color: Colors.white, fontSize: 80),
      ).center(),
      const LegacyText(
        "4",
        style: TextStyle(color: Colors.white, fontSize: 80),
      ).center(),
      const LegacyText(
        "5",
        style: TextStyle(color: Colors.white, fontSize: 80),
      ).center(),
    ];

    return SegmentTabsScaffold(
      title: '佣金报表',
      tabs: titles,
      pages: pages,
      bodyBuilder: (context, index, onTap, tabs, pages) {
        return Column(
          children: [
            SegmentBar(items: tabs, currentIndex: index, onTap: onTap),
            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(index: index, children: pages),
            ),
          ],
        );
      },
    );
  }
}

/// 顶部分段容器（外界传入 tabs + pages）
class SegmentTabsScaffold extends StatefulWidget {
  final String? title;
  final List<String> tabs;
  final List<Widget> pages;
  final int initialIndex;

  /// ✅ 新增：允许外部自定义 bodyBuilder
  final Widget Function(
    BuildContext context,
    int currentIndex,
    void Function(int index) onTap,
    List<String> tabs,
    List<Widget> pages,
  )?
  bodyBuilder;

  const SegmentTabsScaffold({
    super.key,
    this.title,
    required this.tabs,
    required this.pages,
    this.initialIndex = 0,
    this.bodyBuilder,
  }) : assert(tabs.length == pages.length);

  @override
  State<SegmentTabsScaffold> createState() => _SegmentTabsScaffoldState();
}

class _SegmentTabsScaffoldState extends State<SegmentTabsScaffold> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171A22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A22),
        elevation: 0,
        centerTitle: true,
        title: LegacyText(
          widget.title ?? '',
          style: const TextStyle(
            color: Color(0xFFE6EBF2),
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFE6EBF2),
          ),
          onPressed: () {
            showToast("Hello");
          },
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),

          /// ✅ 使用外部自定义布局，否则 fallback 默认 Column
          child:
              widget.bodyBuilder?.call(
                context,
                _index,
                (i) => setState(() => _index = i),
                widget.tabs,
                widget.pages,
              ) ??
              Container(),
        ),
      ),
    );
  }
}

class SegmentBar extends StatelessWidget {
  final List<String> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const SegmentBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28, // 胶囊高度
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          return SegmentChip(
            text: items[i],
            selected: i == currentIndex,
            onTap: () => onTap(i),
          );
        },
      ),
    );
  }
}

class SegmentChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const SegmentChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFFFD8A6) : const Color(0xFF252A35);
    final fg = selected ? const Color(0xFF2B2B2B) : const Color(0xFFBFC6D0);
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: LegacyText(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// 独立运行与目录预览共用同一份原始教学逻辑。
void main() => launchLegacyStandalone(legacyOriginalMain, title: '胶囊按钮切页');
