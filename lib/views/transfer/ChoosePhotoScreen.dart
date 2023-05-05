import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/photo_introduction_config.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/admob/reward_interstitial_ads_holder.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/api/transform_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/SignupScreen.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:cartoonizer/views/transfer/choose_video_container.dart';
import 'package:cartoonizer/views/transfer/pick_photo_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../gallery_saver.dart';
import '../../models/OfflineEffectModel.dart';
import '../advertisement/reward_advertisement_screen.dart';
import '../share/ShareScreen.dart';
import 'choose_tab_bar.dart';

enum EntrySource {
  fromDiscovery,
  fromEffect,
}

class ChoosePhotoScreen extends StatefulWidget {
  int tabPos;
  int pos;
  int itemPos;
  EntrySource entrySource;
  RecentEffectModel? recentEffectModel;

  ChoosePhotoScreen({
    Key? key,
    required this.tabPos,
    required this.pos,
    required this.itemPos,
    this.entrySource = EntrySource.fromEffect,
    this.recentEffectModel,
  }) : super(key: key);

  @override
  _ChoosePhotoScreenState createState() => _ChoosePhotoScreenState();
}

class _ChoosePhotoScreenState extends State<ChoosePhotoScreen> with SingleTickerProviderStateMixin {
  var algoName = "";
  var urlFinal = "";
  var _image = "";
  late var rootPath;

  set image(String data) {
    _image = data;
    imageSize = null;
    _cachedImage = null;
  }

  String get image => _image;
  GlobalKey cropKey = GlobalKey();
  var videoPath = "";
  late ImagePicker imagePicker;
  UserManager userManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  final EffectDataController effectDataController = Get.find();
  ChoosePhotoScreenController controller = Get.put(ChoosePhotoScreenController());
  UploadImageController uploadImageController = Get.put(UploadImageController());
  late RecentController recentController;

  late ItemScrollController titleScrollController;
  final ItemPositionsListener titleScrollPositionsListener = ItemPositionsListener.create();
  List<ChooseTabInfo> tabList = [];
  List<ChooseTitleInfo> tabTitleList = [];
  List<ChooseTabItemInfo> tabItemList = [];
  int currentTabIndex = 0;
  int currentTitleIndex = 0;
  var currentItemIndex = 0.obs;

  late double itemWidth;
  late ItemScrollController itemScrollController;
  final ItemPositionsListener itemScrollPositionsListener = ItemPositionsListener.create();
  late VoidCallback itemScrollPositionsListen;

  VideoPlayerController? _videoPlayerController;
  Map<String, OfflineEffectModel> offlineEffect = {};
  Map<String, GlobalKey<EffectVideoPlayerState>> videoKeys = {};

  late RewardInterstitialAdsHolder rewardAdsHolder;
  late StreamSubscription userChangeListener;
  late StreamSubscription userLoginListener;
  _BuildType lastBuildType = _BuildType.waterMark;

  Widget? _cachedImage;
  Size? imageSize;
  late double imgContainerWidth;
  late double imgContainerHeight;

