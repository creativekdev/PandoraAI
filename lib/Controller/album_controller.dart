import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:photo_album_manager/photo_album_manager.dart';
import 'package:worker_manager/worker_manager.dart';

class AlbumController extends GetxController {
  late CacheManager cacheManager = AppDelegate.instance.getManager();
  List<AlbumModelEntity> faceList = [];
  List<AlbumModelEntity> otherList = [];
  bool loading = false;
  late StreamSubscription onClearCacheListener;

  @override
  onInit() {
    super.onInit();
    faceList = cacheManager.photoSourceOperator.faceList;
    otherList = cacheManager.photoSourceOperator.otherList;
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
    return PhotoAlbumManager.checkPermissions();
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
        if (!TextUtil.isEmpty(entity.originalPath)) {
          try {
            File file = File(entity.originalPath!);
            var inputImage = InputImage.fromFile(file);
            FaceDetector faceDetector = FaceDetector(options: FaceDetectorOptions());
            List<Face> faces = await faceDetector.processImage(inputImage);
            bool needUpdate = false;
            if (faces.isNotEmpty) {
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
            faceDetector.close();
          } on PlatformException catch (e) {
            LogUtil.e(e.toString(), tag: 'face-detector');
          }
        }
      }
    } else {
      // increase load, loop from last to first, and insert to top at list
      for (int i = list.length - 1; i >= 0; i--) {
        var entity = list[i];
        if (TextUtil.isEmpty(entity.originalPath)) {
          continue;
        }
        if (faceList.exist((t) => t.originalPath == entity.originalPath) || otherList.exist((t) => t.originalPath == entity.originalPath)) {
          continue;
        }
        try {
          File file = File(entity.originalPath!);
          var inputImage = InputImage.fromFile(file);
          FaceDetector faceDetector = FaceDetector(options: FaceDetectorOptions());
          List<Face> faces = await faceDetector.processImage(inputImage);
          if (faces.isNotEmpty) {
            faceList.insert(0, entity);
          } else {
            otherList.insert(0, entity);
          }
          update();
          faceDetector.close();
        } on PlatformException catch (e) {
          LogUtil.e(e.toString(), tag: 'face-detector');
        }
      }
    }
    loading = false;
    update();
    cacheManager.photoSourceOperator.saveData(faceList, otherList);
    return true;
  }
}
