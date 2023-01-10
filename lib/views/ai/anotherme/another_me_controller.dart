import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/src/types/image_source.dart';

class AnotherMeController extends GetxController {
  File? _sourcePhoto;

  File? get sourcePhoto => _sourcePhoto;

  TransAICachedManager _transManager = TransAICachedManager();

  TransAICachedManager get transManager => _transManager;
  List<String> _transKeyList = [];

  List<String> get transKeyList => _transKeyList;

  int recordIndex = -1;

  Map _initialConfig = {};

  set initialConfig(Map config) {
    _initialConfig = config;
    update();
  }

  Map get initialConfig => _initialConfig;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool hasChoosePhoto() => _sourcePhoto != null;

  bool hasTransRecord() => _transKeyList.isNotEmpty;

  Future<bool> startTransfer(String imageUrl) async {
    if (TextUtil.isEmpty(imageUrl)) {
      return false;
    }
    transKeyList.add(imageUrl);
    recordIndex = transKeyList.length - 1;
    update();
    return true;
  }

  Future<bool> _uploadAndSave(
    File file,
    UploadImageController uploadImageController, {
    File? sourceFile,
  }) async {
    var uploadResult = await uploadImageController.uploadCompressedImage(file);
    if (!uploadResult) {
      return false;
    }
    if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
      return false;
    }
    _sourcePhoto = sourceFile ?? file;
    update();
    return true;
  }

  Future<bool> takePhoto(
    ImageSource source,
    UploadImageController uploadImageController,
  ) async {
    XFile? image = await ImagePicker().pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
    if (image == null) {
      return false;
    }
    var file = File(image.path);
    File compressedImage = await imageCompressAndGetFile(file);
    return _uploadAndSave(compressedImage, uploadImageController, sourceFile: file);
  }

  Future<bool> pickFromRecent(UploadRecordEntity record, UploadImageController uploadImageController) async {
    var file = File(record.fileName);
    return _uploadAndSave(file, uploadImageController);
  }

  Future<bool> pickFromAiSource(File file, UploadImageController uploadImageController) async {
    File compressedImage = await imageCompressAndGetFile(file);
    return _uploadAndSave(compressedImage, uploadImageController, sourceFile: file);
  }

  onSelectRecord(int index) {
    recordIndex = index;
    update();
  }
}
