import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@iOS李明杰解析/MJModel.dart';
import 'package:jobs_flutter_base_config/JobsDemoTools/JobsFlutterTools/高仿@iOS李明杰解析/Demo/game_model.dart';

class CategoryModel extends MJModel<CategoryModel> {
  int? categoryId;
  String? categoryName;
  List<GameModel>? games;

  CategoryModel({this.categoryId, this.categoryName, this.games});

  @override
  Map<String, String> keyMapping() => {
    'categoryId': 'id',
    'categoryName': 'name',
    'games': 'game_list',
  };

  @override
  Map<String, dynamic> toJson() => {
    'id': categoryId,
    'name': categoryName,
    'game_list': games?.map((e) => e.toJson()).toList(),
  };

  @override
  List<String> getFieldNames() => ['categoryId', 'categoryName', 'games'];

  @override
  Type? getFieldType(String field) {
    switch (field) {
      case 'categoryId':
        return int;
      case 'categoryName':
        return String;
      case 'games':
        return GameModel;
    }
    return null;
  }

  @override
  void setField(String field, dynamic value) {
    switch (field) {
      case 'categoryId':
        categoryId = value;
        break;
      case 'categoryName':
        categoryName = value;
        break;
      case 'games':
        games = value?.cast<GameModel>();
        break;
    }
  }
}
