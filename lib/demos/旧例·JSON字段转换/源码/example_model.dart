import 'package:json_annotation/json_annotation.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/数据处理/action_cfg.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/Data/Data.3rd/数据处理/JsonConverter.dart';

part 'example_model.g.dart';

@JsonSerializable()
class ExampleModel {
  @JsonKey(fromJson: _cfgFromJson, toJson: _cfgToJson)
  final ActionCfg? cfg;

  @JsonKey(fromJson: _cfgListFromJson, toJson: _cfgListToJson)
  final List<ActionCfg>? cfgList;

  @JsonKey(fromJson: _cfgMapFromJson, toJson: _cfgMapToJson)
  final Map<String, ActionCfg>? cfgMap;

  ExampleModel({this.cfg, this.cfgList, this.cfgMap});

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleModelToJson(this);

  // ---------- 绑定到三件套的静态适配器 ----------
  static ActionCfg? _cfgFromJson(Object? json) =>
      const MapOrStringJsonConverter<ActionCfg>(ActionCfg.fromJson)
          .fromJson(json);
  static Object? _cfgToJson(ActionCfg? v) =>
      const MapOrStringJsonConverter<ActionCfg>(ActionCfg.fromJson).toJson(v);

  static List<ActionCfg>? _cfgListFromJson(Object? json) =>
      const MapOrStringListJsonConverter<ActionCfg>(ActionCfg.fromJson)
          .fromJson(json);
  static Object? _cfgListToJson(List<ActionCfg>? v) =>
      const MapOrStringListJsonConverter<ActionCfg>(ActionCfg.fromJson)
          .toJson(v);

  static Map<String, ActionCfg>? _cfgMapFromJson(Object? json) =>
      const MapOrStringMapJsonConverter<ActionCfg>(ActionCfg.fromJson)
          .fromJson(json);
  static Object? _cfgMapToJson(Map<String, ActionCfg>? v) =>
      const MapOrStringMapJsonConverter<ActionCfg>(ActionCfg.fromJson)
          .toJson(v);
}
