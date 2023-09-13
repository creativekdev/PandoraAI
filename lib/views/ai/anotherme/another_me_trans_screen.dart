import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/recent/recent_controller.dart';
import 'package:cartoonizer/controller/upload_image_controller.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/widgets/outline_widget.dart';
import 'package:cartoonizer/widgets/router/routers.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/widgets/switch_image_card.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/utils/ffmpeg_util.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/print/print.dart';
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
    file = widget.file;
    transResult = widget.resultFile;
    delay(() {
      if (transResult == null) {
        generate(context, controller);
      } else {
        controller.sourcePhoto = file;
        controller.transKey = transResult!.path;
        controller.onSuccess();
      }
    });
  }

  void generate(BuildContext _context, AnotherMeController controller) async {
    var needUpload = TextUtil.isEmpty(uploadImageController.imageUrl(file).value);
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
          showLimitDialog(context, type: value.error!, function: 'metaverse', source: 'metaverse_result_page');
        } else {
          Navigator.of(context).pop();
        }
      }
    });
    controller.onTakePhoto(file).then((value) {
      uploadImageController.upload(file: file).then((value) async {
        if (TextUtil.isEmpty(value)) {
          simulateProgressBarController.onError();
        } else {
          simulateProgressBarController.uploadComplete();
          controller.startTransfer(uploadImageController.imageUrl(file).value, await uploadImageController.getCachedId(file), (response) {
            uploadImageController.deleteUploadData(file);
          }).then((value) {
            if (value != null) {
              if (value.entity != null) {
                uploadImageController.updateCachedId(file, value.entity!.cacheId ?? '');
                var image = File(controller.transKey!);
                recentController.onMetaverseUsed(file, image);
                transResult = image;
                simulateProgressBarController.loadComplete();
                // 增加次数判断，看是否显示rate_us
                UserManager userManager = AppDelegate.instance.getManager();
                userManager.rateNoticeOperator.onSwitch(Get.context!, true);
              } else {
                simulateProgressBarController.onError(error: value.type);
              }
            } else {
              simulateProgressBarController.onError();
            }
          });
        }
      });
    });
  }

  Future<void> showAnim(BuildContext context) async {
    return Navigator.of(context).push<void>(NoAnimRouter(
      TransResultAnimScreen(
        origin: file,
        result: transResult!,
        ratio: ratio,
      ),
      settings: RouteSettings(name: '/TransResultAnimScreen'),
    ));
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
            backgroundColor: Colors.transparent,
            appBar: AppNavigationBar(
              backgroundColor: Colors.transparent,
              backAction: () {
                Navigator.of(context).pop(true);
              },
              trailing: Image.asset(
                Images.ic_more,
                height: $(24),
                width: $(24),
                color: Colors.white,
              ).intoGestureDetector(onTap: () {
                LiPopMenu.showLinePop(
                  context,
                  listData: [
                    ListPopItem(
                        text: S.of(context).share_to_discovery,
                        icon: Images.ic_share_discovery,
                        onTap: () {
                          shareToDiscovery(controller);
                        }),
                    ListPopItem(
                        text: S.of(context).share_out,
                        icon: Images.ic_share,
                        onTap: () {
                          shareToOut(controller);
                        }),
                  ],
                );
              }),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SwitchImageCard(
                    origin: file,
                    result: File(controller.transKey!),
                  ),
                ),
                AMOptContainer(
                  key: optKey,
                  onChoosePhotoTap: () {
                    optKey.currentState!.dismiss().whenComplete(() {
                      controller.clear();
                      Events.metaverseCompleteTakeAgain();
                      Navigator.of(context).pop(false);
                    });
                  },
                  onDownloadTap: () {
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
                            }
                          });
                        } else {
                          await showLoading();
                          // var uint8list = await ImageUtils.printAnotherMeData(file, File(controller.transKey!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
                          // var list = uint8list.toList();
                          // var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
                          // var imgPath = path + '${DateTime.now().millisecondsSinceEpoch}.png';
                          // await File(imgPath).writeAsBytes(list);
                          await GallerySaver.saveImage(controller.transKey!, albumName: saveAlbumName);
                          await hideLoading();
                          Events.metaverseCompleteDownload(type: 'image');
                          CommonExtension().showImageSavedOkToast(context);
                        }
                      }
                    });
                  },
                  onGenerateAgainTap: () {
                    controller.clearTransKey();
                    generate(context, controller);
                  },
                  onSharePrintTap: () async {
                    Print.open(context, source: 'anotherme_result', file: transResult!);
                  },
                ).intoContainer(padding: EdgeInsets.only(top: $(10), bottom: $(10)))
              ],
            ),
          ).intoContainer(
              padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(15)),
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_another_me_trans_bg), fit: BoxFit.fill)));
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

  shareToDiscovery(AnotherMeController controller) {
    if (TextUtil.isEmpty(controller.transKey)) {
      return;
    }
    showSaveDialog(context, false).then((value) {
      if (value == null) {
        return;
      }
      Function action = () {};
      if (value) {
        action = () {
          showDialog<String>(context: context, barrierDismissible: false, builder: (_) => TransResultVideoBuildDialog(result: transResult!, origin: file, ratio: ratio))
              .then((value) async {
            if (!TextUtil.isEmpty(value)) {
              await showLoading();
              if (TextUtil.isEmpty(value)) {
                await hideLoading();
                return;
              }
              AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
              await hideLoading();
              ShareDiscoveryScreen.push(
                context,
                image: value!,
                isVideo: true,
                effectKey: '',
                category: HomeCardType.anotherme,
              ).then((value) {
                if (value ?? false) {
                  Events.metaverseCompleteShare(source: photoType == 'recently' ? 'recently' : 'metaverse', platform: 'discovery', type: 'video');
                  showShareSuccessDialog(context);
                }
              });
              AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
            }
          });
        };
      } else {
        action = () async {
          var resultFile = File(controller.transKey!);
          await showLoading();
          String? url = await uploadImageController.upload(file: file);
          hideLoading();
          ShareDiscoveryScreen.push(
            context,
            effectKey: 'Me-taverse',
            originalUrl: url,
            image: base64Encode(resultFile.readAsBytesSync()),
            isVideo: false,
            category: HomeCardType.anotherme,
          ).then((value) {
            if (value ?? false) {
              Events.metaverseCompleteShare(source: photoType == 'recently' ? 'recently' : 'metaverse', platform: 'discovery', type: 'image');
              showShareSuccessDialog(context);
            }
          });
        };
      }
      AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_metaverse', callback: () {
        action.call();
      }, autoExec: true);
    });
  }

  shareToOut(AnotherMeController controller) {
    showSaveDialog(context, false).then((value) async {
      if (value != null) {
        if (value) {
          showDialog<String>(context: context, barrierDismissible: false, builder: (_) => TransResultVideoBuildDialog(result: transResult!, origin: file, ratio: ratio))
              .then((value) async {
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
          await showLoading();
          if (TextUtil.isEmpty(controller.transKey)) {
            return;
          }
          var uint8list = await ImageUtils.printAnotherMeData(file, File(controller.transKey!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
          AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
          await hideLoading();
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
  }
}
