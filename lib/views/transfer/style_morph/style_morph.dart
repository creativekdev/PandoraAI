import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph_screen.dart';

class StyleMorph {
  static Future open(BuildContext context, String source, {RecentStyleMorphModel? record, String? initKey}) async {
    if (record == null) {
      return _open(context, source, initKey);
    } else {
      return _openFromRecent(context, source, record, initKey);
    }
  }

  static Future _open(BuildContext context, String source, String? initKey) async {
    var list = await PickAlbumScreen.pickImage(context, count: 1, switchAlbum: true);
    if (list == null || list.isEmpty) {
      return;
    }
    var first = await list.first.file;
    if (first == null || !first.existsSync()) {
      CommonExtension().showToast('Image not exist');
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await ImageUtils.onImagePick(first.path, cacheManager.storageOperator.recordStyleMorphDir.path);
    Events.styleMorphLoading(source: source);
    RecentController recentController = Get.find<RecentController>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StyleMorphScreen(
            source: source,
            record: recentController.styleMorphList.pick((t) => t.originalPath == path) ?? RecentStyleMorphModel()
              ..originalPath = path,
            initKey: initKey,
            photoType: 'gallery'),
        settings: RouteSettings(name: 'StyleMorphScreen'),
      ),
    );
  }

  static Future _openFromRecent(BuildContext context, String source, RecentStyleMorphModel record, String? initKey) async {
    Events.styleMorphLoading(source: source);
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StyleMorphScreen(
          source: source,
          record: record,
          photoType: 'gallery',
          initKey: initKey,
        ),
        settings: RouteSettings(name: 'StyleMorphScreen'),
      ),
    );
  }
}
