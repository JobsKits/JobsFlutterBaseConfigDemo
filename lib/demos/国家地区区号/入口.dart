import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

import 'country_data.dart';

class CountryCallingCodesDemo extends StatefulWidget {
  const CountryCallingCodesDemo({super.key});
  @override
  State<CountryCallingCodesDemo> createState() => _CountryCodesState();
}

class _CountryCodesState extends State<CountryCallingCodesDemo> {
  final query = TextEditingController();
  String? selected;
  @override
  void initState() {
    super.initState();
    UiDemoStore.read('country-selection', null).then((v) {
      if (mounted && v is String) setState(() => selected = v);
    });
  }

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final code = locale.languageCode == 'zh' && locale.scriptCode == 'Hant'
        ? 'zh-Hant'
        : locale.languageCode;
    final index = const [
      'zh',
      'zh-Hant',
      'bo',
      'en',
      'ja',
      'fr',
      'es',
      'de',
      'ru',
      'ko',
    ].indexOf(code);
    final items = countryCallingCodes
        .where(
          (e) => '${e[0]} +${e[1]} ${(e[2] as List).join(' ')}'
              .toLowerCase()
              .contains(query.text.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(uiTr(context, '国家地区区号'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: query,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: uiTr(context, '搜索功能'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: uiTr(context, '清空搜索'),
                  onPressed: () {
                    query.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
          if (selected != null) Text('${uiTr(context, '已选择')}: $selected'),
          Expanded(
            child: items.isEmpty
                ? uiEmpty(context, () {
                    query.clear();
                    setState(() {});
                  })
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final e = items[i];
                      final names = e[2] as List;
                      return ListTile(
                        selected: selected == '${e[0]} +${e[1]}',
                        selectedTileColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        title: Text('${names[index < 0 ? 3 : index]}'),
                        subtitle: Text('${e[0]}'),
                        trailing: Text('+${e[1]}'),
                        onTap: () {
                          setState(() => selected = '${e[0]} +${e[1]}');
                          UiDemoStore.write('country-selection', selected).then(
                            (result) {
                              if (mounted && result is String)
                                setState(() => selected = result);
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

void main() =>
    runApp(const JobsDemoApp(home: CountryCallingCodesDemo(), title: '国家地区区号'));
