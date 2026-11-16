// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExampleModel _$ExampleModelFromJson(Map<String, dynamic> json) => ExampleModel(
      cfg: ExampleModel._cfgFromJson(json['cfg']),
      cfgList: ExampleModel._cfgListFromJson(json['cfgList']),
      cfgMap: ExampleModel._cfgMapFromJson(json['cfgMap']),
    );

Map<String, dynamic> _$ExampleModelToJson(ExampleModel instance) =>
    <String, dynamic>{
      'cfg': ExampleModel._cfgToJson(instance.cfg),
      'cfgList': ExampleModel._cfgListToJson(instance.cfgList),
      'cfgMap': ExampleModel._cfgMapToJson(instance.cfgMap),
    };
