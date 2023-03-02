import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_screen.dart';
import 'package:photo_manager/photo_manager.dart';

class AnotherMe {
  static String logoBackTag = 'am_back_logo';
  static String takeItemTag = 'am_take_item';

  static Future<void> open(BuildContext context, {RecentMetaverseEntity? entity, required String source}) async {
    Events.metaverseLoading(source: source);
    return await Navigator.push<void>(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/AnotherMeScreen"),
        builder: (context) => AnotherMeScreen(
          entity: entity,
        ),
      ),
    );
  }

  static Future<bool> checkPermissions() async {
    var values = await [Permission.photos, Permission.microphone, Permission.camera, Permission.storage].request();
    for (var result in values.values) {
      if (result.isDenied || result.isPermanentlyDenied) {
        return false;
      }
    }
    return true;
  }
}
