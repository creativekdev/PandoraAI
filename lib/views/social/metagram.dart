import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/Widgets/connector/platform_connector_page.dart';
import 'package:cartoonizer/Widgets/image/sync_download_video.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';

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
          var url = effectDataController.data!.promotionResources.first.url!;
          var fileName = EncryptUtil.encodeMd5(url);
          var type = getFileType(url);
          var storageOperator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
          var videoDir = storageOperator.videoDir;
          var savePath = videoDir.path + fileName + '.' + type;
          if (!File(savePath).existsSync()) {
            await SyncDownloadVideo(url: url, type: type).getVideo();
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
