import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumController extends GetxController {
  late CacheManager cacheManager = AppDelegate.instance.getManager();
  List<AssetEntity> faceList = [];
  List<AssetEntity> otherList = [];
  int pageSize = 100;
  bool loading = false;
  late StreamSubscription onClearCacheListener;
  AssetPathEntity? album;

  @override
  onInit() {
    super.onInit();
    // faceList = cacheManager.photoSourceOperator.faceList;
    // otherList = cacheManager.photoSourceOperator.otherList;
    onClearCacheListener = EventBusHelper().eventBus.on<OnClearCacheEvent>().listen((event) {
      faceList.clear();
      otherList.clear();
      update();
    });
  }

  @override
  dispose() {
    super.dispose();
    onClearCacheListener.cancel();
  }

  Future<AssetPathEntity?> getTotalAlbum() async {
    if (album != null) return album;
    List<AssetPathEntity> list = await PhotoManager.getAssetPathList(type: RequestType.image);
    AssetPathEntity? a;
    for (var value in list) {
      var valueCount = await value.assetCountAsync;
      var oldCount = await a?.assetCountAsync;
      if (valueCount >= (oldCount ?? 0)) {
        a = value;
      }
    }
    album = a;
    return a;
  }

  Future<bool> loadData() async {
    if (album == null || loading) {
      return false;
    }
    var takenCount = faceList.length + otherList.length;
    var count = await album!.assetCountAsync;
    if (takenCount >= count) {
      return false;
    }
    loading = true;
    update();
    List<AssetEntity> mediaPage;
    if (takenCount > count - pageSize) {
      mediaPage = await album!.getAssetListRange(start: takenCount, end: count - takenCount);
    } else {
      mediaPage = await album!.getAssetListRange(start: takenCount, end: pageSize);
    }
    for (var value in mediaPage) {
      bool needUpdate = false;
      var faceImage = await hasFace(value);
      if (faceImage) {
        faceList.add(value);
        if (faceList.length % 20 == 0) {
          needUpdate = true;
        }
      } else {
        otherList.add(value);
        if (otherList.length % 20 == 0) {
          needUpdate = true;
        }
      }
      if (needUpdate) {
        update();
        await cacheManager.photoSourceOperator.saveData(faceList, otherList);
      }
    }
    loading = false;
    update();
    return true;
  }

  /// check face image,
  /// crop new thumbnail base on face if has,
  /// crop centre pos base on image if not.
  Future<bool> hasFace(AssetEntity entity) async {
    try {
      var bytes = await entity.thumbnailDataWithSize(ThumbnailSize(512, 512), quality: 100);
      var tempImage = getTempImage(entity);
      if (!tempImage.existsSync()) {
        await tempImage.writeAsBytes(bytes!);
      }
      InputImage inputImage = InputImage.fromFile(tempImage);
      FaceDetector faceDetector = FaceDetector(options: FaceDetectorOptions());
      List<Face> faces = await faceDetector.processImage(inputImage);
      faceDetector.close();
      var imageInfo = await SyncFileImage(file: tempImage).getImage();
      var image = imageInfo.image;
      var thumbnail = getThumbnail(entity);
      var face = pickAvailableFace(faces);
      if (thumbnail.existsSync()) {
        //has crop already
        return face != null;
      }
      Uint8List savedImageData;
      if (face != null) {
        var boundingBox = face.boundingBox;
        var centrePos = Offset((boundingBox.right + boundingBox.left) / 2, (boundingBox.bottom + boundingBox.top) / 2);
        var targetWidth = boundingBox.width * 1.5;
        var targetHeight = boundingBox.height * 1.5;
        if (centrePos.dx - targetWidth / 2 < 0) {
          targetWidth = centrePos.dx * 2;
        } else if (centrePos.dx + targetWidth / 2 > image.width) {
          targetWidth = (image.width - centrePos.dx) * 2;
        }
        if (centrePos.dy - targetHeight / 2 < 0) {
          targetHeight = centrePos.dy * 2;
        } else if (centrePos.dy + targetHeight / 2 > image.height) {
          targetHeight = (image.height - centrePos.dy) * 2;
        }
        Rect rect = Rect.fromLTWH(centrePos.dx - targetWidth / 2, centrePos.dy - targetHeight / 2, targetWidth, targetHeight);
        Uint8List imageData = await cropFile(image, rect);
        savedImageData = imageData;
        await thumbnail.writeAsBytes(savedImageData.toList());
      } else {
        // crop base on centre pos
        Rect rect;
        var newImageSize;
        var offset = ((image.width - image.height) / 2).abs();
        if (image.width > image.height) {
          newImageSize = image.height;
          rect = Rect.fromLTWH(offset, 0, newImageSize.toDouble(), newImageSize.toDouble());
        } else {
          newImageSize = image.width;
          rect = Rect.fromLTWH(0, offset, newImageSize.toDouble(), newImageSize.toDouble());
        }
        Uint8List imageData = await cropFile(image, rect);
        savedImageData = imageData;
      }
      await thumbnail.writeAsBytes(savedImageData.toList(), flush: true);
      return face != null;
    } on PlatformException catch (e) {
      LogUtil.e(e.toString(), tag: 'face-detector');
      return false;
    } catch (e) {
      LogUtil.e(e.toString(), tag: 'face-detector');
      return false;
    }
  }

  Face? pickAvailableFace(List<Face> list) {
    Face? result;
    for (var value in list) {
      var angleX = (value.headEulerAngleX ?? 0).abs();
      var angleY = (value.headEulerAngleY ?? 0).abs();
      var angleZ = (value.headEulerAngleZ ?? 0).abs();
      if (angleX < 15 && angleY < 15 && angleZ < 15) {
        result = value;
        break;
      }
    }
    return result;
  }

  File getThumbnail(AssetEntity medium) {
    var cropHomePath = cacheManager.storageOperator.cropDir.path;
    var newThumbnailPath = cropHomePath + EncryptUtil.encodeMd5(medium.id) + ".png";
    return File(newThumbnailPath);
  }

  File getTempImage(AssetEntity medium) {
    var tempHomePath = cacheManager.storageOperator.tempDir.path;
    var newPath = tempHomePath + EncryptUtil.encodeMd5(medium.id) + ".png";
    return File(newPath);
  }
}
