import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/api/text2image_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/models/txt2img_result_entity.dart';
import 'package:cartoonizer/models/txt2img_style_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';

class Txt2imgController extends GetxController {
  late UploadImageController uploadImageController;
  final List<ImageScale> imageScaleList = [
    ImageScale.square(),
    ImageScale.fourToThree(),
    ImageScale.threeToFour(),
  ];

  late Text2ImageApi api;
  TextEditingController editingController = TextEditingController();
  int maxLength = 1000;

  ImageScale imageScale = ImageScale.threeToFour();

  String? filePath;
  Map<String, dynamic>? parameters;
  File? initFile;

  List<String> promptList = [];
  List<Txt2imgStyleEntity> styleList = [];
  Txt2imgStyleEntity? selectedStyle;

  ScrollController scrollController = ScrollController();
  CacheManager cacheManager = AppDelegate().getManager();
  RecentController recentController = Get.find();
  bool _displayText = false;

  Txt2imgController();

  set displayText(bool value) {
    _displayText = value;
    update();
  }

  bool get displayText => _displayText;

  @override
  void onInit() {
    super.onInit();
    uploadImageController = UploadImageController();
    rootBundle.loadString('assets/images/prompts.txt').then((value) {
      var split = value.split('\n');
      List<int> posList = [];
      while (posList.length < 5) {
        var nextInt = Random().nextInt(split.length);
        if (!posList.contains(nextInt)) {
          posList.add(nextInt);
        }
      }
      promptList.clear();
      for (var pos in posList) {
        promptList.add(split[pos]);
      }
      if (TextUtil.isEmpty(editingController.text)) {
        editingController.text = promptList.first;
      }
      update();
    });
    api = Text2ImageApi().bindController(this);
  }

  @override
  void onReady() {
    super.onReady();
    api.artists().then((value) {
      if (value != null) {
        styleList = value;
        update();
        EventBusHelper().eventBus.fire(OnTxt2imgStyleUpdateEvent());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    uploadImageController.dispose();
  }

  void onPromptClick(String prompt) {
    editingController.text = prompt;
    editingController.selection = TextSelection(baseOffset: prompt.length, extentOffset: prompt.length);
    update();
  }

  Future<TransferResult?> generate() async {
    var text = editingController.text.trim();
    if (TextUtil.isEmpty(text)) {
      CommonExtension().showToast('Please input prompt to generate image');
      return null;
    }
    if (selectedStyle != null) {
      if (text.endsWith(',')) {
        text += ' (art by ${selectedStyle!.name})';
      } else {
        text += ', (art by ${selectedStyle!.name})';
      }
    }
    var groundLimitEntity = await AppApi().getTxt2ImgLimit();
    if (groundLimitEntity != null) {
      if (groundLimitEntity.usedCount >= groundLimitEntity.dailyLimit) {
        if (AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
          return TransferResult()..error = AccountLimitType.guest;
        } else if (isVip()) {
          return TransferResult()..error = AccountLimitType.vip;
        } else {
          return TransferResult()..error = AccountLimitType.normal;
        }
      }
    }
    var rootPath = cacheManager.storageOperator.recordTxt2imgDir.path;
    var result = await api.text2image(
      prompt: text,
      directoryPath: rootPath,
      initImage: initFile == null ? null : uploadImageController.imageUrl(initFile!).value,
      width: imageScale.width,
      height: imageScale.height,
    );

    if (result != null) {
      filePath = result.filePath;
      parameters = result.parameters;
      recentController.onTxt2imgUsed(filePath!, text, initFile?.path, selectedStyle?.name, parameters!);
      update();

      var params = <String, dynamic>{
        'prompt': text,
        'width': imageScale.width,
        'height': imageScale.height,
        'result_id': result.s,
      };
      if (initFile != null) {
        if (!TextUtil.isEmpty(uploadImageController.imageUrl(initFile!).value)) {
          params['init_images'] = [uploadImageController.imageUrl(initFile!).value];
        }
      }
      AppApi().logTxt2Img(params);
      return TransferResult()..data = result;
    } else {
      return null;
    }
  }

  Future<bool> saveToGallery(ui.Image image) async {
    var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return false;
    }
    var s = cacheManager.storageOperator.tempDir.path + EncryptUtil.encodeMd5(filePath ?? '') + '.png';
    await File(s).writeAsBytes(byteData.buffer.asUint8List());
    await GallerySaver.saveImage(s, albumName: saveAlbumName);
    return true;
  }
}

class TransferResult {
  Txt2imgResultEntity? data;
  AccountLimitType? error;

  TransferResult();
}

class ImageScale {
  int width = 0;
  int height = 0;
  String scaleString = '0:0';

  ImageScale();

  factory ImageScale.square() => ImageScale()
    ..width = 512
    ..height = 512
    ..scaleString = '1:1';

  factory ImageScale.twoToThree() => ImageScale()
    ..width = 320
    ..height = 480
    ..scaleString = '2:3';

  factory ImageScale.threeToFour() => ImageScale()
    ..width = 384
    ..height = 512
    ..scaleString = '3:4';

  factory ImageScale.fourToThree() => ImageScale()
    ..width = 512
    ..height = 384
    ..scaleString = '4:3';

  @override
  String toString() {
    return 'ImageScale{width: $width, height: $height, scaleString: $scaleString}';
  }

  @override
  bool operator ==(Object other) {
    if (other is ImageScale) {
      return toString() == other.toString();
    } else {
      return false;
    }
  }

  Size getSize(double maxSize) {
    var scale = width / height;
    if (scale > 1) {
      return Size(maxSize, maxSize / scale);
    } else {
      return Size(maxSize * scale, maxSize);
    }
  }
}
