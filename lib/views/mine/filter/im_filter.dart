import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/mine/filter/ImFilterScreen.dart';

class ImFilter {

  static Future open(BuildContext context) async {
    // Events.facetoonLoading(source: source);
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ImFilterScreen"),
        builder: (context) =>
            ImFilterScreen(),
      ),
    ).then((value) {
      AppDelegate.instance.getManager<UserManager>().refreshUser();
    });
  }
}
