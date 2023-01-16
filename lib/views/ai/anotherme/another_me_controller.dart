import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class AnotherMeController extends GetxController {
  File? _sourcePhoto;

  File? get sourcePhoto => _sourcePhoto;

  clear(UploadImageController uploadImageController) {
    uploadImageController.updateImageUrl('');
    _sourcePhoto = null;
    _transKey = null;
    _mFaceRatio = null;
    update();
  }

  String? _transKey;

  String? get transKey => _transKey;

  clearTransKey() {
    _transKey = null;
    update();
  }

  Map _initialConfig = {};

  set initialConfig(Map config) {
    _initialConfig = config;
    update();
  }

  Map get initialConfig => _initialConfig;

  late Uploader api;
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
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
  }

  bool hasChoosePhoto() => _sourcePhoto != null;

  bool hasTransRecord() => _transKey != null;

  Future<bool> startTransfer(String imageUrl) async {
    if (TextUtil.isEmpty(imageUrl)) {
      return false;
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
    var baseEntity = await api.generateAnotherMe(imageUrl, _mFaceRatio!);
    if (baseEntity == null) {
      return false;
    }
    if (baseEntity.images.isEmpty) {
      return false;
    }
    var imageData = baseEntity.images.first;
    var key = EncryptUtil.encodeMd5(imageData);
    var imageUint8List = base64Decode(imageData);
    var storageOperator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
    var name = storageOperator.imageDir.path + key + '.png';
    await File(name).writeAsBytes(imageUint8List.toList(), flush: true);
    _transKey = name;
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

  Future<bool> onTakePhoto(
    XFile image,
    UploadImageController uploadImageController,
  ) async {
    _transKey = null;
    update();
    var file = File(image.path);
    File compressedImage = await imageCompressAndGetFile(file, imageSize: 768);
    return _uploadAndSave(compressedImage, uploadImageController, sourceFile: file);
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
    File compressedImage = await imageCompressAndGetFile(file, imageSize: 768);
    return _uploadAndSave(compressedImage, uploadImageController, sourceFile: file);
  }

  Future<bool> pickFromRecent(UploadRecordEntity record, UploadImageController uploadImageController) async {
    var file = File(record.fileName);
    return _uploadAndSave(file, uploadImageController);
  }

  Future<bool> pickFromAiSource(File file, UploadImageController uploadImageController) async {
    File compressedImage = await imageCompressAndGetFile(file, imageSize: 768);
    return _uploadAndSave(compressedImage, uploadImageController, sourceFile: file);
  }
}
