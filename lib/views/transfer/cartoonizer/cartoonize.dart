import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/effect_data_controller.dart';
import 'package:cartoonizer/controller/recent/recent_controller.dart';
import 'package:cartoonizer/widgets/gallery/pick_album.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/ai/edition/image_edition.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/cartoonizer_screen.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';

class Cartoonize {
  static Future open(
    BuildContext context, {
    required String source,
    RecentEffectModel? record,
    String? initKey,
  }) async {
    EffectDataController dataController = Get.find();
    String category = 'cartoonize';
    if (initKey != null) {
      var list = dataController.data?.sticker?.children ?? [];
      for (var value in list) {
        if (category == 'sticker') {
          break;
        }
        for (var key in value.effects) {
          if (key == initKey) {
            category = 'sticker';
            break;
          }
        }
      }
    }
    if (category == 'sticker') {
      bool result = await PermissionsUtil.checkPermissions();
      if (result) {
        if (record == null) {
          return _open(context, source, initKey).then((value) {
            AppDelegate.instance.getManager<UserManager>().refreshUser();
          });
        } else {
          return _openFromRecent(context, source, record, initKey).then((value) {
            AppDelegate.instance.getManager<UserManager>().refreshUser();
          });
        }
      } else {
        return PermissionsUtil.permissionDenied(context);
      }
    } else {
      ImageEdition.open(context,
          source: source, style: EffectStyle.Cartoonizer, function: ImageEditionFunction.effect, initKey: initKey, record: record, cardType: HomeCardType.cartoonize);
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
    var path = await ImageUtils.onImagePick(first.path, cacheManager.storageOperator.recordCartoonizeDir.path);
    Events.facetoonLoading(source: source);
    RecentController recentController = Get.find<RecentController>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartoonizeScreen(
            source: source,
            record: recentController.effectList.pick((t) => t.originalPath == path) ?? RecentEffectModel(category: 'cartoonize')
              ..originalPath = path,
            initKey: initKey,
            photoType: 'gallery'),
        settings: RouteSettings(name: '/CartoonizeScreen'),
      ),
    );
  }

  static Future _openFromRecent(BuildContext context, String source, RecentEffectModel record, String? initKey) async {
    Events.facetoonLoading(source: source);
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CartoonizeScreen(
          source: source,
          record: record,
          photoType: 'gallery',
          initKey: initKey,
        ),
        settings: RouteSettings(name: '/CartoonizeScreen'),
      ),
    );
  }
}
