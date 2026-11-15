import '../demos/钱包卡片/钱包卡片.dart';
import '../demos/滑动解锁/滑动解锁.dart';
import '../demos/手势解锁/手势解锁.dart';
import '../demos/数字动效/数字动效.dart';
import '../demos/环形进度/环形进度.dart';
import '../demos/验证码输入/验证码输入.dart';
import '../demos/折叠分组/折叠分组.dart';
import '../demos/翻页浏览/翻页浏览.dart';
import '../demos/瀑布流/瀑布流.dart';

import 'package:flutter/material.dart';

import '../demos/侧滑菜单/侧滑菜单.dart';
import '../demos/悬浮时钟/悬浮时钟.dart';
import '../demos/搜索历史/搜索历史.dart';
import '../demos/空态重载/空态重载.dart';
import '../demos/弹出菜单/弹出菜单.dart';

class NewDemoEntry {
  const NewDemoEntry({
    required this.id,
    required this.title,
    required this.group,
    required this.sourcePath,
    required this.builder,
    this.tags = const [],
  });
  final String id;
  final String title;
  final String group;
  final String sourcePath;
  final WidgetBuilder builder;
  final List<String> tags;
}

final parallelDemos = <NewDemoEntry>[
  NewDemoEntry(
    id: 'parallel-side-menu',
    title: '侧滑菜单',
    group: '交互与动画',
    sourcePath: 'lib/demos/侧滑菜单/侧滑菜单.dart',
    builder: (_) => const SideMenuDemo(),
    tags: ['drawer', 'JobsSideMenu', '半开', '全开'],
  ),
  NewDemoEntry(
    id: 'parallel-clock',
    title: '悬浮时钟',
    group: '交互与动画',
    sourcePath: 'lib/demos/悬浮时钟/悬浮时钟.dart',
    builder: (_) => const FloatingClockDemo(),
    tags: ['floating', 'drag', '磁吸'],
  ),
  NewDemoEntry(
    id: 'parallel-search',
    title: '搜索历史',
    group: '数据与状态',
    sourcePath: 'lib/demos/搜索历史/搜索历史.dart',
    builder: (_) => const SearchHistoryDemo(),
    tags: ['search', 'history', 'JobsSearcher'],
  ),
  NewDemoEntry(
    id: 'parallel-empty',
    title: '空态重载',
    group: '基础与布局',
    sourcePath: 'lib/demos/空态重载/空态重载.dart',
    builder: (_) => const EmptyStateDemo(),
    tags: ['empty', 'JobsEmptyAuto', 'retry'],
  ),
  NewDemoEntry(
    id: 'parallel-popup',
    title: '弹出菜单',
    group: '交互与动画',
    sourcePath: 'lib/demos/弹出菜单/弹出菜单.dart',
    builder: (_) => const PopupMenuDemo(),
    tags: ['popup', 'menu', 'JobsPopupMenu'],
  ),
  NewDemoEntry(
    id: 'parallel-progress',
    title: '环形进度',
    group: '交互与动画',
    sourcePath: 'lib/demos/环形进度/环形进度.dart',
    builder: (_) => const CircularProgressDemo(),
  ),
  NewDemoEntry(
    id: 'parallel-code-input',
    title: '验证码输入',
    group: '交互与动画',
    sourcePath: 'lib/demos/验证码输入/验证码输入.dart',
    builder: (_) => const CodeInputDemo(),
  ),
  NewDemoEntry(
    id: 'parallel-groups',
    title: '折叠分组',
    group: '基础与布局',
    sourcePath: 'lib/demos/折叠分组/折叠分组.dart',
    builder: (_) => const CollapsibleGroupsDemo(),
  ),
  NewDemoEntry(
    id: 'parallel-pages',
    title: '翻页浏览',
    group: '基础与布局',
    sourcePath: 'lib/demos/翻页浏览/翻页浏览.dart',
    builder: (_) => const PageBrowsingDemo(),
  ),
  NewDemoEntry(
    id: 'parallel-masonry',
    title: '瀑布流',
    group: '基础与布局',
    sourcePath: 'lib/demos/瀑布流/瀑布流.dart',
    builder: (_) => const MasonryDemo(),
  ),
  NewDemoEntry(
    id: 'parallel-wallet-cards',
    title: '钱包卡片',
    group: '交互与动画',
    sourcePath: 'lib/demos/钱包卡片/钱包卡片.dart',
    builder: (_) => const WalletCardsDemo(),
  ),
  NewDemoEntry(
    id: 'parallel-slide-unlock',
    title: '滑动解锁',
    group: '交互与动画',
    sourcePath: 'lib/demos/滑动解锁/滑动解锁.dart',
    builder: (_) => const SlideUnlockDemo(),
  ),
  NewDemoEntry(
    id: 'parallel-pattern-unlock',
    title: '手势解锁',
    group: '交互与动画',
    sourcePath: 'lib/demos/手势解锁/手势解锁.dart',
    builder: (_) => const PatternUnlockDemo(),
  ),
  NewDemoEntry(
    id: 'parallel-animated-number',
    title: '数字动效',
    group: '交互与动画',
    sourcePath: 'lib/demos/数字动效/数字动效.dart',
    builder: (_) => const AnimatedNumberDemo(),
  ),
];
