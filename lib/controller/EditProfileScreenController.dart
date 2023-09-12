import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';

class EditProfileScreenController extends GetxController {
  final imageUrl = "".obs;
  updateImageUrl(String url) => imageUrl.value = url;

  final Rx<File?> image = (null as File?).obs;
  updateImageFile(File lFile) => image.value = lFile;

  final isPhotoSelect = false.obs;
  changeIsPhotoSelect(bool value) => isPhotoSelect.value = value;

  final isLoading = false.obs;
  changeIsLoading(bool value) => isLoading.value = value;
}
