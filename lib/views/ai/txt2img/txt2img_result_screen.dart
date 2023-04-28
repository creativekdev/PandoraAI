import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/txt2img/txt2img_controller.dart';
import 'package:cartoonizer/views/ai/txt2img/widget/txt2img_opt_container.dart';
import 'package:cartoonizer/views/ai/txt2img/widget/prompt_border.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:vibration/vibration.dart';

class Txt2imgResultScreen extends StatefulWidget {
  Txt2imgController controller;

  Txt2imgResultScreen({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<Txt2imgResultScreen> createState() => _Txt2imgResultScreenState();
}

class _Txt2imgResultScreenState extends AppState<Txt2imgResultScreen> {
  GlobalKey<AGOptContainerState> optKey = GlobalKey();
  late Txt2imgController controller;
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

  generate(Txt2imgController controller) {
    SimulateProgressBarController progressController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: false,
      controller: progressController,
      config: SimulateProgressBarConfig.txt2img(context),
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
        if (value.error != null) {
          showLimitDialog(context, value.error!);
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
          progressController.onError(error: value.error);
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
      backgroundColor: Colors.black,
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        blurAble: true,
      ),
      body: GetBuilder<Txt2imgController>(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: TextUtil.isEmpty(controller.filePath) ? Container() : buildImage(context, controller),
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
                      Uint8List list = File(controller.filePath!).readAsBytesSync();
                      ShareDiscoveryScreen.push(
                        context,
                        effectKey: 'txt2img',
                        originalUrl: null,
                        image: base64Encode(list),
                        isVideo: false,
                        category: DiscoveryCategory.txt2img,
                        payload: controller.parameters != null
                            ? jsonEncode({
                                "txt2img_params": controller.parameters,
                                "displayText": controller.displayText,
                              })
                            : null,
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
                    },
                    autoExec: true,
                  );
                },
              ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(25))),
            ],
          );
        },
      ),
    );
  }

  showLimitDialog(BuildContext context, AccountLimitType type) {
    showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: $(27)),
                Image.asset(
                  Images.ic_limit_icon,
                ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(22))),
                SizedBox(height: $(16)),
                TitleTextWidget(
                  type.getContent(context, 'AI Artist'),
                  ColorConstant.White,
                  FontWeight.w500,
                  $(13),
                  maxLines: 100,
                  align: TextAlign.center,
                ).intoContainer(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(
                    bottom: $(30),
                    left: $(30),
                    right: $(30),
                  ),
                  alignment: Alignment.center,
                ),
                Text(
                  type.getSubmitText(context),
                  style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
                )
                    .intoContainer(
                  width: double.maxFinite,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: ColorConstant.DiscoveryBtn),
                  padding: EdgeInsets.only(top: $(10), bottom: $(10)),
                  alignment: Alignment.center,
                )
                    .intoGestureDetector(onTap: () {
                  Navigator.of(context).pop(false);
                }),
                type.getPositiveText(context) != null
                    ? Text(
                        type.getPositiveText(context)!,
                        style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
                      )
                        .intoContainer(
                        width: double.maxFinite,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: Color(0xff292929)),
                        padding: EdgeInsets.only(top: $(10), bottom: $(10)),
                        margin: EdgeInsets.only(top: $(16), bottom: $(24)),
                        alignment: Alignment.center,
                      )
                        .intoGestureDetector(onTap: () {
                        Navigator.pop(_, true);
                      })
                    : SizedBox.shrink(),
              ],
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))).customDialogStyle()).then((value) {
      if (value == null) {
        Navigator.of(context).pop();
      } else if (value) {
        switch (type) {
          case AccountLimitType.guest:
            userManager.doOnLogin(context,
                logPreLoginAction: 'txt2img_generate_limit',
                callback: () {
                  Navigator.of(context).pop();
                },
                autoExec: true,
                onCancel: () {
                  Navigator.of(context).pop();
                });
            break;
          case AccountLimitType.normal:
            userManager.doOnLogin(context,
                logPreLoginAction: 'txt2img_generate_limit',
                callback: () {
                  PaymentUtils.pay(context, 'txt2img_result_page').then((value) {
                    Navigator.of(context).pop();
                  });
                },
                autoExec: true,
                onCancel: () {
                  Navigator.of(context).pop();
                });
            break;
          case AccountLimitType.vip:
            break;
        }
      } else {
        userManager.doOnLogin(context, logPreLoginAction: 'txt2img_generate_limit', callback: () {
          Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
          EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.MINE.id()]));
          delay(() => SubmitInvitedCodeScreen.push(Get.context!), milliseconds: 200);
          // Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
        }, autoExec: true);
      }
    });
  }

  buildImage(BuildContext context, Txt2imgController controller) {
    if (controller.displayText) {
      return SingleChildScrollView(
        child: RepaintBoundary(
          key: key,
          child: Column(
            children: [
              Image.file(
                File(controller.filePath!),
                fit: BoxFit.contain,
              ),
              Text(
                controller.editingController.text,
                style: TextStyle(
                  color: Color(0xffb3b3b3),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: $(14),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              )
                  .intoGestureDetector(
                    onDoubleTap: Platform.isIOS
                        ? () {
                            Clipboard.setData(ClipboardData(text: controller.editingController.text));
                            CommonExtension().showToast(S.of(context).copy_successfully);
                          }
                        : null,
                    onLongPress: Platform.isAndroid
                        ? () {
                            Clipboard.setData(ClipboardData(text: controller.editingController.text));
                            Vibration.hasVibrator().then((value) {
                              if (value ?? false) {
                                CommonExtension().showToast(S.of(context).copy_successfully);
                                Vibration.vibrate(duration: 50);
                              }
                            });
                          }
                        : null,
                  )
                  .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12))),
            ],
          ).intoContainer(color: Colors.black),
        ),
      );
    } else {
      return RepaintBoundary(
        key: key,
        child: Image.file(
          File(controller.filePath!),
          fit: BoxFit.contain,
        ),
      );
    }
  }
}
