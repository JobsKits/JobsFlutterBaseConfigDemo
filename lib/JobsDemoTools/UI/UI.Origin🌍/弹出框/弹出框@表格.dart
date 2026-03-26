import 'package:flutter/material.dart';
import 'package:jobs_runners/jobs_runners.dart';

/// 弹出一个表格展示会员等级和对应的优惠信息，点击按钮可以关闭弹窗
void main() =>
    runApp(JobsGetRunner(const DemoPage(), title: 'Popup Table Demo'));

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          MembershipDiscountPopup.show(context);
        },
        child: const Text('弹出会员优惠信息'),
      ),
    );
  }
}

class MembershipDiscountPopup extends StatelessWidget {
  const MembershipDiscountPopup({super.key});

  static final List<MemberBenefitModel> _data = [
    MemberBenefitModel(level: '青铜会员', discount: '9.8折', desc: '每月1张免邮券'),
    MemberBenefitModel(level: '白银会员', discount: '9.5折', desc: '每月2张免邮券'),
    MemberBenefitModel(level: '黄金会员', discount: '9.0折', desc: '生日双倍积分'),
    MemberBenefitModel(level: '铂金会员', discount: '8.8折', desc: '专属客服'),
    MemberBenefitModel(level: '钻石会员', discount: '8.5折', desc: '优先发货'),
    MemberBenefitModel(level: '黑金会员', discount: '8.2折', desc: '全年免邮'),
    MemberBenefitModel(level: '星耀会员', discount: '8.0折', desc: '新品抢先购'),
    MemberBenefitModel(level: '王者会员', discount: '7.8折', desc: '专属礼包'),
    MemberBenefitModel(level: '荣耀会员', discount: '7.5折', desc: '积分翻倍'),
    MemberBenefitModel(level: '至尊会员', discount: '7.2折', desc: '线下活动资格'),
    MemberBenefitModel(level: '传奇会员', discount: '7.0折', desc: '全年专享券包'),
    MemberBenefitModel(level: '殿堂会员', discount: '6.8折', desc: '节日礼品'),
    MemberBenefitModel(level: '皇冠会员', discount: '6.5折', desc: '专属折扣日'),
    MemberBenefitModel(level: '尊耀会员', discount: '6.2折', desc: '新品免预约'),
    MemberBenefitModel(level: '巅峰会员', discount: '6.0折', desc: '全渠道最高权益'),
  ];

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'MembershipDiscountPopup',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const MembershipDiscountPopup();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width - 32,
          height: 520,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 16,
                color: Colors.black26,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildTableView(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('关闭'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '会员级别优惠信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E6EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildTableRow(_data[index], index);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      height: 44,
      color: const Color(0xFFF7F8FA),
      child: const Row(
        children: [
          _TableCell(
            text: '会员等级',
            flex: 3,
            isHeader: true,
            alignment: Alignment.centerLeft,
          ),
          _TableCell(
            text: '折扣',
            flex: 2,
            isHeader: true,
          ),
          _TableCell(
            text: '权益说明',
            flex: 4,
            isHeader: true,
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(MemberBenefitModel item, int index) {
    return Container(
      color: index.isEven ? Colors.white : const Color(0xFFFCFCFC),
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          _TableCell(
            text: item.level,
            flex: 3,
            alignment: Alignment.centerLeft,
          ),
          _TableCell(
            text: item.discount,
            flex: 2,
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          _TableCell(
            text: item.desc,
            flex: 4,
            alignment: Alignment.centerLeft,
          ),
        ],
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isHeader;
  final Alignment alignment;
  final TextStyle? textStyle;

  const _TableCell({
    required this.text,
    required this.flex,
    this.isHeader = false,
    this.alignment = Alignment.center,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = isHeader
        ? const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          )
        : const TextStyle(
            fontSize: 13,
            color: Colors.black87,
            height: 1.4,
          );

    return Expanded(
      flex: flex,
      child: Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Text(
          text,
          style: textStyle ?? defaultStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class MemberBenefitModel {
  final String level;
  final String discount;
  final String desc;

  const MemberBenefitModel({
    required this.level,
    required this.discount,
    required this.desc,
  });
}
