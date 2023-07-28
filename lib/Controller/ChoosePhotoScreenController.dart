import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/crop_record_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart' as path;

const int axisOffset = 20;
const double expandPercent = 0.20;

@Deprecated('弃用，人脸识别等待后续重新实现')
class ChoosePhotoScreenController extends GetxController {
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StorageOperator storageOperator;
  Map<String, CropRecordEntity> cropRecordCache = {};
  var faceDetector = FaceDetector(options: FaceDetectorOptions());

  @override
  Future<void> onInit() async {
    super.onInit();
    storageOperator = cacheManager.storageOperator;
    loadCropCache();
  }

  @override
  dispose() {
    faceDetector.close();
    super.dispose();
  }

  Future<void> loadCropCache() async {
    cropRecordCache.clear();
    dynamic jsonString = cacheManager.getJson(CacheManager.imageCropHistory) ?? [];
    if (jsonString is Map) {
      jsonString.forEach((key, value) async {
        var cropRecordEntity = CropRecordEntity.fromJson(json.decode(value));
        var file = File(cropRecordEntity.fileName);
        if (file.existsSync()) {
          cropRecordCache[key] = cropRecordEntity;
        }
      });
    }
  }

  void _saveCropCacheMap() {
    Map<String, String> cache = {};
    cropRecordCache.forEach((key, value) {
      cache[key] = json.encode(value.toJson());
    });
    cacheManager.setJson(CacheManager.imageCropHistory, cache);
  }

  final isPhotoSelect = false.obs;

  changeIsPhotoSelect(bool value) => isPhotoSelect.value = value;

  final isVideo = false.obs;

  changeIsVideo(bool value) => isVideo.value = value;

  final isPhotoDone = false.obs;

  changeIsPhotoDone(bool value) => isPhotoDone.value = value;

  final isChecked = false.obs;

  changeIsChecked(bool value) => isChecked.value = value;

  final isLoading = false.obs;

  changeIsLoading(bool value) => isLoading.value = value;

  final transingImage = false.obs;

  changeTransingImage(bool value) => transingImage.value = value;

  // @deprecated
  // final lastSelectedIndex = 0.obs;
  // setLastSelectedIndex(int i) => lastSelectedIndex.value = i;
  //
  // @deprecated
  // final lastItemIndex = 0.obs;
  // setLastItemIndex(int i) => lastItemIndex.value = i;
  //
  // @deprecated
  // final lastItemIndex1 = 0.obs;
  // setLastItemIndex1(int i) => lastItemIndex1.value = i;

  final Rx<File?> image = (null as File?).obs;

  updateImageFile(File lFile) => image.value = lFile;

  final Rx<File?> cropImage = (null as File?).obs;

  updateCropImageFile(File cFile) => cropImage.value = cFile;

  final videoFile = (null as File?).obs;

  updateVideoFile(File file) => videoFile.value = file;
  final videoUrl = "".obs;

  updateVideoUrl(String str) => videoUrl.value = str;

  final imageUrl = "".obs;

  updateImageUrl(String str) => imageUrl.value = str;

  buildCropFile() async {
    var file = image.value;
    if (file == null) {
      return;
    }
    var key = await md5File(file);
    var inputImage = InputImage.fromFile(file);
    List<Face> faceList = await faceDetector.processImage(inputImage);
    if (faceList.isEmpty) {
      return;
    }
    var first = faceList.first;
    List<int> cropList = [
      first.boundingBox.left.toInt(),
      first.boundingBox.top.toInt(),
      first.boundingBox.right.toInt(),
      first.boundingBox.bottom.toInt(),
    ];
    String f_name = path.basename(file.path);
    var newPath = "${storageOperator.cropDir.path}/$f_name";
    if (File(newPath).existsSync()) {
      var cache = cropRecordCache[key];
      if (cache != null) {
        if (cropEquals(cache.cropList, cropList)) {
          updateCropImageFile(File(cache.fileName));
          return;
        }
      }
    }
    var resolve = FileImage(file).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      var imageInfo = image.image;
      List<int> crops = cropList;
      int width = cropList[2] - cropList[0];
      int height = cropList[3] - cropList[1];
      var i = width - height;
      if ((i) > axisOffset) {
        crops[0] = cropList[0] + i ~/ 2;
        crops[2] = cropList[2] - i ~/ 2;
      } else if (i < -axisOffset) {
        crops[1] = cropList[1] - i ~/ 2;
        crops[3] = cropList[3] + i ~/ 2;
      }
      execCropFile([...crops], imageInfo, newPath, key, cropList, expandPercent);
    }));
  }

  void execCropFile(List<int> crops, ui.Image imageInfo, String newPath, String key, List<int> cropList, double percent) {
    int correctWidth = crops[2] - crops[0];
    int correctHeight = crops[3] - crops[1];
    int expandVerticalSize = (correctWidth * percent).toInt();
    int expandHorizontalSize = (correctHeight * percent).toInt();
    crops[0] = crops[0] - (crops[0] > expandVerticalSize ? expandVerticalSize : crops[0]);
    crops[1] = crops[1] - (crops[1] > expandHorizontalSize ? expandHorizontalSize : crops[1]);
    if (crops[2] < imageInfo.width - expandVerticalSize) {
      crops[2] += expandVerticalSize;
    } else {
      crops[2] = imageInfo.width;
    }
    if (crops[3] < imageInfo.height - expandHorizontalSize) {
      crops[3] += expandHorizontalSize;
    } else {
      crops[3] = imageInfo.height;
    }
    cropFileToTarget(imageInfo, Rect.fromLTRB(crops[0].toDouble(), crops[1].toDouble(), crops[2].toDouble(), crops[3].toDouble()), newPath).then((file) {
      updateCropImageFile(file);
      cropRecordCache[key] = CropRecordEntity(fileName: newPath, cropList: cropList);
      _saveCropCacheMap();
    });
  }

  bool cropEquals(List<int> oldList, List<int> newList) {
    if (newList.length != 4) {
      return false;
    }
    if (newList[0] == oldList[0] && newList[1] == oldList[1] && newList[2] == oldList[2] && newList[3] == oldList[3]) {
      return true;
    }
    return false;
  }

  Future<void> saveOriginalIfNotExist() async {
    if (image.value == null) {
      return;
    }
    var value = image.value as File;
    var dirPath = cacheManager.storageOperator.recordCartoonizeDir.path;
    if (value.path.contains(dirPath)) {
      return;
    }
    var fileName = EncryptUtil.encodeMd5(value.path);
    var path = dirPath + fileName + '.' + getFileType(value.path);
    var result = File(path);
    var bool = await result.exists();
    if (bool) {
      updateImageFile(result);
      return;
    }
    await value.copy(path);
    updateImageFile(result);
  }
}
