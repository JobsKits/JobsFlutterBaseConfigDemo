part of 'demo_hub_app.dart';

enum HubFilter { all, recent }

class DemoHome extends StatefulWidget {
  const DemoHome({super.key, required this.repository});
  final CatalogRepository repository;
  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  final menu = JobsSideMenuController();
  final scroll = ScrollController();
  final floating = HomeFloatingController();
  final layout = HomeLayout();
  final List<String> recent = [];
  final List<String> history = [];
  late final List<LegacyDemoEntry> demos = [
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
    ...curatedDemos,
  ];
  HubFilter filter = HubFilter.all;
  bool fullMenu = false;
  bool pushMenu = true;
  bool moreOpen = false;
  bool showClock = true;
  bool homeActive = true;
  int loadGeneration = 0;
  int layoutRevision = 0;
  SharedPreferences? preferences;
  JobsDemoSettings? observedSettings;
  Map<String, String> previousSettings = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = JobsDemoScope.of(context);
    if (observedSettings != settings) {
      observedSettings?.removeListener(syncSettings);
      observedSettings = settings;
      previousSettings = settingsSnapshot;
      settings.addListener(syncSettings);
    }
  }

  Map<String, String> get settingsSnapshot => {
    'theme': observedSettings!.themeMode.name,
    'locale': observedSettings!.locale.toLanguageTag(),
    'refreshStyle': observedSettings!.refreshStyle.name,
    'refreshHaptics': '${observedSettings!.refreshHaptics}',
    'refreshSound': '${observedSettings!.refreshSound}',
  };

  void syncSettings() {
    final next = settingsSnapshot;
    for (final entry in next.entries) {
      if (previousSettings[entry.key] != entry.value) {
        unawaited(widget.repository.savePreference(entry.key, entry.value));
      }
    }
    previousSettings = next;
  }

  void resetLayout() {
    layout.restore({});
    layout.collapsed.addAll(demos.map((e) => e.group).toSet().skip(1));
  }

  @override
  void initState() {
    super.initState();
    unawaited(loadPreferences().then((_) => mounted ? reload() : null));
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    preferences = prefs;
    setState(() {
      final knownIds = demos.map((entry) => entry.id).toSet();
      recent.addAll(
        (prefs.getStringList('hub.recent') ?? [])
            .where(knownIds.contains)
            .toSet()
            .take(30),
      );
      history.addAll(prefs.getStringList('hub.history') ?? []);
      fullMenu = prefs.getBool('hub.fullMenu') ?? false;
      pushMenu = prefs.getBool('hub.pushMenu') ?? true;
      showClock = prefs.getBool('hub.showClock') ?? true;
      layout.remember = prefs.getBool('hub.rememberLayout') ?? true;
      if (layout.remember) {
        layout.restore({
          for (final key in layout.snapshot.keys)
            key: prefs.getStringList('hub.layout.$key') ?? [],
        });
      }
      if (!layout.remember || !prefs.containsKey('hub.layout.collapsed')) {
        layout.collapsed.addAll(demos.map((e) => e.group).toSet().skip(1));
      }
    });
  }

  Future<void> reload() async {
    final generation = ++loadGeneration;
    final revision = layoutRevision;
    final ids = await widget.repository.loadOrder();
    if (!mounted ||
        generation != loadGeneration ||
        ids == null ||
        revision != layoutRevision) {
      return;
    }
    final known = demos.map((e) => e.id).toSet();
    setState(() {
      layout.entries
        ..clear()
        ..addAll(ids.where(known.contains).toSet());
    });
  }

  void persist(String key, List<String> value) {
    unawaited(preferences?.setStringList('hub.$key', value));
    unawaited(widget.repository.savePreference(key, value));
  }

  void setFlag(String key, bool value) {
    unawaited(preferences?.setBool('hub.$key', value));
    unawaited(widget.repository.savePreference(key, value));
  }

  void saveLayout() {
    layoutRevision++;
    for (final item in layout.snapshot.entries) {
      if (layout.remember) {
        unawaited(
          preferences?.setStringList('hub.layout.${item.key}', item.value),
        );
      } else {
        unawaited(preferences?.remove('hub.layout.${item.key}'));
      }
    }
    unawaited(
      widget.repository.savePreference('layout', {
        'remember': layout.remember,
        ...layout.snapshot,
      }),
    );
  }

  Future<void> visit(Widget page) async {
    menu.close();
    setState(() => homeActive = false);
    try {
      await Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => page));
    } finally {
      if (mounted) setState(() => homeActive = true);
    }
  }

  void open(LegacyDemoEntry entry, [BuildContext? from]) {
    recent
      ..remove(entry.id)
      ..insert(0, entry.id);
    if (recent.length > 30) recent.removeLast();
    persist('recent', recent);
    setState(() {});
    if (from == null) {
      visit(entry.builder(context));
    } else {
      Navigator.of(from).push(MaterialPageRoute<void>(builder: entry.builder));
    }
  }

  void searchDemos() => visit(
    _DemoSearchPage(
      demos: demos,
      history: history,
      repository: widget.repository,
      saveHistory: () => persist('history', history),
      onOpen: open,
    ),
  );

  void pin(LegacyDemoEntry entry) {
    setState(() {
      if (!layout.pinned.remove(entry.id)) {
        layout.pinned.insert(0, entry.id);
        layout.collapsed.remove('@pinned');
      } else {
        layout.collapsed.remove(entry.group);
      }
    });
    saveLayout();
    if (layout.pinned.contains(entry.id) && scroll.hasClients) {
      unawaited(
        scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  List<LegacyDemoEntry> get visible => demos
      .where(
        (e) => switch (filter) {
          HubFilter.all => true,
          HubFilter.recent => recent.contains(e.id),
        },
      )
      .toList();

  @override
  void dispose() {
    observedSettings?.removeListener(syncSettings);
    menu.dispose();
    scroll.dispose();
    floating.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = JobsDemoScope.of(context);
    final colors = Theme.of(context).colorScheme;
    final entries = visible;
    final byId = {for (final entry in entries) entry.id: entry};
    final grouped = <String, List<String>>{};
    final ids = layout.ordered(
      byId.keys,
      filter == HubFilter.recent ? recent : layout.entries,
    );
    final pinned = layout.pinned.where(byId.containsKey).toList();
    if (filter == HubFilter.recent) {
      grouped['@recent'] = ids;
    } else {
      if (pinned.isNotEmpty) grouped['@pinned'] = pinned;
      for (final id in ids.where((id) => !layout.pinned.contains(id))) {
        grouped.putIfAbsent(byId[id]!.group, () => []).add(id);
      }
    }
    final groups = [
      if (filter == HubFilter.recent)
        '@recent'
      else ...[
        if (pinned.isNotEmpty) '@pinned',
        ...layout.ordered(
          demos.map((entry) => entry.group).where(grouped.containsKey),
          layout.groups,
        ),
      ],
    ];
    final anyExpanded = groups.any((key) => !layout.collapsed.contains(key));
    return JobsSideMenu(
      controller: menu,
      fullWidth: fullMenu,
      widthFactor: .5,
      presentation: pushMenu
          ? JobsSideMenuPresentation.push
          : JobsSideMenuPresentation.overlay,
      enabled: homeActive,
      menu: Material(
        color: colors.surface,
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(
                title: Text(
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
                    HubFilter.recent => Icons.history,
                  }),
                  title: Text(tr(context, filterName(value))),
                  onTap: () {
                    setState(() => filter = value);
                    menu.close();
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(tr(context, '设置')),
                onTap: () => showSettings(settings),
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(tr(context, '开屏演示')),
                onTap: () => visit(DemoSplash(next: () => const _SplashDone())),
              ),
            ],
          ),
        ),
      ),
      child: HomeFloatingControls(
        controller: floating,
        active: homeActive,
        showClock: showClock,
        onOpenClock: () => visit(
          WorldClockPage(
            onFormatChanged: (value) => unawaited(
              widget.repository.savePreference('worldClock12Hour', value),
            ),
          ),
        ),
        onClockVisibilityChanged: (value) {
          setState(() => showClock = value);
          setFlag('showClock', value);
        },
        onPress: () {
          if (!scroll.hasClients) return;
          scroll.animateTo(
            scroll.offset > scroll.position.maxScrollExtent / 2
                ? 0
                : scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
        },
        child: Scaffold(
          key: const ValueKey('demo-home'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xff0f1115)
              : Colors.white,
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              tooltip: tr(context, '打开菜单'),
              onPressed: menu.toggle,
              icon: const Icon(Icons.menu),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(context, '功能实验室'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'JobsFlutterBaseConfigDemo',
                  key: const ValueKey('home-project-source'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                key: const ValueKey('hub-menu'),
                tooltip: tr(context, '更多'),
                icon: Icon(
                  moreOpen
                      ? CupertinoIcons.ellipsis_circle_fill
                      : CupertinoIcons.ellipsis_circle,
                  size: 32,
                ),
                onOpened: () => setState(() => moreOpen = true),
                onCanceled: () => setState(() => moreOpen = false),
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onSelected: (action) {
                  setState(() => moreOpen = false);
                  if (action == 'search') searchDemos();
                  if (action == 'settings') showSettings(settings);
                  if (action == 'collapse') {
                    setState(() {
                      if (anyExpanded) {
                        layout.collapsed.addAll(groups);
                      } else {
                        layout.collapsed.clear();
                      }
                    });
                    saveLayout();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'search',
                    child: Text(tr(context, '搜索Demo')),
                  ),
                  PopupMenuItem(
                    value: 'collapse',
                    enabled: filter == HubFilter.all,
                    child: Text(tr(context, anyExpanded ? '全部收缩' : '全部展开')),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Text(tr(context, '设置')),
                  ),
                ],
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Text(tr(context, filterName(filter))),
                      const Spacer(),
                      Text('${entries.length}'),
                    ],
                  ),
                ),
                Expanded(
                  child: entries.isEmpty
                      ? JobsEmptyState(
                          title: tr(context, '尚无浏览记录'),
                          message: tr(context, '选择一个功能开始探索'),
                          onReload: reload,
                          action: FilledButton(
                            onPressed: () =>
                                setState(() => filter = HubFilter.all),
                            child: Text(tr(context, '全部功能')),
                          ),
                        )
                      : JobsAdaptiveRefresh(
                          historyKey: 'demo-hub.${filter.name}',
                          onRefresh: reload,
                          child: ReorderableListView.builder(
                            key: const PageStorageKey('demo-list'),
                            scrollController: scroll,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                            physics: const JobsRefreshScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            buildDefaultDragHandles: false,
                            itemCount: groups.length,
                            onReorderItem: (from, to) {
                              if (to > from) to++;
                              if (filter == HubFilter.recent ||
                                  groups[from] == '@pinned')
                                return;
                              final movable = groups
                                  .where((g) => g != '@pinned')
                                  .toList();
                              final offset = pinned.isEmpty ? 0 : 1;
                              setState(
                                () => layout.reorder(
                                  movable,
                                  layout.groups,
                                  from - offset,
                                  (to - offset).clamp(0, movable.length),
                                ),
                              );
                              saveLayout();
                            },
                            itemBuilder: (context, index) {
                              final group = groups[index];
                              final collapsed =
                                  group != '@recent' &&
                                  layout.collapsed.contains(group);
                              final groupIds = grouped[group]!;
                              return Padding(
                                key: ValueKey('group-$group'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: Material(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xff191b20)
                                      : const Color(0xfff2f2f7),
                                  borderRadius: BorderRadius.circular(14),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              key: ValueKey(
                                                'group-toggle-$group',
                                              ),
                                              minTileHeight: 64,
                                              minVerticalPadding: 10,
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                    left: 16,
                                                    right: 10,
                                                  ),
                                              title: Wrap(
                                                spacing: 6,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Text(
                                                    tr(
                                                      context,
                                                      group == '@pinned'
                                                          ? '置顶'
                                                          : group == '@recent'
                                                          ? '最近使用'
                                                          : group,
                                                    ),
                                                  ),
                                                  Text('(${groupIds.length})'),
                                                ],
                                              ),
                                              titleTextStyle: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                color: colors.onSurface,
                                              ),
                                              subtitle: Text(
                                                '${groupIds.length} Demo · ${tr(context, collapsed ? '点击展开' : '已展开')}',
                                              ),
                                              subtitleTextStyle: TextStyle(
                                                fontSize: 13,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              trailing: Icon(
                                                group == '@recent'
                                                    ? Icons.history
                                                    : collapsed
                                                    ? Icons.chevron_right
                                                    : Icons.expand_more,
                                                size: 16,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              onTap: () {
                                                if (group == '@recent') return;
                                                setState(() {
                                                  if (!layout.collapsed.remove(
                                                    group,
                                                  ))
                                                    layout.collapsed.add(group);
                                                });
                                                saveLayout();
                                              },
                                            ),
                                          ),
                                          if (!group.startsWith('@'))
                                            ReorderableDragStartListener(
                                              index: index,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: Tooltip(
                                                  message: tr(context, '拖动排序'),
                                                  child: const Icon(
                                                    Icons.drag_handle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (!collapsed)
                                        ReorderableListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          shrinkWrap: true,
                                          primary: false,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          buildDefaultDragHandles: false,
                                          itemCount: groupIds.length,
                                          onReorderItem: (from, to) {
                                            if (filter == HubFilter.recent)
                                              return;
                                            if (to > from) to++;
                                            setState(
                                              () => layout.reorder(
                                                groupIds,
                                                group == '@pinned'
                                                    ? layout.pinned
                                                    : filter == HubFilter.recent
                                                    ? recent
                                                    : layout.entries,
                                                from,
                                                to,
                                              ),
                                            );
                                            saveLayout();
                                            if (filter == HubFilter.recent)
                                              persist('recent', recent);
                                          },
                                          itemBuilder: (context, row) => Column(
                                            key: ValueKey(
                                              'entry-row-${groupIds[row]}',
                                            ),
                                            children: [
                                              entryTile(
                                                byId[groupIds[row]]!,
                                                row,
                                              ),
                                              if (row < groupIds.length - 1)
                                                Divider(
                                                  height: 1,
                                                  thickness: .5,
                                                  indent: 16,
                                                  endIndent: 16,
                                                  color: colors.outlineVariant,
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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

  String filterName(HubFilter value) => switch (value) {
    HubFilter.all => '全部功能',
    HubFilter.recent => '最近使用',
  };

  Widget entryTile(LegacyDemoEntry entry, int index) => ListTile(
    key: ValueKey('demo-${entry.id}'),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    minTileHeight: 56,
    minVerticalPadding: 8,
    title: Text(tr(context, entry.title)),
    titleTextStyle: TextStyle(
      fontSize: 17,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    subtitle: entry.tags.isEmpty
        ? null
        : Text(
            entry.tags.take(2).join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
    subtitleTextStyle: TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    onTap: () => open(entry),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: tr(
            context,
            layout.pinned.contains(entry.id) ? '取消置顶' : '置顶',
          ),
          icon: Icon(
            layout.pinned.contains(entry.id)
                ? Icons.push_pin
                : Icons.push_pin_outlined,
          ),
          onPressed: () => pin(entry),
        ),
        PopupMenuButton<String>(
          tooltip: tr(context, '更多'),
          onSelected: (action) {
            if (action == 'source')
              showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(tr(context, '源码位置')),
                  content: SelectableText(entry.sourcePath),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(tr(context, '取消')),
                    ),
                  ],
                ),
              );
            if (action == 'run') {
              Clipboard.setData(
                ClipboardData(text: 'flutter run -t "${entry.entryPath}"'),
              );
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(tr(context, '复制运行命令'))));
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'source', child: Text(tr(context, '源码位置'))),
            PopupMenuItem(value: 'run', child: Text(tr(context, '复制运行命令'))),
          ],
        ),
        if (filter != HubFilter.recent)
          ReorderableDragStartListener(
            index: index,
            child: Tooltip(
              message: tr(context, '拖动排序'),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    ),
  );

  void showSettings(JobsDemoSettings settings) => visit(
    StatefulBuilder(
      builder: (context, update) => Scaffold(
        appBar: AppBar(title: Text(tr(context, '设置'))),
        body: ListView(
          key: const ValueKey('hub-settings-list'),
          children: [
            // 公共面板统一负责主题、语言和全局控件样式。
            const JobsDemoSettingsPanel(scrollable: false),
            const Divider(),
            SwitchListTile(
              title: Text(tr(context, '侧滑菜单')),
              subtitle: Text(tr(context, fullMenu ? '全开' : '半开')),
              value: fullMenu,
              onChanged: (value) {
                setState(() => fullMenu = value);
                update(() {});
                setFlag('fullMenu', value);
              },
            ),
            SwitchListTile(
              title: Text(tr(context, '菜单展开方式')),
              subtitle: Text(tr(context, pushMenu ? '平移首页' : '覆盖首页')),
              value: pushMenu,
              onChanged: (value) {
                setState(() => pushMenu = value);
                update(() {});
                setFlag('pushMenu', value);
              },
            ),
            SwitchListTile(
              title: Text(tr(context, '记住列表布局')),
              subtitle: layout.remember ? null : Text(tr(context, '重启后恢复默认布局')),
              value: layout.remember,
              onChanged: (value) {
                setState(() => layout.remember = value);
                update(() {});
                setFlag('rememberLayout', value);
                saveLayout();
              },
            ),
            ListTile(
              title: Text(tr(context, '恢复默认布局')),
              onTap: () {
                setState(resetLayout);
                update(() {});
                saveLayout();
              },
            ),
            SwitchListTile(
              title: Text(tr(context, '悬浮时间按钮')),
              value: showClock,
              onChanged: (value) {
                setState(() => showClock = value);
                update(() {});
                setFlag('showClock', value);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(tr(context, '调试工具')),
              onTap: () {
                floating.showDebugEntry();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _DemoSearchPage extends StatefulWidget {
  const _DemoSearchPage({
    required this.demos,
    required this.history,
    required this.repository,
    required this.saveHistory,
    required this.onOpen,
  });
  final List<LegacyDemoEntry> demos;
  final List<String> history;
  final CatalogRepository repository;
  final VoidCallback saveHistory;
  final void Function(LegacyDemoEntry, BuildContext) onOpen;
  @override
  State<_DemoSearchPage> createState() => _DemoSearchPageState();
}

class _DemoSearchPageState extends State<_DemoSearchPage> {
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    search.addListener(changed);
  }

  void changed() => setState(() {});
  void remember() {
    final query = search.text.trim();
    if (query.isEmpty) return;
    widget.history
      ..remove(query)
      ..insert(0, query);
    if (widget.history.length > 20) widget.history.removeLast();
    widget.saveHistory();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final results = widget.demos
        .where(
          (entry) =>
              '${tr(context, entry.title)} ${entry.title} ${entry.group} ${entry.tags.join(' ')} ${entry.sourcePath}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
    return Scaffold(
      key: const ValueKey('hub-search-page'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          key: const ValueKey('hub-search'),
          controller: search,
          autofocus: true,
          onSubmitted: (_) {
            remember();
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: tr(context, '搜索功能'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: tr(context, '清空搜索'),
                    onPressed: search.clear,
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr(context, '取消')),
          ),
        ],
      ),
      body: SafeArea(
        child: query.isEmpty
            ? (widget.history.isEmpty
                  ? JobsEmptyState(
                      title: tr(context, '没有搜索历史'),
                      message: tr(context, '搜索功能'),
                      onReload: () async {
                        await widget.repository.loadOrder();
                      },
                    )
                  : ListView(
                      children: [
                        ListTile(
                          title: Text(tr(context, '搜索历史')),
                          trailing: TextButton(
                            onPressed: () {
                              setState(widget.history.clear);
                              widget.saveHistory();
                            },
                            child: Text(tr(context, '清空历史')),
                          ),
                        ),
                        for (final word in widget.history)
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(word),
                            onTap: () => search.text = word,
                            trailing: IconButton(
                              tooltip: tr(context, '清空搜索'),
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() => widget.history.remove(word));
                                widget.saveHistory();
                              },
                            ),
                          ),
                      ],
                    ))
            : results.isEmpty
            ? JobsEmptyState(
                title: tr(context, '没有匹配的功能'),
                message: tr(context, '搜索功能'),
                onReload: () async {
                  await widget.repository.loadOrder();
                },
                action: FilledButton(
                  onPressed: search.clear,
                  child: Text(tr(context, '清空搜索')),
                ),
              )
            : ListView.builder(
                itemCount: results.length,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context, index) => ListTile(
                  title: Text(tr(context, results[index].title)),
                  subtitle: Text(tr(context, results[index].group)),
                  onTap: () {
                    remember();
                    widget.onOpen(results[index], context);
                  },
                ),
              ),
      ),
    );
  }
}
