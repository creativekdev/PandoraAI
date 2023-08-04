import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:cartoonizer/views/mine/filter/Crop.dart';

class CropHolder extends ImageEditionBaseHolder {
  List<CropItem> items = [
    CropItem.origin(),
    CropItem.square(),
    CropItem.c23(),
    CropItem.c34(),
    CropItem.c916(),
  ];
  late CropItem _currentItem;

  CropItem get currentItem => _currentItem;

  set currentItem(CropItem item) {
    _currentItem = item;
    update();
  }

  CropHolder({required super.parent});

  @override
  initData() {
    currentItem = items.first;
  }
}
