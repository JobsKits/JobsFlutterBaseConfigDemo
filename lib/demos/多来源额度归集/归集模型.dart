enum CollectionStatus { ready, running, success, failed, cancelled }

class CollectionSource {
  CollectionSource(
    this.id,
    this.titleKey,
    this.categoryKey,
    this.units, {
    this.selected = true,
    this.status = CollectionStatus.ready,
    this.attempts = 0,
  });
  final String id, titleKey, categoryKey;
  final int units;
  bool selected;
  CollectionStatus status;
  int attempts;
  String get token => 'sample-v1-$id-$units';
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': titleKey,
    'category': categoryKey,
    'units': units,
    'selected': selected,
    'status': status.index,
    'attempts': attempts,
  };
  factory CollectionSource.fromJson(Map d) {
    if (['id', 'title', 'category'].any((k) => d[k] is! String) ||
        d['units'] is! int ||
        d['units'] <= 0 ||
        d['units'] > 100000000 ||
        d['selected'] is! bool ||
        d['status'] is! int ||
        d['status'] < 0 ||
        d['status'] >= CollectionStatus.values.length ||
        d['attempts'] is! int ||
        d['attempts'] < 0) {
      throw const FormatException('Source');
    }
    var status = CollectionStatus.values[d['status']];
    if (status == CollectionStatus.running) status = CollectionStatus.cancelled;
    return CollectionSource(
      d['id'],
      d['title'],
      d['category'],
      d['units'],
      selected: d['selected'],
      status: status,
      attempts: d['attempts'],
    );
  }
}

class CollectionReceipt {
  const CollectionReceipt(this.token, this.sourceId, this.units);
  final String token, sourceId;
  final int units;
  Map<String, dynamic> toJson() => {
    'token': token,
    'source': sourceId,
    'units': units,
  };
}

typedef CollectAction = Future<bool> Function(
  CollectionSource source,
  String token,
);

/// Cancellation stops accepting pending responses; committed receipts remain immutable.
class CollectionEngine {
  CollectionEngine(this.sources, [List<CollectionReceipt>? receipts])
    : receipts = receipts ?? [];
  final List<CollectionSource> sources;
  final List<CollectionReceipt> receipts;
  bool running = false;
  int _generation = 0;
  int get collected => receipts.fold(0, (sum, r) => sum + r.units);
  bool committed(String token) => receipts.any((r) => r.token == token);
  bool commit(CollectionSource source) {
    if (committed(source.token)) return false;
    receipts.add(CollectionReceipt(source.token, source.id, source.units));
    source.status = CollectionStatus.success;
    return true;
  }

  Future<void> run(
    CollectAction action,
    void Function() onChange, {
    bool failuresOnly = false,
  }) async {
    if (running) return;
    final queue = sources
        .where(
          (s) =>
              !committed(s.token) &&
              (failuresOnly
                  ? s.status == CollectionStatus.failed
                  : s.selected && s.status != CollectionStatus.success),
        )
        .toList();
    if (queue.isEmpty) return;
    running = true;
    final generation = ++_generation;
    var next = 0;
    Future<void> worker() async {
      while (generation == _generation && next < queue.length) {
        final source = queue[next++];
        source.status = CollectionStatus.running;
        source.attempts++;
        onChange();
        var success = false;
        try {
          success = await action(source, source.token);
        } catch (_) {}
        if (generation != _generation) return;
        if (success) {
          commit(source);
        } else {
          source.status = CollectionStatus.failed;
        }
        onChange();
      }
    }

    onChange();
    await Future.wait([worker(), worker()]);
    if (generation == _generation) {
      running = false;
      onChange();
    }
  }

  void cancel() {
    _generation++;
    running = false;
    for (final s in sources) {
      if (s.status == CollectionStatus.running) {
        s.status = CollectionStatus.cancelled;
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'sources': sources.map((s) => s.toJson()).toList(),
    'receipts': receipts.map((r) => r.toJson()).toList(),
  };
  factory CollectionEngine.fromJson(Map d) {
    if (d['sources'] is! List ||
        d['receipts'] is! List ||
        (d['sources'] as List).length > 100 ||
        (d['receipts'] as List).length > 100) {
      throw const FormatException('Collection');
    }
    final sources = (d['sources'] as List)
        .map((v) => CollectionSource.fromJson(v as Map))
        .toList();
    if (sources.map((s) => s.id).toSet().length != sources.length) {
      throw const FormatException('Duplicate source');
    }
    final receipts = <CollectionReceipt>[];
    for (final r in d['receipts'] as List) {
      if (r is! Map ||
          r['token'] is! String ||
          r['source'] is! String ||
          r['units'] is! int) {
        throw const FormatException('Receipt');
      }
      final matches = sources.where(
        (s) =>
            s.id == r['source'] &&
            s.token == r['token'] &&
            s.units == r['units'],
      );
      if (matches.length != 1 || receipts.any((v) => v.token == r['token'])) {
        throw const FormatException('Receipt reference');
      }
      matches.single.status = CollectionStatus.success;
      receipts.add(CollectionReceipt(r['token'], r['source'], r['units']));
    }
    if (sources.any(
      (s) =>
          s.status == CollectionStatus.success &&
          !receipts.any((r) => r.token == s.token),
    )) {
      throw const FormatException('Uncommitted success');
    }
    return CollectionEngine(sources, receipts);
  }
  static bool accepts(Map<String, dynamic> d) {
    try {
      CollectionEngine.fromJson(d);
      return true;
    } catch (_) {
      return false;
    }
  }

  static CollectionEngine sample() => CollectionEngine([
    CollectionSource('design', '设计工作区', '工作区', 12500),
    CollectionSource('docs', '文档工作区', '工作区', 7800),
    CollectionSource('lab', '实验室项目', '项目', 4600),
    CollectionSource('release', '发布项目', '项目', 9200),
  ]);
}
