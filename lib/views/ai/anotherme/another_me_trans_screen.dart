import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/utils/ffmpeg_util.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/trans_result_card.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'anotherme.dart';
import 'trans_result_anim_screen.dart';
import 'widgets/am_opt_container.dart';
import 'widgets/trans_result_video_build_dialog.dart';

class AnotherMeTransScreen extends StatefulWidget {
  File file;
  double ratio;
  File? resultFile;
  String photoType;

  AnotherMeTransScreen({
    Key? key,
    required this.file,
    required this.ratio,
    this.resultFile,
    required this.photoType,
  }) : super(key: key);

  @override
  State<AnotherMeTransScreen> createState() => _AnotherMeTransScreenState();
}

class _AnotherMeTransScreenState extends AppState<AnotherMeTransScreen> {
  late File file;
  late double ratio;
  UserManager userManager = AppDelegate().getManager();
  AnotherMeController controller = Get.find();
  UploadImageController uploadImageController = Get.find();
  RecentController recentController = Get.find();
  GlobalKey<AMOptContainerState> optKey = GlobalKey();
  late double resultCardWidth;
  late double resultCardHeight;
  late double dividerSize;
  File? transResult;
  late String photoType;
  int generateCount = 0;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'metaverse_generate_screen');
    ratio = widget.ratio;
    photoType = widget.photoType;
    dividerSize = $(4);
    resultCardWidth = ScreenUtil.screenSize.width - $(32);
    resultCardHeight = ratio > ImageUtils.axisRatioFlag ? (resultCardWidth - dividerSize) / 2 * ratio : resultCardWidth * ratio * 2 + dividerSize;
    file = widget.file;
    transResult = widget.resultFile;
    delay(() {
      if (transResult == null) {
        generate(context, controller);
      } else {
        md5File(file).then((value) {
          uploadImageController.needUploadByKey(value);
        });
        controller.sourcePhoto = file;
        controller.transKey = transResult!.path;
        controller.onSuccess();
      }
    });
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
      } else if (value) {
        switch (type) {
          case AccountLimitType.guest:
            userManager.doOnLogin(context, logPreLoginAction: 'metaverse_generate_limit', toSignUp: true);
            break;
          case AccountLimitType.normal:
            userManager.doOnLogin(context, logPreLoginAction: 'metaverse_generate_limit', callback: () {
              PaymentUtils.pay(context, 'metaverse_result_page');
            }, autoExec: true);
            break;
          case AccountLimitType.vip:
            break;
        }
      } else {
        userManager.doOnLogin(context, logPreLoginAction: 'metaverse_generate_limit', callback: () {
          Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
          EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.MINE.id()]));
          delay(() => SubmitInvitedCodeScreen.push(Get.context!), milliseconds: 200);
          // Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
        }, autoExec: true);
      }
    });
  }

  void generate(BuildContext _context, AnotherMeController controller) async {
    var key = await md5File(file);
    var needUpload = await uploadImageController.needUploadByKey(key);
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      _context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.anotherMe(context),
    ).then((value) {
      if (value == null) {
        controller.onError();
      } else if (value.result) {
        Events.metaverseCompleteSuccess(photo: photoType);
        generateCount++;
        if (generateCount - 1 > 0) {
          Events.metaverseCompleteGenerateAgain(time: generateCount - 1);
        }
        controller.onSuccess();
        setState(() {
          showAnim(context);
        });
      } else {
        controller.onError();
        if (value.error != null) {
          showLimitDialog(context, value.error!);
        } else {
          Navigator.of(context).pop();
        }
      }
    });
    controller.onTakePhoto(file, uploadImageController, key).then((value) {
      simulateProgressBarController.uploadComplete();
      if (value) {
        uploadImageController.getCachedIdByKey(key).then((cachedId) {
          controller.startTransfer(uploadImageController.imageUrl.value, cachedId, (response) {
            uploadImageController.deleteUploadData(null, key: key);
          }).then((value) {
            if (value != null) {
              if (value.entity != null) {
                uploadImageController.updateCachedId(file, value.entity!.cacheId ?? '');
                var image = File(controller.transKey!);
                recentController.onMetaverseUsed(file, image);
                transResult = image;
                simulateProgressBarController.loadComplete();
              } else {
                simulateProgressBarController.onError(error: value.type);
              }
            } else {
              simulateProgressBarController.onError();
            }
          });
        });
      } else {
        simulateProgressBarController.onError();
      }
    });
  }

  Future<void> showAnim(BuildContext context) async {
    return Navigator.of(context).push<void>(NoAnimRouter(TransResultAnimScreen(
      origin: file,
      result: transResult!,
      ratio: ratio,
    )));
  }

  @override
  Widget buildWidget(BuildContext context) => WillPopScope(
      child: GetBuilder<AnotherMeController>(
        init: controller,
        builder: (controller) {
          if (TextUtil.isEmpty(controller.transKey)) {
            return Scaffold(
                backgroundColor: ColorConstant.BackgroundColor,
                body: Stack(children: [
                  Image.file(
                    File(file.path),
                    width: ScreenUtil.screenSize.width,
                    height: ScreenUtil.screenSize.height,
                    fit: BoxFit.contain,
                  ),
                  Image.asset(
                    Images.ic_back,
                    height: $(24),
                    width: $(24),
                  )
                      .intoContainer(
                        padding: EdgeInsets.all($(10)),
                        margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight(), left: $(5)),
                      )
                      .hero(tag: AnotherMe.logoBackTag)
                      .intoGestureDetector(onTap: () {
                    Navigator.pop(context, true);
                  }),
                  controller.error()
                      ? Positioned(
                          bottom: ScreenUtil.getBottomPadding(context, padding: 32),
                          child: OutlineWidget(
                            radius: $(12),
                            strokeWidth: $(2),
                            gradient: LinearGradient(
                              colors: [Color(0xFF04F1F9), Color(0xFF7F97F3), Color(0xFFEC5DD8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            child: Text(
                              S.of(context).generate_again,
                              style: TextStyle(
                                color: ColorConstant.White,
                                fontSize: $(17),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ).intoContainer(
                              height: $(48),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: Color(0x44000000), borderRadius: BorderRadius.circular($(12))),
                              padding: EdgeInsets.all($(2)),
                            ),
                          ).intoGestureDetector(onTap: () {
                            controller.clearTransKey();
                            generate(context, controller);
                          }).intoContainer(width: ScreenUtil.screenSize.width - $(160), margin: EdgeInsets.symmetric(horizontal: $(80))),
                        )
                      : Container(),
                ]));
          }
          return Scaffold(
            backgroundColor: ColorConstant.BackgroundColor,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Stack(
                                children: [
                                  Image.asset(Images.ic_mt_result_top),
                                  Text(
                                    '@${userManager.user?.getShownName() ?? 'Pandora User'}',
                                    style: TextStyle(
                                      color: ColorConstant.White,
                                      fontFamily: 'Poppins',
                                      fontSize: $(14),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ).marginOnly(left: $(16), top: $(50)),
                                ],
                              ),
                              Expanded(
                                child: Image.asset(
                                  Images.ic_mt_result_middle,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Image.asset(Images.ic_mt_result_bottom),
                            ],
                          ),
                          ClipRRect(
                            child: TransResultNewCard(
                              originalImage: file,
                              resultImage: File(controller.transKey!),
                              width: resultCardWidth,
                              height: resultCardHeight,
                              direction: ratio > ImageUtils.axisRatioFlag ? Axis.horizontal : Axis.vertical,
                              dividerSize: dividerSize,
                            ),
                            borderRadius: BorderRadius.circular($(12)),
                          )
                              .intoContainer(
                                margin: EdgeInsets.only(right: 2, left: 2),
                              )
                              .intoCenter()
                              .intoContainer(padding: EdgeInsets.only(top: 48)),
                          Image.asset(
                            ratio > ImageUtils.axisRatioFlag ? Images.ic_another_arrow_right : Images.ic_another_arrow_down,
                            width: $(18),
                          ).intoContainer(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: $(48)),
                          ),
                        ],
                      ).intoContainer(
                        margin: EdgeInsets.only(right: 14, left: 14, top: 50 + ScreenUtil.getStatusBarHeight(), bottom: $(13)),
                      ),
                    ),
                    AMOptContainer(
                      key: optKey,
                      onChoosePhotoTap: () {
                        optKey.currentState!.dismiss().whenComplete(() {
                          controller.clear(uploadImageController);
                          Events.metaverseCompleteTakeAgain();
                          Navigator.of(context).pop(false);
                        });
                      },
                      onDownloadTap: () async {
                        showSaveDialog(context, true).then((value) async {
                          if (value != null) {
                            if (value) {
                              showDialog<String>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => TransResultVideoBuildDialog(result: transResult!, origin: file, ratio: ratio)).then((value) async {
                                if (!TextUtil.isEmpty(value)) {
                                  await showLoading();
                                  await GallerySaver.saveVideo(value!, true, toDcim: true, albumName: saveAlbumName);
                                  await hideLoading();
                                  Events.metaverseCompleteDownload(type: 'video');
                                  CommonExtension().showVideoSavedOkToast(context);
                                  delay(() {
                                    UserManager userManager = AppDelegate.instance.getManager();
                                    userManager.rateNoticeOperator.onSwitch(context);
                                  }, milliseconds: 2000);
                                }
                              });
                            } else {
                              await showLoading();
                              var uint8list = await ImageUtils.printAnotherMeData(file, File(controller.transKey!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
                              var list = uint8list.toList();
                              var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
                              var imgPath = path + '${DateTime.now().millisecondsSinceEpoch}.png';
                              await File(imgPath).writeAsBytes(list);
                              await GallerySaver.saveImage(imgPath, albumName: saveAlbumName);
                              await hideLoading();
                              Events.metaverseCompleteDownload(type: 'image');
                              CommonExtension().showImageSavedOkToast(context);
                              delay(() {
                                UserManager userManager = AppDelegate.instance.getManager();
                                userManager.rateNoticeOperator.onSwitch(context);
                              }, milliseconds: 2000);
                            }
                          }
                        });
                      },
                      onGenerateAgainTap: () {
                        controller.clearTransKey();
                        generate(context, controller);
                      },
                      onShareDiscoveryTap: () async {
                        if (TextUtil.isEmpty(controller.transKey)) {
                          return;
                        }
                        AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_metaverse', callback: () {
                          var file = File(controller.transKey!);
                          ShareDiscoveryScreen.push(
                            context,
                            effectKey: 'Me-taverse',
                            originalUrl: uploadImageController.imageUrl.value,
                            image: base64Encode(file.readAsBytesSync()),
                            isVideo: false,
                            category: HomeCardType.anotherme,
                          ).then((value) {
                            if (value ?? false) {
                              Events.metaverseCompleteShare(source: photoType == 'recently' ? 'recently' : 'metaverse', platform: 'discovery', type: 'image');
                              showShareSuccessDialog(context);
                            }
                          });
                        }, autoExec: true);
                      },
                      onShareTap: () async {
                        showSaveDialog(context, false).then((value) async {
                          if (value != null) {
                            if (value) {
                              showDialog<String>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => TransResultVideoBuildDialog(result: transResult!, origin: file, ratio: ratio)).then((value) async {
                                if (!TextUtil.isEmpty(value)) {
                                  await showLoading();
                                  if (TextUtil.isEmpty(value)) {
                                    await hideLoading();
                                    return;
                                  }
                                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                                  await hideLoading();
                                  ShareScreen.startShare(context,
                                      backgroundColor: Color(0x77000000),
                                      style: 'Me-taverse',
                                      image: value!,
                                      isVideo: true,
                                      originalUrl: null,
                                      preShareVideo: (platform, filePath) async {
                                        if (Platform.isIOS) {
                                          var newFile = filePath + '.ins.mp4';
                                          if (File(newFile).existsSync()) {
                                            return newFile;
                                          }
                                          var command = FFmpegUtil.commandVideoToInstagram(originFile: filePath, targetFile: newFile);
                                          var session = await FFmpegKit.execute(command);
                                          FFmpegKit.cancel(session.getSessionId());
                                          return newFile;
                                        } else {
                                          return filePath;
                                        }
                                      },
                                      effectKey: 'Me-taverse',
                                      onShareSuccess: (platform) {
                                        Events.metaverseCompleteShare(source: photoType == 'recently' ? 'recently' : 'metaverse', platform: platform, type: 'video');
                                      });
                                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                                }
                              });
                            } else {
                              if (TextUtil.isEmpty(controller.transKey)) {
                                return;
                              }
                              await showLoading();
                              var uint8list = await ImageUtils.printAnotherMeData(file, File(controller.transKey!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
                              await hideLoading();
                              AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                              ShareScreen.startShare(context,
                                  backgroundColor: Color(0x77000000),
                                  style: 'Me-taverse',
                                  image: base64Encode(uint8list),
                                  isVideo: false,
                                  originalUrl: null,
                                  effectKey: 'Me-taverse', onShareSuccess: (platform) {
                                Events.metaverseCompleteShare(source: photoType == 'recently' ? 'recently' : 'metaverse', platform: platform, type: 'image');
                              });
                              AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                            }
                          }
                        });
                      },
                    ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(35)))
                  ],
                ).intoContainer(
                  width: ScreenUtil.screenSize.width,
                  height: ScreenUtil.screenSize.height,
                ),
                Image.asset(
                  Images.ic_back,
                  height: $(24),
                  width: $(24),
                )
                    .intoContainer(
                      padding: EdgeInsets.all($(10)),
                      margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight(), left: $(5)),
                    )
                    .hero(tag: AnotherMe.logoBackTag)
                    .intoGestureDetector(onTap: () {
                  Navigator.pop(context, true);
                }),
              ],
            ).intoContainer(
                height: ScreenUtil.screenSize.height,
                width: ScreenUtil.screenSize.width,
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_another_me_trans_bg), fit: BoxFit.fill))),
          );
        },
      ),
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      });

  Future<bool?> showSaveDialog(BuildContext context, bool isSave) {
    return showModalBottomSheet<bool>(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleTextWidget(isSave ? S.of(context).metaverse_save_video : S.of(context).metaverse_share_video, ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop(true);
              }),
              Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
              TitleTextWidget(isSave ? S.of(context).metaverse_save_image : S.of(context).metaverse_share_image, ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop(false);
              }),
            ],
          ).intoContainer(
              padding: EdgeInsets.only(top: $(15), bottom: $(10) + ScreenUtil.getBottomPadding(context)),
              decoration: BoxDecoration(
                  color: ColorConstant.EffectFunctionGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular($(24)),
                    topRight: Radius.circular($(24)),
                  )));
        },
        backgroundColor: Colors.transparent);
  }
}
