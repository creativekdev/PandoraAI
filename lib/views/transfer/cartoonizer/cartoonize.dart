import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/recent_entity.dart';

import 'ChoosePhotoScreen.dart';

class Cartoonize {
  static Future open(
    BuildContext context, {
    required String source,
    int tabPos = 0,
    int categoryPos = 0,
    int itemPos = 0,
    RecentEffectModel? recentEffectModel,
  }) async {
    Events.facetoonLoading(source: source);
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(
          tabPos: tabPos,
          pos: categoryPos,
          itemPos: itemPos,
          recentEffectModel: recentEffectModel,
        ),
      ),
    ).then((value) {
      AppDelegate.instance.getManager<UserManager>().refreshUser();
    });
  }
}
