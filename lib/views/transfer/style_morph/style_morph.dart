import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph_screen.dart';

import '../../ai/edition/image_edition.dart';
import '../controller/all_transfer_controller.dart';

class StyleMorph {
  static Future open(BuildContext context, String source, {RecentStyleMorphModel? record, String? initKey}) async {
    ImageEdition.open(context,
        source: source, style: EffectStyle.StyleMorph, function: ImageEditionFunction.effect, initKey: initKey, record: record, cardType: HomeCardType.stylemorph);
    return;
    bool result = await PermissionsUtil.checkPermissions();
    if (result) {
      if (record == null) {
        return _open(context, source, initKey);
      } else {
        return _openFromRecent(context, source, record, initKey);
      }
    } else {
      return PermissionsUtil.permissionDenied(context);
    }
  }

  static Future _open(BuildContext context, String source, String? initKey) async {
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
    Events.styleMorphLoading(source: source);
    RecentController recentController = Get.find<RecentController>();
    List<RecentStyleMorphModel> pickList = recentController.styleMorphList.filter((t) => t.originalPath == path);
    RecentStyleMorphModel pick;
    if (pickList.isNotEmpty) {
      pick = pickList.first;
      for (var value in pickList) {
        if (!pick.itemList.exist((t) => t.key == value.itemList.first.key)) {
          pick.itemList.add(value.itemList.first);
        }
      }
    } else {
      pick = RecentStyleMorphModel()..originalPath = path;
    }
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return StyleMorphScreen(source: source, record: pick, initKey: initKey, photoType: 'gallery');
        },
        settings: RouteSettings(name: '/StyleMorphScreen'),
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
        settings: RouteSettings(name: '/StyleMorphScreen'),
      ),
    );
  }
}
