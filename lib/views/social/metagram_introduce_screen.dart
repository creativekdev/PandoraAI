import 'dart:io';

import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/Widgets/connector/platform_connector_page.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class MetagramIntroduceScreen extends StatefulWidget {
  const MetagramIntroduceScreen({Key? key}) : super(key: key);

  @override
  State<MetagramIntroduceScreen> createState() => _MetagramIntroduceScreenState();
}

class _MetagramIntroduceScreenState extends State<MetagramIntroduceScreen> {
  File? file;
  bool onCompleted = false;

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'metagram_introduce_screen');
    EffectDataController effectDataController = Get.find<EffectDataController>();
    if (effectDataController.data?.promotionResources.isNotEmpty ?? false) {
      var url = effectDataController.data!.promotionResources.first.url!;
      var fileName = EncryptUtil.encodeMd5(url);
      var type = getFileType(url);
      var storageOperator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
      var videoDir = storageOperator.videoDir;
      var savePath = videoDir.path + fileName + '.' + type;
      var videoFile = File(savePath);
      if (videoFile.existsSync()) {
        file = videoFile;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          Positioned(
            child: EffectVideoPlayer(
              url: file!.path,
              isFile: true,
              loop: false,
              onCompleted: () {
                if (mounted) {
                  delay(() {
                    setState(() {
                      onCompleted = true;
                    });
                  });
                }
              },
            ).visibility(visible: file != null && !onCompleted),
            top: 0,
            right: 0,
            left: 0,
          ),
          Positioned(
            child: Image.asset(
              Images.ic_metagram_intro_bg,
              width: ScreenUtil.screenSize.width,
              fit: BoxFit.cover,
            ).visibility(visible: file == null || onCompleted),
            top: 0,
            right: 0,
            left: 0,
          ),
          Positioned(
            child: Container(
              color: Colors.black,
              height: $(143),
            ),
            bottom: 0,
            left: 0,
            right: 0,
          ),
          Positioned(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleTextWidget('Metagram', Color(0xFFFFE674), FontWeight.normal, $(12)).visibility(visible: onCompleted),
                SizedBox(height: $(4)),
                TitleTextWidget('Anime-fy your Instagram posts!', Colors.white, FontWeight.normal, $(20), maxLines: 3)
                    .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(60)))
                    .visibility(visible: onCompleted),
                Container(
                  height: $(50),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00000000),
                        Color(0x99000000),
                        Color(0xff000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                TitleTextWidget('Connect IG biz account', Colors.black, FontWeight.normal, $(16))
                    .intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular($(32))),
                )
                    .intoGestureDetector(onTap: () {
                  PlatformConnectorPage.push(context, platform: ConnectorPlatform.instagramBusiness).then((value) {
                    if (value ?? false) {
                      Navigator.of(context).pop(value);
                    }
                  });
                }).intoContainer(color: Colors.black, width: ScreenUtil.screenSize.width, padding: EdgeInsets.only(left: $(26), right: $(26), top: $(35))),
                TitleTextWidget('Connect IG personal account', Colors.white, FontWeight.normal, $(14))
                    .intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                )
                    .intoGestureDetector(onTap: () {
                  PlatformConnectorPage.push(context, platform: ConnectorPlatform.instagram).then((value) {
                    if (value ?? false) {
                      Navigator.of(context).pop(value);
                    }
                  });
                }).intoContainer(color: Colors.black, width: ScreenUtil.screenSize.width, padding: EdgeInsets.symmetric(horizontal: $(26))),
                Container(
                  color: Colors.black,
                  width: ScreenUtil.screenSize.width,
                  height: ScreenUtil.getBottomPadding(context),
                ),
              ],
            ),
            bottom: 0,
            left: 0,
            right: 0,
          ),
          Positioned(
            child: Icon(
              Icons.close,
              size: $(24),
              color: Colors.white,
            ).intoContainer(padding: EdgeInsets.all($(10))).intoGestureDetector(onTap: () {
              Navigator.of(context).pop(false);
            }),
            top: ScreenUtil.getStatusBarHeight(),
            left: $(5),
          ),
        ],
      ),
    );
  }
}
