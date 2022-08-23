import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/ads_holder.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/Widgets/admob/reward_interstitial_ads_holder.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/indicator/line_tab_indicator.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/SignupScreen.dart';
import 'package:cartoonizer/views/advertisement/processing_advertisement_screen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../gallery_saver.dart';
import '../models/OfflineEffectModel.dart';
import 'advertisement/reward_advertisement_screen.dart';
import 'share/ShareScreen.dart';

enum EntrySource {
  fromRecent,
  fromDiscovery,
  fromEffect,
}

class ChoosePhotoScreen extends StatefulWidget {
  final List<EffectModel> list;
  int pos;
  int? itemPos;
  EntrySource entrySource;
  bool hasOriginalCheck;

  ChoosePhotoScreen({
    Key? key,
    required this.list,
    required this.pos,
    this.itemPos,
    this.entrySource = EntrySource.fromEffect,
    this.hasOriginalCheck = true,
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

  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ChoosePhotoScreenController controller = ChoosePhotoScreenController();
  late RecentController recentController;
  late ItemScrollController scrollController;
  late ItemScrollController categoryScrollController;
  TabController? effectTabController;
  var itemPos = 0;
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
            width: double.maxFinite,
            height: imageSize?.height ?? 85.w,
          ),
          Align(
            child: Image.asset(
              Images.ic_watermark,
              width: (imageSize?.width ?? 85.w) * 0.56,
            ).intoContainer(margin: EdgeInsets.only(bottom: 7.w)),
            alignment: Alignment.bottomCenter,
          ).visibility(visible: imageSize != null),
        ],
      ).intoContainer(width: imageSize?.width ?? 85.w, height: imageSize?.height ?? 85.w);
      if (imageSize == null) {
        asyncRefreshImageSize(imageUint8List);
      }
    } else {
      _cachedImage = Image.memory(
        imageUint8List,
        width: 85.w,
        height: 85.w,
      );
    }
    return _cachedImage!;
  }

  asyncRefreshImageSize(Uint8List imageUint8List) {
    var resolve = MemoryImage(imageUint8List).resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      var scale = image.image.width / image.image.height;
      if (scale < 0.9) {
        double height = 85.w;
        double width = height * scale;
        imageSize = Size(width, height);
      } else if (scale > 1.1) {
        double width = 85.w;
        double height = width / scale;
        imageSize = Size(width, height);
      } else {
        imageSize = Size(85.w, 85.w);
      }
      _cachedImage = null;
      setState(() {});
    }));
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
    adsHolder.onDispose();
    rewardAdsHolder.onDispose();
    userChangeListener.cancel();
    userLoginListener.cancel();
  }

  @override
  void initState() {
    super.initState();

    logEvent(Events.upload_page_loading);
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
    recentController = Get.find();

    controller.setLastItemIndex(widget.pos);
    controller.setLastItemIndex1(widget.pos);
    if (widget.itemPos != null) {
      controller.setLastSelectedIndex(widget.itemPos!);
    } else {
      controller.setLastSelectedIndex(widget.list[widget.pos].getDefaultPos());
    }
    imagePicker = ImagePicker();
    scrollController = ItemScrollController();
    categoryScrollController = ItemScrollController();
    if (widget.entrySource == EntrySource.fromRecent) {
      effectTabController = TabController(length: widget.list.length, vsync: this);
      effectTabController!.index = controller.lastItemIndex.value;
    }
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPos != ((widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index)) {
        controller.setLastItemIndex1((widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index);
        try {
          itemPos = (widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index;
          categoryScrollController.scrollTo(
            index: (widget.pos == widget.list.length - 1)
                ? widget.pos
                : (itemPositionsListener.itemPositions.value.first.index > 0)
                    ? itemPositionsListener.itemPositions.value.first.index - 1
                    : 0,
            duration: Duration(milliseconds: 10),
          );
        } catch (error) {
          print("error");
          print(error);
        }
      }
    });
    userManager.refreshUser();
    if (widget.entrySource == EntrySource.fromDiscovery) {
      autoScrollToSelectedIndex();
    }
  }

  /// calculate scroll offset in child horizontal list
  void autoScrollToSelectedIndex() {
    var index = controller.lastSelectedIndex.value;
    var screenWidth = ScreenUtil.screenSize.width;
    //remove padding offset and get real rate of selectedIndex in hole child list
    var d = (screenWidth - $(40)) / screenWidth;
    var alignment = d * index / 4;
    delay(() {
      scrollController.scrollTo(index: controller.lastItemIndex.value, duration: Duration(milliseconds: 200), alignment: -alignment);
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

  showSavePhotoDialog(BuildContext context) {
    if (lastBuildType == _BuildType.hdImage) {
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
                  RewardAdvertisementScreen.push(context, adsHolder: rewardAdsHolder).then((value) {
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
                }).visibility(visible: !userManager.isNeedLogin && userManager.user!.userSubscription.isEmpty),
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
    var category = widget.list[controller.lastItemIndex.value];
    var effects = category.effects;
    var keys = effects.keys.toList();
    var selectedEffect = effects[keys[controller.lastSelectedIndex.value]];
    logEvent(Events.result_download, eventValues: {"effect": selectedEffect!.key});

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
                middle: TitleTextWidget(StringConstant.cartoonize, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
                trailing: Image.asset(
                  Images.ic_share,
                  width: $(24),
                ).intoGestureDetector(onTap: () async {
                  var category = widget.list[controller.lastItemIndex.value];
                  var effects = category.effects;
                  var keys = effects.keys.toList();
                  var selectedEffect = effects[keys[controller.lastSelectedIndex.value]];
                  logEvent(Events.result_share, eventValues: {"effect": selectedEffect!.key});
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
                    ShareScreen.startShare(
                      context,
                      backgroundColor: Color(0x77000000),
                      style: selectedEffect.key,
                      image: (controller.isVideo.value) ? videoPath : image,
                      isVideo: controller.isVideo.value,
                      originalUrl: urlFinal,
                      effectKey: selectedEffect.key,
                    );
                  }
                }).offstage(offstage: !controller.isPhotoDone.value),
              ),
              body: Column(
                children: [
                  Obx(
                    () => Expanded(
                      child: (controller.isPhotoDone.value)
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: $(44)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 2.h),
                                    child: (controller.isVideo.value)
                                        ? AspectRatio(
                                            aspectRatio: _videoPlayerController!.value.aspectRatio,
                                            child: VideoPlayer(_videoPlayerController!),
                                          ).intoContainer(height: 85.w)
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [cachedImage],
                                          ).intoContainer(height: 85.w),
                                  ),
                                  Obx(() => Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            controller.isChecked.value ? ImagesConstant.ic_checked : ImagesConstant.ic_unchecked,
                                            width: 20,
                                            height: 20,
                                          ).intoInkWell(onTap: () async {
                                            print(controller.isChecked.value);
                                            if (controller.isChecked.value) {
                                              controller.changeIsChecked(false);
                                            } else {
                                              controller.changeIsChecked(true);
                                            }
                                          }),
                                          SizedBox(width: 1.5.w),
                                          TitleTextWidget(StringConstant.in_original, ColorConstant.BtnTextColor, FontWeight.w500, 14),
                                          SizedBox(width: 2.w),
                                        ],
                                      )).intoContainer(margin: EdgeInsets.only(bottom: $(4))).offstage(offstage: !widget.hasOriginalCheck),
                                  buildSuccessFunctions(context),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: $(4)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SimpleShadow(
                                          child: Image.asset(
                                            ImagesConstant.ic_emoji1,
                                            height: 10.w,
                                            width: 10.w,
                                          ),
                                          sigma: 5,
                                        ).intoGestureDetector(onTap: () async {
                                          likeDislike(true);
                                        }),
                                        SizedBox(width: 5.w),
                                        SimpleShadow(
                                          child: Image.asset(
                                            ImagesConstant.ic_emoji2,
                                            height: 10.w,
                                            width: 10.w,
                                          ),
                                          sigma: 5,
                                        ).intoGestureDetector(onTap: () async {
                                          likeDislike(false);
                                        }),
                                      ],
                                    ),
                                  ).visibility(visible: false),
                                  SizedBox(height: 1.5.h),
                                ],
                              ),
                            )
                          : Stack(
                              children: [
                                Obx(() => Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          controller.isPhotoSelect.value
                                              ? ClipRRect(
                                                  child: Image.file(
                                                    controller.image.value as File,
                                                    fit: BoxFit.cover,
                                                    width: 71.w,
                                                    height: 71.w,
                                                  ),
                                                  borderRadius: BorderRadius.circular($(8)),
                                                ).intoContainer(margin: EdgeInsets.only(bottom: $(15)))
                                              : Image.asset(
                                                  ImagesConstant.ic_man,
                                                  height: 40.h,
                                                  width: 70.w,
                                                ),
                                          GestureDetector(
                                            onTap: () {
                                              pickImageFromGallery(context, from: "center");
                                            },
                                            child: ButtonWidget(StringConstant.choose_photo, radius: $(8), padding: EdgeInsets.symmetric(horizontal: $(50))),
                                          ),
                                          SizedBox(height: 1.h),
                                          GestureDetector(
                                            onTap: () {
                                              pickImageFromCamera(context, from: "center");
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 1.h),
                                              child: TitleTextWidget(StringConstant.take_selfie, ColorConstant.White, FontWeight.w400, 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ).visibility(visible: !controller.isPhotoDone.value)),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    height: $(42),
                    child: widget.entrySource == EntrySource.fromRecent
                        ? Theme(
                            data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
                            child: TabBar(
                              indicatorSize: TabBarIndicatorSize.label,
                              indicator: LineTabIndicator(
                                width: $(20),
                                strokeCap: StrokeCap.butt,
                                borderSide: BorderSide(width: $(4), color: ColorConstant.BlueColor),
                              ),
                              labelPadding: EdgeInsets.symmetric(horizontal: $(10)),
                              isScrollable: true,
                              padding: EdgeInsets.symmetric(horizontal: $(15)),
                              labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: $(16), fontWeight: FontWeight.w600),
                              unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: $(16), fontWeight: FontWeight.w400),
                              tabs: widget.list.map((e) => Text(e.effects.values.toList()[0].displayName)).toList(),
                              controller: effectTabController,
                              onTap: (index) {
                                controller.setLastItemIndex(index);
                                controller.setLastItemIndex1(index);
                                controller.setLastSelectedIndex(0);
                                scrollController.scrollTo(index: index, duration: Duration(milliseconds: 10));
                                if (controller.image.value != null) {
                                  controller.changeIsPhotoSelect(true);
                                  controller.changeIsLoading(true);
                                  getCartoon(context);
                                }
                              },
                            ))
                        : ScrollablePositionedList.builder(
                            initialScrollIndex: widget.pos,
                            itemCount: widget.list.length,
                            scrollDirection: Axis.horizontal,
                            itemScrollController: categoryScrollController,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return _buildTextItem(context, index);
                            },
                          ),
                  ),
                  Container(
                    height: $(100),
                    margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                    child: Scrollbar(
                      thickness: 0.0,
                      child: ScrollablePositionedList.separated(
                        initialScrollIndex: widget.pos,
                        itemCount: widget.list.length,
                        scrollDirection: Axis.horizontal,
                        itemScrollController: scrollController,
                        itemPositionsListener: itemPositionsListener,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, itemIndex) {
                          return _buildCarouselItem(context, itemIndex);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return _buildSeparator();
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: $(12)),
                ],
              ),
            )),
      ),
    );
  }

  @override
  // ignore: must_call_super
  void didChangeDependencies() {
    // super.didChangeDependencies();
  }

  Widget buildSuccessFunctions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Obx(
          () => Expanded(
            child: Image.asset(
              Images.ic_camera,
              height: $(24),
              width: $(24),
            )
                .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  decoration: BoxDecoration(color: ColorConstant.EffectFunctionGrey, borderRadius: BorderRadius.circular($(6))),
                )
                .intoGestureDetector(
                  onTap: () => showPickPhotoDialog(context),
                )
                .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(7)), constraints: BoxConstraints(maxWidth: ScreenUtil.screenSize.width / 3)),
          ).visibility(visible: controller.isPhotoSelect.value),
        ),
        Obx(
          () => Expanded(
            child: Image.asset(
              Images.ic_download,
              height: $(24),
              width: $(24),
            )
                .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  decoration: BoxDecoration(color: ColorConstant.EffectFunctionBlue, borderRadius: BorderRadius.circular($(6))),
                )
                .intoGestureDetector(
                  onTap: () => showSavePhotoDialog(context),
                )
                .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(7))),
          ).visibility(visible: controller.isPhotoDone.value),
        ),
        Obx(() => Expanded(
              child: Image.asset(
                Images.ic_share_discovery,
                height: $(24),
                width: $(24),
              )
                  .intoContainer(
                padding: EdgeInsets.symmetric(vertical: $(12)),
                decoration: BoxDecoration(color: ColorConstant.EffectFunctionGrey, borderRadius: BorderRadius.circular($(6))),
              )
                  .intoGestureDetector(
                onTap: () async {
                  var category = widget.list[controller.lastItemIndex.value];
                  var effects = category.effects;
                  var keys = effects.keys.toList();
                  var selectedEffect = effects[keys[controller.lastSelectedIndex.value]];
                  logEvent(Events.result_share, eventValues: {"effect": selectedEffect!.key});
                  AppDelegate.instance.getManager<UserManager>().doOnLogin(context, callback: () async {
                    if (controller.isVideo.value) {
                      var videoUrl = '${_getAiHostByStyle(selectedEffect)}/resource/' + controller.videoUrl.value;
                      ShareDiscoveryScreen.push(
                        context,
                        effectKey: selectedEffect.key,
                        originalUrl: urlFinal,
                        image: videoUrl,
                        isVideo: controller.isVideo.value,
                      );
                    } else {
                      ShareDiscoveryScreen.push(
                        context,
                        effectKey: selectedEffect.key,
                        originalUrl: urlFinal,
                        image: image,
                        isVideo: controller.isVideo.value,
                      );
                    }
                  });
                },
              ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(7))),
            ).visibility(visible: controller.isPhotoDone.value)),
      ],
    ).intoContainer(margin: EdgeInsets.only(top: $(25), left: $(23), right: $(23))).visibility(visible: controller.isPhotoSelect.value);
  }

  Widget _buildCarouselItem(BuildContext context, int itemIndex) {
    var effects = widget.list[itemIndex].effects;
    var keys = effects.keys.toList();

    return Container(
      padding: EdgeInsets.only(left: 0, right: 0, top: $(7.2), bottom: $(7.2)),
      margin: EdgeInsets.only(
        left: itemIndex == 0 ? $(15) : 0,
        right: itemIndex == widget.list.length - 1 ? $(15) : 0,
      ),
      child: ListView.builder(
        itemCount: keys.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Obx(() => _buildListItem(context, index, itemIndex));
        },
      ),
    );
  }

  Widget _createEffectModelIcon(BuildContext context, {required EffectItem effectItem, required bool checked}) {
    var width = (ScreenUtil.screenSize.width - 5 * $(12)) / 4;
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
        width: width,
        height: width,
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
    var width = (ScreenUtil.screenSize.width - 5 * $(12)) / 4;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.fill,
      height: width,
      width: width,
      placeholder: (context, url) {
        return Container(
          height: width,
          width: width,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          height: width,
          width: width,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, int index, int itemIndex) {
    var effects = widget.list[itemIndex].effects;
    var keys = effects.keys.toList();
    var effectItem = effects[keys[index]];
    var checked = (controller.lastSelectedIndex.value == index && controller.lastItemIndex.value == itemIndex);
    Widget icon = OutlineWidget(
        radius: $(10.8),
        strokeWidth: 3,
        gradient: LinearGradient(
          colors: [checked ? Color(0xffE31ECD) : Colors.transparent, checked ? Color(0xff243CFF) : Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular($(8)),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: _createEffectModelIcon(context, effectItem: effectItem!, checked: checked),
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
          padding: EdgeInsets.all($(3.2)),
        ));

    return icon.intoGestureDetector(onTap: () async {
      controller.setLastSelectedIndex(index);
      controller.setLastItemIndex(itemIndex);
      controller.setLastItemIndex1(itemIndex);
      if (widget.entrySource == EntrySource.fromRecent) {
        effectTabController?.index = itemIndex;
      } else {
        categoryScrollController.scrollTo(index: itemIndex, duration: Duration(milliseconds: 10));
      }
      if (controller.image.value != null) {
        controller.changeIsPhotoSelect(true);
        controller.changeIsLoading(true);
        getCartoon(context);
      }
    });
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
      // String imageUrl = "https://free-socialbook.s3.us-west-2.amazonaws.com/$f_name";
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

  Future<void> getCartoon(BuildContext context, {bool rebuild = false}) async {
    refreshLastBuildType();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      controller.changeIsLoading(false);
      CommonExtension().showToast(StringConstant.no_internet_msg);
    }

    var category = widget.list[controller.lastItemIndex.value];
    var effects = category.effects;
    var keys = effects.keys.toList();
    var selectedEffect = effects[keys[controller.lastSelectedIndex.value]];

    String aiHost = _getAiHostByStyle(selectedEffect!);

    var key = controller.isChecked.value && isSupportOriginalFace(selectedEffect) ? selectedEffect.key + "-original_face" : selectedEffect.key;

    if (offlineEffect.containsKey(key) && !rebuild) {
      var data = offlineEffect[key] as OfflineEffectModel;
      if (data.data.toString().startsWith('<')) {
        controller.changeIsLoading(false);
        CommonExtension().showToast(data.data.toString().substring(data.data.toString().indexOf('<p>') + 3, data.data.toString().indexOf('</p>')));
      } else if (data.data.toString() == "") {
        controller.changeIsLoading(false);
        CommonExtension().showToast(data.message);
      } else if (data.data.toString().endsWith(".mp4")) {
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

        if (imageUrl == "") return;

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
            final cartoonizeResponse = await API.post("${aiHost}/api/image/cartoonize", body: dataBody);
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
              } else if (parsed['data'].toString().endsWith(".mp4")) {
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
              CommonExtension().showToast('Error while processing image');
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
              } else if (parsed['data'].toString().endsWith(".mp4")) {
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
              CommonExtension().showToast('Error while processing image');
            }
          }
          await userManager.refreshUser(context: context);
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
        CommonExtension().showToast("Error while uploading image");
        EventBusHelper().eventBus.fire(OnCartoonizerFinishedEvent(data: false));
      }
    }
  }

  Future<void> likeDislike(bool like) async {
    controller.changeIsLoading(true);
    var databody = {
      'type': "cartoonize",
      'like': like ? 1 : -1,
      'url': urlFinal,
      'algo': algoName,
    };

    await API.post("/api/tool/matting/evaluate", body: databody).whenComplete(() async {
      controller.changeIsLoading(false);
    });
  }

  Widget _buildSeparator() {
    if (widget.entrySource == EntrySource.fromRecent) {
      return Container();
    }
    return VerticalDivider(
      color: ColorConstant.HintColor,
      width: 1.w,
      indent: 3.h,
      endIndent: 3.h,
      thickness: 0.4.w,
    );
  }

  Widget _buildTextItem(BuildContext context, int index) {
    return Obx(() {
      var item = widget.list[index].effects.values.toList()[0];
      return GestureDetector(
        onTap: () async {
          controller.setLastItemIndex1(index);
          scrollController.scrollTo(index: index, duration: Duration(milliseconds: 10));
        },
        child: Padding(
          padding: EdgeInsets.only(left: $(6), right: $(6), top: $(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TitleTextWidget(
                widget.entrySource == EntrySource.fromRecent ? item.displayName : widget.list[index].displayName,
                (index == controller.lastItemIndex1.value) ? ColorConstant.White : ColorConstant.EffectGrey,
                (index == controller.lastItemIndex1.value) ? FontWeight.w600 : FontWeight.w400,
                $(16),
              ),
              Container(
                margin: EdgeInsets.only(top: $(4)),
                width: $(18),
                height: $(4),
                color: (index == controller.lastItemIndex1.value) ? ColorConstant.BlueColor : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    });
  }

  bool isSupportOriginalFace(EffectItem effect) {
    return effect.originalFace;
  }

  String _getAiHostByStyle(EffectItem effect) {
    var server = effect.server;
    return userManager.aiServers[server] ?? Config.instance.apiHost;
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
