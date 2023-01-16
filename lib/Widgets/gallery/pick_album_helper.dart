import 'package:cartoonizer/Common/importFile.dart';
import 'package:photo_gallery/photo_gallery.dart';

class PickAlbumHelper {
  static Future<List<Medium>> getNewest({int reqCount = 20}) async {
    var list = await PhotoGallery.listAlbums(mediumType: MediumType.image);
    if (list.isEmpty) {
      return [];
    }
    var cameraAlbum = list.pick((t) => (t.name ?? '').toLowerCase().contains('camera'));
    Album? totalAlbum = null;
    if (cameraAlbum != null) {
      totalAlbum = cameraAlbum;
    } else {
      for (var value in list) {
        if (value.count > (totalAlbum?.count ?? 0)) {
          totalAlbum = value;
        }
      }
    }
    if (totalAlbum == null) {
      return [];
    }
    int c = reqCount;
    if (totalAlbum.count < c) {
      c = totalAlbum.count;
    }
    var mediaPage = await totalAlbum.listMedia(take: c);
    return mediaPage.items;
  }
}
