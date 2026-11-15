import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobs_demo_foundation/jobs_demo_foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog_repository.dart';
import 'interop_catalog.dart';
import 'interop_strings.dart';
import 'extra_catalog.dart';
import 'extra_strings.dart';
import 'legacy_catalog.dart';
import 'parallel_catalog.dart';
import 'native_catalog.dart';
import 'data_parity_catalog.dart';
import 'lab_strings.dart';
import 'ui_parity_catalog.dart';
import 'ui_parity_strings.dart';
import 'platform_catalog.dart';
import 'platform_strings.dart';

class DemoHubApp extends StatefulWidget {
  const DemoHubApp({
    super.key,
    required this.settings,
    this.repository,
    this.splashDuration = const Duration(seconds: 2),
  });
  final JobsDemoSettings settings;
  final CatalogRepository? repository;
  final Duration splashDuration;
  @override
  State<DemoHubApp> createState() => _DemoHubAppState();
}

class _DemoHubAppState extends State<DemoHubApp> {
  late final repository = widget.repository ?? CatalogRepository();
  @override
  void initState() {
    super.initState();
    JobsDemoStrings.registerTranslations(labTranslations);
    JobsDemoStrings.registerTranslations(interopTranslations);
    JobsDemoStrings.registerTranslations(extraTranslations);
    JobsDemoStrings.registerTranslations(uiParityTranslations);
    JobsDemoStrings.registerTranslations(platformTranslations);
    widget.settings.addListener(syncLocale);
  }

  void syncLocale() {
    if (Get.locale != widget.settings.locale) {
      unawaited(Get.updateLocale(widget.settings.locale));
    }
  }

  @override
  void dispose() {
    widget.settings.removeListener(syncLocale);
    if (widget.repository == null) repository.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => JobsDemoScope(
    settings: widget.settings,
    child: AnimatedBuilder(
      animation: widget.settings,
      builder: (context, _) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jobs Flutter',
        theme: jobsDemoTheme(Brightness.light),
        darkTheme: jobsDemoTheme(Brightness.dark),
        themeMode: widget.settings.themeMode,
        locale: widget.settings.locale,
        supportedLocales: jobsDemoLocales,
        localizationsDelegates: jobsDemoLocalizationDelegates,
        getPages: [
          GetPage(
            name: "/widget",
            page: () => platformDemos
                .firstWhere((e) => e.id == "platform-widget")
                .builder(context),
          ),
        ],
        home: DemoSplash(
          duration: widget.splashDuration,
          next: () => DemoHome(repository: repository),
        ),
      ),
    ),
  );
}

class DemoSplash extends StatefulWidget {
  const DemoSplash({
    super.key,
    required this.next,
    this.duration = const Duration(seconds: 2),
  });
  final Widget Function() next;
  final Duration duration;
  @override
  State<DemoSplash> createState() => _DemoSplashState();
}

class _DemoSplashState extends State<DemoSplash> {
  Timer? timer;
  bool leaving = false;
  @override
  void initState() {
    super.initState();
    timer = Timer(widget.duration, leave);
  }

