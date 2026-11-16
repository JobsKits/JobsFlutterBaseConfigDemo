import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/富文本/Json表格/没有合并/BonusRewardModel.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/UI/UI.Origin🌍/富文本/Json表格/没有合并/BonusTableView.dart';

class BonusTablePage extends StatefulWidget {
  const BonusTablePage({super.key});

  @override
  State<BonusTablePage> createState() => _BonusTablePageState();
}

class _BonusTablePageState extends State<BonusTablePage> {
  List<BonusTable> tables = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final jsonStr = await rootBundle.loadString(
      'lib/resource/bonus_rich_text_data.json',
    );
    final List<dynamic> jsonList = json.decode(jsonStr);
    final List<BonusTable> loaded = jsonList
        .map((e) => BonusTable.fromJson(e))
        .toList();

    setState(() => tables = loaded);
  }

  @override
  Widget build(BuildContext context) {
    return tables.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, index) => BonusTableView(data: tables[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemCount: tables.length,
          );
  }
}
