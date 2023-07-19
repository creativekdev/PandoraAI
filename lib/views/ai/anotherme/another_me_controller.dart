import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/another_me_result_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';

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
  late AppApi appApi;
  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  bool get viewInit => _viewInit;

  @override
  void onInit() {
    super.onInit();
    api = Uploader().bindController(this);
    appApi = AppApi().bindController(this);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    appApi.unbind();
  }

  bool hasChoosePhoto() => _sourcePhoto != null;

  bool hasTransRecord() => _transKey != null;

  Future<TransferResult?> startTransfer(String imageUrl, String? cachedId, onFailed) async {
    if (TextUtil.isEmpty(imageUrl)) {
      return null;
    }
    var metaverseLimitEntity = await appApi.getMetaverseLimit();
    if (metaverseLimitEntity != null) {
      if (metaverseLimitEntity.usedCount >= metaverseLimitEntity.dailyLimit) {
        if (AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
          return TransferResult()..type = AccountLimitType.guest;
        } else if (isVip()) {
          return TransferResult()..type = AccountLimitType.vip;
        } else {
          return TransferResult()..type = AccountLimitType.normal;
        }
      }
    }
    var baseEntity = await api.generateAnotherMe(imageUrl, cachedId, onFailed);
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
    AppApi().logAnotherMe({
      'init_images': [imageUrl],
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
  AccountLimitType? type;

  TransferResult();
}
