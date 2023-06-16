import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/drawable/colorfill/ai_coloring_screen.dart';

class AiColoring {
  static Future open(BuildContext context, {RecentColoringEntity? record, required String source}) async {
    bool result = await AnotherMe.checkPermissions();
    if (result) {
      if (record == null) {
        return _open(context, source);
      } else {
        return _openFromRecent(context, source, record);
      }
    } else {
      return AnotherMe.permissionDenied(context);
    }
  }

  static Future _open(BuildContext context, String source) async {
    var list = await PickAlbumScreen.pickImage(context, count: 1, switchAlbum: true);
    if (list == null || list.isEmpty) {
      return;
    }
    var first = await list.first.originFile;
    if (first == null || !first.existsSync()) {
      CommonExtension().showToast('Image not exist');
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await ImageUtils.onImagePick(first.path, cacheManager.storageOperator.recordStyleMorphDir.path);
    Events.aiColoringLoading(source: source);
    return Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/AiColoringScreen"),
      builder: (_) => AiColoringScreen(
        source: source,
        record: RecentColoringEntity()
          ..originFilePath = path
          ..updateDt = DateTime.now().millisecondsSinceEpoch,
        photoType: 'gallery',
      ),
    ));
  }

  static Future _openFromRecent(BuildContext context, String source, RecentColoringEntity record) async {
    Events.aiColoringLoading(source: source);
    return Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: 'AiColoringScreen'),
        builder: (_) => AiColoringScreen(
          source: source,
          record: record,
          photoType: 'gallery',
        ),
      ),
    );
  }
}