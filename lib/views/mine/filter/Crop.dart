import 'package:cartoonizer/common/importFile.dart';

class CropItem {
  List<CropConfig> configs = [];

  factory CropItem.origin() => CropItem(configs: []);

  factory CropItem.square() => CropItem(configs: [CropConfig(width: 1, height: 1, title: 'Square', checked: true)]);

  factory CropItem.c23() => CropItem(configs: [CropConfig(width: 3, height: 2, title: '3:2', checked: true), CropConfig(width: 2, height: 3, title: '2:3', checked: false)]);

  factory CropItem.c34() => CropItem(configs: [CropConfig(width: 4, height: 3, title: '4:3', checked: true), CropConfig(width: 3, height: 4, title: '3:4', checked: false)]);

  factory CropItem.c916() => CropItem(configs: [CropConfig(width: 16, height: 9, title: '16:9', checked: true), CropConfig(width: 9, height: 16, title: '9:16', checked: false)]);

  CropItem({required this.configs});

  String get title {
    return configs.pick((t) => t.checked)?.title ?? 'Original';
  }

  CropConfig? get config {
    return configs.pick((t) => t.checked);
  }
}

class CropConfig {
  double width;
  double height;
  String title;
  bool checked;

  CropConfig({required this.width, required this.height, required this.title, required this.checked});

  double get ratio => width / height;
}