  void leave() {
    if (!mounted || leaving) return;
    leaving = true;
    timer?.cancel();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => widget.next()));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      key: const ValueKey('splash'),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 16,
              child: TextButton(
                onPressed: leave,
                child: Text(tr(context, '跳过')),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jobs',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Flutter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr(context, '功能实验室'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: leave,
                    child: Text(tr(context, '开始探索')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum HubFilter { all, favorites, recent }

class DemoHome extends StatefulWidget {
  const DemoHome({super.key, required this.repository});
  final CatalogRepository repository;
  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  final search = TextEditingController();
  final searchFocus = FocusNode();
  final menu = JobsSideMenuController();
  final Set<String> favorites = {};
  final List<String> recent = [];
  final List<String> history = [];
  late List<LegacyDemoEntry> demos;
  HubFilter filter = HubFilter.all;
  bool searching = false;
  bool fullMenu = false;
  int loadGeneration = 0;
  SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    demos = [
      ...parallelDemos.map(
        (e) => LegacyDemoEntry(
          id: e.id,
          title: e.title,
          group: e.group,
          sourcePath: e.sourcePath,
          tags: e.tags,
          builder: e.builder,
        ),
      ),
      ...nativeDemos,
      ...dataParityDemos,
      ...interopDemos,
      ...extraDemos,
      ...uiParityDemos,
      ...platformDemos,
      ...legacyDemos,
    ];
    search.addListener(() => setState(() {}));
    searchFocus.addListener(() {
      if (searchFocus.hasFocus && !searching) {
        setState(() => searching = true);
        menu.close();
      }
    });
    unawaited(loadPreferences());
    unawaited(reload());
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    preferences = prefs;
    setState(() {
      favorites.addAll(prefs.getStringList('hub.favorites') ?? []);
      recent.addAll(prefs.getStringList('hub.recent') ?? []);
      history.addAll(prefs.getStringList('hub.history') ?? []);
      fullMenu = prefs.getBool('hub.fullMenu') ?? false;
    });
  }

  Future<void> reload() async {
    final generation = ++loadGeneration;
    final ids = await widget.repository.loadOrder();
    if (!mounted || generation != loadGeneration || ids == null) return;
    final ranks = {for (var i = 0; i < ids.length; i++) ids[i]: i};
    setState(
      () => demos.sort(
        (a, b) =>
            (ranks[a.id] ?? ids.length).compareTo(ranks[b.id] ?? ids.length),
      ),
    );
  }

  void persist(String key, List<String> value) {
    unawaited(preferences?.setStringList('hub.$key', value));
    unawaited(widget.repository.savePreference(key, value));
  }

  void rememberQuery() {
    final query = search.text.trim();
    if (query.isEmpty) return;
    history.remove(query);
    history.insert(0, query);
    if (history.length > 20) history.removeLast();
    persist('history', history);
  }

  void open(LegacyDemoEntry demo) {
    rememberQuery();
    recent.remove(demo.id);
    recent.insert(0, demo.id);
    if (recent.length > 30) recent.removeLast();
    persist('recent', recent);
    setState(() {});
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => demo.builder(context)),
    );
  }

  @override
  void dispose() {
    search.dispose();
    searchFocus.dispose();
    menu.dispose();
    super.dispose();
  }

  List<LegacyDemoEntry> get visible {
    final query = search.text.trim().toLowerCase();
    var result = demos
        .where(
          (e) =>
              searching ||
              switch (filter) {
                HubFilter.all => true,
                HubFilter.favorites => favorites.contains(e.id),
                HubFilter.recent => recent.contains(e.id),
              },
        )
        .where(
          (e) =>
              '${tr(context, e.title)} ${e.title} ${e.group} ${e.tags.join(' ')} ${e.sourcePath}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
    if (!searching && filter == HubFilter.recent) {
      result.sort(
        (a, b) => recent.indexOf(a.id).compareTo(recent.indexOf(b.id)),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final settings = JobsDemoScope.of(context);
    final colors = Theme.of(context).colorScheme;
    final entries = visible;
    final groups = <String, List<LegacyDemoEntry>>{};
    for (final entry in entries) {
      groups.putIfAbsent(entry.group, () => []).add(entry);
    }
    return PopScope(
      canPop: !searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && searching) {
          searchFocus.unfocus();
          search.clear();
          setState(() => searching = false);
        }
      },
      child: JobsSideMenu(
        controller: menu,
        fullWidth: fullMenu,
        widthFactor: .78,
        enabled: !searching,
        menu: Material(
          color: colors.surface,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: const Text(
                    'Jobs Flutter',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                for (final value in HubFilter.values)
                  ListTile(
                    selected: filter == value,
                    selectedColor: colors.onPrimaryContainer,
                    selectedTileColor: colors.primaryContainer,
                    leading: Icon(switch (value) {
                      HubFilter.all => Icons.apps,
                      HubFilter.favorites => Icons.star_outline,
                      HubFilter.recent => Icons.history,
                    }),
                    title: Text(
                      tr(context, switch (value) {
                        HubFilter.all => '全部功能',
                        HubFilter.favorites => '收藏',
                        HubFilter.recent => '最近使用',
                      }),
                    ),
                    onTap: () {
                      setState(() => filter = value);
                      menu.close();
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(tr(context, '设置')),
                  onTap: () {
                    menu.close();
                    showSettings(settings);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(tr(context, '开屏演示')),
                  onTap: () {
                    menu.close();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            DemoSplash(next: () => const _SplashDone()),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        child: Scaffold(
          key: const ValueKey('demo-home'),
          appBar: AppBar(
            leading: searching
                ? null
                : IconButton(
                    tooltip: tr(context, '打开菜单'),
                    onPressed: menu.toggle,
                    icon: const Icon(Icons.menu),
                  ),
            title: Text(tr(context, '功能实验室')),
            actions: [
              if (!searching)
                IconButton(
                  tooltip: tr(context, '设置'),
                  onPressed: () => showSettings(settings),
                  icon: const Icon(Icons.settings_outlined),
                ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('hub-search'),
                          controller: search,
                          focusNode: searchFocus,
                          onTap: () {
                            setState(() => searching = true);
                            menu.close();
                          },
                          onSubmitted: (_) => setState(rememberQuery),
                          decoration: InputDecoration(
                            hintText: tr(context, '搜索功能'),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: tr(context, '清空搜索'),
                                    onPressed: search.clear,
                                    icon: const Icon(Icons.close),
                                  ),
                          ),
                        ),
                      ),
                      if (searching)
                        TextButton(
                          onPressed: () {
                            search.clear();
                            searchFocus.unfocus();
                            setState(() => searching = false);
                          },
                          child: Text(tr(context, '取消')),
                        ),
                    ],
                  ),
                ),
                if (!searching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          tr(context, switch (filter) {
                            HubFilter.all => '全部功能',
                            HubFilter.favorites => '收藏',
                            HubFilter.recent => '最近使用',
                          }),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const Spacer(),
                        Text(
                          '${entries.length}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: searching && search.text.isEmpty
                      ? historyView()
                      : entries.isEmpty
                      ? emptyView()
                      : RefreshIndicator(
                          onRefresh: reload,
                          child: ListView.builder(
                            key: const PageStorageKey('demo-list'),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: groups.length,
                            itemBuilder: (context, index) {
                              final group = groups.keys.elementAt(index);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      20,
                                      20,
                                      8,
                                    ),
                                    child: Text(
                                      tr(context, group),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: colors.primary),
                                    ),
                                  ),
                                  for (final entry in groups[group]!)
                                    ListTile(
                                      key: ValueKey('demo-${entry.id}'),
                                      title: Text(tr(context, entry.title)),
                                      subtitle: Text(
                                        entry.tags.take(2).join(' · '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: tr(context, '收藏'),
                                            icon: Icon(
                                              favorites.contains(entry.id)
                                                  ? Icons.star
                                                  : Icons.star_outline,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                favorites.contains(entry.id)
                                                    ? favorites.remove(entry.id)
                                                    : favorites.add(entry.id);
                                              });
                                              persist(
                                                'favorites',
                                                favorites.toList(),
                                              );
                                            },
                                          ),
                                          PopupMenuButton<String>(
                                            tooltip: tr(context, '更多'),
                                            onSelected: (value) {
                                              if (value == 'source') {
                                                showDialog<void>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: Text(
                                                      tr(context, '源码位置'),
                                                    ),
                                                    content: SelectableText(
                                                      entry.sourcePath,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: Text(
                                                          tr(context, '取消'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              if (value == 'run') {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text:
                                                        'flutter run -t "${entry.entryPath}"',
                                                  ),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          tr(context, '复制运行命令'),
                                                        ),
                                                      ),
                                                    );
                                              }
                                            },
                                            itemBuilder: (_) => [
                                              PopupMenuItem(
                                                value: 'source',
                                                child: Text(
                                                  tr(context, '源码位置'),
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'run',
                                                child: Text(
                                                  tr(context, '复制运行命令'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      onTap: () => open(entry),
                                    ),
                                  const Divider(indent: 20, endIndent: 20),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget emptyView() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 48),
          const SizedBox(height: 16),
          Text(
            tr(
              context,
              search.text.isNotEmpty
                  ? '没有匹配的功能'
                  : filter == HubFilter.favorites
                  ? '尚无收藏'
                  : '尚无浏览记录',
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              context,
              filter == HubFilter.favorites ? '点击星标收藏常用功能' : '选择一个功能开始探索',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              search.clear();
              setState(() {
                searching = false;
                filter = HubFilter.all;
              });
              unawaited(reload());
            },
            child: Text(tr(context, search.text.isNotEmpty ? '清空搜索' : '全部功能')),
          ),
          TextButton(onPressed: reload, child: Text(tr(context, '重新加载'))),
        ],
      ),
    ),
  );

  Widget historyView() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Row(
        children: [
          Text(
            tr(context, '搜索历史'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(history.clear);
              persist('history', history);
            },
            child: Text(tr(context, '清空历史')),
          ),
        ],
      ),
      if (history.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(tr(context, '搜索功能')),
        ),
      for (final query in history)
        ListTile(
          leading: const Icon(Icons.history),
          title: Text(query),
          onTap: () => search.text = query,
          trailing: IconButton(
            tooltip: tr(context, '清空搜索'),
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => history.remove(query));
              persist('history', history);
            },
          ),
        ),
    ],
  );

  void showSettings(JobsDemoSettings settings) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StatefulBuilder(
          builder: (context, update) => Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: Text(tr(context, '设置')),
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    tr(context, '主题'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(
                    value: mode,
                    groupValue: settings.themeMode,
                    title: Text(
                      tr(context, switch (mode) {
                        ThemeMode.system => '跟随系统',
                        ThemeMode.light => '白天',
                        ThemeMode.dark => '黑夜',
                      }),
                    ),
                    onChanged: (mode) {
                      settings.setThemeMode(mode!);
                      update(() {});
                      unawaited(
                        widget.repository.savePreference('theme', mode.name),
                      );
                    },
                  ),
                const Divider(),
                SwitchListTile(
                  title: Text(tr(context, '侧滑菜单')),
                  subtitle: Text(tr(context, fullMenu ? '全开' : '半开')),
                  value: fullMenu,
                  onChanged: (value) {
                    setState(() => fullMenu = value);
                    update(() {});
                    unawaited(preferences?.setBool('hub.fullMenu', value));
                    unawaited(
                      widget.repository.savePreference('fullMenu', value),
                    );
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    tr(context, '语言'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                for (var i = 0; i < jobsDemoLocales.length; i++)
                  RadioListTile<Locale>(
                    value: jobsDemoLocales[i],
                    groupValue: settings.locale,
                    title: Text(
                      const [
                        '简体中文',
                        '繁體中文',
                        'བོད་ཡིག',
                        'English',
                        '日本語',
                        'Français',
                        'Español',
                        'Deutsch',
                        'Русский',
                        '한국어',
                      ][i],
                    ),
                    onChanged: (locale) {
                      settings.setLocale(locale!);
                      update(() {});
                      unawaited(
                        widget.repository.savePreference(
                          'locale',
                          locale.toLanguageTag(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashDone extends StatelessWidget {
  const _SplashDone();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, '开屏演示'))),
    body: Center(
      child: FilledButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr(context, '开始探索')),
      ),
    ),
  );
}
