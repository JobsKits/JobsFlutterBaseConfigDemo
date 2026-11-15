import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';

class PickerLaboratoryDemo extends StatefulWidget {
  const PickerLaboratoryDemo({super.key});
  @override
  State<PickerLaboratoryDemo> createState() => _PickerLaboratoryState();
}

class _PickerLaboratoryState extends State<PickerLaboratoryDemo> {
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  String value = 'Flutter';
  double hue = 120;
  final Set<String> chosen = {};
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(uiTr(context, '综合选择器'))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(labelText: uiTr(context, '条目')),
          items: [
            for (final item in ['Flutter', 'Dart', 'Jobs'])
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (v) => setState(() => value = v!),
        ),
        const SizedBox(height: 20),
        OutlinedButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
            );
            if (picked != null && mounted) setState(() => date = picked);
          },
          child: Text(
            '${uiTr(context, '日历')}: ${MaterialLocalizations.of(context).formatMediumDate(date)}',
          ),
        ),
        OutlinedButton(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null && mounted) setState(() => time = picked);
          },
          child: Text(time.format(context)),
        ),
        const SizedBox(height: 20),
        Text(uiTr(context, '颜色')),
        Slider(
          value: hue,
          min: 0,
          max: 360,
          activeColor: HSVColor.fromAHSV(1, hue, .8, .8).toColor(),
          onChanged: (v) => setState(() => hue = v),
        ),
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: HSVColor.fromAHSV(1, hue, .8, .8).toColor(),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final item in ['Flutter', 'Dart', 'Jobs'])
              FilterChip(
                label: Text(item),
                selected: chosen.contains(item),
                onSelected: (v) =>
                    setState(() => v ? chosen.add(item) : chosen.remove(item)),
              ),
          ],
        ),
        Text('${uiTr(context, '已选择')}: ${chosen.join(', ')}'),
      ],
    ),
  );
}

void main() =>
    runApp(const JobsDemoApp(home: PickerLaboratoryDemo(), title: '综合选择器'));
