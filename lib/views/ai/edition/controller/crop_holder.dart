import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:image/image.dart' as imgLib;

class CropHolder extends ImageEditionBaseHolder {
  List<CropConfig> items = [
    CropConfig(width: -1, height: -1, title: 'Original'),
    CropConfig(width: 1, height: 1, title: '1:1'),
    CropConfig(width: 3, height: 2, title: '3:2'),
    CropConfig(width: 2, height: 3, title: '2:3'),
    CropConfig(width: 4, height: 3, title: '4:3'),
    CropConfig(width: 3, height: 4, title: '3:4'),
    CropConfig(width: 16, height: 9, title: '16:9'),
    CropConfig(width: 9, height: 16, title: '9:16'),
  ];
  double originalRatio = 1;
  late int originWidth;
  late int originHeight;
  CropConfig? _currentItem;
  late List<int> originData;

  CropConfig? get currentItem => _currentItem;

  set currentItem(CropConfig? item) {
    _currentItem = item;
    update();
  }

  CropHolder({required super.parent});

  var scrollController = ScrollController();

  @override
  onInit() {
    return super.onInit();
  }

  @override
  Future initData() async {
    await super.initData();
    // currentItem = items.first;
    originalRatio = shownImage!.width / shownImage!.height;
    originWidth = shownImage!.width;
    originHeight = shownImage!.height;
    imgLib.PngEncoder pngEncoder = imgLib.PngEncoder();
    originData = pngEncoder.encodeImage(shownImage!);
    update();
  }

  @override
  dispose() {
    scrollController.dispose();
    return super.dispose();
  }

  @override
  onResetClick() async {
    await initData();
    canReset = false;
  }

  @override
  Future onSwitchImage(imgLib.Image image) async {
    shownImage = image;
    currentItem = items.first;
    originalRatio = shownImage!.width / shownImage!.height;
    originWidth = shownImage!.width;
    originHeight = shownImage!.height;
    imgLib.JpegEncoder jpegEncoder = imgLib.JpegEncoder();
    originData = jpegEncoder.encodeImage(shownImage!);
    update();
  }
}

class CropConfig {
  double width;
  double height;
  String title;

  CropConfig({required this.width, required this.height, required this.title});

  double get ratio => width / height;
}
