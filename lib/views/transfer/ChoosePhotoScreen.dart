import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/photo_introduction_config.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/ads_holder.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/Widgets/admob/reward_interstitial_ads_holder.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/SignupScreen.dart';
import 'package:cartoonizer/views/advertisement/processing_advertisement_screen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../../gallery_saver.dart';
import '../../models/OfflineEffectModel.dart';
import '../advertisement/reward_advertisement_screen.dart';
import '../share/ShareScreen.dart';
import 'choose_tab_bar.dart';

enum EntrySource {
  fromRecent,
  fromDiscovery,
  fromEffect,
}

class ChoosePhotoScreen extends StatefulWidget {
  int tabPos;
  int pos;
  int itemPos;
  EntrySource entrySource;

  ChoosePhotoScreen({
    Key? key,
    required this.tabPos,
    required this.pos,
    required this.itemPos,
    this.entrySource = EntrySource.fromEffect,
  }) : super(key: key);

  @override
  _ChoosePhotoScreenState createState() => _ChoosePhotoScreenState();
}

class _ChoosePhotoScreenState extends State<ChoosePhotoScreen> with SingleTickerProviderStateMixin {
  var algoName = "";
  var urlFinal = "";
  var _image = "";

  set image(String data) {
    _image = data;
    imageSize = null;
    _cachedImage = null;
  }

  String get image => _image;
  var videoPath = "";
  late ImagePicker imagePicker;
  UserManager userManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  final EffectDataController effectDataController = Get.find();
  final ChoosePhotoScreenController controller = ChoosePhotoScreenController();
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

  late WidgetAdsHolder adsHolder;
  late RewardInterstitialAdsHolder rewardAdsHolder;
  late StreamSubscription userChangeListener;
  late StreamSubscription userLoginListener;
  _BuildType lastBuildType = _BuildType.waterMark;

  Widget? _cachedImage;
  Size? imageSize;
  late double imgContainerSize;

