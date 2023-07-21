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
import 'package:cartoonizer/views/transfer/cartoonizer/cartoonizer_controller.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Common/Extension.dart';
import '../../../Common/event_bus_helper.dart';
import '../../../Widgets/cacheImage/cached_network_image_utils.dart';
import '../../../Widgets/image/sync_image_provider.dart';
import '../../../app/app.dart';
import '../../../app/cache/cache_manager.dart';
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
import '../refcode/submit_invited_code_screen.dart';
import 'ImFilterScreen.dart';
import 'im_filter.dart';

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
  late StyleMorphController styleMorphController;
  late CartoonizerController cartoonizerController;
  double itemWidth = ScreenUtil.screenSize.width / 6;
  int generateCount = 0;
  UserManager userManager = AppDelegate.instance.getManager();
  GlobalKey cropKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.isStyleMorph) {
      styleMorphController = Get.find();
    } else {
      cartoonizerController = Get.find();
    }
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<StyleMorphController>();
    Get.delete<CartoonizerController>();
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
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "/ImFilterScreen"),
                builder: (context) => ImFilterScreen(
                  filePath: widget.isStyleMorph ? styleMorphController.resultFile!.path : cartoonizerController.resultFile!.path,
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
    if (widget.isStyleMorph) {
      if (styleMorphController.selectedEffect == null) {
        CommonExtension().showToast(S.of(context).select_a_style);
        return;
      }
      await showLoading();
      GallerySaver.saveImage(styleMorphController.resultMap[styleMorphController.selectedEffect!.key]!, albumName: saveAlbumName);
      await hideLoading();
      CommonExtension().showImageSavedOkToast(context);
      Events.styleMorphDownload(type: 'image');
    } else {
      if (cartoonizerController.selectedEffect == null) {
        CommonExtension().showToast(S.of(context).select_a_style);
        return;
      }
      if (cartoonizerController.resultFile == null) {
        CommonExtension().showToast(S.of(context).select_a_style);
        return;
      }
      await showLoading();
      if (cartoonizerController.containsOriginal.value) {
        ui.Image? cropImage;
        if (cropKey.currentContext != null) {
          cropImage = await getBitmapFromContext(cropKey.currentContext!, pixelRatio: 6);
        }
        var resultImage = await SyncFileImage(file: cartoonizerController.resultFile!).getImage();
        var uint8list = await addWaterMark(originalImage: cropImage, image: resultImage.image);
        String imgDir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
        var file = File(imgDir + "${DateTime.now().millisecondsSinceEpoch}.png");
        await file.writeAsBytes(uint8list.toList());
        await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
        file.delete();
      } else {
        GallerySaver.saveImage(cartoonizerController.resultFile!.path, albumName: saveAlbumName);
      }
      await hideLoading();
      CommonExtension().showImageSavedOkToast(context);
      Events.facetoonResultSave(type: 'image');
    }
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
              widget.isStyleMorph ? (styleMorphController.resultFile ?? styleMorphController.originFile) : (cartoonizerController.resultFile ?? cartoonizerController.originFile),
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
              var data = widget.isStyleMorph ? styleMorphController.categories[index] : cartoonizerController.categories[index];
              var checked = widget.isStyleMorph ? (styleMorphController.selectedTitle == data) : (cartoonizerController.selectedTitle == data);
              return title(data.title, checked).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(8)), color: Colors.transparent).intoGestureDetector(
                  onTap: () {
                widget.isStyleMorph ? styleMorphController.onTitleSelected(index) : cartoonizerController.onTitleSelected(index);
                setState(() {});
              });
            },
            itemCount: widget.isStyleMorph ? styleMorphController.categories.length : cartoonizerController.categories.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
        Container(
          height: $(80),
          padding: EdgeInsets.symmetric(horizontal: $(15)),
          width: ScreenUtil.screenSize.width,
          child: ListView.separated(
            itemBuilder: (context, index) {
              var data = widget.isStyleMorph ? styleMorphController.selectedTitle!.effects[index] : cartoonizerController.selectedTitle!.effects[index];
              var checked = widget.isStyleMorph ? data == styleMorphController.selectedEffect : data == cartoonizerController.selectedEffect;
              return SizedBox(
                width: itemWidth,
                height: itemWidth,
                child: Padding(
                  padding: EdgeInsets.all($(2)),
                  child: item(data, checked).intoGestureDetector(onTap: () async {
                    widget.isStyleMorph ? styleMorphController.onItemSelected(index) : cartoonizerController.onItemSelected(index);
                    if (widget.isStyleMorph) {
                      if (styleMorphController.selectedEffect != null && styleMorphController.resultMap[styleMorphController.selectedEffect!.key] == null) {
                        await generate();
                        setState(() {});
                      }
                    } else {
                      if (cartoonizerController.selectedEffect != null && cartoonizerController.resultMap[cartoonizerController.selectedEffect!.key] == null) {
                        await generate();
                        setState(() {});
                      }
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
            itemCount: widget.isStyleMorph ? styleMorphController.selectedTitle!.effects.length : cartoonizerController.selectedTitle!.effects.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    ).intoContainer(
      height: $(115),
    );
  }

  generate() async {
    String key = await md5File(widget.isStyleMorph ? styleMorphController.originFile : cartoonizerController.originFile);
    var needUpload = await uploadImageController.needUploadByKey(key);
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.cartoonize(context),
    ).then((value) {
      if (value == null) {
        // widget.isStyleMorph ? styleMorphController.onError() : cartoonizerController.onError();
      } else if (value.result) {
        Events.styleMorphCompleteSuccess(photo: widget.photoType);
        generateCount++;
        if (generateCount - 1 > 0) {
          Events.metaverseCompleteGenerateAgain(time: generateCount - 1);
        }
        setState(() {});
        // widget.isStyleMorph ? styleMorphController.onSuccess() : cartoonizerController.onSuccess();
      } else {
        // widget.isStyleMorph ? styleMorphController.onError() : cartoonizerController.onError();
        if (value.error != null) {
          showLimitDialog(context, value.error!);
        }
      }
    });
    if (needUpload) {
      EffectManager effectManager = AppDelegate().getManager();
      var imageSize = effectManager.data?.imageMaxl ?? 512;
      File compressedImage = await imageCompressAndGetFile(widget.isStyleMorph ? styleMorphController.originFile : cartoonizerController.originFile, imageSize: imageSize);
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
    if (widget.isStyleMorph) {
      styleMorphController.startTransfer(uploadImageController.imageUrl.value, cachedId, onFailed: (response) {
        uploadImageController.deleteUploadData(styleMorphController.originFile, key: key);
      }).then((value) {
        if (value != null) {
          if (value.entity != null) {
            simulateProgressBarController.loadComplete();
            Events.styleMorphCompleteSuccess(photo: widget.photoType);
            // Events.facetoonGenerated(style: controller.selectedEffect?.key ?? '');
          } else {
            simulateProgressBarController.onError(error: value.type);
          }
        } else {
          simulateProgressBarController.onError();
        }
      });
    } else {
      cartoonizerController.startTransfer(uploadImageController.imageUrl.value, cachedId, onFailed: (response) {
        uploadImageController.deleteUploadData(cartoonizerController.originFile, key: key);
      }).then((value) {
        if (value != null) {
          if (value.entity != null) {
            simulateProgressBarController.loadComplete();
            Events.styleMorphCompleteSuccess(photo: widget.photoType);
          } else {
            simulateProgressBarController.onError(error: value.type);
          }
        } else {
          simulateProgressBarController.onError();
        }
      });
    }
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
    if (widget.isStyleMorph) {
      if (styleMorphController.selectedEffect == null) {
        CommonExtension().showToast(S.of(context).select_a_style);
        return;
      }
    } else {
      if (cartoonizerController.selectedEffect == null) {
        CommonExtension().showToast(S.of(context).select_a_style);
        return;
      }
    }

    if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
      await showLoading();
      String key = await md5File(widget.isStyleMorph ? styleMorphController.originFile : cartoonizerController.originFile);
      var needUpload = await uploadImageController.needUploadByKey(key);
      if (needUpload) {
        File compressedImage = await imageCompressAndGetFile(widget.isStyleMorph ? styleMorphController.originFile : cartoonizerController.originFile);
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
      var file = File(widget.isStyleMorph
          ? styleMorphController.resultMap[styleMorphController.selectedEffect!.key]!
          : cartoonizerController.resultMap[cartoonizerController.selectedEffect!.key]!);
      ShareDiscoveryScreen.push(
        context,
        effectKey: widget.isStyleMorph ? styleMorphController.selectedEffect!.key : cartoonizerController.selectedEffect!.key,
        originalUrl: uploadImageController.imageUrl.value,
        image: base64Encode(file.readAsBytesSync()),
        isVideo: false,
        category: widget.isStyleMorph ? HomeCardType.stylemorph : HomeCardType.cartoonize,
      ).then((value) {
        if (value ?? false) {
          Events.facetoonResultShare(source: widget.photoType, platform: 'discovery', type: 'image');
          showShareSuccessDialog(context);
        }
      });
    }, autoExec: true);
  }

  shareOut(BuildContext context) async {
    if (widget.isStyleMorph) {
      if (styleMorphController.selectedEffect == null) {
        CommonExtension().showToast(S.of(context).select_a_style);
        return;
      }
    } else {
      if (cartoonizerController.selectedEffect == null) {
        CommonExtension().showToast(S.of(context).select_a_style);
        return;
      }
    }

    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var uint8list = await ImageUtils.printStyleMorphDrawData(
        widget.isStyleMorph ? styleMorphController.originFile : cartoonizerController.originFile,
        File(widget.isStyleMorph
            ? styleMorphController.resultMap[styleMorphController.selectedEffect!.key]!
            : cartoonizerController.resultMap[cartoonizerController.selectedEffect!.key]!),
        '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    ShareScreen.startShare(context,
        backgroundColor: Color(0x77000000),
        style: widget.isStyleMorph ? 'StyleMorph' : cartoonizerController.selectedEffect!.key,
        image: base64Encode(uint8list),
        isVideo: false,
        originalUrl: null,
        effectKey: widget.isStyleMorph ? 'StyleMorph' : cartoonizerController.selectedEffect!.key, onShareSuccess: (platform) {
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
