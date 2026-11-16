enum QuotePolicy { any, favorable, manual }

class QuoteItem {
  const QuoteItem(
    this.id,
    this.titleKey,
    this.cents, {
    this.acceptedCents,
    this.selected = true,
    this.quantity = 1,
    this.minimum = 1,
    this.active = true,
  });
  final String id, titleKey;
  final int cents, quantity, minimum;
  final int? acceptedCents;
  final bool selected, active;
  QuoteItem copy({
    int? cents,
    int? acceptedCents,
    bool? selected,
    int? quantity,
    int? minimum,
    bool? active,
  }) => QuoteItem(
    id,
    titleKey,
    cents ?? this.cents,
    acceptedCents: acceptedCents ?? this.acceptedCents,
    selected: selected ?? this.selected,
    quantity: quantity ?? this.quantity,
    minimum: minimum ?? this.minimum,
    active: active ?? this.active,
  );
  bool get pending => cents != acceptedCents;
  bool get valid => active && quantity >= minimum && quantity <= 20 && !pending;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': titleKey,
    'cents': cents,
    'accepted': acceptedCents,
    'selected': selected,
    'quantity': quantity,
    'minimum': minimum,
    'active': active,
  };
  factory QuoteItem.fromJson(Map d) {
    if (d['id'] is! String ||
        d['title'] is! String ||
        d['cents'] is! int ||
        d['cents'] <= 0 ||
        d['cents'] > 10000000 ||
        d['accepted'] is! int ||
        d['accepted'] <= 0 ||
        d['quantity'] is! int ||
        d['quantity'] < 1 ||
        d['quantity'] > 20 ||
        d['minimum'] is! int ||
        d['minimum'] < 1 ||
        d['minimum'] > 20 ||
        d['selected'] is! bool ||
        d['active'] is! bool) {
      throw const FormatException('Quote item');
    }
    return QuoteItem(
      d['id'],
      d['title'],
      d['cents'],
      acceptedCents: d['accepted'],
      selected: d['selected'],
      quantity: d['quantity'],
      minimum: d['minimum'],
      active: d['active'],
    );
  }
}

class QuoteBook {
  const QuoteBook(this.items, this.version, this.policy);
  final List<QuoteItem> items;
  final int version;
  final QuotePolicy policy;
  List<QuoteItem> get selected => items.where((i) => i.selected).toList();
  int get total => selected.fold(0, (sum, i) => sum + i.cents * i.quantity);
  bool get canSubmit =>
      selected.isNotEmpty &&
      selected.length <= 10 &&
      selected.every((i) => i.valid);
  String get fingerprint => toJson().toString();
  QuoteBook edit(String id, QuoteItem Function(QuoteItem) update) => QuoteBook(
    [
      for (final i in items)
        if (i.id == id) update(i) else i,
    ],
    version + 1,
    policy,
  );
  QuoteBook withPolicy(QuotePolicy value) =>
      QuoteBook(items, version + 1, value);
  QuoteBook accept() => QuoteBook(
    [
      for (final i in items)
        if (i.selected) i.copy(acceptedCents: i.cents) else i,
    ],
    version + 1,
    policy,
  );
  QuoteBook tick() {
    final step = version % 3;
    return QuoteBook(
      [
        for (var index = 0; index < items.length; index++)
          (() {
            final i = items[index];
            final next = (i.cents + (index == 0 ? 125 : -75)).clamp(
              100,
              10000000,
            );
            final accept =
                policy == QuotePolicy.any ||
                (policy == QuotePolicy.favorable &&
                    next <= (i.acceptedCents ?? i.cents));
            return i.copy(
              cents: next,
              acceptedCents: accept ? next : i.acceptedCents,
              active: index != 2 || step != 1,
              minimum: index == 1 && step == 2 ? 3 : 1,
            );
          })(),
      ],
      version + 1,
      policy,
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((i) => i.toJson()).toList(),
    'version': version,
    'policy': policy.index,
  };
  factory QuoteBook.fromJson(Map d) {
    if (d['items'] is! List ||
        (d['items'] as List).length > 30 ||
        d['version'] is! int ||
        d['version'] < 0 ||
        d['policy'] is! int ||
        d['policy'] < 0 ||
        d['policy'] >= QuotePolicy.values.length) {
      throw const FormatException('Quote book');
    }
    final items = (d['items'] as List)
        .map((v) => QuoteItem.fromJson(v as Map))
        .toList();
    if (items.map((i) => i.id).toSet().length != items.length) {
      throw const FormatException('Duplicate quote');
    }
    return QuoteBook(items, d['version'], QuotePolicy.values[d['policy']]);
  }
  static bool accepts(Map<String, dynamic> d) {
    try {
      QuoteBook.fromJson(d);
      return true;
    } catch (_) {
      return false;
    }
  }

  static const sample = QuoteBook(
    [
      QuoteItem('desk', '桌面整理套件', 2400, acceptedCents: 2400),
      QuoteItem('notes', '笔记本套装', 1600, acceptedCents: 1600),
      QuoteItem('lamp', '阅读灯', 3900, acceptedCents: 3900, selected: false),
    ],
    1,
    QuotePolicy.manual,
  );
}
