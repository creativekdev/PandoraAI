import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
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
  int maxLength = 200;

  String? imageBase64;

  List<String>? promptList = null;
  Map<String, List<AiGroundStyleEntity>>? styleMap = null;
  List<String>? categoryList = null;
  int selectedCategoryIndex = 0;
  AiGroundStyleEntity? selectedStyle;

  ScrollController scrollController = ScrollController();

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
      promptList = value.filter((t) => t != null).map((e) => e!.split(' ').first).toList();
      update();
    });
    api.artists().then((value) {
      if (value != null) {
        styleMap = value;
        categoryList = styleMap!.keys.toList();
        update();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
  }

  void onPromptClick(String prompt) {
    var oldText = editingController.text;
    if (oldText.endsWith(prompt)) {
      return;
    }
    oldText += prompt;
    if (oldText.length > maxLength) {
      oldText = oldText.substring(0, maxLength);
    }
    editingController.text = oldText;
    editingController.selection = TextSelection(baseOffset: oldText.length, extentOffset: oldText.length);
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
    api.text2image(prompt: text, initImage: initImageUrl).then((value) {
      if (value != null) {
        imageBase64 = value;
        progressController.loadComplete();
        update();
      } else {
        progressController.onError();
      }
    });
  }

  Future saveToGallery() async {
    var uint8list = base64Decode(imageBase64!);
    var list = uint8list.toList();
    var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    var imgPath = path + '${DateTime.now().millisecondsSinceEpoch}.png';
    await File(imgPath).writeAsBytes(list);
    await GallerySaver.saveImage(imgPath, albumName: saveAlbumName);
  }
}
