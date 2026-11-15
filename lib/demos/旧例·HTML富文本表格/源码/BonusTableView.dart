import 'package:jobs_flutter_base_config/demo_hub/legacy_launch.dart';
import 'package:flutter/material.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/富文本/Json表格/没有合并/BonusRewardModel.dart';

class BonusTableView extends StatelessWidget {
  final BonusTable data;

  const BonusTableView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: LegacyText(
            data.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),
        LegacyText(
          data.condition,
          style: const TextStyle(color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Table(
          border: TableBorder.all(color: Colors.black54),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
              children: [
                Padding(
                  padding: EdgeInsets.all(6),
                  child: LegacyText(
                    "活动要求",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: LegacyText(
                    "总有效投注",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: LegacyText(
                    "赠送彩金",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ...data.rewards.map(
              (r) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: LegacyText(
                      data.condition,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: LegacyText(r.bets, textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: LegacyText(r.bonus, textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LegacyText(
          "示例：${data.example}",
          style: const TextStyle(color: Colors.black54),
        ),
        LegacyText(
          "申请时间：${data.applyTime}",
          style: const TextStyle(color: Colors.black54),
        ),
        const Divider(height: 32),
      ],
    );
  }
}
