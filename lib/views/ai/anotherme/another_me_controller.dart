import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/another_me_result_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class AnotherMeController extends GetxController {
  File? _sourcePhoto;

  File? get sourcePhoto => _sourcePhoto;

  set sourcePhoto(File? file) {
    _sourcePhoto = file;
  }

  String? _error;

  bool error() => _error != null;

  onError() {
    _error = '';
    update();
  }

  onSuccess() {
    _error = null;
    update();
  }

  clear(UploadImageController uploadImageController) {
    uploadImageController.updateImageUrl('');
    _sourcePhoto = null;
    _transKey = null;
    _mFaceRatio = null;
    update();
  }

  String? _transKey;

  String? get transKey => _transKey;

  set transKey(String? key) {
    _transKey = key;
  }

  clearTransKey() {
    _transKey = null;
    _error = null;
    update();
  }

  late Uploader api;
  late CartoonizerApi cartoonizerApi;
  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  bool get viewInit => _viewInit;

  int? _mFaceRatio;

  @override
  void onInit() {
    super.onInit();
    api = Uploader().bindController(this);
    cartoonizerApi = CartoonizerApi().bindController(this);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    cartoonizerApi.unbind();
  }

  bool hasChoosePhoto() => _sourcePhoto != null;

  bool hasTransRecord() => _transKey != null;

  Future<TransferResult?> startTransfer(String imageUrl, String? cachedId) async {
    if (TextUtil.isEmpty(imageUrl)) {
      return null;
    }
    var metaverseLimitEntity = await cartoonizerApi.getMetaverseLimit();
    if (metaverseLimitEntity != null) {
      if (metaverseLimitEntity.usedCount >= metaverseLimitEntity.dailyLimit) {
        if (isVip()) {
          return TransferResult()
            ..msgTitle = S.of(Get.context!).generate_reached_limit_title.replaceAll('%s', 'Me-taverse')
            ..msgContent = S.of(Get.context!).generate_reached_limit_vip.replaceAll('%s', 'Me-taverse');
        } else {
          return TransferResult()
            ..msgTitle = S.of(Get.context!).generate_reached_limit_title.replaceAll('%s', 'Me-taverse')
            ..msgContent = S.of(Get.context!).generate_reached_limit.replaceAll('%s', 'Me-taverse');
        }
      }
    }
    if (_mFaceRatio == null) {
      int faceRatio = 0;
      var image = await SyncFileImage(file: sourcePhoto!).getImage();
      var totalArea = image.image.width * image.image.height;
      FaceDetector detector = FaceDetector(options: FaceDetectorOptions());
      var list = await detector.processImage(InputImage.fromFile(sourcePhoto!));
      int maxFaceArea = 0;
      list.forEach((element) {
        var area = element.boundingBox.width * element.boundingBox.height;
        if (area > maxFaceArea) {
          maxFaceArea = area.toInt();
        }
      });
      detector.close();
      if (maxFaceArea != 0) {
        faceRatio = (totalArea / maxFaceArea).round();
      }
      _mFaceRatio = faceRatio;
    }
    var baseEntity = await api.generateAnotherMe(imageUrl, _mFaceRatio!, cachedId);
    if (baseEntity == null) {
      return null;
    }
    if (baseEntity.images.isEmpty) {
      return null;
    }
    var imageData = baseEntity.images.first;
    var key = EncryptUtil.encodeMd5(imageData);
    var imageUint8List = base64Decode(imageData);
    var storageOperator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
    var name = storageOperator.recordMetaverseDir.path + key + '.png';
    await File(name).writeAsBytes(imageUint8List.toList(), flush: true);
    _transKey = name;
    CartoonizerApi().logAnotherMe({
      'init_images': [imageUrl],
      'face_ratio': _mFaceRatio,
      'result_id': baseEntity.s,
    });
    return TransferResult()..entity = baseEntity;
  }

  Future<bool> _uploadAndSave(
    String key,
    File file,
    UploadImageController uploadImageController, {
    File? sourceFile,
  }) async {
    var uploadResult = await uploadImageController.uploadCompressedImage(file, key: key);
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

  Future<bool> onTakePhoto(
    File file,
    UploadImageController uploadImageController,
    String key,
  ) async {
    _transKey = null;
    update();
    File compressedImage = await imageCompressAndGetFile(file, imageSize: 768);
    return _uploadAndSave(key, compressedImage, uploadImageController, sourceFile: file);
  }
}

class TransferResult {
  AnotherMeResultEntity? entity;
  String? msgTitle;
  String? msgContent;

  TransferResult();
}
