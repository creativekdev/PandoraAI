import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/ground/ai_ground_controller.dart';
import 'package:cartoonizer/views/ai/ground/widget/agopt_container.dart';
import 'package:cartoonizer/views/ai/ground/widget/prompt_border.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';

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
  UserManager userManager = AppDelegate().getManager();
  GlobalKey key = GlobalKey();
  int generateCount = 0;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    if (TextUtil.isEmpty(controller.filePath)) {
      delay(() => generate(controller));
    }
  }

  generate(AiGroundController controller) {
    SimulateProgressBarController progressController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: false,
      controller: progressController,
      config: SimulateProgressBarConfig.aiGround(context),
    ).then((value) {
      if (value == null) {
        Navigator.of(context).pop();
      } else if (value.result) {
        Events.txt2imgResultShow(
          style: controller.selectedStyle?.name,
          isUploadReference: controller.initFile != null,
          isUseSuggestion: controller.promptList.contains(controller.editingController.text.toString()),
        );
        setState(() {
          generateCount++;
          if (generateCount - 1 > 0) {
            Events.txt2imgCompleteGenerateAgain(time: generateCount - 1);
          }
        });
      } else {
        if (value.errorTitle != null && value.errorContent != null) {
          showLimitDialog(context, value.errorTitle!, value.errorContent!);
        } else {
          Navigator.of(context).pop();
        }
      }
    });
    controller.generate().then((value) {
      if (value != null) {
        if (value.data != null) {
          progressController.loadComplete();
        } else {
          progressController.onError(errorTitle: value.msgTitle, errorContent: value.msgContent);
        }
      } else {
        progressController.onError();
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (generateCount == 0 && controller.filePath == null) {
      return Container();
    }
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
                child: TextUtil.isEmpty(controller.filePath)
                    ? Container()
                    : RepaintBoundary(
                        key: key,
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            Image.file(
                              File(controller.filePath!),
                              fit: BoxFit.contain,
                            ),
                            controller.displayText
                                ? Positioned(
                                    child: PromptBorder(
                                      child: Text(
                                        controller.editingController.text,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: $(14),
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      color: Color(0x88000000),
                                      padding: EdgeInsets.symmetric(horizontal: $(10), vertical: $(8)),
                                      radius: $(4),
                                    ),
                                    left: 15,
                                    right: 15,
                                    bottom: 20,
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      )
                        .intoContainer(
                          width: ScreenUtil.screenSize.width,
                        )
                        .intoCenter(),
              ),
              AGOptContainer(
                key: optKey,
                displayText: controller.displayText,
                onDisplayTap: () {
                  controller.displayText = !controller.displayText;
                },
                onDownloadTap: () {
                  showLoading().whenComplete(() async {
                    var image = await getBitmapFromContext(key.currentContext!, pixelRatio: 1.5);
                    if (image == null) {
                      hideLoading().whenComplete(() {
                        CommonExtension().showToast(S.of(context).commonFailedToast);
                      });
                    } else {
                      controller.saveToGallery(image).then((value) {
                        hideLoading().whenComplete(() {
                          if (value) {
                            Events.txt2imgCompleteDownload(type: 'image', textDisplay: controller.displayText);
                            CommonExtension().showImageSavedOkToast(context);
                            delay(() {
                              UserManager userManager = AppDelegate.instance.getManager();
                              userManager.rateNoticeOperator.onSwitch(context);
                            }, milliseconds: 2000);
                          } else {
                            CommonExtension().showToast(S.of(context).commonFailedToast);
                          }
                        });
                      });
                    }
                  });
                },
                onGenerateAgainTap: () {
                  generate(controller);
                },
                onShareTap: () async {
                  var image = await getBitmapFromContext(key.currentContext!, pixelRatio: 1.5);
                  if (image == null) {
                    hideLoading().whenComplete(() {
                      CommonExtension().showToast(S.of(context).commonFailedToast);
                    });
                  } else {
                    var byteData = await image.toByteData(format: ImageByteFormat.png);
                    Uint8List list = byteData!.buffer.asUint8List();
                    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                    ShareScreen.startShare(context,
                        backgroundColor: Color(0x77000000),
                        style: 'txt2img',
                        image: base64Encode(list),
                        isVideo: false,
                        originalUrl: null,
                        effectKey: 'txt2img', onShareSuccess: (platform) {
                      Events.txt2imgCompleteShare(
                        source: 'txt2img',
                        platform: platform,
                        type: 'image',
                        textDisplay: controller.displayText,
                      );
                    });
                    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                  }
                },
                onShareDiscoveryTap: () async {
                  AppDelegate.instance.getManager<UserManager>().doOnLogin(
                    context,
                    logPreLoginAction: 'share_discovery_from_txt2img',
                    callback: () async {
                      var image = await getBitmapFromContext(key.currentContext!, pixelRatio: 1.5);
                      if (image == null) {
                        hideLoading().whenComplete(() {
                          CommonExtension().showToast(S.of(context).commonFailedToast);
                        });
                      } else {
                        var byteData = await image.toByteData(format: ImageByteFormat.png);
                        Uint8List list = byteData!.buffer.asUint8List();
                        ShareDiscoveryScreen.push(
                          context,
                          effectKey: 'txt2img',
                          originalUrl: null,
                          image: base64Encode(list),
                          isVideo: false,
                          category: DiscoveryCategory.txt2img,
                          payload: controller.parameters != null ? jsonEncode({"txt2img_params": controller.parameters}) : null,
                        ).then((value) {
                          if (value ?? false) {
                            Events.txt2imgCompleteShare(
                              source: 'txt2img',
                              platform: 'discovery',
                              type: 'image',
                              textDisplay: controller.displayText,
                            );
                            showShareSuccessDialog(context);
                          }
                        });
                      }
                    },
                    autoExec: true,
                  );
                },
              ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(12))),
            ],
          );
        },
      ),
    );
  }

  showLimitDialog(BuildContext context, String title, String content) {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: $(27)),
                Image.asset(
                  Images.ic_warning,
                  width: $(32),
                  color: Color(0xFFFD4245),
                ).intoContainer(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFFD4245), width: 1),
                      borderRadius: BorderRadius.circular($(48)),
                    )),
                SizedBox(height: $(20)),
                TitleTextWidget(
                  title,
                  Color(0xFFFD4245),
                  FontWeight.w500,
                  $(17),
                  maxLines: 100,
                  align: TextAlign.center,
                ).intoContainer(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(horizontal: $(30)),
                  alignment: Alignment.center,
                ),
                SizedBox(height: $(8)),
                TitleTextWidget(
                  content,
                  ColorConstant.White,
                  FontWeight.w500,
                  $(13),
                  maxLines: 100,
                  align: TextAlign.center,
                ).intoContainer(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(
                    bottom: $(40),
                    left: $(30),
                    right: $(30),
                  ),
                  alignment: Alignment.center,
                ),
                Container(height: 1, color: ColorConstant.LineColor),
                Row(
                  children: [
                    isVip()
                        ? SizedBox.shrink()
                        : Expanded(
                            child: Text(
                              S.of(context).upgrade,
                              style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(17)),
                            )
                                .intoContainer(
                              width: double.maxFinite,
                              color: Colors.transparent,
                              padding: EdgeInsets.only(top: $(10), bottom: $(12)),
                              alignment: Alignment.center,
                            )
                                .intoGestureDetector(onTap: () {
                              Navigator.pop(_, true);
                            }),
                          ),
                    isVip() ? SizedBox.shrink() : Container(height: $(48), color: ColorConstant.LineColor, width: 1),
                    Expanded(
                      child: Text(
                        S.of(context).ok1,
                        style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(17)),
                      )
                          .intoContainer(
                        width: double.maxFinite,
                        color: Colors.transparent,
                        padding: EdgeInsets.only(top: $(10), bottom: $(12)),
                        alignment: Alignment.center,
                      )
                          .intoGestureDetector(onTap: () {
                        Navigator.pop(_, false);
                      }),
                    ),
                  ],
                ),
              ],
            ).customDialogStyle()).then((value) {
      if (value ?? false) {
        userManager.doOnLogin(context, logPreLoginAction: 'txt2img_generate_limit', callback: () {
          PaymentUtils.pay(context, 'txt2img_result_page').then((value) {
            Navigator.of(context).pop();
          });
        }, autoExec: true);
      } else {
        userManager.doOnLogin(context, logPreLoginAction: 'txt2img_generate_limit', callback: () {
          Navigator.of(context).pop();
        }, autoExec: true);
      }
    });
  }
}
