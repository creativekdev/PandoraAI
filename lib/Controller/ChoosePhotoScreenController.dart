import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';

class ChoosePhotoScreenController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    var sharedPreferences = await SharedPreferences.getInstance();
    isLogin.value = sharedPreferences.getBool("isLogin") ?? false;
  }

  final isPhotoSelect = false.obs;
  changeIsPhotoSelect(bool value) => isPhotoSelect.value = value;

  final isVideo = false.obs;
  changeIsVideo(bool value) => isVideo.value = value;

  final isPhotoDone = false.obs;
  changeIsPhotoDone(bool value) => isPhotoDone.value = value;

  final isRate = true.obs;
  changeIsRate(bool value) => isRate.value = value;

  final isLogin = false.obs;
  changeIsLogin(bool value) => isLogin.value = value;

  final isChecked = false.obs;
  changeIsChecked(bool value) => isChecked.value = value;

  final isLoading = false.obs;
  changeIsLoading(bool value) => isLoading.value = value;

  final lastSelectedIndex = 0.obs;
  setLastSelectedIndex(int i) => lastSelectedIndex.value = i;

  final lastItemIndex = 0.obs;
  setLastItemIndex(int i) => lastItemIndex.value = i;

  final lastItemIndex1 = 0.obs;
  setLastItemIndex1(int i) => lastItemIndex1.value = i;

  final Rx<File?> image = (null as File?).obs;
  updateImageFile(dynamic lFile) => image.value = lFile;

  final videoUrl = "".obs;
  updateVideoUrl(String str) => videoUrl.value = str;
}
