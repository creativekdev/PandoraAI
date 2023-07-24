import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/mine/filter/im_filter_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Common/Extension.dart';
import '../../../Common/event_bus_helper.dart';
import '../../../Widgets/cacheImage/cached_network_image_utils.dart';
import '../../../app/app.dart';
import '../../../app/cache/storage_operator.dart';
import '../../../app/effect_manager.dart';
import '../../../app/thirdpart/thirdpart_manager.dart';
import '../../../app/user/user_manager.dart';
import '../../../gallery_saver.dart';
import '../../../models/api_config_entity.dart';
import '../../../models/enums/account_limit_type.dart';
import '../../../models/enums/app_tab_id.dart';
import '../../../models/enums/home_card_type.dart';
import '../../../utils/img_utils.dart';
import '../../../utils/utils.dart';
import '../../ai/anotherme/widgets/li_pop_menu.dart';
import '../../ai/anotherme/widgets/simulate_progress_bar.dart';
import '../../payment.dart';
import '../../share/ShareScreen.dart';
import '../../share/share_discovery_screen.dart';
import '../../transfer/controller/cartoonizer_controller.dart';
import '../../transfer/controller/style_morph_controller.dart';
import '../../transfer/controller/transfer_base_controller.dart';
import '../refcode/submit_invited_code_screen.dart';
import 'im_filter.dart';
import 'im_filter_screen.dart';

class ImEffectScreen extends StatefulWidget {
  final File resultFile;
  final File originFile;
  final TABS tab;
  final String source;
  final String photoType;
  final bool isStyleMorph;

  ImEffectScreen({
    Key? key,
    required this.originFile,
    required this.resultFile,
    this.tab = TABS.EFFECT,
    required this.source,
    required this.photoType,
    this.isStyleMorph = true,
  }) : super(key: key);

  @override
  _ImEffectScreenState createState() => _ImEffectScreenState();
}

class _ImEffectScreenState extends AppState<ImEffectScreen> with SingleTickerProviderStateMixin {
  List<String> _rightTabList = [Images.ic_effect, Images.ic_filter, Images.ic_adjust, Images.ic_crop, Images.ic_background]; //, Images.ic_letter];
  UploadImageController uploadImageController = Get.put(UploadImageController());
  late TransferBaseController controller;
  double itemWidth = ScreenUtil.screenSize.width / 6;
  int generateCount = 0;
  UserManager userManager = AppDelegate.instance.getManager();
  GlobalKey cropKey = GlobalKey();
  bool isFirst = true;

  ImFilterController filterController = Get.put(ImFilterController());

  @override
  void initState() {
    super.initState();
    if (widget.isStyleMorph) {
      controller = Get.find<StyleMorphController>();
    } else {
      controller = Get.find<CartoonizerController>();
    }
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<TransferBaseController>();
    Get.delete<ImFilterController>();
  }

