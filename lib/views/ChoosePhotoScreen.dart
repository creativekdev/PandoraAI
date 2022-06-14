import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/api.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/common/utils.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/views/SignupScreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:video_player/video_player.dart';

import '../gallery_saver.dart';
import '../models/OfflineEffectModel.dart';
import 'PurchaseScreen.dart';
import 'ShareScreen.dart';
import 'StripeSubscriptionScreen.dart';

class ChoosePhotoScreen extends StatefulWidget {
  final List<EffectModel> list;
  int pos;
  int? itemPos;
  bool isFromRecent;
  bool hasOriginalCheck;

  ChoosePhotoScreen({
    Key? key,
    required this.list,
    required this.pos,
    this.itemPos,
    this.isFromRecent = false,
    this.hasOriginalCheck = true,
  }) : super(key: key);

  @override
  _ChoosePhotoScreenState createState() => _ChoosePhotoScreenState();
}

class _ChoosePhotoScreenState extends State<ChoosePhotoScreen> {
  var algoName = "";
  var urlFinal = "";
  var image = "";
  var videoPath = "";
  late ImagePicker imagePicker;
  late UserModel _user;

  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ChoosePhotoScreenController controller = ChoosePhotoScreenController();
  late RecentController recentController;
  late ItemScrollController scrollController;
  late ItemScrollController scrollController1;
  var itemPos = 0;
  VideoPlayerController? _videoPlayerController;
  Map<String, OfflineEffectModel> offlineEffect = {};

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController?.dispose();
  }

  @override
  void initState() {
    super.initState();

    logEvent(Events.upload_page_loading);

    recentController = Get.find();
    initStoreInfo();

    controller.setLastItemIndex(widget.pos);
    controller.setLastItemIndex1(widget.pos);
    if (widget.itemPos != null) {
      controller.setLastSelectedIndex(widget.itemPos!);
    } else {
      controller.setLastSelectedIndex(widget.list[widget.pos].getDefaultPos());
    }
    imagePicker = ImagePicker();
    scrollController = ItemScrollController();
    scrollController1 = ItemScrollController();
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPos != ((widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index)) {
        controller.setLastItemIndex1((widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index);
        try {
          itemPos = (widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index;
          scrollController1.scrollTo(
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
  }

  Future<void> initStoreInfo() async {
    _user = await API.getLogin();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isLogin = sharedPreferences.getBool("isLogin") ?? false;
    controller.changeIsLogin(isLogin);
  }

  Obx _buildSignupBlock(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: !controller.isLogin.value,
        child: GestureDetector(
          onTap: () => {
            logEvent(Events.result_signup_get_credit),
            GetStorage().write('signup_through', 'result_signup_get_credit'),
            GetStorage().write('login_back_page', '/ChoosePhotoScreen'),
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "/SignupScreen", arguments: "choose_photo"),
                builder: (context) => SignupScreen(),
              ),
            ).then((value) async {
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
              bool isLogin = sharedPreferences.getBool("isLogin") ?? false;
              if (isLogin) {
                await API.getLogin(needLoad: false, context: context);
                controller.changeIsLogin(isLogin);
                setState(() {});
              }
            })
          },
          child: RoundedBorderBtnWidget(StringConstant.signup_text),
        ),
      ),
    );
  }

  FutureBuilder _buildPremiumBlock() {
    return FutureBuilder(
        future: API.getLogin(),
        builder: (context, snapshot) {
          bool visible = false;
          if (snapshot.data != null) {
            UserModel user = snapshot.data as UserModel;
            if (user.email != '' && (user.credit <= 0 && !user.subscription.containsKey('id'))) {
              visible = true;
            }
          }
          return Visibility(
              visible: visible,
              child: Column(children: [
                SizedBox(
                  height: 1.5.h,
                ),
                TitleTextWidget(StringConstant.no_watermark, ColorConstant.HintColor, FontWeight.w400, 14),
                SizedBox(
                  height: 2.h,
                ),
                GestureDetector(
                  onTap: () => {
                    if (Platform.isIOS)
                      {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: "/PurchaseScreen"),
                              builder: (context) => PurchaseScreen(),
                            )).then((value) => {setState(() {})})
                      }
                    else
                      {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: "/StripeSubscriptionScreen"),
                              builder: (context) => StripeSubscriptionScreen(),
                            )).then((value) => {setState(() {})})
                      }
                  },
                  child: ButtonWidget(StringConstant.go_premium),
                ),
                SizedBox(
                  height: 2.h,
                ),
              ]));
        });
  }

  Future<bool> _willPopCallback(BuildContext context) async {
    if (controller.isPhotoDone.value) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Wrap(
            children: [
              Container(
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: Card(
                    elevation: 1.h,
                    shadowColor: Color.fromRGBO(0, 0, 0, 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4.w),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        children: [
                          TitleTextWidget(StringConstant.exit_msg, ColorConstant.TextBlack, FontWeight.w600, 18),
                          SizedBox(
                            height: 1.h,
                          ),
                          TitleTextWidget(StringConstant.exit_msg1, ColorConstant.HintColor, FontWeight.w400, 14),
                          SizedBox(
                            height: 1.h,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 6.h,
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: Card(
                                elevation: 2.h,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w)),
                                shadowColor: ColorConstant.ShadowColor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.w),
                                    gradient: RadialGradient(
                                      colors: [ColorConstant.RadialColor1, ColorConstant.RadialColor2],
                                      radius: 1.w,
                                    ),
                                  ),
                                  child: Center(
                                    child: TitleTextWidget(StringConstant.exit_editing, ColorConstant.White, FontWeight.w600, 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              child: TitleTextWidget(StringConstant.cancel, ColorConstant.HintColor, FontWeight.w400, 16),
                              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 5.w),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
    return Future.value(true);
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
      child: Scaffold(
        backgroundColor: ColorConstant.BackgroundColor,
        body: Obx(() => LoadingOverlay(
              isLoading: controller.isLoading.value,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeConstants.TopBarEdgeInsets,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              logEvent(Events.result_back);
                              Navigator.maybePop(context);
                            },
                            child: Image.asset(
                              ImagesConstant.ic_back,
                              height: 30,
                              width: 30,
                            ),
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoSelect.value,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: true,
                              child: GestureDetector(
                                onTap: () {
                                  pickImageFromGallery(context, from: "result");
                                },
                                child: Image.asset(
                                  ImagesConstant.ic_gallery,
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 3.w,
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoSelect.value,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: true,
                              child: GestureDetector(
                                onTap: () async {
                                  pickImageFromCamera(context, from: "result");
                                },
                                child: Image.asset(
                                  ImagesConstant.ic_camera,
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoDone.value,
                              child: SizedBox(
                                width: 3.w,
                              ),
                            ),
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoDone.value,
                              child: GestureDetector(
                                onTap: () async {
                                  var category = widget.list[controller.lastItemIndex.value];
                                  var effects = category.effects;
                                  var keys = effects.keys.toList();
                                  var selectedEffect = effects[keys[controller.lastSelectedIndex.value]];
                                  logEvent(Events.result_download, eventValues: {"effect": selectedEffect!.key});

                                  if (controller.isVideo.value) {
                                    controller.changeIsLoading(true);
                                    await GallerySaver.saveVideo('${_getAiHostByStyle(selectedEffect)}/resource/' + controller.videoUrl.value, true).then((value) async {
                                      controller.changeIsLoading(false);
                                      videoPath = value as String;
                                      if (value != "") {
                                        CommonExtension().showVideoSavedOkToast(context);
                                      } else {
                                        CommonExtension().showFailedToast(context);
                                      }
                                    });
                                  } else {
                                    await ImageGallerySaver.saveImage(base64Decode(image), quality: 100, name: "Cartoonizer_${DateTime.now().millisecondsSinceEpoch}");
                                    CommonExtension().showImageSavedOkToast(context);
                                  }
                                },
                                child: Image.asset(
                                  ImagesConstant.ic_download,
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 3.w,
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoDone.value,
                              child: GestureDetector(
                                onTap: () async {
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
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              settings: RouteSettings(name: "/ShareScreen"),
                                              builder: (context) => ShareScreen(
                                                style: selectedEffect.key,
                                                image: (controller.isVideo.value) ? videoPath : image,
                                                isVideo: controller.isVideo.value,
                                              ),
                                            ));
                                      } else {
                                        CommonExtension().showToast("Oops Failed!");
                                      }
                                    });
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings: RouteSettings(name: "/ShareScreen"),
                                          builder: (context) => ShareScreen(
                                            style: selectedEffect.key,
                                            image: (controller.isVideo.value) ? videoPath : image,
                                            isVideo: controller.isVideo.value,
                                          ),
                                        ));
                                  }
                                },
                                child: Image.asset(
                                  ImagesConstant.ic_share,
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Expanded(
                        child: (controller.isPhotoDone.value)
                            ? SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 2.h),
                                      child: (controller.isVideo.value)
                                          ? AspectRatio(
                                              aspectRatio: _videoPlayerController!.value.aspectRatio,
                                              child: VideoPlayer(_videoPlayerController!),
                                            )
                                          : Image.memory(
                                              base64Decode(image),
                                              width: 88.w,
                                              height: 88.w,
                                            ),
                                    ),
                                    SizedBox(height: 1.h),
                                    _buildSignupBlock(context),
                                    _buildPremiumBlock(),
                                    TitleTextWidget(
                                      StringConstant.rate_result,
                                      ColorConstant.BtnTextColor,
                                      FontWeight.w500,
                                      12.sp,
                                    ).visibility(visible: false),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 1.h),
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
                                            Image.asset(
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
                                      ).visibility(visible: !controller.isPhotoSelect.value)),
                                  Obx(() => Column(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 2.h),
                                              child: Center(
                                                child: Container(
                                                  width: 90.w,
                                                  child: Card(
                                                    color: ColorConstant.CardColor,
                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                    elevation: 1.h,
                                                    shadowColor: Color.fromRGBO(0, 0, 0, 0.5),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(2.w),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(5.w),
                                                      child: DottedBorder(
                                                        color: ColorConstant.White,
                                                        strokeWidth: 0.1.h,
                                                        radius: Radius.circular(1.w),
                                                        borderType: BorderType.RRect,
                                                        child: Padding(
                                                          padding: EdgeInsets.all(4.w),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.max,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Stack(
                                                                children: [
                                                                  (controller.image.value) != null
                                                                      ? ClipRRect(
                                                                          borderRadius: BorderRadius.circular(2.w),
                                                                          child: Image.file(
                                                                            controller.image.value as File,
                                                                            fit: BoxFit.cover,
                                                                            width: 68.w,
                                                                          ),
                                                                        )
                                                                      : SizedBox(),
                                                                  Positioned(
                                                                    left: 2.w,
                                                                    bottom: 2.w,
                                                                    child: GestureDetector(
                                                                      onTap: () async {
                                                                        offlineEffect.clear();
                                                                        controller.changeIsPhotoSelect(false);
                                                                        controller.changeIsPhotoDone(false);
                                                                        controller.updateImageFile(null);
                                                                        controller.updateImageUrl("");
                                                                      },
                                                                      child: Image.asset(
                                                                        ImagesConstant.ic_delete,
                                                                        width: 8.w,
                                                                        height: 8.w,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2.h,
                                          )
                                        ],
                                      ).visibility(visible: controller.isPhotoSelect.value)),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.end,
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
                        )).offstage(offstage: !widget.hasOriginalCheck),
                    SizedBox(height: 0.5.h).offstage(offstage: !widget.hasOriginalCheck),
                    Container(
                      height: widget.isFromRecent ? $(150) : $(100),
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
                    Container(
                      height: 5.h,
                      child: ScrollablePositionedList.builder(
                        initialScrollIndex: widget.pos,
                        itemCount: widget.list.length,
                        scrollDirection: Axis.horizontal,
                        itemScrollController: scrollController1,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return _buildTextItem(context, index);
                        },
                      ),
                    ).offstage(offstage: widget.isFromRecent),
                    SizedBox(height: Platform.isAndroid ? $(12) : 0).offstage(offstage: widget.isFromRecent),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, int itemIndex) {
    var effects = widget.list[itemIndex].effects;
    var keys = effects.keys.toList();

    return Padding(
      padding: EdgeInsets.all($(3.6)),
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

  Widget _createEffectModelIcon(BuildContext context, {required EffectItem effectItem}) {
    if (effectItem.imageUrl.endsWith("mp4")) {
      return Container(
        width: 20.w,
        height: 20.w,
        child: EffectVideoPlayer(url: effectItem.imageUrl),
      );
    } else {
      return _imageWidget(context, imageUrl: effectItem.imageUrl);
    }
  }

  Widget _imageWidget(BuildContext context, {required String imageUrl}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.fill,
      height: 20.w,
      width: 20.w,
      placeholder: (context, url) {
        return Container(
          height: 20.w,
          width: 20.w,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          height: 20.w,
          width: 20.w,
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
    Widget icon = Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(7.2)),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: _createEffectModelIcon(context, effectItem: effectItem!),
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
        padding: EdgeInsets.all($(3.6)),
        decoration: BoxDecoration(
            color: ColorConstant.BackgroundColor,
            borderRadius: BorderRadius.circular($(10.8)),
            border: Border.all(
              color: checked ? ColorConstant.BlueColor : ColorConstant.BackgroundColor,
              width: $(1.8),
            )));

    return Padding(
      padding: EdgeInsets.all(widget.isFromRecent ? 0 : $(3.6)),
      child: (widget.isFromRecent
              ? Column(
                  children: [
                    icon,
                    SizedBox(height: $(10)),
                    Text(
                      effectItem.displayName,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        color: checked ? ColorConstant.BlueColor : ColorConstant.White,
                        fontSize: $(14),
                        height: 1,
                        fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ).intoContainer(constraints: BoxConstraints(maxWidth: $(86)), alignment: Alignment.center),
                  ],
                )
              : icon)
          .intoGestureDetector(onTap: () async {
        controller.setLastSelectedIndex(index);
        controller.setLastItemIndex(itemIndex);
        controller.setLastItemIndex1(itemIndex);
        scrollController1.scrollTo(index: itemIndex, duration: Duration(milliseconds: 10));
        if (controller.image.value != null) {
          controller.changeIsPhotoSelect(true);
          controller.changeIsLoading(true);
          getCartoon(context);
        }
      }),
    );
  }

  Future<void> _showInterstitialVideo() async {
    bool showAds = isShowAds(_user);
    if (showAds == false) return;

    var isInterstitialVideoAvailable = await FlutterApplovinMax.isInterstitialLoaded((listener) => null);
    if (isInterstitialVideoAvailable as bool) {
      FlutterApplovinMax.showInterstitialVideo((listener) => null);
    }
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
      File compressedImage = await imageCompressAndGetFile(File(image.path));

      offlineEffect.clear();
      controller.updateImageFile(compressedImage);
      controller.updateImageUrl("");
      controller.changeIsPhotoSelect(true);
      controller.changeIsLoading(true);
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
      File compressedImage = await imageCompressAndGetFile(File(image.path));

      offlineEffect.clear();
      controller.updateImageFile(compressedImage);
      controller.updateImageUrl("");
      controller.changeIsPhotoSelect(true);
      controller.changeIsLoading(true);
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
    String f_name = basename((controller.image.value as File).path);
    String c_type = "image/*";
    final params = {
      "bucket": b_name,
      "file_name": f_name,
      "content_type": c_type,
    };
    final response = await API.get("https://socialbook.io/api/file/presigned_url", params: params);
    final Map parsed = json.decode(response.body.toString());
    var url = (parsed['data'] ?? '').toString();
    var res = await put(Uri.parse(url), body: (controller.image.value as File).readAsBytesSync());

    if (res.statusCode == 200) {
      // String imageUrl = "https://free-socialbook.s3.us-west-2.amazonaws.com/$f_name";
      var imageUrl = url.split("?")[0];
      controller.updateImageUrl(imageUrl);
      return imageUrl;
    }

    return '';
  }

  Future<void> getCartoon(BuildContext context) async {
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

    if (offlineEffect.containsKey(key)) {
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
      controller.changeIsRate(true);
      _showInterstitialVideo();

      try {
        var imageUrl = controller.imageUrl.value;
        if (imageUrl == "") {
          imageUrl = await uploadCompressedImage();
        }

        if (imageUrl == "") return;

        var sharedPrefs = await SharedPreferences.getInstance();
        final tokenResponse = await API.get("/api/tool/image/cartoonize/token");
        final Map tokenParsed = json.decode(tokenResponse.body.toString());

        int resultSuccess = 0;

        if (tokenResponse.statusCode == 200) {
          if (tokenParsed['data'] == null) {
            List<String> imageArray = ["$imageUrl"];
            var dataBody = {
              'querypics': imageArray,
              'is_data': 0,
              'algoname': controller.isChecked.value && isSupportOriginalFace(selectedEffect) ? selectedEffect.algoname + "-original_face" : selectedEffect.algoname,
              'direct': 1,
            };
            selectedEffect.handleApiParams(dataBody);
            final cartoonizeResponse = await API.post("${aiHost}/api/image/cartoonize", body: dataBody);
            if (cartoonizeResponse.statusCode == 200) {
              final Map parsed = json.decode(cartoonizeResponse.body.toString());

              if (parsed['data'].toString().startsWith('<')) {
                controller.changeIsLoading(false);
                offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                CommonExtension().showToast(parsed['data'].toString().substring(parsed['data'].toString().indexOf('<p>') + 3, parsed['data'].toString().indexOf('</p>')));
              } else if (parsed['data'].toString() == "") {
                controller.changeIsLoading(false);
                offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: parsed['message']));
                CommonExtension().showToast(parsed['message']);
              } else if (parsed['data'].toString().endsWith(".mp4")) {
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
              } else {
                offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                controller.changeIsLoading(false);
                image = parsed['data'];
                urlFinal = imageUrl;
                algoName = selectedEffect.algoname;
                controller.changeIsPhotoDone(true);
                controller.changeIsVideo(false);
                var params = {"algoname": selectedEffect.algoname};
                API.get("/api/log/cartoonize", params: params);
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
            };
            selectedEffect.handleApiParams(dataBody);
            final cartoonizeResponse = await API.post("${aiHost}/api/image/cartoonize/token", body: dataBody);
            print(cartoonizeResponse.statusCode);
            print(cartoonizeResponse.body.toString());
            if (cartoonizeResponse.statusCode == 200) {
              final Map parsed = json.decode(cartoonizeResponse.body.toString());
              if (parsed['data'].toString().startsWith('<')) {
                controller.changeIsLoading(false);
                offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                CommonExtension().showToast(parsed['data'].toString().substring(parsed['data'].toString().indexOf('<p>') + 3, parsed['data'].toString().indexOf('</p>')));
              } else if (parsed['data'].toString() == "") {
                controller.changeIsLoading(false);
                offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: parsed['message']));
                CommonExtension().showToast(parsed['message']);
              } else if (parsed['data'].toString().endsWith(".mp4")) {
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
              } else {
                offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                controller.changeIsLoading(false);
                image = parsed['data'];
                urlFinal = imageUrl;
                algoName = selectedEffect.algoname;
                controller.changeIsPhotoDone(true);
                controller.changeIsVideo(false);
                var params = {"algoname": selectedEffect.algoname};
                API.get("/api/log/cartoonize", params: params);
              }
              resultSuccess = 1;
            } else {
              controller.changeIsLoading(false);
              CommonExtension().showToast('Error while processing image');
            }
          }
          await API.getLogin(needLoad: true, context: context);
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

        logEvent(Events.photo_cartoon_result, eventValues: {
          "success": resultSuccess,
          "effect": selectedEffect.key,
          "sticker_name": selectedEffect.stickerName,
          "category": category.key,
          "original_face": controller.isChecked.value && isSupportOriginalFace(selectedEffect) ? 1 : 0,
        });
        if (!widget.isFromRecent) {
          recentController.onEffectUsed(selectedEffect);
        } else {
          recentController.onEffectUsedToCache(selectedEffect);
        }
      } catch (e) {
        print(e);
        controller.changeIsLoading(false);
        CommonExtension().showToast(e.toString());
        // CommonExtension().showToast("Error while uploading image");
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
      controller.changeIsRate(false);
    });
  }

  Widget _buildSeparator() {
    if (widget.isFromRecent) {
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
    return Obx(() => GestureDetector(
          onTap: () async {
            controller.setLastItemIndex1(index);
            scrollController.scrollTo(index: index, duration: Duration(milliseconds: 10));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 6),
            child: TitleTextWidget(widget.list[index].displayName, (index == controller.lastItemIndex1.value) ? ColorConstant.BlueColor : ColorConstant.White,
                (index == controller.lastItemIndex1.value) ? FontWeight.w600 : FontWeight.w400, 14),
          ),
        ));
  }

  bool isSupportOriginalFace(EffectItem effect) {
    return effect.originalFace;
  }

  String _getAiHostByStyle(EffectItem effect) {
    var server = effect.server;
    return _user.ai_servers[server] ?? Config.instance.aiHost;
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

                      bool isLogin = sharedPreferences.getBool("isLogin") ?? false;
                      if (isLogin) {
                        await API.getLogin(needLoad: false, context: context);
                        controller.changeIsLogin(isLogin);
                        setState(() {});
                      }
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
}
