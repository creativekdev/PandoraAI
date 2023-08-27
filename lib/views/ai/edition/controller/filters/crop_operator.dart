import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/croppy/src/model/crop_image_result.dart';
import 'package:cartoonizer/views/ai/edition/controller/filters/base_filter_operator.dart';

class CropOperator extends BaseFilterOperator {
  late List<CropConfig> items;

  late CropConfig _currentItem;

  CropConfig get currentItem => _currentItem;

  set currentItem(CropConfig item) {
    _currentItem = item;
    update();
  }

  CropImageResult? _cropData;

  CropImageResult? get cropData => _cropData;

  set cropData(CropImageResult? data) {
    this._cropData = data;
    parent.buildImage();
  }

  var scrollController = ScrollController();

  CropOperator({required super.parent});

  Rect getShownRect(double scale) {
    if (cropData == null) {
      return Rect.zero;
    }
    var rect = cropData!.transformationsData.cropRect;
    return Rect.fromLTRB(rect.left * scale, rect.top * scale, rect.right * scale, rect.bottom * scale);
  }

  Rect getFinalRect() {
    if (cropData == null) {
      return Rect.zero;
    }
    return cropData!.transformationsData.cropRect;
  }

  @override
  onInit() {
    items = [
      CropConfig(width: 100, height: 100 / parent.originRatio, title: 'Original'),
      CropConfig(width: 1, height: 1, title: '1:1'),
      CropConfig(width: 3, height: 2, title: '3:2'),
      CropConfig(width: 2, height: 3, title: '2:3'),
      CropConfig(width: 4, height: 3, title: '4:3'),
      CropConfig(width: 3, height: 4, title: '3:4'),
      CropConfig(width: 16, height: 9, title: '16:9'),
      CropConfig(width: 9, height: 16, title: '9:16'),
    ];
    currentItem = items.first;
  }
}

class CropConfig {
  double width;
  double height;
  String title;

  CropConfig({required this.width, required this.height, required this.title});

  double get ratio => width / height;
}
