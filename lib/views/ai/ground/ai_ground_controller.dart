import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/text2image_api.dart';

class AiGroundController extends GetxController {
  late Text2ImageApi api;
  TextEditingController editingController = TextEditingController();
  int maxLength = 200;

  List<String> promptList = [];

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
}
