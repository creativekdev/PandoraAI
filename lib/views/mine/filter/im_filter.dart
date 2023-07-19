import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/camera/pai_camera_screen.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/views/mine/filter/ImFilterScreen.dart';

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
}
