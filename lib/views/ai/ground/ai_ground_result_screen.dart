import 'dart:convert';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/am_opt_container.dart';
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
    controller = widget.controller;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
      ),
      body: GetBuilder<AiGroundController>(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                  child: Image.memory(
                base64Decode(controller.imageBase64!),
                fit: BoxFit.contain,
              )),
              AGOptContainer(
                key: optKey,
                onDownloadTap: () {
                  showLoading().whenComplete(() {
                    controller.saveToGallery().whenComplete(() {
                      hideLoading().whenComplete(() {
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
                      style: 'Me-taverse',
                      image: controller.imageBase64 ?? '',
                      isVideo: false,
                      originalUrl: null,
                      effectKey: 'Me-taverse',
                      onShareSuccess: (platform) {});
                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                },
              ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(35))),
            ],
          );
        },
      ),
    ).intoContainer(
        height: ScreenUtil.screenSize.height,
        width: ScreenUtil.screenSize.width,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_another_me_trans_bg), fit: BoxFit.fill)));
  }
}
