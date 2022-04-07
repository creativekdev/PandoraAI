import 'DataModel.dart';

class CategoryModel {
  late DataModel data;

  CategoryModel({
    required this.data,
  });
  CategoryModel.fromJson(Map<String, dynamic> json) {
    data = ((json['data'] != null) ? DataModel.fromJson(json['data']) : null)!;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}
