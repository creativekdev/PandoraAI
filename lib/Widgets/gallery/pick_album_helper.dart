import 'package:cartoonizer/Common/importFile.dart';
import 'package:photo_manager/photo_manager.dart';

class PickAlbumHelper {
  static Future<List<AssetEntity>> getNewest({int reqCount = 20}) async {
    var list = await PhotoManager.getAssetPathList(type: RequestType.image);
    if (list.isEmpty) {
      return [];
    }
    AssetPathEntity? totalAlbum = null;
    for (var value in list) {
      var count = await value.assetCountAsync;
      var totalCount = await totalAlbum?.assetCountAsync;
      if (count > (totalCount ?? 0)) {
        totalAlbum = value;
      }
    }
    if (totalAlbum == null) {
      return [];
    }
    int c = reqCount;
    var totalCount = totalAlbum.assetCountAsync;
    if (await totalCount < c) {
      c = await totalCount;
    }
    return await totalAlbum.getAssetListRange(start: 0, end: c);
  }
}
