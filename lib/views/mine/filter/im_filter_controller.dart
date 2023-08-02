import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cropperx/cropperx.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Common/Extension.dart';
import '../../../Common/importFile.dart';
import '../../../app/app.dart';
import '../../../app/cache/cache_manager.dart';
import '../../../gallery_saver.dart';
import '../../../images-res.dart';
import '../../../utils/utils.dart';
import 'Adjust.dart';
import 'BackgroundRemoval.dart';
import 'Crop.dart';
import 'Filter.dart';
import 'im_filter.dart';

class ImFilterController extends GetxController {
  ImFilterController();

  late File imageFile;
  String? _filePath;

  set filePath(String? value) {
    _filePath = value;
    onSelectImage(_filePath!);
    update();
  }

  String? get filePath => _filePath;

  File? personImageFile;
  double imageRatio = 1.0;
  late imgLib.Image image, personImage;
  imgLib.Image? backgroundImage;
  Color? backgroundColor;
  late ui.Image personImageForUi;
  Uint8List? _byte, personImageByte;

  set byte(Uint8List? value) {
    _byte = value;
    update();
  }

  // get方法
  Uint8List? get byte => _byte;
  final GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  GlobalKey ImageViewerBackgroundKey = GlobalKey();
  bool originalShowing = false;

  double itemWidth = (ScreenUtil.screenSize.width - $(90)) / 5;
  var currentItemIndex = 0.obs;
  List<String> rightTabList = [Images.ic_filter, Images.ic_adjust, Images.ic_crop, Images.ic_background]; //, Images.ic_letter];
  late TABS selectedRightTab;
  late TABS preSelectedTab;

  int selectedEffectID = 0;
  Filter filter = new Filter();
  Adjust adjust = new Adjust();
  Crop crop = new Crop();
  BackgroundRemoval backgroundRemoval = new BackgroundRemoval();

  int currentAdjustID = 0;

  int selectedCropID = 0;
  var processedImageURL = null;

  Future<ui.Image> convertImage(imgLib.Image image) async {
    List<int> pngBytes = imgLib.encodePng(image);
    Uint8List uint8List = Uint8List.fromList(pngBytes);
    ui.Codec codec = await ui.instantiateImageCodec(uint8List);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  InnerFilter(String filterStr) async {
    byte = Uint8List.fromList(imgLib.encodeJpg(await Filter.ImFilter(filterStr, image)));
    update();
  }

  Future<void> saveToAlbum(BuildContext context) async {
    if (byte == null) return;
    String imgDir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    var file = File(imgDir + "${DateTime.now().millisecondsSinceEpoch}.png");
    if (selectedRightTab == TABS.CROP && crop.selectedID > 0) {
      Uint8List? _croppedByte = await Cropper.crop(
        cropperKey: cropperKey,
      );
      await file.writeAsBytes(_croppedByte!);
    } else {
      await file.writeAsBytes(byte!);
    }
    await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
    CommonExtension().showImageSavedOkToast(context);
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future onSelectImage(String filePath) async {
    var pickFile = File(filePath);
    imageFile = File(pickFile.path);
    image = await getLibImage(await getImage(imageFile));
    imageRatio = image.width / image.height;
    // todo： 新建一个界面做动画
    byte = Uint8List.fromList(imgLib.encodeJpg(image));
    await filter.calcAvatars(image);
    update();
  }

  onResultShare({required String source, required String platform, required String photo}) {
    Events.facetoonResultShare(source: source, platform: platform, photo: 'image');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
