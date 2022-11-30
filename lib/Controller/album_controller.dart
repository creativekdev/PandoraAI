import 'dart:io';
import 'dart:math';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:photo_album_manager/photo_album_manager.dart';

class AlbumController extends GetxController {
  late CacheManager cacheManager = AppDelegate.instance.getManager();
  List<AlbumModelEntity> faceList = [];
  List<AlbumModelEntity> otherList = [];
  bool loading = false;
  late StreamSubscription onClearCacheListener;
  PermissionStatus? permissionStatus;

  @override
  onInit() {
    super.onInit();
    faceList = cacheManager.photoSourceOperator.faceList.filter((e) => File(e.thumbPath!).existsSync());
    otherList = cacheManager.photoSourceOperator.otherList.filter((e) => File(e.thumbPath!).existsSync());
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

  Future<PermissionStatus> checkPermissions() async {
    if (permissionStatus == null || permissionStatus != PermissionStatus.granted) {
      permissionStatus = await PhotoAlbumManager.checkPermissions();
    }
    return permissionStatus!;
  }

  Future<bool> syncFromAlbum() async {
    if (loading) {
      return false;
    }
    loading = true;
    update();
    int reqCount = 50;
    var firstLoad = faceList.isEmpty && otherList.isEmpty;
    if (firstLoad) {
      reqCount = 100;
    }
    List<AlbumModelEntity> list = await PhotoAlbumManager.getDescAlbumImg(maxCount: reqCount);
    if (firstLoad) {
      // first load, just add to list
      for (AlbumModelEntity entity in list) {
        bool needUpdate = false;
        var faceImage = await hasFace(entity);
        if (faceImage) {
          faceList.add(entity);
          if (faceList.length % 20 == 0) {
            needUpdate = true;
          }
        } else {
          otherList.add(entity);
          if (otherList.length % 20 == 0) {
            needUpdate = true;
          }
        }
        if (needUpdate) {
          update();
          await cacheManager.photoSourceOperator.saveData(faceList, otherList);
        }
      }
    } else {
      // increase load, loop from last to first, and insert to top at list
      for (int i = list.length - 1; i >= 0; i--) {
        var entity = list[i];
        var cropHomePath = cacheManager.storageOperator.cropDir.path;
        var newThumbnailPath = cropHomePath + EncryptUtil.encodeMd5(entity.originalPath!) + '.png';
        if (faceList.exist((t) => t.thumbPath == newThumbnailPath) || otherList.exist((t) => t.thumbPath == newThumbnailPath)) {
          continue;
        }
        var faceImage = await hasFace(entity);
        if (faceImage) {
          faceList.insert(0, entity);
        } else {
          otherList.insert(0, entity);
        }
        update();
      }
    }
    loading = false;
    update();
    cacheManager.photoSourceOperator.saveData(faceList, otherList);
    return true;
  }

  /// check face image,
  /// crop new thumbnail base on face if has,
  /// crop centre pos base on image if not.
  Future<bool> hasFace(AlbumModelEntity entity) async {
    try {
      if (Platform.isIOS) {
        File file = File(entity.thumbPath!);
        InputImage inputImage = InputImage.fromFile(file);
        FaceDetector faceDetector = FaceDetector(options: FaceDetectorOptions());
        List<Face> faces = await faceDetector.processImage(inputImage);
        faceDetector.close();
        return pickAvailableFace(faces) != null;
      }
      if (TextUtil.isEmpty(entity.originalPath)) {
        var albumModelEntity = await PhotoAlbumManager.getOriginalResource(entity.localIdentifier!);
        if (albumModelEntity == null || TextUtil.isEmpty(albumModelEntity.originalPath)) {
          throw Exception('has no original image');
        }
        entity.originalPath = albumModelEntity.originalPath;
      }
      File file = File(entity.originalPath!);
      InputImage inputImage = InputImage.fromFile(file);
      FaceDetector faceDetector = FaceDetector(options: FaceDetectorOptions());
      List<Face> faces = await faceDetector.processImage(inputImage);
      faceDetector.close();
      if (!TextUtil.isEmpty(entity.thumbPath)) {
        File(entity.thumbPath!).delete();
      }
      var imageInfo = await SyncFileImage(file: file).getImage();
      var image = imageInfo.image;
      var cropHomePath = cacheManager.storageOperator.cropDir.path;
      var newThumbnailPath = cropHomePath + EncryptUtil.encodeMd5(entity.originalPath!) + ".png";
      var newThumbnailFile = File(newThumbnailPath);
      entity.thumbPath = newThumbnailPath;
      var face = pickAvailableFace(faces);
      if (newThumbnailFile.existsSync()) {
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
        if (min(targetWidth, targetHeight) > 512) {
          double cropPercent = 512 / min(targetWidth, targetHeight);
          savedImageData = await FlutterImageCompress.compressWithList(
            imageData,
            minWidth: 512,
            minHeight: 512,
            quality: (cropPercent * 100).toInt(),
          );
        } else {
          savedImageData = imageData;
        }
        await newThumbnailFile.writeAsBytes(savedImageData.toList());
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
        if (min(image.width, image.height) > 512) {
          //bigger than 512, compress image property
          double cropPercent = 512 / newImageSize;
          savedImageData = await FlutterImageCompress.compressWithList(
            imageData,
            minWidth: 512,
            minHeight: 512,
            quality: (cropPercent * 100).toInt(),
          );
        } else {
          savedImageData = imageData;
        }
      }
      await newThumbnailFile.writeAsBytes(savedImageData.toList(), flush: true);
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
}
