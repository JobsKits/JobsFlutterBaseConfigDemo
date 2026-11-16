class BonusReward {
  final String bets;
  final String bonus;

  BonusReward({required this.bets, required this.bonus});

  factory BonusReward.fromJson(Map<String, dynamic> json) =>
      BonusReward(bets: json['bets'] ?? '', bonus: json['bonus'] ?? '');
}

class BonusTable {
  final String title;
  final String condition;
  final List<BonusReward> rewards;
  final String example;
  final String applyTime;

  BonusTable({
    required this.title,
    required this.condition,
    required this.rewards,
    required this.example,
    required this.applyTime,
  });

  factory BonusTable.fromJson(Map<String, dynamic> json) => BonusTable(
    title: json['title'] ?? '',
    condition: json['condition'] ?? '',
    rewards: (json['rewards'] as List<dynamic>)
        .map((e) => BonusReward.fromJson(e))
        .toList(),
    example: json['example'] ?? '',
    applyTime: json['apply_time'] ?? '',
  );
}
