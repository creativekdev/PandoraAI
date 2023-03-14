import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/ground/ai_ground_controller.dart';
import 'package:cartoonizer/views/ai/ground/widget/agopt_container.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';

class AiGroundResultScreen extends StatefulWidget {
  AiGroundController controller;

  AiGroundResultScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<AiGroundResultScreen> createState() => _AiGroundResultScreenState();
}

class _AiGroundResultScreenState extends AppState<AiGroundResultScreen> {
  GlobalKey<AGOptContainerState> optKey = GlobalKey();
  late AiGroundController controller;

  @override
  void initState() {
    super.initState();
    Events.txt2imgResultShow();
    controller = widget.controller;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
      ),
      body: GetBuilder<AiGroundController>(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                  child: Image.file(
                File(controller.filePath!),
                fit: BoxFit.contain,
              )),
              AGOptContainer(
                key: optKey,
                onDownloadTap: () {
                  showLoading().whenComplete(() {
                    controller.saveToGallery().whenComplete(() {
                      hideLoading().whenComplete(() {
                        Events.txt2imgCompleteDownload(type: 'image');
                        CommonExtension().showImageSavedOkToast(context);
                      });
                    });
                  });
                },
                onGenerateAgainTap: () {
                  optKey.currentState?.dismiss().whenComplete(() {
                    Navigator.of(context).pop(true);
                  });
                },
                onShareTap: () async {
                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                  ShareScreen.startShare(context,
                      backgroundColor: Color(0x77000000),
                      style: 'txt2img',
                      image: base64Encode(File(controller.filePath!).readAsBytesSync()),
                      isVideo: false,
                      originalUrl: null,
                      effectKey: 'Me-taverse', onShareSuccess: (platform) {
                    Events.txt2imgCompleteShare(source: 'txt2img', platform: platform, type: 'image');
                  });
                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                },
                onShareDiscoveryTap: () async {
                  AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_txt2img', callback: () {
                    ShareDiscoveryScreen.push(
                      context,
                      effectKey: 'txt2img',
                      originalUrl: null,
                      image: base64Encode(File(controller.filePath!).readAsBytesSync()),
                      isVideo: false,
                      category: DiscoveryCategory.txt2img,
                    ).then((value) {
                      if (value ?? false) {
                        Events.txt2imgCompleteShare(source: 'txt2img', platform: 'discovery', type: 'image');
                        showShareSuccessDialog(context);
                      }
                    });
                  }, autoExec: true);
                },
              ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(12))),
            ],
          );
        },
      ),
    );
  }
}
