import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_screen.dart';

class AnotherMe {
  static String logoBackTag = 'am_back_logo';
  static String takeItemTag = 'am_take_item';

  static Future open(BuildContext context) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/AnotherMeScreen"),
        builder: (context) => AnotherMeScreen(),
      ),
    );
  }
}
