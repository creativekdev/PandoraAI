import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/api/text2image_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/models/ai_ground_style_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:common_utils/common_utils.dart';
import 'package:cartoonizer/gallery_saver.dart';

import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'ai_ground_result_screen.dart';

class AiGroundController extends GetxController {
  late Text2ImageApi api;
  TextEditingController editingController = TextEditingController();
  int maxLength = 1000;

  int imgWidth = 512;
  int height = 512;
  String? filePath;
  File? initFile;

  List<String>? promptList = null;
  List<AiGroundStyleEntity> styleList = [];
  AiGroundStyleEntity? selectedStyle;

  ScrollController scrollController = ScrollController();
  CacheManager cacheManager = AppDelegate().getManager();
  RecentController recentController = Get.find();

  @override
  void onInit() {
    super.onInit();
    var d = ScreenUtil.screenSize.height - $(168) - ScreenUtil.getBottomPadding(Get.context!);
    var scale = d / ScreenUtil.screenSize.width;
    var ht = imgWidth * scale;
    height = (ht ~/ 64) * 64;
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

  void onPlayClick(BuildContext context, String? initImageUrl) {
    var text = editingController.text.trim();
    if (TextUtil.isEmpty(text)) {
      CommonExtension().showToast('Please input prompt to generate image');
      return;
    }
    if (selectedStyle != null) {
      text += '(art by ${selectedStyle!.name})';
    }
    SimulateProgressBarController progressController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(context, needUploadProgress: false, controller: progressController, config: SimulateProgressBarConfig.aiGround()).then((value) {
      if (value != null && value.first) {
        Navigator.of(context)
            .push(
          MaterialPageRoute(builder: (context) => AiGroundResultScreen(controller: this)),
        )
            .then((value) {
          if (value ?? false) {
            onPlayClick(context, initImageUrl);
          }
        });
      }
    });
    var rootPath = cacheManager.storageOperator.recordAiGroundDir.path;
    api
        .text2image(
      prompt: text,
      directoryPath: rootPath,
      initImage: initImageUrl,
      width: imgWidth,
      height: height,
    )
        .then((value) {
      if (value != null) {
        filePath = value;
        progressController.loadComplete();
        recentController.onAiGroundUsed(filePath!, text, initFile?.path, selectedStyle?.name);
        update();
      } else {
        progressController.onError();
      }
    });
  }

  Future saveToGallery() async {
    await GallerySaver.saveImage(filePath!, albumName: saveAlbumName);
  }
}
