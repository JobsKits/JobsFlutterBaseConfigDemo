import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/extra_support.dart';

import 'package:lunar/lunar.dart';

class LunarCalendarLabDemo extends StatefulWidget {
  const LunarCalendarLabDemo({super.key});
  @override
  State<LunarCalendarLabDemo> createState() => _State();
}

class _State extends State<LunarCalendarLabDemo> {
  DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final solar = Solar.fromDate(date), lunar = solar.getLunar();
    return ExtraFrame(
      title: '农历与节气',
      children: [
        CalendarDatePicker(
          initialDate: date,
          firstDate: DateTime(1901),
          lastDate: DateTime(2099, 12, 31),
          onDateChanged: (v) => setState(() => date = v),
        ),
        Text('${extraTr(context, '公历')}：${solar.toYmd()}'),
        Text(
          '${extraTr(context, '农历')}：${lunar.getYearInChinese()} ${lunar.getMonthInChinese()} ${lunar.getDayInChinese()}',
        ),
        Text(
          '${extraTr(context, '干支生肖')}：${lunar.getYearInGanZhi()} ${lunar.getYearShengXiao()}',
        ),
        Text(
          '${extraTr(context, '节日节气')}：${[...lunar.getFestivals(), ...solar.getFestivals(), lunar.getJieQi()].where((s) => s.isNotEmpty).join(' · ')}',
        ),
        Text(
          '${extraTr(context, '下一节气')}：${lunar.getNextJieQi().getName()} ${lunar.getNextJieQi().getSolar().toYmdHms()}',
        ),
      ],
    );
  }
}

void main() => runApp(const JobsDemoApp(home: LunarCalendarLabDemo()));
