import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/images-res.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/api/text2image_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/models/ai_ground_result_entity.dart';
import 'package:cartoonizer/models/ai_ground_style_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';

class AiGroundController extends GetxController {
  final List<ImageScale> imageScaleList = [
    ImageScale.square(),
    ImageScale.fourToThree(),
    ImageScale.threeToFour(),
  ];

  late Text2ImageApi api;
  TextEditingController editingController = TextEditingController();
  int maxLength = 1000;

  ImageScale imageScale = ImageScale.square();

  String? filePath;
  Map<String, dynamic>? parameters;
  File? initFile;

  List<String>? promptList = null;
  List<AiGroundStyleEntity> styleList = [];
  AiGroundStyleEntity? selectedStyle;

  ScrollController scrollController = ScrollController();
  CacheManager cacheManager = AppDelegate().getManager();
  RecentController recentController = Get.find();
  UploadImageController uploadImageController;
  bool _displayText = false;

  AiGroundController({required this.uploadImageController});

  set displayText(bool value) {
    _displayText = value;
    update();
  }

  bool get displayText => _displayText;

  @override
  void onInit() {
    super.onInit();
    api = Text2ImageApi().bindController(this);
  }

  @override
  void onReady() {
    super.onReady();
    Future.wait([
      api.randomPrompt(),
      api.randomPrompt(),
      api.randomPrompt(),
      api.randomPrompt(),
      api.randomPrompt(),
    ]).then((value) {
      promptList = value.filter((t) => t != null).map((e) => e!).toList();
      update();
    });
    api.artists().then((value) {
      if (value != null) {
        styleList = value;
        update();
        EventBusHelper().eventBus.fire(OnAiGroundStyleUpdateEvent());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
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
      text += '(art by ${selectedStyle!.name})';
    }
    var groundLimitEntity = await CartoonizerApi().getTxt2ImgLimit();
    if (groundLimitEntity != null) {
      if (groundLimitEntity.usedCount >= groundLimitEntity.dailyLimit) {
        if (isVip()) {
          return TransferResult()
            ..msgTitle = S.of(Get.context!).generate_reached_limit_title.replaceAll('%s', 'AI Artist')
            ..msgContent = S.of(Get.context!).generate_reached_limit_vip.replaceAll('%s', 'AI Artist');
        } else {
          return TransferResult()
            ..msgTitle = S.of(Get.context!).generate_reached_limit_title.replaceAll('%s', 'AI Artist')
            ..msgContent = S.of(Get.context!).generate_reached_limit.replaceAll('%s', 'AI Artist');
        }
      }
    }
    var rootPath = cacheManager.storageOperator.recordAiGroundDir.path;
    var result = await api.text2image(
      prompt: text,
      directoryPath: rootPath,
      initImage: uploadImageController.imageUrl.value,
      width: imageScale.width,
      height: imageScale.height,
    );

    if (result != null) {
      filePath = result.filePath;
      parameters = result.parameters;
      recentController.onAiGroundUsed(filePath!, text, initFile?.path, selectedStyle?.name, parameters!);
      update();

      var params = <String, dynamic>{
        'prompt': text,
        'width': imageScale.width,
        'height': imageScale.height,
        'result_id': result.s,
      };
      if (!TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
        params['init_images'] = [uploadImageController.imageUrl.value];
      }
      CartoonizerApi().logTxt2Img(params);
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
  AiGroundResultEntity? data;
  String? msgTitle;
  String? msgContent;

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
