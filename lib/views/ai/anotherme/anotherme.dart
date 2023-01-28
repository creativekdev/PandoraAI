import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_screen.dart';

class AnotherMe {
  static String logoBackTag = 'am_back_logo';
  static String takeItemTag = 'am_take_item';

  static Future<bool> open(BuildContext context) async {
    var bool = await _checkPermissions();
    if (!bool) {
      return false;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/AnotherMeScreen"),
        builder: (context) => AnotherMeScreen(),
      ),
    );
    return true;
  }

  static Future<bool> _checkPermissions() async {
    var values = await [Permission.photos, Permission.camera, Permission.storage].request();
    for (var result in values.values) {
      if (result.isDenied || result.isPermanentlyDenied) {
        CommonExtension().showToast('Please grant all permissions');
        return false;
      }
    }
    return true;
  }
}
