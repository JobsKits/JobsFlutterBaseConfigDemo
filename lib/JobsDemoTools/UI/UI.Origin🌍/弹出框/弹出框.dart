import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/JobsRunners/JobsGetXRunner.dart';
/// 弹出一个GridView展示会员等级和对应的优惠信息，点击按钮可以关闭弹窗
void main() => runApp(JobsGetRunner(const DemoPage(), title: 'Popup GridView Demo'));

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 弹出 View Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            MembershipDiscountPopup.show(context);
          },
          child: const Text('弹出会员优惠信息'),
        ),
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
                  child: GridView.builder(
                    itemCount: _data.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3列
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final item = _data[index];
                      return _buildGridItem(item);
                    },
                  ),
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

  Widget _buildGridItem(MemberBenefitModel item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E6EB),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.level,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            item.discount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
