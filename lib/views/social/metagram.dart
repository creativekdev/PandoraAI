import 'package:cartoonizer/controller/effect_data_controller.dart';
import 'package:cartoonizer/widgets/auth/connector_platform.dart';
import 'package:cartoonizer/widgets/image/sync_download_video.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/utils/utils.dart';

import 'metagram_introduce_screen.dart';
import 'metagram_screen.dart';

class Metagram {
  static void openBySelf(
    BuildContext context, {
    required String source,
  }) {
    UserManager userManager = AppDelegate().getManager();
    userManager.doOnLogin(context, logPreLoginAction: 'pre_open_metagram_action', callback: () async {
      var hasIgConnection = userManager.platformConnections.containsKey(ConnectorPlatform.instagram);
      if (hasIgConnection) {
        var coreUserId = userManager.platformConnections[ConnectorPlatform.instagram]?.first.coreUserId;
        Events.metagramLoading(source: source);
        Navigator.of(context).push(MaterialPageRoute(
          settings: RouteSettings(name: "/MetagramScreen"),
          builder: (context) => MetagramScreen(
            source: source,
            coreUserId: coreUserId!,
            isSelf: true,
          ),
        ));
      } else {
        EffectDataController effectDataController = Get.find<EffectDataController>();
        if (effectDataController.data?.promotionResources.isNotEmpty ?? false) {
          var resource = effectDataController.data!.promotionResources.first;
          if (resource.type == DiscoveryResourceType.video) {
            await SyncDownloadVideo(type: getFileType(resource.url ?? ''), url: resource.url ?? '').getVideo();
          }
        }
        Navigator.of(context)
            .push<bool>(MaterialPageRoute(
          settings: RouteSettings(name: "/MetagramIntroduceScreen"),
          builder: (context) => MetagramIntroduceScreen(source: source),
        ))
            .then((value) {
          if (value ?? false) {
            openBySelf(context, source: source);
          }
        });
      }
    }, autoExec: true);
  }

  static Future<void> open(
    BuildContext context, {
    required String source,
    required SocialPostPageEntity socialPostPage,
  }) async {
    UserManager userManager = AppDelegate().getManager();
    var hasIgConnection = userManager.platformConnections.containsKey(ConnectorPlatform.instagram);
    int? coreUserId;
    if (hasIgConnection) {
      coreUserId = userManager.platformConnections[ConnectorPlatform.instagram]?.first.coreUserId;
    }
    Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/MetagramScreen"),
      builder: (context) => MetagramScreen(
        source: source,
        coreUserId: socialPostPage.coreUserId!,
        isSelf: coreUserId == socialPostPage.coreUserId,
      ),
    ));
  }
}
