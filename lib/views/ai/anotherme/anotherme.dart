import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_screen.dart';

class AnotherMe {
  static String logoBackTag = 'am_back_logo';
  static String takeItemTag = 'am_take_item';

  static Future<void> open(BuildContext context) async {
    return await Navigator.push<void>(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/AnotherMeScreen"),
        builder: (context) => AnotherMeScreen(),
      ),
    );
  }

  static Future<bool> checkPermissions() async {
    var values = await [Permission.photos, Permission.microphone, Permission.camera, Permission.storage].request();
    for (var result in values.values) {
      if (result.isDenied || result.isPermanentlyDenied) {
        CommonExtension().showToast('Please grant all permissions');
        return false;
      }
    }
    return true;
  }
}
