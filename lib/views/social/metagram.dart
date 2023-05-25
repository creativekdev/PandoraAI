import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/Widgets/connector/platform_connector_page.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';

import 'metagram_introduce_screen.dart';
import 'metagram_screen.dart';

class Metagram {
  static Future<void> openBySelf(
    BuildContext context, {
    required String source,
  }) async {
    UserManager userManager = AppDelegate().getManager();
    var hasIgConnection = userManager.platformConnections.containsKey(ConnectorPlatform.instagram);
    if (hasIgConnection) {
      var coreUserId = userManager.platformConnections[ConnectorPlatform.instagram]?.first.coreUserId;
      Navigator.of(context).push(MaterialPageRoute(
        settings: RouteSettings(name: "/MetagramScreen"),
        builder: (context) => MetagramScreen(
          source: source,
          coreUserId: coreUserId,
        ),
      ));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(
        settings: RouteSettings(name: "/MetagramIntroduceScreen"),
        builder: (context) => MetagramIntroduceScreen(),
      ))
          .then((value) {
        if (value) {
          openBySelf(context, source: source);
        }
      });

    }
  }

  static Future<void> open(
    BuildContext context, {
    required String source,
    required SocialPostPageEntity socialPostPage,
  }) async {
    Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/MetagramScreen"),
      builder: (context) => MetagramScreen(
        source: source,
        coreUserId: socialPostPage.coreUserId,
      ),
    ));
  }
}
