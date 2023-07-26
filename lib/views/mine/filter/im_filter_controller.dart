import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cropperx/cropperx.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Common/Extension.dart';
import '../../../Common/importFile.dart';
import '../../../Controller/effect_data_controller.dart';
import '../../../Controller/upload_image_controller.dart';
import '../../../api/filter_api.dart';
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

  // File? _personImageFile;
  double imageRatio = 16 / 9;
  late imgLib.Image image, personImage, backgroundImage;
  late ui.Image personImageForUi;
  Uint8List? byte, personImageByte;
  final GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  GlobalKey ImageViewerBackgroundKey = GlobalKey();
  bool originalShowing = false;

  double itemWidth = (ScreenUtil.screenSize.width - $(90)) / 5;
  var currentItemIndex = 0.obs;
  List<String> rightTabList = [Images.ic_filter, Images.ic_adjust, Images.ic_crop, Images.ic_background]; //, Images.ic_letter];
  late TABS selectedRightTab;

  int selectedEffectID = 0;
  Filter filter = new Filter();
  Adjust adjust = new Adjust();
  Crop crop = new Crop();
  BackgroundRemoval backgroundRemoval = new BackgroundRemoval();

  int currentAdjustID = 0;

  int selectedCropID = 0;
  var processedImageURL = null;

  UploadImageController uploadImageController = UploadImageController();

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
    image = await getLibImage(await getImage(imageFile!));
    imageRatio = image.width / image.height;
    // uploadImageController.updateImageUrl('');
    // image = await getLibImage(await getImage(imageFile));
    byte = Uint8List.fromList(imgLib.encodeJpg(image));
    personImage = image;
    personImageByte = await Uint8List.fromList(imgLib.encodeJpg(image));
    personImageForUi = await convertImage(image);

    await filter.calcAvatars(image);

    File compressedImage = await imageCompressAndGetFile(imageFile, imageSize: Get.find<EffectDataController>().data?.imageMaxl ?? 512);
    await uploadImageController.uploadCompressedImage(compressedImage);
    uploadImageController.update();
    var url = await FilterApi(client: DioNode().build()).removeBgAndSave(
        imageUrl: uploadImageController.imageUrl.value,
        onFailed: (response) {
          if (response.data != null) {
            var data = response.data;
            if (data['code'] == "DAILY_IP_LIMIT_EXCEEDED") {
              //todo
              CommonExtension().showToast(S.of(Get.context!).DAILY_IP_LIMIT_EXCEEDED);
            }
          }
        });
    if (url != null) {
      File personImageFile = File(url);
      personImage = await getLibImage(await getImage(personImageFile));
      personImageByte = await Uint8List.fromList(imgLib.encodeJpg(personImage));
      personImageForUi = await convertImage(personImage);
    }
    update();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
