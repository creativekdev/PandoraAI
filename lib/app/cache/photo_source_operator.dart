import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:photo_gallery/photo_gallery.dart';

class PhotoSourceOperator {
  CacheManager cacheManager;
  List<Medium> faceList = [];
  List<Medium> otherList = [];

  PhotoSourceOperator({required this.cacheManager});

  init() async {
    var faceJson = cacheManager.getJson(CacheManager.photoSourceFace) ?? [];
    if (faceJson is List) {
      faceList = faceJson.map((e) => Medium.fromJson(e)).toList();
      faceList = await faceList.filterSync((e) async {
        try {
          await e.getThumbnail(width: 128, height: 128, highQuality: true);
          return true;
        } catch (exception) {
          return false;
        }
      });
    } else {
      faceList = [];
    }
    var otherJson = cacheManager.getJson(CacheManager.photoSourceOther) ?? [];
    if (otherJson is List) {
      otherList = otherJson.map((e) => Medium.fromJson(e)).toList();
      otherList = await otherList.filterSync((e) async {
        try {
          await e.getThumbnail(width: 128, height: 128, highQuality: true);
          return true;
        } catch (exception) {
          return false;
        }
      });
    } else {
      otherList = [];
    }
  }

  Future<void> saveData(List<Medium> faceList, List<Medium> otherList) async {
    this.faceList = faceList;
    this.otherList = otherList;
    await cacheManager.setJson(
        CacheManager.photoSourceFace,
        faceList.map((e) {
          var map = e.toMap();
          map.remove('creationDate');
          map.remove('modifiedDate');
          return map;
        }).toList());
    await cacheManager.setJson(
        CacheManager.photoSourceOther,
        otherList.map((e) {
          var map = e.toMap();
          map.remove('creationDate');
          map.remove('modifiedDate');
          return map;
        }).toList());
  }
}