  Future<ui.Image> convertImage(imgLib.Image image) async {
    List<int> pngBytes = imgLib.encodePng(image);
    Uint8List uint8List = Uint8List.fromList(pngBytes);
    ui.Codec codec = await ui.instantiateImageCodec(uint8List);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Widget _buildRightTab() {
    List<Widget> buttons = [];
    int num = 0;
    for (var img in _rightTabList) {
      int cur = num;
      buttons.add(GestureDetector(
        onTap: () {
          setState(() {
            if (isFirst) {
              filterController.filePath = controller.resultFile!.path;
              isFirst = false;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "/ImFilterScreen"),
                builder: (context) => ImFilterScreen(
                  filePath: controller.resultFile!.path,
                  tab: TABS.values[cur],
                  onCallback: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          });
        },
        child: Container(
          width: $(40),
          height: $(40),
          decoration: (TABS.EFFECT == TABS.values[cur])
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF68F0AF), const Color(0xFF05E0D5)],
                  ),
                  borderRadius: BorderRadius.circular($(20)),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular($(20)),
                ),
          child: FractionallySizedBox(
            widthFactor: 0.6,
            heightFactor: 0.6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ));
      num++;
    }

    return Align(
        alignment: Alignment.centerRight,
        child: Container(
            height: $(350),
            width: $(50),
            margin: EdgeInsets.only(right: $(10)),
            child: Column(children: [
              Container(
                  decoration: BoxDecoration(color: Color.fromARGB(100, 22, 44, 33), borderRadius: BorderRadius.all(Radius.circular($(50)))),
                  padding: EdgeInsets.symmetric(horizontal: $(5), vertical: $(10)),
                  height: $(220),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: buttons)),
              SizedBox(height: $(50)),
            ])));
  }

  Future<void> saveToAlbum() async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }
    await showLoading();
    GallerySaver.saveImage(controller.resultMap[controller.selectedEffect!.key]!, albumName: saveAlbumName);
    await hideLoading();
    CommonExtension().showImageSavedOkToast(context);
    Events.styleMorphDownload(type: 'image');
  }

  Widget _buildImageView() {
    return Stack(children: <Widget>[
      Row(
        children: [
          Expanded(
              child: Container(
            key: cropKey,
            margin: EdgeInsets.only(top: $(5)),
            child: Image.file(
              controller.resultFile ?? controller.originFile,
              fit: BoxFit.fitHeight,
            ),
          ))
        ],
      ),
      _buildRightTab()
    ]);
  }

  Widget item(EffectItem data, bool checked) {
    var image = CachedNetworkImageUtils.custom(
      context: context,
      imageUrl: data.imageUrl,
      fit: BoxFit.cover,
      useOld: false,
    );
    if (checked) {
      return Stack(
        fit: StackFit.expand,
        children: [
          image,
          Container(
            color: Color(0x55000000),
            child: Image.asset(
              Images.ic_metagram_yes,
              width: $(22),
            ).intoCenter(),
          ),
        ],
      );
    }
    return image;
  }

  Widget title(String title, bool checked) {
    var text = Text(
      title,
      style: TextStyle(
        color: checked ? ColorConstant.White : ColorConstant.EffectGrey,
        fontSize: $(13),
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
    );
    text;
    if (checked) {
      return ShaderMask(
          shaderCallback: (Rect bounds) => LinearGradient(
                colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Offset.zero & bounds.size),
          blendMode: BlendMode.srcATop,
          child: text);
    } else {
      return text;
    }
  }

  Widget _buildEffectController() {
    return Column(
      children: [
        Container(
          height: $(30),
          padding: EdgeInsets.symmetric(horizontal: $(15)),
          width: ScreenUtil.screenSize.width,
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(
                width: $(10),
              );
            },
            itemBuilder: (context, index) {
              var data = controller.categories[index];
              var checked = controller.selectedTitle == data;
              return title(data.title, checked).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(8)), color: Colors.transparent).intoGestureDetector(
                  onTap: () {
                controller.onTitleSelected(index);
                setState(() {});
              });
            },
            itemCount: controller.categories.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
        Container(
          height: $(80),
          padding: EdgeInsets.symmetric(horizontal: $(15)),
          width: ScreenUtil.screenSize.width,
          child: ListView.separated(
            itemBuilder: (context, index) {
              var data = controller.selectedTitle!.effects[index];
              var checked = data == controller.selectedEffect;
              return SizedBox(
                width: itemWidth,
                height: itemWidth,
                child: Padding(
                  padding: EdgeInsets.all($(2)),
                  child: item(data, checked).intoGestureDetector(onTap: () async {
                    controller.onItemSelected(index);
                    if (controller.selectedEffect != null && controller.resultMap[controller.selectedEffect!.key] == null) {
                      await generate();
                      setState(() {});
                    }
                  }),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                width: $(10),
              );
            },
            itemCount: controller.selectedTitle!.effects.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    ).intoContainer(
      height: $(115),
    );
  }

  generate() async {
    String key = await md5File(controller.originFile);
    var needUpload = await uploadImageController.needUploadByKey(key);
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.cartoonize(context),
    ).then((value) {
      if (value == null) {
      } else if (value.result) {
        generateCount++;
        if (generateCount - 1 > 0) {
          controller.onGenerateAgainSuccess(time: generateCount - 1, source: widget.source, style: widget.photoType);
        }
        setState(() {});
      } else {
        if (value.error != null) {
          showLimitDialog(context, value.error!);
        }
      }
    });
    if (needUpload) {
      EffectManager effectManager = AppDelegate().getManager();
      var imageSize = effectManager.data?.imageMaxl ?? 512;
      File compressedImage = await imageCompressAndGetFile(controller.originFile, imageSize: imageSize);
      await uploadImageController.uploadCompressedImage(compressedImage, key: key);
      if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
        simulateProgressBarController.onError();
      } else {
        simulateProgressBarController.uploadComplete();
      }
    }
    if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
      return;
    }
    var cachedId = await uploadImageController.getCachedIdByKey(key);
    controller.startTransfer(uploadImageController.imageUrl.value, cachedId, onFailed: (response) {
      uploadImageController.deleteUploadData(controller.originFile, key: key);
    }).then((value) {
      if (value != null) {
        if (value.entity != null) {
          simulateProgressBarController.loadComplete();
          controller.onGenerateSuccess(
            source: widget.source,
            style: widget.photoType,
          );
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
                  type.getContent(context, 'Style Morph'),
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
                logPreLoginAction: 'stylemorph_generate_limit',
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
                logPreLoginAction: 'filter_stylemorph_generate_limit',
                callback: () {
                  PaymentUtils.pay(context, 'filter_stylemorph_generate_limit').then((value) {
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
        userManager.doOnLogin(context, logPreLoginAction: 'filter_stylemorph/facetoon_generate_limit', callback: () {
          Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
          EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.MINE.id()]));
          delay(() => SubmitInvitedCodeScreen.push(Get.context!), milliseconds: 500);
          // Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
        }, autoExec: true);
      }
    });
  }

  shareToDiscovery(BuildContext context) async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }

    if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
      await showLoading();
      String key = await md5File(controller.originFile);
      var needUpload = await uploadImageController.needUploadByKey(key);
      if (needUpload) {
        File compressedImage = await imageCompressAndGetFile(controller.originFile);
        await uploadImageController.uploadCompressedImage(compressedImage, key: key);
        await hideLoading();
        if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
          return;
        }
      } else {
        await hideLoading();
      }
    }
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_cartoonize', callback: () {
      var file = File(controller.resultMap[controller.selectedEffect!.key]!);
      ShareDiscoveryScreen.push(
        context,
        effectKey: controller.selectedEffect!.key,
        originalUrl: uploadImageController.imageUrl.value,
        image: base64Encode(file.readAsBytesSync()),
        isVideo: false,
        category: widget.isStyleMorph ? HomeCardType.stylemorph : HomeCardType.cartoonize,
      ).then((value) {
        if (value ?? false) {
          controller.onResultShare(source: widget.photoType, platform: 'effect', photo: 'image');
          showShareSuccessDialog(context);
        }
      });
    }, autoExec: true);
  }

  shareOut(BuildContext context) async {
    if (controller.selectedEffect == null) {
      CommonExtension().showToast(S.of(context).select_a_style);
      return;
    }

    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var uint8list = await ImageUtils.printStyleMorphDrawData(
        controller.originFile, File(controller.resultMap[controller.selectedEffect!.key]!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    ShareScreen.startShare(context,
        backgroundColor: Color(0x77000000),
        style: controller.selectedEffect!.key,
        image: base64Encode(uint8list),
        isVideo: false,
        originalUrl: null,
        effectKey: controller.selectedEffect!.key, onShareSuccess: (platform) {
      Events.styleMorphCompleteShare(source: widget.photoType, platform: platform, type: 'image');
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backAction: () async {
          Navigator.of(context).pop();
        },
        heroTag: IMAppbarTag,
        middle: Image.asset(Images.ic_download, height: $(24), width: $(24)).intoGestureDetector(
          onTap: () {
            saveToAlbum();
          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        backgroundColor: ColorConstant.BackgroundColor,
        trailing: Image.asset(
          Images.ic_more,
          width: $(24),
        ).intoGestureDetector(onTap: () async {
          LiPopMenu.showLinePop(
            context,
            listData: [
              ListPopItem(
                  text: S.of(context).share_to_discovery,
                  icon: Images.ic_share_discovery,
                  onTap: () {
                    shareToDiscovery(context);
                  }),
              ListPopItem(
                  text: S.of(context).share_out,
                  icon: Images.ic_share,
                  onTap: () {
                    shareOut(context);
                  }),
            ],
          );
        }),
      ),
      body: Column(
        children: [
          Expanded(child: _buildImageView().hero(tag: EffectImageViewTag)),
          // _buildInOutControlPad().hero(tag: EffectInOutControlPadTag),
          // SizedBox(height: $(8)),
          _buildEffectController(),
          SizedBox(height: ScreenUtil.getBottomPadding(context)),
        ],
      ),
    );
  }
}