  Widget get cachedImage {
    if (_cachedImage != null) {
      return _cachedImage!;
    }
    var imageUint8List = base64Decode(image);
    if (lastBuildType == _BuildType.waterMark) {
      _cachedImage = Stack(
        children: [
          Image.memory(
            imageUint8List,
            width: imgContainerSize,
            height: imgContainerSize - 24,
            fit: BoxFit.fill,
          ).marginSymmetric(vertical: 12),
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: imgContainerSize,
                height: imgContainerSize,
              )),
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Image.memory(
                  imageUint8List,
                  width: double.maxFinite,
                  height: imageSize?.height ?? imgContainerSize,
                ),
                Align(
                  child: Image.asset(
                    Images.ic_watermark,
                    width: (imageSize?.width ?? imgContainerSize) * 0.56,
                  ).intoContainer(margin: EdgeInsets.only(bottom: 7.w)),
                  alignment: Alignment.bottomCenter,
                ).visibility(visible: imageSize != null),
              ],
            ).intoContainer(width: double.maxFinite, height: imageSize?.height ?? imgContainerSize),
          ),
        ],
      ).intoContainer(width: imgContainerSize, height: imgContainerSize);
      if (imageSize == null) {
        asyncRefreshImageSize(imageUint8List);
      }
    } else {
      _cachedImage = Stack(
        children: [
          Image.memory(
            imageUint8List,
            width: imgContainerSize,
            height: imgContainerSize - 12,
            fit: BoxFit.fill,
          ),
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: imgContainerSize,
                height: imgContainerSize,
              )),
          Image.memory(
            imageUint8List,
            width: imgContainerSize,
            height: imgContainerSize,
          )
        ],
      ).intoContainer(width: imgContainerSize, height: imgContainerSize);
    }
    return _cachedImage!;
  }

  asyncRefreshImageSize(Uint8List imageUint8List) {
    var resolve = MemoryImage(imageUint8List).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      var scale = image.image.width / image.image.height;
      if (scale < 0.9) {
        double height = imgContainerSize;
        double width = height * scale;
        imageSize = Size(width, height);
      } else if (scale > 1.1) {
        double width = imgContainerSize;
        double height = width / scale;
        imageSize = Size(width, height);
      } else {
        imageSize = Size(imgContainerSize, imgContainerSize);
      }
      _cachedImage = null;
      setState(() {});
    }));
  }

  bool lastChangeByTap = false;

  @override
  void dispose() {
    super.dispose();
    thirdpartManager.adsHolder.ignore = false;
    _videoPlayerController?.dispose();
    adsHolder.onDispose();
    rewardAdsHolder.onDispose();
    userChangeListener.cancel();
    userLoginListener.cancel();
    itemScrollPositionsListener.itemPositions.removeListener(itemScrollPositionsListen);
  }

  @override
  void initState() {
    super.initState();
    logEvent(Events.upload_page_loading);
    recentController = Get.find();
    if (widget.entrySource != EntrySource.fromRecent) {
      tabList = effectDataController.tabList;
      tabTitleList = effectDataController.tabTitleList;
      tabItemList = effectDataController.tabItemList;
    } else {
      buildFromRecent();
    }
    currentTabIndex = widget.tabPos;
    currentTitleIndex = widget.pos;
    currentItemIndex.value = widget.itemPos;
    thirdpartManager.adsHolder.ignore = true;
    itemWidth = (ScreenUtil.screenSize.width - $(90)) / 5;
    imgContainerSize = ScreenUtil.screenSize.width;
    userChangeListener = EventBusHelper().eventBus.on<UserInfoChangeEvent>().listen((event) {
      setState(() {});
    });
    userLoginListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      setState(() {});
    });
    adsHolder = CardAdsHolder(
      width: ScreenUtil.screenSize.width - $(32),
      scale: 0.75,
      onUpdated: () {},
      adId: AdMobConfig.PROCESSING_AD_ID,
    );
    adsHolder.initHolder();
    rewardAdsHolder = RewardInterstitialAdsHolder(adId: AdMobConfig.REWARD_PROCESSING_AD_ID);
    rewardAdsHolder.initHolder();

    imagePicker = ImagePicker();
    initTabBar();
    autoScrollToSelectedIndex();
    if (userManager.aiServers.isEmpty) {
      delay(() {
        controller.changeIsLoading(true);
        userManager.refreshUser().then((value) {
          if (value.aiServers.isEmpty) {
            CommonExtension().showToast('Load server config failed');
            Navigator.of(context).pop();
          } else {
            controller.changeIsLoading(false);
          }
        });
      });
    }
  }

  void buildFromRecent() {
    tabList = [ChooseTabInfo(key: 'recent', title: 'recent')];
    var buildList = recentController.getBuildList();
    for (int i = 0; i < buildList.length; i++) {
      var effectModel = buildList[i];
      int categoryIndex = tabTitleList.length;
      tabTitleList.add(ChooseTitleInfo(title: effectModel.displayName, categoryKey: effectModel.key, tabKey: 'recent'));
      List<EffectItem> effectItems = effectModel.effects.values.toList();
      for (int j = 0; j < effectItems.length; j++) {
        tabItemList.add(ChooseTabItemInfo(
          data: effectItems[j],
          tabKey: 'recent',
          categoryKey: effectModel.key,
          categoryIndex: categoryIndex,
          childIndex: j,
        ));
      }
    }
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
    delay(() {
      titleScrollController.jumpTo(index: currentTitleIndex);
      itemScrollController.jumpTo(index: currentItemIndex.value);
    }, milliseconds: 32);
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
            TitleTextWidget(StringConstant.exit_msg, ColorConstant.White, FontWeight.w600, 18),
            SizedBox(height: $(15)),
            TitleTextWidget(StringConstant.exit_msg1, ColorConstant.HintColor, FontWeight.w400, 14),
            SizedBox(height: $(15)),
            TitleTextWidget(
              StringConstant.exit_editing,
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
              StringConstant.cancel,
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

  showPickPhotoDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleTextWidget('Select from album', ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop();
                pickImageFromGallery(context, from: "result");
              }),
              Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
              TitleTextWidget('Take a selfie', ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop();
                pickImageFromCamera(context, from: "result");
              }),
              Container(height: $(10), width: double.maxFinite, color: ColorConstant.BackgroundColor),
              TitleTextWidget(StringConstant.cancel, ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.only(top: $(10), bottom: $(10) + MediaQuery.of(context).padding.bottom),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop();
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
      saveToAlbum();
    } else {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleTextWidget('Save into the album', ColorConstant.White, FontWeight.normal, $(17))
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  color: Colors.transparent,
                  width: double.maxFinite,
                )
                    .intoGestureDetector(onTap: () async {
                  Navigator.of(context).pop();
                  await saveToAlbum();
                }),
                Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(
                  margin: EdgeInsets.symmetric(horizontal: $(25)),
                ),
                TitleTextWidget('Save HD, watermark-free image', ColorConstant.White, FontWeight.normal, $(17))
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
                    watchAdText: StringConstant.watchAdText,
                  ).then((value) {
                    if (value ?? false) {
                      setState(() {
                        lastBuildType = _BuildType.hdImage;
                        _cachedImage = null;
                        imageSize = null;
                      });
                      saveToAlbum();
                    } else {
                      refreshLastBuildType();
                    }
                  });
                }).visibility(visible: userManager.isNeedLogin || userManager.user!.userSubscription.isEmpty),
                Divider(height: 0.5, color: ColorConstant.EffectGrey)
                    .intoContainer(
                      margin: EdgeInsets.symmetric(horizontal: $(25)),
                    )
                    .visibility(visible: userManager.isNeedLogin),
                TitleTextWidget(StringConstant.signup_text, ColorConstant.White, FontWeight.normal, $(17))
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  color: Colors.transparent,
                  width: double.maxFinite,
                )
                    .intoGestureDetector(onTap: () async {
                  Navigator.of(context).pop();
                  logEvent(Events.result_signup_get_credit);
                  GetStorage().write('signup_through', 'result_signup_get_credit');
                  GetStorage().write('login_back_page', '/ChoosePhotoScreen');
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
                      getCartoon(context, rebuild: true);
                    }
                  });
                }).visibility(visible: userManager.isNeedLogin),
                Container(height: $(10), width: double.maxFinite, color: ColorConstant.BackgroundColor),
                TitleTextWidget(StringConstant.cancel, ColorConstant.White, FontWeight.normal, $(17))
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
    logEvent(Events.result_download, eventValues: {"effect": selectedEffect.key});

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
      if (lastBuildType == _BuildType.waterMark) {
        var imageData = await decodeImageFromList(base64Decode(image));
        var assetImage = AssetImage(Images.ic_watermark).resolve(ImageConfiguration.empty);
        assetImage.addListener(ImageStreamListener((image, synchronousCall) async {
          var uint8list = await addWaterMark(image: imageData, watermark: image.image, widthRate: 0.22);
          await ImageGallerySaver.saveImage(uint8list, quality: 100, name: "Cartoonizer_${DateTime.now().millisecondsSinceEpoch}");
          CommonExtension().showImageSavedOkToast(context);
        }));
      } else {
        await ImageGallerySaver.saveImage(base64Decode(image), quality: 100, name: "Cartoonizer_${DateTime.now().millisecondsSinceEpoch}");
        CommonExtension().showImageSavedOkToast(context);
      }
    }
  }

  Future<void> shareOut() async {
    var selectedEffect = tabItemList[currentItemIndex.value].data;
    logEvent(Events.result_share, eventValues: {"effect": selectedEffect.key});
    if (controller.isVideo.value) {
      controller.changeIsLoading(true);
      await GallerySaver.saveVideo('${_getAiHostByStyle(selectedEffect)}/resource/' + controller.videoUrl.value, false).then((value) async {
        controller.changeIsLoading(false);
        videoPath = value as String;
        if (value != "") {
          ShareScreen.startShare(
            context,
            backgroundColor: Color(0x77000000),
            style: selectedEffect.key,
            image: (controller.isVideo.value) ? videoPath : image,
            isVideo: controller.isVideo.value,
            originalUrl: urlFinal,
            effectKey: selectedEffect.key,
          );
        } else {
          CommonExtension().showToast(StringConstant.commonFailedToast);
        }
      });
    } else {
      AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
      ShareScreen.startShare(
        context,
        backgroundColor: Color(0x77000000),
        style: selectedEffect.key,
        image: (controller.isVideo.value) ? videoPath : image,
        isVideo: controller.isVideo.value,
        originalUrl: urlFinal,
        effectKey: selectedEffect.key,
      ).then((value) {
        AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        recentController.loadingFromCache().whenComplete(() {
          recentController.refreshDataList();
        });
        return _willPopCallback(context);
      },
      child: Obx(
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
                  Obx(
                    () => Expanded(
                      child: (controller.isPhotoDone.value)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: (controller.isVideo.value)
                                      ? AspectRatio(
                                          aspectRatio: _videoPlayerController!.value.aspectRatio,
                                          child: VideoPlayer(_videoPlayerController!),
                                        ).intoContainer(height: imgContainerSize, width: imgContainerSize)
                                      : Center(child: cachedImage).intoContainer(
                                          height: imgContainerSize,
                                          width: imgContainerSize,
                                        ),
                                ),
                              ],
                            )
                          : Obx(() => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    controller.isPhotoSelect.value
                                        ? ClipRRect(
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.file(
                                                  controller.image.value as File,
                                                  fit: BoxFit.cover,
                                                  width: imgContainerSize,
                                                  height: imgContainerSize,
                                                ),
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: Image.asset(
                                                    Images.ic_loading_filled,
                                                    color: ColorConstant.White,
                                                  )
                                                      .intoContainer(
                                                          padding: EdgeInsets.all(12),
                                                          height: imgContainerSize / 5.2,
                                                          width: imgContainerSize / 5.2,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(8),
                                                            color: Color(0x66000000),
                                                          ))
                                                      .intoGestureDetector(onTap: () {
                                                    controller.changeIsLoading(true);
                                                    getCartoon(context);
                                                  }).visibility(visible: !controller.isLoading.value),
                                                ),
                                              ],
                                            ).intoContainer(width: imgContainerSize, height: imgContainerSize),
                                            borderRadius: BorderRadius.circular($(0)),
                                          ).intoContainer(margin: EdgeInsets.only(bottom: $(tabItemList.length == 1 ? 100 : 15)))
                                        : ClipRRect(
                                            child: Image.asset(
                                              (PhotoIntroductionConfig[tabTitleList[currentTitleIndex].categoryKey] ?? defaultPhotoIntroductionConfig)['image']!,
                                              height: imgContainerSize - 60,
                                              width: imgContainerSize - 60,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                    controller.isPhotoSelect.value
                                        ? Container()
                                        : Text(
                                            (PhotoIntroductionConfig[tabTitleList[currentTitleIndex].categoryKey] ?? defaultPhotoIntroductionConfig)['text']!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 22,
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
                                            constraints: BoxConstraints(minHeight: $(110)),
                                            alignment: Alignment.center,
                                          ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(Images.ic_camera, width: $(24)),
                                        SizedBox(width: $(8)),
                                        Text(
                                          StringConstant.choose_photo,
                                          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(16), fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    )
                                        .intoContainer(
                                            width: double.maxFinite,
                                            padding: EdgeInsets.symmetric(vertical: $(10)),
                                            margin: EdgeInsets.symmetric(horizontal: $(30)),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: ColorConstant.DiscoveryBtn,
                                              borderRadius: BorderRadius.circular($(8)),
                                            ))
                                        .intoGestureDetector(onTap: () {
                                      showPickPhotoDialog(context);
                                    }),
                                  ],
                                ),
                              ).visibility(visible: !controller.isPhotoDone.value)),
                    ),
                  ),
                  Obx(() => buildSuccessFunctions(context).visibility(visible: controller.isPhotoDone.value)),
                  SizedBox(height: $(10)),
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
                      if (index == tabItemList.length - 1 || widget.entrySource == EntrySource.fromRecent) {
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
                      tabList: tabList.map((e) => e.title).toList(),
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
                            itemScrollController.jumpTo(index: categoryPos);
                          }
                          if (!controller.isPhotoSelect.value) {
                            currentItemIndex.value = tabItemPos;
                          }
                        });
                        delay(() {
                          lastChangeByTap = false;
                        }, milliseconds: 32);
                      }).visibility(visible: controller.isPhotoDone.value && tabList.length > 1),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + $(15)),
                ],
              ),
            ).ignore(ignoring: controller.isLoading.value)),
      ),
    );
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
            if (controller.isChecked.value && isSupportOriginalFace(effectItem))
              Positioned(
                bottom: $(1),
                left: $(3.6),
                child: controller.image.value != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular($(36)),
                        child: Image.file(
                          controller.image.value as File,
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
        if (widget.entrySource != EntrySource.fromRecent) {
          if (effect.tabKey != tabList[currentTabIndex].key) {
            currentTabIndex = tabList.findPosition((data) => data.key == effect.tabKey)!;
          }
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

  Widget buildSuccessFunctions(BuildContext context) {
    return Row(
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
              ).intoInkWell(onTap: () async {
                print(controller.isChecked.value);
                if (controller.isChecked.value) {
                  controller.changeIsChecked(false);
                } else {
                  controller.changeIsChecked(true);
                }
                if (controller.isPhotoSelect.value) {
                  controller.changeIsLoading(true);
                  getCartoon(context);
                }
              }),
              SizedBox(width: $(6)),
              TitleTextWidget(StringConstant.in_original, ColorConstant.BtnTextColor, FontWeight.w500, 14),
              SizedBox(width: $(20)),
            ],
          ).offstage(offstage: !tabItemList[currentItemIndex.value].data.originalFace),
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
                    onTap: () => showPickPhotoDialog(context),
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
                    shareToDiscovery(context);
                  },
                )
                .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)))
                .visibility(visible: controller.isPhotoDone.value)),
          ],
        ))
      ],
    ).intoContainer(margin: EdgeInsets.only(top: $(10), left: $(23), right: $(23), bottom: $(10))).visibility(visible: controller.isPhotoSelect.value);
  }

  Future<void> shareToDiscovery(BuildContext context) async {
    var selectedEffect = tabItemList[currentItemIndex.value].data;
    logEvent(Events.result_share, eventValues: {"effect": selectedEffect.key});
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, currentPageRoute: '/ChoosePhotoScreen', callback: () async {
      if (controller.isVideo.value) {
        var videoUrl = '${_getAiHostByStyle(selectedEffect)}/resource/' + controller.videoUrl.value;
        ShareDiscoveryScreen.push(
          context,
          effectKey: selectedEffect.key,
          originalUrl: urlFinal,
          image: videoUrl,
          isVideo: true,
        );
      } else {
        if (lastBuildType == _BuildType.waterMark) {
          var shareWatermark = () async {
            //share with watermark
            controller.changeIsLoading(true);
            var imageData = await decodeImageFromList(base64Decode(image));
            var assetImage = AssetImage(Images.ic_watermark).resolve(ImageConfiguration.empty);
            assetImage.addListener(ImageStreamListener((image, synchronousCall) async {
              var uint8list = await addWaterMark(image: imageData, watermark: image.image, widthRate: 0.22);
              var newImage = base64Encode(uint8list);
              controller.changeIsLoading(false);
              ShareDiscoveryScreen.push(
                context,
                effectKey: selectedEffect.key,
                originalUrl: urlFinal,
                image: newImage,
                isVideo: false,
              );
            }));
          };
          if (!rewardAdsHolder.adsReady) {
            // has no admob, just share watermark
            shareWatermark.call();
          } else {
            // get reward to share hd
            showShareDiscoveryDialog(context).then((value) async {
              if (value != null) {
                if (value) {
                  RewardAdvertisementScreen.push(
                    context,
                    adsHolder: rewardAdsHolder,
                    watchAdText: StringConstant.watchAdToShareText,
                  ).then((value) {
                    if (value ?? false) {
                      setState(() {
                        lastBuildType = _BuildType.hdImage;
                      });
                      ShareDiscoveryScreen.push(
                        context,
                        effectKey: selectedEffect.key,
                        originalUrl: urlFinal,
                        image: image,
                        isVideo: false,
                      );
                    }
                  });
                } else {
                  shareWatermark.call();
                }
              }
            });
          }
        } else {
          ShareDiscoveryScreen.push(
            context,
            effectKey: selectedEffect.key,
            originalUrl: urlFinal,
            image: image,
            isVideo: false,
          );
        }
      }
    });
  }

  Widget _createEffectModelIcon(BuildContext context, {required EffectItem effectItem, required bool checked}) {
    if (effectItem.imageUrl.contains("-transform")) {
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
    if (!isShowAdsNew()) {
      return false;
    }
    ProcessingAdvertisementScreen.push(context, adsHolder: adsHolder).then((value) {
      if (value == null) {
        onCancel.call();
      } else if (value) {
        onSuccess.call();
      } else {
        onFail?.call();
      }
      if (!adsHolder.adsReady) {
        adsHolder.initHolder();
      }
    });
    return true;
  }

  Future<void> pickImageFromGallery(BuildContext context, {String from = "center"}) async {
    logEvent(Events.upload_photo, eventValues: {"method": "photo", "from": from});
    var source = ImageSource.gallery;
    try {
      XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
      if (image == null) {
        CommonExtension().showToast("cancelled");
        return;
      }
      controller.changeIsLoading(true);
      File compressedImage = await imageCompressAndGetFile(File(image.path));

      offlineEffect.clear();
      controller.updateImageFile(compressedImage);
      controller.updateImageUrl("");
      controller.changeIsPhotoSelect(true);
      controller.changeIsPhotoDone(false);
      getCartoon(context);
    } on PlatformException catch (error) {
      if (error.code == "photo_access_denied") {
        showPhotoLibraryPermissionDialog(context);
      }
    } catch (error) {
      CommonExtension().showToast("Try to select valid image");
    }
  }

  Future<void> pickImageFromCamera(BuildContext context, {String from = "center"}) async {
    logEvent(Events.upload_photo, eventValues: {"method": "camera", "from": from});
    var source = ImageSource.camera;
    try {
      XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
      if (image == null) {
        CommonExtension().showToast("cancelled");
        return;
      }
      controller.changeIsLoading(true);
      File compressedImage = await imageCompressAndGetFile(File(image.path));

      offlineEffect.clear();
      controller.updateImageFile(compressedImage);
      controller.updateImageUrl("");
      controller.changeIsPhotoSelect(true);
      controller.changeIsPhotoDone(false);
      getCartoon(context);
    } on PlatformException catch (error) {
      if (error.code == "camera_access_denied") {
        showCameraPermissionDialog(context);
      }
    } catch (error) {
      CommonExtension().showToast("Try to select valid image");
    }
  }

  Future<String> uploadCompressedImage() async {
    String b_name = "free-socialbook";
    String f_name = path.basename((controller.image.value as File).path);
    var fileType = f_name.substring(f_name.lastIndexOf(".") + 1);
    if (TextUtil.isEmpty(fileType)) {
      fileType = '*';
    }
    String c_type = "image/${fileType}";
    final params = {
      "bucket": b_name,
      "file_name": f_name,
      "content_type": c_type,
    };
    final response = await API.get("https://socialbook.io/api/file/presigned_url", params: params);
    final Map parsed = json.decode(response.body.toString());
    var url = (parsed['data'] ?? '').toString();
    var baseEntity = await Uploader().uploadFile(url, controller.image.value as File, c_type);
    if (baseEntity != null) {
      var imageUrl = url.split("?")[0];
      controller.updateImageUrl(imageUrl);
      return imageUrl;
    }

    return '';
  }

  refreshLastBuildType() {
    setState(() {
      lastBuildType = getBuildType();
    });
  }

  _BuildType getBuildType() {
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
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      controller.changeIsLoading(false);
      CommonExtension().showToast(StringConstant.no_internet_msg);
      return;
    }

    var selectedEffect = tabItemList[currentItemIndex.value].data;
    EffectModel? category = findCategory(selectedEffect);
    if (category == null) {
      controller.changeIsLoading(false);
      // CommonExtension().showToast(StringConstant.commonFailedToast);
      CommonExtension().showToast('cannot find category');
      return;
    }
    String aiHost = _getAiHostByStyle(selectedEffect);

    var key = controller.isChecked.value && isSupportOriginalFace(selectedEffect) ? selectedEffect.key + "-original_face" : selectedEffect.key;

    if (offlineEffect.containsKey(key) && !rebuild) {
      var data = offlineEffect[key] as OfflineEffectModel;
      if (data.data.toString().startsWith('<')) {
        controller.changeIsLoading(false);
        CommonExtension().showToast(data.data.toString().substring(data.data.toString().indexOf('<p>') + 3, data.data.toString().indexOf('</p>')));
      } else if (data.data.toString() == "") {
        controller.changeIsLoading(false);
        CommonExtension().showToast(data.message);
      } else if (data.data.toString().contains(".mp4")) {
        controller.updateVideoUrl(data.data);
        _videoPlayerController = VideoPlayerController.network('${aiHost}/resource/' + controller.videoUrl.value)
          ..setLooping(true)
          ..initialize().then((value) async {
            controller.changeIsLoading(false);
          });
        _videoPlayerController!.play();

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
    } else {
      bool ignoreResult = false;
      Function? successForward;
      bool hasAd = _judgeAndShowAdvertisement(
        onSuccess: () {
          successForward?.call();
          onSwitchOnce();
        },
        onCancel: () {
          ignoreResult = true;
          controller.changeIsLoading(false);
          logEvent(Events.photo_cartoon_result, eventValues: {
            "success": 2,
            "effect": selectedEffect.key,
            "sticker_name": selectedEffect.stickerName,
            "category": category.key,
            "original_face": controller.isChecked.value && isSupportOriginalFace(selectedEffect) ? 1 : 0,
          });
        },
        onFail: () {
          controller.changeIsLoading(false);
        },
      );
      try {
        var imageUrl = controller.imageUrl.value;
        if (imageUrl == "") {
          imageUrl = await uploadCompressedImage();
        }

        if (imageUrl == "") {
          controller.changeIsLoading(false);
          EventBusHelper().eventBus.fire(OnCartoonizerFinishedEvent(data: false));
          return;
        }

        var sharedPrefs = await SharedPreferences.getInstance();
        final tokenResponse = await API.get("/api/tool/image/cartoonize/token");
        final Map tokenParsed = json.decode(tokenResponse.body.toString());

        if (ignoreResult) {
          controller.changeIsLoading(false);
          return;
        }
        int resultSuccess = 0;

        if (tokenResponse.statusCode == 200) {
          if (tokenParsed['data'] == null) {
            List<String> imageArray = ["$imageUrl"];
            var dataBody = {
              'querypics': imageArray,
              'is_data': 0,
              'algoname': controller.isChecked.value && isSupportOriginalFace(selectedEffect) ? selectedEffect.algoname + "-original_face" : selectedEffect.algoname,
              'direct': 1,
              'hide_watermark': 1,
            };
            selectedEffect.handleApiParams(dataBody);
            final cartoonizeResponse = await API.post(aiHost.cartoonizeApi, body: dataBody);
            if (ignoreResult) {
              controller.changeIsLoading(false);
              return;
            }
            if (cartoonizeResponse.statusCode == 200) {
              final Map parsed = json.decode(cartoonizeResponse.body.toString());

              var dataString = parsed['data'].toString();
              if (TextUtil.isEmpty(dataString)) {
                logEvent(Events.transform_img_failed, eventValues: {
                  'code': parsed['code'],
                  'message': parsed['message'],
                });
              }
              if (dataString.startsWith('<')) {
                successForward = () {
                  controller.changeIsLoading(false);
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                  CommonExtension().showToast(dataString.substring(dataString.indexOf('<p>') + 3, dataString.indexOf('</p>')));
                };
              } else if (dataString == "") {
                successForward = () {
                  controller.changeIsLoading(false);
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: parsed['message']));
                  CommonExtension().showToast(parsed['message']);
                };
              } else if (dataString.contains(".mp4")) {
                successForward = () {
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                  controller.updateVideoUrl(parsed['data']);
                  _videoPlayerController = VideoPlayerController.network('${aiHost}/resource/' + controller.videoUrl.value)
                    ..setLooping(true)
                    ..initialize().then((value) async {
                      controller.changeIsLoading(false);
                    });
                  _videoPlayerController!.play();

                  urlFinal = imageUrl;
                  algoName = selectedEffect.algoname;
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(true);
                };
              } else {
                successForward = () {
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                  controller.changeIsLoading(false);
                  image = parsed['data'];
                  urlFinal = imageUrl;
                  algoName = selectedEffect.algoname;
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(false);
                  var params = {"algoname": selectedEffect.algoname};
                  API.get("/api/log/cartoonize", params: params);
                };
              }
              if (!hasAd) {
                successForward.call();
                onSwitchOnce();
              }
              resultSuccess = 1;
            } else {
              controller.changeIsLoading(false);
              CommonExtension().showToast('Error while processing image, HttpCode: ${cartoonizeResponse.statusCode}');
            }
          } else {
            var token = tokenParsed['data'];
            List<String> imageArray = ["$imageUrl"];

            var dataBody = {
              'querypics': imageArray,
              'is_data': 0,
              'algoname': controller.isChecked.value && isSupportOriginalFace(selectedEffect) ? selectedEffect.algoname + "-original_face" : selectedEffect.algoname,
              'direct': 1,
              'token': token,
              'hide_watermark': 1,
            };
            selectedEffect.handleApiParams(dataBody);
            final cartoonizeResponse = await API.post("${aiHost}/api/image/cartoonize/token", body: dataBody);
            print(cartoonizeResponse.statusCode);
            print(cartoonizeResponse.body.toString());
            if (ignoreResult) {
              controller.changeIsLoading(false);
              return;
            }
            if (cartoonizeResponse.statusCode == 200) {
              final Map parsed = json.decode(cartoonizeResponse.body.toString());
              if (parsed['data'].toString().startsWith('<')) {
                successForward = () {
                  controller.changeIsLoading(false);
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                  CommonExtension().showToast(parsed['data'].toString().substring(parsed['data'].toString().indexOf('<p>') + 3, parsed['data'].toString().indexOf('</p>')));
                };
              } else if (parsed['data'].toString() == "") {
                successForward = () {
                  controller.changeIsLoading(false);
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: parsed['message']));
                  CommonExtension().showToast(parsed['message']);
                };
              } else if (parsed['data'].toString().contains(".mp4")) {
                successForward = () {
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                  controller.updateVideoUrl(parsed['data']);
                  _videoPlayerController = VideoPlayerController.network('${aiHost}/resource/' + controller.videoUrl.value)
                    ..setLooping(true)
                    ..initialize().then((value) async {
                      controller.changeIsLoading(false);
                    });
                  _videoPlayerController!.play();

                  urlFinal = imageUrl;
                  algoName = selectedEffect.algoname;
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(true);
                };
              } else {
                successForward = () {
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                  controller.changeIsLoading(false);
                  image = parsed['data'];
                  urlFinal = imageUrl;
                  algoName = selectedEffect.algoname;
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(false);
                  var params = {"algoname": selectedEffect.algoname};
                  API.get("/api/log/cartoonize", params: params);
                };
              }
              if (!hasAd) {
                successForward.call();
                onSwitchOnce();
              }
              resultSuccess = 1;
            } else {
              controller.changeIsLoading(false);
              CommonExtension().showToast('Error while processing image, HttpCode: ${cartoonizeResponse.statusCode}');
            }
          }
        } else {
          controller.changeIsLoading(false);
          var responseBody = json.decode(tokenResponse.body);
          if (responseBody['code'] == 'DAILY_IP_LIMIT_EXCEEDED') {
            bool isLogin = sharedPrefs.getBool("isLogin") ?? false;

            if (!isLogin) {
              showDialogLogin(context, sharedPrefs);
            } else {
              CommonExtension().showToast(StringConstant.DAILY_IP_LIMIT_EXCEEDED);
            }
          } else {
            CommonExtension().showToast(responseBody['message']);
          }
        }

        EventBusHelper().eventBus.fire(OnCartoonizerFinishedEvent(data: resultSuccess == 1));
        logEvent(Events.photo_cartoon_result, eventValues: {
          "success": resultSuccess,
          "effect": selectedEffect.key,
          "sticker_name": selectedEffect.stickerName,
          "category": category.key,
          "original_face": controller.isChecked.value && isSupportOriginalFace(selectedEffect) ? 1 : 0,
        });
        if (widget.entrySource != EntrySource.fromRecent) {
          recentController.onEffectUsed(selectedEffect);
        } else {
          recentController.onEffectUsedToCache(selectedEffect);
        }
        userManager.refreshUser();
      } catch (e) {
        print(e);
        controller.changeIsLoading(false);
        CommonExtension().showToast("Error while uploading image, e: ${e.toString()}");
        EventBusHelper().eventBus.fire(OnCartoonizerFinishedEvent(data: false));
      }
    }
  }

  bool isSupportOriginalFace(EffectItem effect) {
    return effect.originalFace;
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
                  TitleTextWidget(StringConstant.signup_text1, ColorConstant.TextBlack, FontWeight.w600, 18),
                  SizedBox(
                    height: 1.h,
                  ),
                  TitleTextWidget(StringConstant.signup_text2, ColorConstant.TextBlack, FontWeight.w400, 14, maxLines: 3),
                  SizedBox(
                    height: 2.h,
                  ),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      Navigator.pop(context);
                      GetStorage().write('login_back_page', '/ChoosePhotoScreen');
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: "/SignupScreen", arguments: "choose_photo"),
                            builder: (context) => SignupScreen(),
                          ));
                      userManager.refreshUser(context: context);
                    },
                    child: RoundedBorderBtnWidget(StringConstant.sign_up, color: ColorConstant.TextBlack),
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
    userManager.rateNoticeOperator.onSwitch(context);
  }
}

enum _BuildType {
  waterMark,
  hdImage,
}
