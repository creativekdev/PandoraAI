import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:common_utils/common_utils.dart';
import 'package:skeletons/skeletons.dart';

import 'metagram_item_edit_controller.dart';

class MetagramItemEditScreen extends StatefulWidget {
  MetagramItemEntity entity;
  List<List<DiscoveryResource>> items;
  int index;

  MetagramItemEditScreen({
    Key? key,
    required this.entity,
    required this.items,
    required this.index,
  }) : super(key: key);

  @override
  State<MetagramItemEditScreen> createState() => _MetagramItemEditScreenState();
}

class _MetagramItemEditScreenState extends AppState<MetagramItemEditScreen> {
  late MetagramItemEditController controller;
  int generateCount = 0;
  UserManager userManager = AppDelegate().getManager();

  @override
  void initState() {
    super.initState();
    controller = Get.put(MetagramItemEditController(entity: widget.entity, items: widget.items, index: widget.index));
  }

  @override
  void dispose() {
    Get.delete<MetagramItemEditController>();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GetBuilder<MetagramItemEditController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstant.BackgroundColor,
          appBar: AppNavigationBar(
            backgroundColor: ColorConstant.BackgroundColor,
            middle: Image.asset(
              Images.ic_metagram_download,
              width: $(24),
            )
                .intoContainer(
              padding: EdgeInsets.all($(10)),
              color: Colors.transparent,
            )
                .intoGestureDetector(onTap: () {
              saveImage(controller);
            }).offstage(offstage: controller.resultFile == null),
            trailing: Image.asset(
              Images.ic_metagram_save,
              width: $(24),
              height: $(24),
            )
                .intoContainer(
              padding: EdgeInsets.all($(10)),
              color: Colors.transparent,
            )
                .intoGestureDetector(onTap: () {
              submit(controller);
            }).offstage(offstage: controller.transResult == null),
          ),
          body: Column(
            children: [
              Expanded(
                  child: Stack(
                children: [
                  controller.resultFile == null
                      ? SkeletonAvatar(
                          style: SkeletonAvatarStyle(
                            width: ScreenUtil.screenSize.width,
                            height: ScreenUtil.screenSize.width,
                          ),
                        )
                      : controller.transResult == null
                          ? Image.file(
                              controller.resultFile!,
                              width: ScreenUtil.screenSize.width,
                            )
                          : Image.file(
                              controller.transResult!,
                              fit: BoxFit.contain,
                              width: ScreenUtil.screenSize.width,
                            ),
                  controller.originFile == null || !controller.showOrigin
                      ? SizedBox.shrink()
                      : Image.file(
                          controller.originFile!,
                          width: double.maxFinite,
                        ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: GestureDetector(
                      child: Image.asset(Images.ic_metagram_show_origin, width: $(26)).intoContainer(
                        color: Colors.transparent,
                        padding: EdgeInsets.all($(12)),
                      ),
                      onTapDown: (details) {
                        controller.showOrigin = true;
                      },
                      onTapUp: (details) {
                        controller.showOrigin = false;
                      },
                      onTapCancel: () {
                        controller.showOrigin = false;
                      },
                    ),
                  )
                ],
              ).intoCenter().intoContainer()),
              OutlineWidget(
                radius: $(8),
                strokeWidth: $(2),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFEC5DD8),
                    Color(0xFF7F97F3),
                    Color(0xFF04F1F9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Text(
                  S.of(context).generate_again,
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(16),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                  ),
                ).intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  alignment: Alignment.center,
                ),
              ).intoMaterial(color: Color(0xff222222), borderRadius: BorderRadius.circular($(8))).intoGestureDetector(onTap: () {
                generateAgain(controller);
              }).intoContainer(
                  margin: EdgeInsets.only(
                left: $(12),
                right: $(12),
                bottom: ScreenUtil.getBottomPadding(context) + $(30),
              )),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: $(12)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildItems(controller),
                ),
                scrollDirection: Axis.horizontal,
              ).intoContainer(margin: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(15))).offstage(offstage: true),
            ],
          ),
        );
      },
      init: Get.find<MetagramItemEditController>(),
    );
  }

  generateAgain(MetagramItemEditController controller) {
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: false,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.anotherMe(context),
    ).then((value) {
      if (value == null) {
        controller.onError();
      } else if (value.result) {
        Events.metaverseCompleteSuccess(photo: 'url');
        generateCount++;
        if (generateCount - 1 > 0) {
          Events.metaverseCompleteGenerateAgain(time: generateCount - 1);
        }
        controller.onSuccess();
      } else {
        controller.onError();
        if (value.error != null) {
          showLimitDialog(context, value.error!);
        } else {
          Navigator.of(context).pop();
        }
      }
    });
    controller.startTransfer().then((value) {
      if (value != null) {
        if (value.entity != null) {
          var image = File(controller.transKey!);
          controller.transResult = image;
          controller.update();
          simulateProgressBarController.loadComplete();
        } else {
          simulateProgressBarController.onError(error: value.type);
        }
      } else {
        simulateProgressBarController.onError();
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
            userManager.doOnLogin(context, logPreLoginAction: 'metagram_generate_limit', toSignUp: true);
            break;
          case AccountLimitType.normal:
            userManager.doOnLogin(context, logPreLoginAction: 'metagram_generate_limit', callback: () {
              PaymentUtils.pay(context, 'metagram_result_page');
            }, autoExec: true);
            break;
          case AccountLimitType.vip:
            break;
        }
      } else {
        userManager.doOnLogin(context, logPreLoginAction: 'metagram_generate_limit', callback: () {
          Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
          EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.MINE.id()]));
          delay(() => SubmitInvitedCodeScreen.push(Get.context!), milliseconds: 200);
          // Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
        }, autoExec: true);
      }
    });
  }

  List<Widget> buildItems(MetagramItemEditController controller) {
    var width = ScreenUtil.screenSize.width / 5;
    var height = width / 7 * 8;
    List<Widget> items = [];
    controller.optList.forEach((element) {
      if (element.type == HomeCardType.anotherme) {
        bool checked = element.type == controller.currentType;
        items.add(
          Column(
            children: [
              _CheckItemWidget(
                checked: checked,
                child: Image.asset(
                  Images.ic_metagram_opt_another,
                  width: width,
                  height: height,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(height: $(8)),
              TitleTextWidget(element.type.title(), ColorConstant.White, FontWeight.normal, $(12))
            ],
          ),
        );
      } else if (element.type == HomeCardType.cartoonize) {
        EffectModel data = element.data! as EffectModel;
        var effects = data.effects.values.toList();
        for (int i = 0; i < effects.length; i++) {
          var effectItem = effects[i];
          bool checked;
          if (controller.currentType == HomeCardType.cartoonize) {
            checked = controller.entity.cartoonizeKey == effectItem.key;
          } else {
            checked = false;
          }
          if (i == 0) {
            items.add(
              Column(
                children: [
                  _CheckItemWidget(
                    checked: checked,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular($(8)),
                      child: _imageWidget(
                        context,
                        imageUrl: effectItem.imageUrl,
                        width: width,
                        height: height,
                      ),
                    ),
                  ),
                  SizedBox(height: $(8)),
                  TitleTextWidget(element.type.title(), ColorConstant.White, FontWeight.normal, $(12))
                ],
              ).intoContainer(margin: EdgeInsets.only(left: $(6))),
            );
          } else {
            items.add(
              ClipRRect(
                borderRadius: BorderRadius.circular($(6)),
                child: _CheckItemWidget(
                  checked: checked,
                  child: Stack(
                    children: [
                      _imageWidget(
                        context,
                        imageUrl: effectItem.imageUrl,
                        width: width * 0.8,
                        height: height * 0.8,
                      ),
                      Positioned(
                        child: TitleTextWidget('${i + 1}', ColorConstant.White, FontWeight.normal, $(12), align: TextAlign.center)
                            .intoContainer(alignment: Alignment.center, width: width * 0.8, color: Color(0x99000000)),
                        bottom: 0,
                      ),
                    ],
                  ).intoContainer(width: width * 0.8, height: height * 0.8),
                ),
              ).intoContainer(margin: EdgeInsets.only(left: $(6))),
            );
          }
        }
      }
    });
    return items;
  }

  Widget _imageWidget(BuildContext context, {required String imageUrl, required double width, required double height}) {
    return CachedNetworkImageUtils.custom(
      context: context,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: width,
      height: height,
      placeholder: (context, url) {
        return Container(
          height: height,
          width: width,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          height: height,
          width: width,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void saveImage(MetagramItemEditController controller) async {
    await showLoading();
    var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    var saveFileName = EncryptUtil.encodeMd5('${controller.originFile?.path}${(controller.transResult ?? controller.resultFile)?.path}');
    var imgPath = path + '${saveFileName}.png';
    if (!File(imgPath).existsSync()) {
      var uint8list =
          await ImageUtils.printAnotherMeData(controller.originFile!, controller.transResult ?? controller.resultFile!, '@${userManager.user?.getShownName() ?? 'Pandora User'}');
      var list = uint8list.toList();
      await File(imgPath).writeAsBytes(list);
    }
    await GallerySaver.saveImage(imgPath, albumName: saveAlbumName);
    await hideLoading();
    Events.metaverseCompleteDownload(type: 'image');
    CommonExtension().showImageSavedOkToast(context);
    delay(() {
      UserManager userManager = AppDelegate.instance.getManager();
      userManager.rateNoticeOperator.onSwitch(context);
    }, milliseconds: 2000);
  }

  void submit(MetagramItemEditController controller) {
    showLoading().whenComplete(() {
      controller.updateResult().then((value) {
        hideLoading().whenComplete(() {
          if (value != null) {
            Navigator.of(context).pop();
          }
        });
      });
    });
  }
}

class _CheckItemWidget extends StatelessWidget {
  bool checked;
  final Widget child;

  _CheckItemWidget({Key? key, required this.child, this.checked = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        checked
            ? Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                left: 0,
                child: Image.asset(
                  Images.ic_metagram_yes,
                  width: $(26),
                ).intoCenter().intoContainer(color: Color(0x55000000)),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
