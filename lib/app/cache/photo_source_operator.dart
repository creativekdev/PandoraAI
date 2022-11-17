import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:photo_album_manager/photo_album_manager.dart';

class PhotoSourceOperator {
  CacheManager cacheManager;
  List<AlbumModelEntity> faceList = [];
  List<AlbumModelEntity> otherList = [];

  PhotoSourceOperator({required this.cacheManager});

  init() {
    var faceJson = cacheManager.getJson(CacheManager.photoSourceFace) ?? [];
    if (faceJson is List) {
      faceList = faceJson.map((e) => AlbumModelEntity.fromJson(e)).toList();
      faceList = faceList.filter((e) => File(e.thumbPath!).existsSync());
    } else {
      faceList = [];
    }
    var otherJson = cacheManager.getJson(CacheManager.photoSourceOther) ?? [];
    if (otherJson is List) {
      otherList = otherJson.map((e) => AlbumModelEntity.fromJson(e)).toList();
      otherList = otherList.filter((e) => File(e.thumbPath!).existsSync());
    } else {
      otherList = [];
    }
  }

  Future<void> saveData(List<AlbumModelEntity> faceList, List<AlbumModelEntity> otherList) async {
    this.faceList = faceList;
    this.otherList = otherList;
    await cacheManager.setJson(CacheManager.photoSourceFace, faceList.map((e) => e.toJson()).toList());
    await cacheManager.setJson(CacheManager.photoSourceOther, otherList.map((e) => e.toJson()).toList());
  }
}
