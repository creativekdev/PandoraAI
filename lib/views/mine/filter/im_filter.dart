import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/camera/pai_camera_screen.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/utils/img_utils.dart';

import '../../../Common/Extension.dart';
import '../../../Widgets/gallery/pick_album.dart';
import 'im_effect_screen.dart';
import 'im_filter_screen.dart';

class ImFilter {

  static Future open(BuildContext context, {required TABS tab, required String source}) async {
    Events.imEditionLoading(source: source);
    var paiCameraEntity = await PAICamera.takePhoto(context);
    if (paiCameraEntity == null) {
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await ImageUtils.onImagePick(paiCameraEntity.xFile.path, cacheManager.storageOperator.tempDir.path);
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ImFilterScreen"),
        builder: (context) => ImFilterScreen(
          filePath: path,
          tab: tab,
        ),
      ),
    ).then((value) {
      AppDelegate.instance.getManager<UserManager>().refreshUser();
    });
  }

  static Future openEffectWithCamera(BuildContext context, {required TABS tab, required String source}) async {
    Events.imEditionLoading(source: source);
    var paiCameraEntity = await showPhotoTakeDialog(context);
    if (paiCameraEntity == null) {
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await ImageUtils.onImagePick(paiCameraEntity.xFile.path, cacheManager.storageOperator.tempDir.path);
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ImEffectScreen"),
        builder: (context) => ImEffectScreen(
          originFile: File(path),
          resultFile: File(path),
          source: source,
          photoType: 'camera',
        ),
      ),
    ).then((value) {
      AppDelegate.instance.getManager<UserManager>().refreshUser();
    });
  }

  static Future openEffectWithPhoto(BuildContext context, {required TABS tab, required String source}) async {
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
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImEffectScreen(
          originFile: File(path),
          resultFile: File(path),
          source: source,
          photoType: 'gallery',
        ),
        settings: RouteSettings(name: '/ImEffectScreen'),
      ),
    );
  }
}

typedef OnCallback = void Function();

const String EffectImageViewTag = "EffectImageViewTag";
const String EffectInOutControlPadTag = "EffectInOutControlPadTag";

enum TABS { EFFECT, FILTER, ADJUST, CROP, BACKGROUND, TEXT }
