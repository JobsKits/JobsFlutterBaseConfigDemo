enum InboxAction { read, archive, subscription }

class InboxNotice {
  const InboxNotice(
    this.id,
    this.repository,
    this.reasonKey,
    this.titleKey, {
    this.read = false,
    this.archived = false,
    this.subscribed = true,
  });
  final String id, repository, reasonKey, titleKey;
  final bool read, archived, subscribed;
  InboxNotice copy({bool? read, bool? archived, bool? subscribed}) =>
      InboxNotice(
        id,
        repository,
        reasonKey,
        titleKey,
        read: read ?? this.read,
        archived: archived ?? this.archived,
        subscribed: subscribed ?? this.subscribed,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'repository': repository,
    'reason': reasonKey,
    'title': titleKey,
    'read': read,
    'archived': archived,
    'subscribed': subscribed,
  };
  factory InboxNotice.fromJson(Map d) {
    if (['id', 'repository', 'reason', 'title'].any((k) => d[k] is! String) ||
        ['read', 'archived', 'subscribed'].any((k) => d[k] is! bool)) {
      throw const FormatException('Notice');
    }
    return InboxNotice(
      d['id'],
      d['repository'],
      d['reason'],
      d['title'],
      read: d['read'],
      archived: d['archived'],
      subscribed: d['subscribed'],
    );
  }
}

class InboxBoard {
  const InboxBoard(this.items, this.revision);
  final List<InboxNotice> items;
  final int revision;
  List<InboxNotice> filter({
    String? repository,
    String? reason,
    bool unread = true,
    bool archived = false,
  }) => items
      .where(
        (i) =>
            i.archived == archived &&
            (!unread || !i.read) &&
            (repository == null || i.repository == repository) &&
            (reason == null || i.reasonKey == reason),
      )
      .toList();
  InboxBoard change(Set<String> ids, InboxAction action) => InboxBoard([
    for (final i in items)
      if (ids.contains(i.id))
        switch (action) {
          InboxAction.read => i.copy(read: true),
          InboxAction.archive => i.copy(archived: !i.archived),
          InboxAction.subscription => i.copy(subscribed: !i.subscribed),
        }
      else
        i,
  ], revision + 1);
  InboxBoard restore(Map<String, InboxNotice> before) =>
      InboxBoard([for (final i in items) before[i.id] ?? i], revision + 1);
  Map<String, dynamic> toJson() => {
    'items': items.map((i) => i.toJson()).toList(),
    'revision': revision,
  };
  factory InboxBoard.fromJson(Map d) {
    if (d['items'] is! List ||
        (d['items'] as List).length > 500 ||
        d['revision'] is! int) {
      throw const FormatException('Inbox');
    }
    final items = (d['items'] as List)
        .map((v) => InboxNotice.fromJson(v as Map))
        .toList();
    if (items.map((i) => i.id).toSet().length != items.length) {
      throw const FormatException('Duplicate notice');
    }
    return InboxBoard(items, d['revision']);
  }
  static bool accepts(Map<String, dynamic> d) {
    try {
      InboxBoard.fromJson(d);
      return true;
    } catch (_) {
      return false;
    }
  }

  static const sample = InboxBoard([
    InboxNotice('n1', 'jobs/atlas', '提及', '请审阅缓存更新'),
    InboxNotice('n2', 'jobs/atlas', '分配', '文档发布需要确认'),
    InboxNotice('n3', 'jobs/studio', '提及', '边界测试已有回复'),
    InboxNotice('n4', 'jobs/studio', '关注', '构建任务已完成', read: true),
    InboxNotice('n5', 'jobs/atlas', '关注', '设计讨论有新进展', subscribed: false),
  ], 1);
}
