class ActionCfg {
  final String name;
  final int value;

  ActionCfg({required this.name, required this.value});

  factory ActionCfg.fromJson(Map<String, dynamic> json) {
    return ActionCfg(name: json['name'] as String, value: json['value'] as int);
  }

  Map<String, dynamic> toJson() => {'name': name, 'value': value};

  @override
  String toString() => 'ActionCfg(name: $name, value: $value)';
}
