// 独立运行：flutter run -t "lib/demos/图标字体实验/图标字体实验.dart"
// 使用本工程 pubspec.yaml 声明的依赖与资源。

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:jobs_platform_lab/jobs_platform_lab.dart';
import 'package:url_launcher/url_launcher.dart';

import '分享平台.dart';

import '../../demo_hub/ui_parity_strings.dart';
import '../../demo_hub/ui_parity_support.dart';

void main() => runApp(const JobsDemoApp(home: IconFontLaboratoryDemo()));

class IconFontLaboratoryDemo extends StatefulWidget {
  const IconFontLaboratoryDemo({super.key});
  @override
  State<IconFontLaboratoryDemo> createState() => _IconFontState();
}

class _IconFontState extends State<IconFontLaboratoryDemo> {
  final query = TextEditingController();
  final sample = TextEditingController(text: '阿里妈妈·智造字\nAI 0123456789');
  double size = 34;
  int tab = 0, refresh = 0, rotation = 0, reloadGeneration = 0;
  JobsIconfontAsset asset = JobsIconfontAsset.logo;
  JobsIconfontGlyph selected = JobsIconfontGlyph.component;
  Uint8List? raster;
  String status = '等待';
  int renderGeneration = 0;
  @override
  void dispose() {
    query.dispose();
    sample.dispose();
    super.dispose();
  }

  Future<void> render() async {
    final generation = ++renderGeneration;
    final bytes = await selected.rasterize(
      size: size * 2,
      scale: MediaQuery.devicePixelRatioOf(context),
      color: Theme.of(context).colorScheme.primary,
    );
    if (mounted && generation == renderGeneration)
      setState(() => raster = bytes);
  }

  void event(JobsIconfontCacheSource source) {
    if (mounted)
      setState(
        () => status = switch (source) {
          JobsIconfontCacheSource.memory => '内存缓存',
          JobsIconfontCacheSource.disk => '磁盘缓存',
          JobsIconfontCacheSource.network => '网络',
        },
      );
  }

  Widget image({JobsIconfontAsset? value, int? token, double? width}) =>
      JobsIconfontImage(
        key: ValueKey('preview-$reloadGeneration'),
        asset: value ?? asset,
        refreshToken: token ?? refresh,
        width: width ?? size * 3,
        height: 110,
        onResult: event,
        onError: () {
          if (mounted) setState(() => status = '失败');
        },
      );
  static const appleURL = 'https://developer.apple.com/xcode/swiftui/';
  Future<void> openApple() async {
    try {
      final opened = await launchUrl(Uri.parse(appleURL));
      if (!opened && mounted) uiNotice(context, '失败');
    } catch (_) {
      if (mounted) uiNotice(context, '失败');
    }
  }

  Future<void> shareApple() async {
    try {
      if (JobsPlatformLab.hasNativeBridge) {
        await JobsPlatformLab.invoke<Object?>('system.share', {
          'url': appleURL,
          'text': 'SwiftUI',
        });
      } else if (!await shareBrowserLink(appleURL)) {
        if (mounted) uiNotice(context, '当前平台不支持系统分享');
      }
    } catch (_) {
      if (mounted) uiNotice(context, '失败');
    }
  }

