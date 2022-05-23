import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IntroductionController extends GetxController {
  late PageController controller ;
  final isNext = false;

  @override
  onInit() {
    controller = PageController();
    super.onInit();
  }

  jumpToNextPage(isNext) {
    controller.jumpToPage(controller.page!.round() + 1);
    if(isNext == true) {
      // Get.offAndToNamed(Routes.loginScreen);
    }
    update();
  }
}