  Widget? get cachedImage {
    if (_cachedImage != null) {
      return _cachedImage!;
    }
    var file = File(image);
    if (lastBuildType == _BuildType.waterMark) {
      _cachedImage = Stack(
        children: [
          Image.file(
            file,
            width: imgContainerWidth,
            height: imgContainerHeight - 24,
            fit: BoxFit.cover,
          ).marginSymmetric(vertical: 12),
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: imgContainerWidth,
                height: imgContainerHeight,
              )),
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                controller.cropImage.value != null
                    ? RepaintBoundary(
                        key: cropKey,
                        child: ClipOval(
                            child: Image.file(
                          controller.cropImage.value!,
                          fit: BoxFit.cover,
                          width: ScreenUtil.screenSize.width - 50,
                        )),
                      ).visibility(
                        visible: false,
                        maintainState: true,
                        maintainSize: true,
                        maintainAnimation: true,
                      )
                    : Container(),
                Image.file(
                  file,
                  width: double.maxFinite,
                  height: imageSize?.height ?? imgContainerHeight,
                ),
                buildCropContainer(),
                Align(
                  child: Image.asset(
                    Images.ic_watermark,
                    width: (imageSize?.width ?? imgContainerWidth) * 0.56,
                  ).intoContainer(margin: EdgeInsets.only(bottom: 7.w), decoration: BoxDecoration(color: Color(0x66000000), borderRadius: BorderRadius.circular(8))),
                  alignment: Alignment.bottomCenter,
                ).visibility(visible: imageSize != null),
              ],
            ).intoContainer(width: double.maxFinite, height: imageSize?.height ?? imgContainerHeight),
          ),
        ],
      ).intoContainer(width: imgContainerWidth, height: imgContainerHeight);
      if (imageSize == null) {
        asyncRefreshImageSize(file);
      }
    } else {
      _cachedImage = Stack(
        children: [
          Image.file(
            file,
            width: imgContainerWidth,
            height: imgContainerHeight - 24,
            fit: BoxFit.fill,
          ).intoContainer(margin: EdgeInsets.symmetric(vertical: 12)),
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: imgContainerWidth,
                height: imgContainerHeight,
              )),
          controller.cropImage.value != null
              ? RepaintBoundary(
                  key: cropKey,
                  child: ClipOval(
                      child: Image.file(
                    controller.cropImage.value!,
                    fit: BoxFit.cover,
                    width: ScreenUtil.screenSize.width - 50,
                  )),
                ).visibility(
                  visible: false,
                  maintainState: true,
                  maintainSize: true,
                  maintainAnimation: true,
                )
              : Container(),
          Image.file(
            file,
            width: imgContainerWidth,
            height: imgContainerHeight,
          ),
          buildCropContainer(),
        ],
      ).intoContainer(width: imgContainerWidth, height: imgContainerHeight);
      if (imageSize == null) {
        asyncRefreshImageSize(file);
      }
    }
    return _cachedImage;
  }

  Widget buildCropContainer() {
    return imageSize != null
        ? (controller.cropImage.value != null && includeOriginalFace())
            ? Positioned(
                child: RepaintBoundary(
                  child: ClipOval(
                      child: Image.file(
                    controller.cropImage.value!,
                    width: imageSize!.width / 5,
                  )),
                ),
                bottom: lastBuildType == _BuildType.waterMark ? (imageSize!.height / 20) : ((imgContainerHeight - imageSize!.height) / 2) + (imageSize!.height / 20),
                left: ((imgContainerWidth - imageSize!.width) / 2) + (imageSize!.width / 20),
              )
            : Container()
        : Container();
  }

  asyncRefreshImageSize(File imageFile) {
    var resolve = FileImage(imageFile).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      var scale = image.image.width / image.image.height;
      if (scale < 0.9) {
        double height = imgContainerHeight;
        double width = height * scale;
        imageSize = Size(width, height);
      } else if (scale > 1.1) {
        double width = imgContainerWidth;
        double height = width / scale;
        imageSize = Size(width, height);
      } else {
        imageSize = Size(imgContainerWidth, imgContainerWidth);
      }
      _cachedImage = null;
      delay(() => setState(() {}));
    }));
  }

  bool lastChangeByTap = false;

  late TransformApi transformApi;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'cartoonize_detail_screen');
    recentController = Get.find();
    transformApi = TransformApi()..bind(this);
    rootPath = cacheManager.storageOperator.recordCartoonizeDir.path;
    tabList = effectDataController.tabList;
    tabTitleList = effectDataController.tabTitleList;
    tabItemList = effectDataController.tabItemList;
    currentTabIndex = widget.tabPos;
    currentTitleIndex = widget.pos;
    currentItemIndex.value = widget.itemPos;
    thirdpartManager.adsHolder.ignore = true;
    itemWidth = (ScreenUtil.screenSize.width - $(90)) / 5;
    imgContainerWidth = ScreenUtil.screenSize.width;
    imgContainerHeight = imgContainerWidth;
    userChangeListener = EventBusHelper().eventBus.on<UserInfoChangeEvent>().listen((event) {
      setState(() {});
    });
    userLoginListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      setState(() {});
    });
    rewardAdsHolder = RewardInterstitialAdsHolder(adId: AdMobConfig.REWARD_PROCESSING_AD_ID);
    rewardAdsHolder.initHolder();

    imagePicker = ImagePicker();
    initTabBar();
    judgeAiServers();
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<ChoosePhotoScreenController>();
    Get.delete<UploadImageController>();
    transformApi.unbind();
    thirdpartManager.adsHolder.ignore = false;
    _videoPlayerController?.dispose();
    rewardAdsHolder.onDispose();
    userChangeListener.cancel();
    userLoginListener.cancel();
    itemScrollPositionsListener.itemPositions.removeListener(itemScrollPositionsListen);
  }

  void judgeAiServers() {
    if (userManager.aiServers.isEmpty) {
      delay(() {
        controller.changeIsLoading(true);
        userManager.refreshUser().then((value) {
          if (value.aiServers.isEmpty) {
            CommonExtension().showToast('Load server config failed');
            Navigator.of(context).pop();
          } else {
            controller.changeIsLoading(false);
            judgeAndOpenPickPhotoDialog();
          }
        });
      });
    } else {
      judgeAndOpenPickPhotoDialog();
    }
  }

  judgeAndOpenPickPhotoDialog() {
    delay(() {
      autoScrollToSelectedIndex();
      uploadImageController.loadImageUploadCache().then((value) {
        refreshLastBuildType();
        if (widget.recentEffectModel != null) {
          controller.updateImageFile(File(widget.recentEffectModel!.originalPath!));
          for (var value in widget.recentEffectModel!.itemList) {
            if (value.isVideo) {
              offlineEffect.addIf(!offlineEffect.containsKey(value.key), value.key!,
                  OfflineEffectModel(data: value.imageData!, imageUrl: '', message: "", hasWatermark: lastBuildType == _BuildType.waterMark, localVideo: true));
            } else {
              if (!value.hasWatermark) {
                offlineEffect.addIf(
                  !offlineEffect.containsKey(value.key),
                  value.key!,
                  OfflineEffectModel(data: value.imageData!, imageUrl: '', message: "", hasWatermark: false),
                );
              } else {
                offlineEffect.addIf(
                  !offlineEffect.containsKey(value.key),
                  value.key!,
                  OfflineEffectModel(data: value.imageData!, imageUrl: '', message: "", hasWatermark: lastBuildType == _BuildType.waterMark),
                );
              }
            }
          }
          controller.changeIsLoading(true);
          controller.changeIsPhotoSelect(true);
          getCartoon(context);
        } else {
          if (!controller.isPhotoSelect.value) {
            pickFromRecent(context);
          }
        }
      });
    });
  }

  initTabBar() {
    titleScrollController = ItemScrollController();
    itemScrollController = ItemScrollController();
    itemScrollPositionsListen = () {
      if (!itemScrollController.isAttached) {
        return;
      }
      if (lastChangeByTap) {
        return;
      }
      int? min;
      int? max;
      var positions = itemScrollPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        min = positions
            .where((ItemPosition position) => position.itemTrailingEdge > 0)
            .reduce((ItemPosition min, ItemPosition position) => position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
            .index;
        max = positions
            .where((ItemPosition position) => position.itemLeadingEdge < 1)
            .reduce((ItemPosition max, ItemPosition position) => position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
            .index;
      }
      if (currentItemIndex.value >= min! && currentItemIndex.value <= max!) {
        return;
      }
      int first = itemScrollPositionsListener.itemPositions.value.first.index;
      int last = itemScrollPositionsListener.itemPositions.value.last.index;
      int scrollPos;
      if (first > last) {
        scrollPos = itemScrollPositionsListener.itemPositions.value.last.index;
      } else {
        scrollPos = itemScrollPositionsListener.itemPositions.value.first.index;
      }
      var firstVisibleData = tabItemList[scrollPos];
      if (firstVisibleData.categoryIndex != currentTitleIndex) {
        setState(() {
          int tabPos = tabList.findPosition((data) => data.key == firstVisibleData.tabKey)!;
          if (currentTabIndex != tabPos) {
            currentTabIndex = tabPos;
          }
          currentTitleIndex = firstVisibleData.categoryIndex;
        });
        titleScrollController.jumpTo(index: firstVisibleData.categoryIndex);
      }
    };
    itemScrollPositionsListener.itemPositions.addListener(itemScrollPositionsListen);
  }

  /// calculate scroll offset in child horizontal list
  void autoScrollToSelectedIndex() {
    currentTabIndex = widget.tabPos;
    currentTitleIndex = widget.pos;
    currentItemIndex.value = widget.itemPos;
    titleScrollController.jumpTo(index: currentTitleIndex);
    itemScrollController.jumpTo(index: currentItemIndex.value);
  }

  Future<bool> _willPopCallback(BuildContext context) async {
    if (controller.isPhotoDone.value) {
      showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: $(20)),
            TitleTextWidget(S.of(context).exit_msg, ColorConstant.White, FontWeight.w600, 18),
            SizedBox(height: $(15)),
            TitleTextWidget(S.of(context).exit_msg1, ColorConstant.HintColor, FontWeight.w400, 14),
            SizedBox(height: $(15)),
            TitleTextWidget(
              S.of(context).exit_editing,
              ColorConstant.White,
              FontWeight.w600,
              16,
            )
                .intoContainer(
              margin: EdgeInsets.symmetric(horizontal: $(25)),
              padding: EdgeInsets.symmetric(vertical: $(10)),
              width: double.maxFinite,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: ColorConstant.BlueColor),
            )
                .intoGestureDetector(onTap: () {
              Navigator.pop(context, true);
            }),
            TitleTextWidget(
              S.of(context).cancel,
              ColorConstant.White,
              FontWeight.w400,
              16,
            ).intoPadding(padding: EdgeInsets.only(top: $(15), bottom: $(25))).intoGestureDetector(onTap: () {
              Navigator.pop(context);
            }),
          ],
        ).intoContainer(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: ColorConstant.EffectFunctionGrey,
            borderRadius: BorderRadius.only(topLeft: Radius.circular($(32)), topRight: Radius.circular($(32))),
          ),
        ),
      ).then((value) {
        if (value ?? false) {
          Navigator.pop(context);
        }
      });
      return false;
    } else {
      return true;
    }
  }

  Future<bool?> showShareDiscoveryDialog(BuildContext context) {
    return showModalBottomSheet<bool>(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleTextWidget('Share with HD, watermark-free image', ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop(true);
              }),
              Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
              TitleTextWidget('Share with watermark', ColorConstant.White, FontWeight.normal, $(17))
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
              padding: EdgeInsets.only(top: $(19), bottom: $(10)),
              decoration: BoxDecoration(
                  color: ColorConstant.EffectFunctionGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular($(24)),
                    topRight: Radius.circular($(24)),
                  )));
        },
        backgroundColor: Colors.transparent);
  }

  showSavePhotoDialog(BuildContext context) {
    if (lastBuildType == _BuildType.hdImage || controller.isVideo.value) {
      Events.facetoonResultSave(type: lastBuildType.name);
      saveToAlbum();
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleTextWidget(S.of(context).save_into_album, ColorConstant.White, FontWeight.normal, $(17))
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  color: Colors.transparent,
                  width: double.maxFinite,
                )
                    .intoGestureDetector(onTap: () async {
                  Navigator.of(context).pop();
                  Events.facetoonResultSave(type: lastBuildType.name);
                  await saveToAlbum();
                }),
                Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(
                  margin: EdgeInsets.symmetric(horizontal: $(25)),
                ),
                TitleTextWidget(S.of(context).save_hd_image, ColorConstant.White, FontWeight.normal, $(17))
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  color: Colors.transparent,
                  width: double.maxFinite,
                )
                    .intoGestureDetector(onTap: () {
                  Navigator.of(context).pop();
                  // to reward or pay
                  RewardAdvertisementScreen.push(
                    context,
                    adsHolder: rewardAdsHolder,
                    watchAdText: S.of(context).watchAdText,
                  ).then((value) {
                    if (value ?? false) {
                      var currentEffect = offlineEffect[tabItemList[currentItemIndex.value].data.key];
                      if (currentEffect != null) {
                        currentEffect.hasWatermark = false;
                      }
                      setState(() {
                        lastBuildType = _BuildType.hdImage;
                        _cachedImage = null;
                        imageSize = null;
                      });
                      Events.facetoonResultSave(type: 'watch_ad_hdImage');
                      saveToAlbum();
                    }
                  });
                }).visibility(visible: userManager.isNeedLogin || userManager.user!.userSubscription.isEmpty),
                Divider(height: 0.5, color: ColorConstant.EffectGrey)
                    .intoContainer(
                      margin: EdgeInsets.symmetric(horizontal: $(25)),
                    )
                    .visibility(visible: userManager.isNeedLogin),
                TitleTextWidget(S.of(context).signup_text, ColorConstant.White, FontWeight.normal, $(17))
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  color: Colors.transparent,
                  width: double.maxFinite,
                )
                    .intoGestureDetector(onTap: () async {
                  Navigator.of(context).pop();
                  GetStorage().write('signup_through', 'result_signup_get_credit');
                  GetStorage().write('login_back_page', '/ChoosePhotoScreen');
                  cacheManager.setString(CacheManager.preSignupAction, 'result_signup_get_credit');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/SignupScreen", arguments: "choose_photo"),
                      builder: (context) => SignupScreen(),
                    ),
                  ).then((value) async {
                    if (userManager.isNeedLogin) {
                      return;
                    }
                    if (lastBuildType == _BuildType.waterMark && getBuildType() == _BuildType.hdImage) {
                      controller.changeIsLoading(true);
                      Events.facetoonResultSave(type: 'sign_hdImage');
                      getCartoon(context, rebuild: true);
                    }
                  });
                }).visibility(visible: userManager.isNeedLogin),
                Container(height: $(10), width: double.maxFinite, color: ColorConstant.BackgroundColor),
                TitleTextWidget(S.of(context).cancel, ColorConstant.White, FontWeight.normal, $(17))
                    .intoContainer(
                  padding: EdgeInsets.only(top: $(10), bottom: $(10) + MediaQuery.of(context).padding.bottom),
                  width: double.maxFinite,
                )
                    .intoGestureDetector(onTap: () {
                  Navigator.of(context).pop();
                }),
              ],
            ).intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.only(top: $(19), bottom: $(10)),
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

  Future<void> saveToAlbum() async {
    var selectedEffect = tabItemList[currentItemIndex.value].data;

    if (controller.isVideo.value) {
      controller.changeIsLoading(true);
      var result = await GallerySaver.saveVideo('${_getAiHostByStyle(selectedEffect)}/resource/' + controller.videoUrl.value, true);
      controller.changeIsLoading(false);
      videoPath = result as String;
      if (result != '') {
        CommonExtension().showVideoSavedOkToast(context);
      } else {
        CommonExtension().showFailedToast(context);
      }
    } else {
      var imageData = (await SyncFileImage(file: File(image)).getImage()).image;
      if (lastBuildType == _BuildType.waterMark) {
        var assetImage = AssetImage(Images.ic_watermark).resolve(ImageConfiguration.empty);
        assetImage.addListener(ImageStreamListener((image, synchronousCall) async {
          ui.Image? cropImage;
          if ((controller.cropImage.value != null && includeOriginalFace())) {
            if (cropKey.currentContext != null) {
              cropImage = await getBitmapFromContext(cropKey.currentContext!);
            }
          }
          var uint8list = await addWaterMark(image: imageData, watermark: image.image, originalImage: cropImage);
          String imgDir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
          var file = File(imgDir + "${DateTime.now().millisecondsSinceEpoch}.png");
          await file.writeAsBytes(uint8list.toList());
          await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
          CommonExtension().showImageSavedOkToast(context);
        }));
      } else {
        ui.Image? cropImage;
        if ((controller.cropImage.value != null && includeOriginalFace())) {
          if (cropKey.currentContext != null) {
            cropImage = await getBitmapFromContext(cropKey.currentContext!);
          }
        }
        var uint8list = await addWaterMark(image: imageData, originalImage: cropImage);
        String imgDir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
        var file = File(imgDir + "${DateTime.now().millisecondsSinceEpoch}.png");
        await file.writeAsBytes(uint8list.toList());
        await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
        CommonExtension().showImageSavedOkToast(context);
      }
    }
    delay(() => userManager.rateNoticeOperator.onSwitch(context), milliseconds: 2000);
  }

  Future<void> shareOut() async {
    var selectedEffect = tabItemList[currentItemIndex.value].data;
    if (controller.isVideo.value) {
      controller.changeIsLoading(true);
      await GallerySaver.saveVideo('${_getAiHostByStyle(selectedEffect)}/resource/' + controller.videoUrl.value, false).then((value) async {
        controller.changeIsLoading(false);
        videoPath = value as String;
        if (value != "") {
          AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
          ShareScreen.startShare(context,
              backgroundColor: Color(0x77000000),
              style: selectedEffect.key,
              image: (controller.isVideo.value) ? videoPath : image,
              isVideo: controller.isVideo.value,
              originalUrl: urlFinal,
              effectKey: selectedEffect.key, onShareSuccess: (platform) {
            Events.facetoonResultShare(platform: platform);
          });
          AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
        } else {
          CommonExtension().showToast(S.of(context).commonFailedToast);
        }
      });
    } else {
      AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
      controller.changeIsLoading(true);
      var newImage = await composeImageWithWatermark();
      controller.changeIsLoading(false);
      ShareScreen.startShare(context,
          backgroundColor: Color(0x77000000),
          style: selectedEffect.key,
          image: (controller.isVideo.value) ? videoPath : newImage,
          isVideo: controller.isVideo.value,
          originalUrl: urlFinal,
          effectKey: selectedEffect.key, onShareSuccess: (platform) {
        Events.facetoonResultShare(platform: platform);
      }).then((value) {
        AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
      });
    }
  }

  correctTitlePosition(int lastPos) {
    if (!(lastPos > tabTitleList.length - 5 && currentTitleIndex > tabTitleList.length - 5)) {
      titleScrollController.jumpTo(index: currentTitleIndex);
    }
  }

  correctItemPosition(int lastPos) {
    if (!(lastPos > tabItemList.length - 5 && currentItemIndex > tabItemList.length - 5)) {
      itemScrollController.jumpTo(index: currentItemIndex.value);
    }
  }

  Future<void> shareToDiscovery() async {
    var selectedEffect = tabItemList[currentItemIndex.value].data;
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_facetoon', currentPageRoute: '/ChoosePhotoScreen',
        callback: () async {
      if (controller.isVideo.value) {
        var videoUrl = '${_getAiHostByStyle(selectedEffect)}/resource/' + controller.videoUrl.value;
        ShareDiscoveryScreen.push(
          context,
          effectKey: selectedEffect.key,
          originalUrl: urlFinal,
          image: videoUrl,
          isVideo: true,
          category: DiscoveryCategory.cartoonize,
        ).then((value) {
          if (value ?? false) {
            Events.facetoonResultShare(platform: 'discovery');
            showShareSuccessDialog(context);
          }
        });
      } else {
        controller.changeIsLoading(true);
        var newImage = await composeImageWithWatermark();
        controller.changeIsLoading(false);
        ShareDiscoveryScreen.push(
          context,
          effectKey: selectedEffect.key,
          originalUrl: urlFinal,
          image: newImage,
          isVideo: false,
          category: DiscoveryCategory.cartoonize,
        ).then((value) {
          if (value ?? false) {
            Events.facetoonResultShare(platform: 'discovery');
            showShareSuccessDialog(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var content = Obx(
      () => LoadingOverlay(
          isLoading: controller.isLoading.value,
          child: Scaffold(
            backgroundColor: ColorConstant.BackgroundColor,
            appBar: AppNavigationBar(
              backAction: () async {
                if (await _willPopCallback(context)) {
                  Navigator.of(context).pop();
                }
              },
              backgroundColor: ColorConstant.BackgroundColor,
              trailing: Image.asset(
                Images.ic_share,
                width: $(24),
              ).intoGestureDetector(onTap: () async {
                shareOut();
              }).offstage(offstage: !controller.isPhotoDone.value),
            ),
            body: Column(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    controller.isPhotoDone.value
                        ? Container(
                            child: (controller.isVideo.value && _videoPlayerController != null)
                                ? ChooseVideoContainer(videoPlayerController: _videoPlayerController!, width: imgContainerWidth, height: imgContainerWidth)
                                : Center(child: cachedImage ?? SizedBox.shrink()),
                          )
                        : controller.isPhotoSelect.value
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    controller.image.value as File,
                                    fit: BoxFit.cover,
                                    width: imgContainerWidth,
                                    height: imgContainerHeight,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      Images.ic_loading_filled,
                                      color: ColorConstant.White,
                                    )
                                        .intoContainer(
                                            padding: EdgeInsets.all(12),
                                            height: imgContainerWidth / 5.2,
                                            width: imgContainerWidth / 5.2,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: Color(0x66000000),
                                            ))
                                        .intoGestureDetector(onTap: () {
                                      controller.changeIsLoading(true);
                                      getCartoon(context);
                                    }).visibility(visible: !controller.isLoading.value && !controller.transingImage.value),
                                  ),
                                ],
                              ).intoContainer(width: imgContainerWidth, height: imgContainerHeight)
                            : Expanded(
                                child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ClipRRect(
                                    child: Image.asset(
                                      (PhotoIntroductionConfig[tabTitleList[currentTitleIndex].categoryKey] ?? defaultPhotoIntroductionConfig)['image']!,
                                      height: imgContainerWidth - $(60),
                                      width: imgContainerWidth - $(60),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ).intoContainer(margin: EdgeInsets.only(top: $(25))),
                                  Expanded(
                                      child: Text(
                                    (PhotoIntroductionConfig[tabTitleList[currentTitleIndex].categoryKey] ?? defaultPhotoIntroductionConfig)['text']!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      height: 1,
                                      fontSize: 21,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Color(0xffc4400c),
                                          blurRadius: 6,
                                          offset: Offset(4, 0),
                                        ),
                                        Shadow(
                                          color: Color(0xffc4400c),
                                          blurRadius: 6,
                                          offset: Offset(-4, 0),
                                        ),
                                      ],
                                    ),
                                  ).intoContainer(
                                    alignment: Alignment.center,
                                  )),
                                ],
                              )),
                  ],
                ).listenSizeChanged(onSizeChanged: (size) {
                  setState(() {
                    imgContainerWidth = size.width;
                    imgContainerHeight = size.height - 20;
                  });
                })),
                Obx(() => buildSuccessFunctions(context)),
                SizedBox(height: $(8)),
                ScrollablePositionedList.separated(
                  initialScrollIndex: 0,
                  itemCount: tabTitleList.length,
                  scrollDirection: Axis.horizontal,
                  itemScrollController: titleScrollController,
                  itemPositionsListener: titleScrollPositionsListener,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var checked = currentTitleIndex == index;
                    return (checked
                            ? ShaderMask(
                                shaderCallback: (Rect bounds) => LinearGradient(
                                      colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(Offset.zero & bounds.size),
                                blendMode: BlendMode.srcATop,
                                child: Text(
                                  tabTitleList[index].title,
                                  style: TextStyle(
                                    color: checked ? ColorConstant.White : ColorConstant.EffectGrey,
                                    fontSize: $(12),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ))
                            : Text(
                                tabTitleList[index].title,
                                style: TextStyle(
                                  color: checked ? ColorConstant.White : ColorConstant.EffectGrey,
                                  fontSize: $(12),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ))
                        .intoGestureDetector(onTap: () {
                      if (checked) {
                        return;
                      }
                      lastChangeByTap = true;
                      setState(() {
                        currentTitleIndex = index;
                        int tabPos = tabList.findPosition((data) => data.key == tabTitleList[currentTitleIndex].tabKey)!;
                        if (currentTabIndex != tabPos) {
                          currentTabIndex = tabPos;
                        }
                        int itemPos = tabItemList.findPosition((data) => data.categoryIndex == currentTitleIndex)!;
                        if (itemPos > tabItemList.length - 4) {
                          itemScrollController.jumpTo(index: tabItemList.length - 4, alignment: 0.08);
                        } else {
                          itemScrollController.jumpTo(index: itemPos);
                        }
                      });
                      delay(() {
                        lastChangeByTap = false;
                      }, milliseconds: 32);
                    }).intoContainer(
                            margin: EdgeInsets.only(
                      left: index == 0 ? $(20) : $(12),
                      right: index == tabItemList.length - 1 ? $(20) : $(12),
                    ));
                  },
                  separatorBuilder: (context, index) => Container(),
                ).intoContainer(
                  height: $(28),
                ),
                ScrollablePositionedList.separated(
                  initialScrollIndex: 0,
                  itemCount: tabItemList.length,
                  scrollDirection: Axis.horizontal,
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemScrollPositionsListener,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildTabItem(context, index, itemWidth).intoContainer(
                        margin: EdgeInsets.only(
                      left: index == 0 ? $(15) : 0,
                      right: index == tabItemList.length - 1 ? $(15) : 0,
                    ));
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    if (index == tabItemList.length - 1) {
                      return Container();
                    } else {
                      var current = tabItemList[index];
                      var next = tabItemList[index + 1];
                      if (next.categoryKey == current.categoryKey) {
                        return Container();
                      } else {
                        return VerticalDivider(
                          color: ColorConstant.HintColor,
                          width: $(3),
                          indent: $(12),
                          endIndent: $(12),
                          thickness: 2,
                        );
                      }
                    }
                  },
                ).intoContainer(
                  height: itemWidth + $(4),
                ),
                ChooseTabBar(
                    height: $(36),
                    tabList: tabList.map((e) => e.title.intl).toList(),
                    currentIndex: currentTabIndex,
                    scrollable: tabList.length > 3,
                    onTabClick: (index) {
                      lastChangeByTap = true;
                      setState(() {
                        currentTabIndex = index;
                        int categoryPos = tabTitleList.findPosition((data) => data.tabKey == tabList[index].key)!;
                        if (categoryPos > tabTitleList.length - 4) {
                          titleScrollController.jumpTo(index: tabTitleList.length - 4, alignment: 0.08);
                        } else {
                          titleScrollController.jumpTo(index: categoryPos);
                        }
                        currentTitleIndex = categoryPos;
                        int tabItemPos = tabItemList.findPosition((data) => data.tabKey == tabList[index].key)!;
                        if (tabItemPos > tabItemList.length - 4) {
                          itemScrollController.jumpTo(index: tabItemList.length - 4, alignment: 0.08);
                        } else {
                          itemScrollController.jumpTo(index: tabItemPos);
                        }
                        if (!controller.isPhotoSelect.value) {
                          currentItemIndex.value = tabItemPos;
                        }
                      });
                      delay(() {
                        lastChangeByTap = false;
                      }, milliseconds: 32);
                    }).visibility(visible: tabList.length > 1),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ).ignore(ignoring: controller.isLoading.value)),
    );
    if (TextUtil.isEmpty(_image)) {
      return content;
    } else {
      return WillPopScope(
        onWillPop: () async {
          return _willPopCallback(context);
        },
        child: content,
      );
    }
  }

  Widget _buildTabItem(BuildContext context, int index, double size) {
    var effect = tabItemList[index];
    var effectItem = effect.data;
    var checked = currentItemIndex == index;
    Widget icon = OutlineWidget(
        radius: $(1),
        strokeWidth: 2,
        gradient: LinearGradient(
          colors: [checked ? Color(0xffE31ECD) : Colors.transparent, checked ? Color(0xff243CFF) : Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular($(1)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: _createEffectModelIcon(context, effectItem: effectItem, checked: checked),
            ),
            Visibility(
              visible: (effectItem.key.endsWith("-transform")),
              child: Positioned(
                right: $(3.6),
                top: $(1),
                child: Image.asset(
                  ImagesConstant.ic_video,
                  height: $(18),
                  width: $(18),
                ),
              ),
            ),
            if (includeOriginalFace(effect: effectItem))
              Positioned(
                bottom: $(1),
                left: $(3.6),
                child: controller.cropImage.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular($(36)),
                        child: Image.file(
                          controller.cropImage.value as File,
                          fit: BoxFit.fill,
                          height: $(18),
                          width: $(18),
                        ),
                      )
                    : SizedBox(),
              ),
          ],
        ).intoContainer(
          padding: EdgeInsets.all($(2)),
          width: size + $(4),
          height: size + $(4),
        ));

    return icon.intoGestureDetector(onTap: () async {
      lastChangeByTap = true;
      int lastTitlePos = currentTitleIndex;
      setState(() {
        if (effect.tabKey != tabList[currentTabIndex].key) {
          currentTabIndex = tabList.findPosition((data) => data.key == effect.tabKey)!;
        }
        currentItemIndex.value = index;
        currentTitleIndex = effect.categoryIndex;
      });

      correctTitlePosition(lastTitlePos);

      if (controller.image.value != null) {
        controller.changeIsPhotoSelect(true);
        controller.changeIsLoading(true);
        getCartoon(context);
      }
      delay(() {
        lastChangeByTap = false;
      }, milliseconds: 64);
    });
  }

  Widget buildSuccessFunctions(BuildContext context) => controller.isPhotoSelect.value
      ? Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    controller.isChecked.value ? ImagesConstant.ic_checked : ImagesConstant.ic_unchecked,
                    width: 17,
                    height: 17,
                  ),
                  SizedBox(width: $(6)),
                  TitleTextWidget(S.of(context).in_original, ColorConstant.BtnTextColor, FontWeight.w500, 14),
                  SizedBox(width: $(20)),
                ],
              ).intoGestureDetector(onTap: () async {
                if (controller.isChecked.value) {
                  controller.changeIsChecked(false);
                } else {
                  controller.changeIsChecked(true);
                }
                if (controller.isPhotoSelect.value) {
                  if (controller.cropImage.value == null) {
                    controller.changeIsLoading(true);
                    getCartoon(context);
                  } else {
                    setState(() {
                      _cachedImage = null;
                    });
                  }
                }
              }).offstage(offstage: !tabItemList[currentItemIndex.value].data.originalFace),
            ),
            Obx(
              () => Container(
                height: $(16),
                width: $(2),
                color: ColorConstant.White,
              ).offstage(offstage: !tabItemList[currentItemIndex.value].data.originalFace),
            ),
            Expanded(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => Image.asset(Images.ic_camera, height: $(24), width: $(24))
                      .intoGestureDetector(
                        // onTap: () => showPickPhotoDialog(context),
                        onTap: () => pickFromRecent(context),
                      )
                      .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)))
                      .visibility(visible: controller.isPhotoSelect.value),
                ),
                Obx(
                  () => Image.asset(Images.ic_download, height: $(24), width: $(24))
                      .intoGestureDetector(
                        onTap: () => showSavePhotoDialog(context),
                      )
                      .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)))
                      .visibility(visible: controller.isPhotoDone.value),
                ),
                Obx(() => Image.asset(Images.ic_share_discovery, height: $(24), width: $(24))
                    .intoGestureDetector(
                      onTap: () {
                        shareToDiscovery();
                      },
                    )
                    .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)))
                    .visibility(visible: controller.isPhotoDone.value)),
              ],
            ))
          ],
        )
          .intoContainer(
            margin: EdgeInsets.only(top: $(10), left: $(23), right: $(23), bottom: $(10)),
          )
          .visibility(visible: controller.isPhotoSelect.value)
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(Images.ic_camera, width: $(24)),
            SizedBox(width: $(8)),
            Text(
              S.of(context).choose_photo,
              style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(16), fontWeight: FontWeight.w600),
            ),
          ],
        )
          .intoContainer(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(vertical: $(10)),
              margin: EdgeInsets.only(bottom: $(10), left: $(30), right: $(30)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstant.DiscoveryBtn,
                borderRadius: BorderRadius.circular($(8)),
              ))
          .intoGestureDetector(onTap: () {
          pickFromRecent(context);
        }).visibility(
          visible: true,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
        );

  Widget _createEffectModelIcon(BuildContext context, {required EffectItem effectItem, required bool checked}) {
    if (effectItem.imageUrl.contains("mp4")) {
      var key = videoKeys[effectItem.imageUrl];
      if (key == null) {
        key = GlobalKey<EffectVideoPlayerState>();
        videoKeys[effectItem.imageUrl] = key;
      }
      if (checked) {
        delay(() => key!.currentState?.play(), milliseconds: 32);
      } else {
        key.currentState?.pause();
      }
      return Container(
        width: itemWidth,
        height: itemWidth,
        child: EffectVideoPlayer(
          url: effectItem.imageUrl,
          key: key,
        ),
      );
    } else {
      return _imageWidget(context, imageUrl: effectItem.imageUrl);
    }
  }

  Widget _imageWidget(BuildContext context, {required String imageUrl}) {
    return CachedNetworkImageUtils.custom(
      useOld: true,
      context: context,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      height: itemWidth,
      width: itemWidth,
      placeholder: (context, url) {
        return Container(
          height: itemWidth,
          width: itemWidth,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          height: itemWidth,
          width: itemWidth,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  bool _judgeAndShowAdvertisement({
    required Function onSuccess,
    required Function onCancel,
    Function? onFail,
  }) {
    // if (!isShowAdsNew(type: AdType.processing)) {
    //   return false;
    // }
    // ProcessingAdvertisementScreen.push(context, adsHolder: adsHolder).then((value) {
    //   if (value == null) {
    //     onCancel.call();
    //   } else if (value) {
    //     onSuccess.call();
    //   } else {
    //     onFail?.call();
    //   }
    //   if (!adsHolder.adsReady) {
    //     adsHolder.initHolder();
    //   }
    // });
    return false;
  }

  Future<bool> pickImageFromGallery(BuildContext context, {String from = "center", File? file, UploadRecordEntity? entity}) async {
    var source = ImageSource.gallery;
    try {
      File compressedImage;
      if (file != null) {
        compressedImage = await imageCompressAndGetFile(file);
        if (controller.image.value != null) {
          File oldFile = controller.image.value as File;
          if ((await md5File(oldFile)) == (await md5File(compressedImage))) {
            CommonExtension().showToast(S.of(context).photo_select_already);
            return false;
          }
        }
        controller.updateImageFile(compressedImage);
        controller.updateImageUrl("");
      } else if (entity == null) {
        XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
        if (image == null) {
          CommonExtension().showToast("cancelled");
          return false;
        }
        compressedImage = await imageCompressAndGetFile(File(image.path));
        if (controller.image.value != null) {
          File oldFile = controller.image.value as File;
          if ((await md5File(oldFile)) == (await md5File(compressedImage))) {
            CommonExtension().showToast(S.of(context).photo_select_already);
            return false;
          }
        }
        controller.updateImageFile(compressedImage);
        controller.updateImageUrl("");
      } else {
        controller.updateImageFile(File(entity.fileName));
        controller.updateImageUrl("");
      }
      controller.changeIsLoading(true);
      offlineEffect.clear();
      controller.changeIsPhotoSelect(true);
      controller.changeIsPhotoDone(false);
      getCartoon(context);
      return true;
    } on PlatformException catch (error) {
      if (error.code == "photo_access_denied") {
        showPhotoLibraryPermissionDialog(context);
      }
    } catch (error) {
      CommonExtension().showToast("Try to select valid image");
    }
    return false;
  }

  Future<bool> pickImageFromCamera(BuildContext context, {String from = "center"}) async {
    var source = ImageSource.camera;
    try {
      XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
      if (image == null) {
        CommonExtension().showToast("cancelled");
        return false;
      }
      controller.changeIsLoading(true);
      File compressedImage = await imageCompressAndGetFile(File(image.path));

      offlineEffect.clear();
      controller.updateImageFile(compressedImage);
      controller.updateImageUrl("");
      controller.changeIsPhotoSelect(true);
      controller.changeIsPhotoDone(false);
      getCartoon(context);
      return true;
    } on PlatformException catch (error) {
      if (error.code == "camera_access_denied") {
        showCameraPermissionDialog(context);
      }
    } catch (error) {
      CommonExtension().showToast("Try to select valid image");
    }
    return false;
  }

  refreshLastBuildType() {
    setState(() {
      lastBuildType = getBuildType();
    });
  }

  _BuildType getBuildType() {
    if (userManager.adConfig.processing == 0) {
      return _BuildType.hdImage;
    }
    if (userManager.isNeedLogin) {
      return _BuildType.waterMark;
    } else {
      var socialUserInfo = userManager.user!;
      if (socialUserInfo.cartoonizeCredit <= 0) {
        return _BuildType.waterMark;
      } else {
        return _BuildType.hdImage;
      }
    }
  }

  EffectModel? findCategory(EffectItem effectItem) {
    EffectModel? category;
    var selectedEffect = tabItemList[currentItemIndex.value].data;
    bool find = false;
    for (var element in effectDataController.data!.allEffectList()) {
      if (find) {
        break;
      }
      for (var value in element.effects.values) {
        if (value.key == selectedEffect.key) {
          find = true;
          category = element;
          break;
        }
      }
    }
    return category;
  }

  Future<void> getCartoon(BuildContext context, {bool rebuild = false}) async {
    refreshLastBuildType();
    await controller.saveOriginalIfNotExist();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      controller.changeIsLoading(false);
      CommonExtension().showToast(S.of(context).no_internet_msg);
      return;
    }

    var selectedEffect = tabItemList[currentItemIndex.value].data;
    EffectModel? category = findCategory(selectedEffect);
    if (category == null) {
      controller.changeIsLoading(false);
      // CommonExtension().showToast(S.of(context).commonFailedToast);
      CommonExtension().showToast('cannot find category');
      return;
    }
    String aiHost = _getAiHostByStyle(selectedEffect);

    // var key = includeOriginalFace() ? selectedEffect.key + "-original_face" : selectedEffect.key;
    var key = selectedEffect.key;

    if (offlineEffect.containsKey(key) && !rebuild) {
      var data = offlineEffect[key] as OfflineEffectModel;
      if (data.data.toString().startsWith('<')) {
        controller.changeIsLoading(false);
        CommonExtension().showToast(data.data.toString().substring(data.data.toString().indexOf('<p>') + 3, data.data.toString().indexOf('</p>')));
      } else if (data.data.toString() == "") {
        controller.changeIsLoading(false);
        CommonExtension().showToast(data.message);
      } else if (data.data.toString().contains(".mp4")) {
        if (data.localVideo) {
          initVideoPlayerFromFile(File(data.data));
        } else {
          controller.updateVideoUrl(data.data);
          await initVideoPlayerFromNet(aiHost);
        }

        urlFinal = data.imageUrl;
        algoName = selectedEffect.algoname;
        controller.changeIsPhotoDone(true);
        controller.changeIsVideo(true);
      } else {
        controller.changeIsLoading(false);
        image = data.data;
        urlFinal = data.imageUrl;
        algoName = selectedEffect.algoname;
        controller.changeIsPhotoDone(true);
        controller.changeIsVideo(false);
      }
      lastBuildType = data.hasWatermark ? _BuildType.waterMark : _BuildType.hdImage;
      setState(() {});
    } else {
      Function? successForward;
      SimulateProgressBarController progressBarController = SimulateProgressBarController();
      try {
        var imageUrl = controller.imageUrl.value;
        await controller.buildCropFile();
        controller.changeIsLoading(false);
        controller.changeTransingImage(true);
        bool needUpload = await uploadImageController.needUpload(controller.image.value);
        SimulateProgressBar.startLoading(context, needUploadProgress: needUpload, controller: progressBarController, config: SimulateProgressBarConfig.cartoonize(context));
        if (imageUrl == "") {
          await uploadImageController.uploadCompressedImage(controller.image.value);
          controller.updateImageUrl(uploadImageController.imageUrl.value);
          imageUrl = controller.imageUrl.value;
          progressBarController.uploadComplete();
        }

        if (imageUrl == "") {
          progressBarController.onError();
          await delay(() => {}, milliseconds: 200);
          controller.changeTransingImage(false);
          EventBusHelper().eventBus.fire(OnCartoonizerFinishedEvent(data: false));
          return;
        }

        var sharedPrefs = await SharedPreferences.getInstance();
        final tokenResponse = await API.get("/api/tool/image/cartoonize/token");
        final Map tokenParsed = json.decode(tokenResponse.body.toString());

        int resultSuccess = 0;

        if (tokenResponse.statusCode == 200) {
          if (tokenParsed['data'] == null) {
            List<String> imageArray = ["$imageUrl"];
            String? cachedId = await uploadImageController.getCachedId(controller.image.value);
            var dataBody = {
              'querypics': imageArray,
              'is_data': 0,
              // 'algoname': includeOriginalFace() ? selectedEffect.algoname + "-original_face" : selectedEffect.algoname,
              'algoname': selectedEffect.algoname,
              'direct': 1,
              'hide_watermark': 1,
            };
            if (!TextUtil.isEmpty(cachedId)) {
              dataBody['cache_id'] = cachedId!;
            }
            selectedEffect.handleApiParams(dataBody);
            var rootPath = cacheManager.storageOperator.recordCartoonizeDir.path;
            var baseEntity = await transformApi.transform(
              aiHost.cartoonizeApi,
              rootPath,
              dataBody,
              aiHost: aiHost,
            );
            if (baseEntity != null) {
              final Map parsed = baseEntity.data;
              var cachedId = parsed['cache_id']?.toString();
              if (!TextUtil.isEmpty(cachedId)) {
                uploadImageController.updateCachedId(controller.image.value, cachedId!);
              }
              var dataString = parsed['data'].toString();
              var dataEncode = EncryptUtil.encodeMd5(dataString);
              if (dataString.startsWith('<')) {
                successForward = () async {
                  progressBarController.onError();
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key,
                      OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: "", hasWatermark: lastBuildType == _BuildType.waterMark));
                  CommonExtension().showToast(dataString.substring(dataString.indexOf('<p>') + 3, dataString.indexOf('</p>')));
                };
              } else if (dataString == "") {
                successForward = () async {
                  progressBarController.onError();
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key,
                      OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: parsed['message'], hasWatermark: lastBuildType == _BuildType.waterMark));
                  CommonExtension().showToast(parsed['message']);
                };
              } else if (dataString.contains(".mp4")) {
                successForward = () async {
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key,
                      OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: "", hasWatermark: lastBuildType == _BuildType.waterMark));
                  controller.updateVideoUrl(parsed['data']);
                  await initVideoPlayerFromNet(aiHost);

                  urlFinal = imageUrl;
                  algoName = selectedEffect.algoname;
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(true);
                };
              } else {
                successForward = () async {
                  progressBarController.onError();
                  var fileName = transformApi.getFileName(rootPath, dataEncode);
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key,
                      OfflineEffectModel(data: fileName, imageUrl: imageUrl, message: "", hasWatermark: lastBuildType == _BuildType.waterMark));
                  image = fileName;
                  urlFinal = imageUrl;
                  algoName = selectedEffect.algoname;
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(false);
                  var params = {"algoname": selectedEffect.algoname};
                  API.get("/api/log/cartoonize", params: params);
                };
              }
              progressBarController.loadComplete();
              await successForward.call();
              controller.changeTransingImage(false);
              setState(() {});
              onSwitchOnce();
              resultSuccess = 1;
            } else {
              progressBarController.onError();
              controller.changeTransingImage(false);
              // CommonExtension().showToast('Error while processing image, HttpCode: ${cartoonizeResponse.statusCode}');
            }
          } else {
            var token = tokenParsed['data'];
            List<String> imageArray = ["$imageUrl"];

            var dataBody = {
              'querypics': imageArray,
              'is_data': 0,
              // 'algoname': includeOriginalFace() ? selectedEffect.algoname + "-original_face" : selectedEffect.algoname,
              'algoname': selectedEffect.algoname,
              'direct': 1,
              'token': token,
              'hide_watermark': 1,
            };
            selectedEffect.handleApiParams(dataBody);
            var baseEntity = await transformApi.transform('${aiHost}/api/image/cartoonize/token', rootPath, dataBody, aiHost: aiHost);
            if (baseEntity != null) {
              final Map parsed = baseEntity.data;
              var dataEncode = EncryptUtil.encodeMd5(parsed['data'].toString());
              if (parsed['data'].toString().startsWith('<')) {
                successForward = () async {
                  progressBarController.onError();
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key,
                      OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: "", hasWatermark: lastBuildType == _BuildType.waterMark));
                  CommonExtension().showToast(parsed['data'].toString().substring(parsed['data'].toString().indexOf('<p>') + 3, parsed['data'].toString().indexOf('</p>')));
                };
              } else if (parsed['data'].toString() == "") {
                successForward = () async {
                  progressBarController.onError();
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key,
                      OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: parsed['message'], hasWatermark: lastBuildType == _BuildType.waterMark));
                  CommonExtension().showToast(parsed['message']);
                };
              } else if (parsed['data'].toString().contains(".mp4")) {
                successForward = () async {
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key,
                      OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: "", hasWatermark: lastBuildType == _BuildType.waterMark));
                  controller.updateVideoUrl(parsed['data']);
                  await initVideoPlayerFromNet(aiHost);
                  urlFinal = imageUrl;
                  algoName = selectedEffect.algoname;
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(true);
                };
              } else {
                var fileName = transformApi.getFileName(rootPath, dataEncode);
                successForward = () async {
                  progressBarController.onError();
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key,
                      OfflineEffectModel(data: fileName, imageUrl: imageUrl, message: "", hasWatermark: lastBuildType == _BuildType.waterMark));
                  image = fileName;
                  urlFinal = imageUrl;
                  algoName = selectedEffect.algoname;
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(false);
                  var params = {"algoname": selectedEffect.algoname};
                  API.get("/api/log/cartoonize", params: params);
                };
              }

              progressBarController.loadComplete();
              await successForward.call();
              controller.changeTransingImage(false);
              onSwitchOnce();
              resultSuccess = 1;
            } else {
              progressBarController.onError();
              controller.changeTransingImage(false);
            }
          }
        } else {
          progressBarController.onError();
          controller.changeTransingImage(false);
          var responseBody = json.decode(tokenResponse.body);
          if (responseBody['code'] == 'DAILY_IP_LIMIT_EXCEEDED') {
            bool isLogin = sharedPrefs.getBool("isLogin") ?? false;

            if (!isLogin) {
              showDialogLogin(context, sharedPrefs);
            } else {
              CommonExtension().showToast(S.of(context).DAILY_IP_LIMIT_EXCEEDED);
            }
          } else {
            CommonExtension().showToast(responseBody['message']);
          }
        }

        EventBusHelper().eventBus.fire(OnCartoonizerFinishedEvent(data: resultSuccess == 1));

        if (resultSuccess == 1) {
          Events.facetoonGenerated(style: selectedEffect.key);
          if (TextUtil.isEmpty(controller.videoFile.value?.path) || TextUtil.isEmpty(_image)) {
            return;
          }
          recentController.onEffectUsed(
            selectedEffect,
            original: controller.image.value!,
            imageData: controller.isVideo.value ? controller.videoFile.value!.path : _image,
            isVideo: controller.isVideo.value,
            hasWatermark: lastBuildType == _BuildType.waterMark,
          );
        }
      } catch (e) {
        print(e);
        progressBarController.onError();
        controller.changeTransingImage(false);
        CommonExtension().showToast("Error while uploading image, e: ${e.toString()}");
        EventBusHelper().eventBus.fire(OnCartoonizerFinishedEvent(data: false));
      }
    }
  }

  bool includeOriginalFace({EffectItem? effect}) {
    if (effect == null) {
      effect = tabItemList[currentItemIndex.value].data;
    }
    return controller.isChecked.value && effect.originalFace;
  }

  String _getAiHostByStyle(EffectItem effect) {
    var server = effect.server;
    return userManager.aiServers[server] ?? Config.instance.host;
  }

  void showDialogLogin(BuildContext context, SharedPreferences sharedPrefs) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(2.h),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    ImagesConstant.ic_signup_cartoon,
                    width: 60.w,
                    height: 20.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  TitleTextWidget(S.of(context).signup_text1, ColorConstant.TextBlack, FontWeight.w600, 18),
                  SizedBox(
                    height: 1.h,
                  ),
                  TitleTextWidget(S.of(context).signup_text2, ColorConstant.TextBlack, FontWeight.w400, 14, maxLines: 3),
                  SizedBox(
                    height: 2.h,
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      cacheManager.setString(CacheManager.preSignupAction, 'facetoon_daily_limit');
                      GetStorage().write('login_back_page', '/ChoosePhotoScreen');
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: "/SignupScreen", arguments: "choose_photo"),
                            builder: (context) => SignupScreen(),
                          ));
                      userManager.refreshUser(context: context);
                    },
                    child: RoundedBorderBtnWidget(S.of(context).sign_up, color: ColorConstant.TextBlack),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void onSwitchOnce() {
    var user = userManager.user;
    if (user != null) {
      user.cartoonizeCredit--;
      userManager.user = user;
      refreshLastBuildType();
    }
  }

  Future<void> pickFromRecent(BuildContext context) async {
    PickPhotoScreen.push(
      context,
      selectedFile: controller.image.value,
      controller: uploadImageController,
      floatWidget: _createEffectModelIcon(
        context,
        effectItem: tabItemList[currentItemIndex.value].data,
        checked: true,
      ),
      onPickFromSystem: (takePhoto) async {
        if (takePhoto) {
          return await pickImageFromCamera(context, from: "result");
        } else {
          return await pickImageFromGallery(context, from: "result");
        }
      },
      onPickFromRecent: (entity) async {
        return await pickImageFromGallery(context, from: "result", entity: entity);
      },
      onPickFromAiSource: (file) async {
        return await pickImageFromGallery(context, from: "result", file: file);
      },
    );
  }

  Future<String> composeImageWithWatermark() async {
    var imageData = (await SyncFileImage(file: File(image)).getImage()).image;
    ui.Image? cropImage;
    if ((controller.cropImage.value != null && includeOriginalFace())) {
      if (cropKey.currentContext != null) {
        cropImage = await getBitmapFromContext(cropKey.currentContext!);
      }
    }
    ui.Image? watermark = null;
    if (lastBuildType == _BuildType.waterMark) {
      var imageInfo = await SyncAssetImage(assets: Images.ic_watermark).getImage();
      watermark = imageInfo.image;
    }
    var uint8list = await addWaterMark(image: imageData, originalImage: cropImage, watermark: watermark);
    var newImage = base64Encode(uint8list);
    return newImage;
  }

  Future initVideoPlayerFromNet(String aiHost) async {
    var url = '${aiHost}/resource/' + controller.videoUrl.value;
    var fileName = EncryptUtil.encodeMd5(url);
    var videoDir = cacheManager.storageOperator.videoDir;
    var savePath = videoDir.path + fileName + '.mp4';
    await initVideoPlayerFromFile(File(savePath));
  }

  Future initVideoPlayerFromFile(File file) async {
    _videoPlayerController = VideoPlayerController.file(file)..setLooping(true);
    await _videoPlayerController!.initialize();
    controller.updateVideoFile(file);
    controller.changeIsLoading(false);
    delay(() => _videoPlayerController!.play(), milliseconds: 64);
  }
}

enum _BuildType {
  waterMark,
  hdImage,
}