  Widget glyphPanel() {
    final entries = JobsIconfontGlyph.values
        .where((e) => e.name.toLowerCase().contains(query.text.toLowerCase()))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: query,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: uiTr(context, '搜索功能')),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final glyph in entries)
              ChoiceChip(
                avatar: glyph.build(
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(glyph.name),
                selected: selected == glyph,
                onSelected: (_) => setState(() {
                  selected = glyph;
                  raster = null;
                }),
              ),
          ],
        ),
        if (entries.isEmpty)
          uiEmpty(context, () {
            query.clear();
            setState(() {});
          }),
        const SizedBox(height: 24),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          children: [
            selected.build(
              size: size,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              selected.character,
              style: TextStyle(
                fontFamily: JobsIconfontGlyph.fontFamily,
                fontSize: size,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            OutlinedButton(
              onPressed: render,
              child: selected.build(size: size),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: render, child: Text(uiTr(context, '生成'))),
        if (raster != null)
          Image.memory(raster!, width: size * 2, height: size * 2),
        Text('U+${selected.codePoint.toRadixString(16).toUpperCase()}'),
      ],
    );
  }

  Widget textPanel() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      TextField(
        controller: sample,
        maxLines: 3,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: uiTr(context, '内容')),
      ),
      const SizedBox(height: 20),
      Text(
        sample.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: JobsIconfontGlyph.textFontFamily,
          fontFamilyFallback: const [
            'packages/jobs_demo_foundation/NotoTibetan',
          ],
          fontSize: size,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        sample.text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: size),
      ),
    ],
  );
  Widget remotePanel() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      DropdownButtonFormField<JobsIconfontAsset>(
        initialValue: asset,
        isExpanded: true,
        items: [
          for (final value in JobsIconfontAsset.values)
            DropdownMenuItem(value: value, child: Text(value.name)),
        ],
        onChanged: (value) => setState(() {
          asset = value!;
          refresh = 0;
          status = '等待';
        }),
      ),
      const SizedBox(height: 24),
      Center(child: image()),
      const SizedBox(height: 16),
      Text(uiTr(context, status), textAlign: TextAlign.center),
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: openApple,
            icon: const Icon(Icons.open_in_new),
            label: Text(uiTr(context, '打开Apple官方页面')),
          ),
          OutlinedButton.icon(
            onPressed: shareApple,
            icon: const Icon(Icons.share),
            label: Text(uiTr(context, '系统分享链接')),
          ),
        ],
      ),
      Wrap(
        spacing: 8,
        children: [
          FilledButton(
            onPressed: () => setState(() => refresh++),
            child: Text(uiTr(context, '重新加载')),
          ),
          OutlinedButton(
            onPressed: () async {
              await JobsIconfontCache.shared.clear();
              if (mounted)
                setState(() {
                  refresh++;
                  status = '等待';
                });
            },
            child: Text(uiTr(context, '清空')),
          ),
        ],
      ),
    ],
  );
  Widget reusePanel() => Column(
    children: [
      TextButton.icon(
        onPressed: () => setState(() => rotation++),
        icon: const Icon(Icons.swap_horiz),
        label: Text(uiTr(context, '切换卡片')),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: 40,
          itemBuilder: (context, index) {
            final value = JobsIconfontAsset
                .values[(index + rotation) % JobsIconfontAsset.values.length];
            return ListTile(
              key: ValueKey(index),
              leading: JobsIconfontImage(
                key: ValueKey('image-$index'),
                asset: value,
                width: 54,
                height: 54,
              ),
              title: Text('$index ${value.name}'),
              subtitle: Text(uiTr(context, '图片')),
            );
          },
        ),
      ),
    ],
  );
  Widget cachePanel() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Center(child: image()),
      Text(uiTr(context, status), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () => setState(() {
          refresh = 0;
          reloadGeneration++;
          status = '等待';
        }),
        child: Text(uiTr(context, '读取')),
      ),
      OutlinedButton(
        onPressed: () {
          JobsIconfontCache.shared.clearMemory();
          setState(() {
            refresh = 0;
            reloadGeneration++;
            status = '等待';
          });
        },
        child: Text(uiTr(context, '磁盘缓存')),
      ),
      TextButton(
        onPressed: () async {
          await JobsIconfontCache.shared.clear();
          if (mounted)
            setState(() {
              refresh = 0;
              reloadGeneration++;
              status = '等待';
            });
        },
        child: Text(uiTr(context, '清空')),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: JobsDemoAppBar(title: Text(uiTr(context, '图标字体实验'))),
    body: Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                for (var index = 0; index < 5; index++)
                  ChoiceChip(
                    label: Text(
                      uiTr(
                        context,
                        ['图标字体实验', '字号', '网络', '条目', '内存缓存'][index],
                      ),
                    ),
                    selected: index == tab,
                    onSelected: (_) => setState(() => tab = index),
                  ),
              ],
            ),
          ),
        ),
        Slider(
          value: size,
          min: 18,
          max: 64,
          onChanged: (value) => setState(() => size = value),
        ),
        Expanded(
          child: switch (tab) {
            0 => glyphPanel(),
            1 => textPanel(),
            2 => remotePanel(),
            3 => reusePanel(),
            _ => cachePanel(),
          },
        ),
      ],
    ),
  );
}
