import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/sToken.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Model/EffectModel.dart';
import 'package:cartoonizer/Model/JsonValueModel.dart';
import 'package:cartoonizer/Model/UserModel.dart';
import 'package:cartoonizer/Ui/SignupScreen.dart';
import 'package:cartoonizer/api.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../Model/OfflineEffectModel.dart';
import '../gallery_saver.dart';
import 'PurchaseScreen.dart';
import 'ShareScreen.dart';
import 'package:video_player/video_player.dart';

class ChoosePhotoScreen extends StatefulWidget {
  final List<EffectModel> list;
  int pos;

  ChoosePhotoScreen({Key? key, required this.list, required this.pos}) : super(key: key);

  @override
  _ChoosePhotoScreenState createState() => _ChoosePhotoScreenState();
}

class _ChoosePhotoScreenState extends State<ChoosePhotoScreen> {
  var algoName = "";
  var urlFinal = "";
  var image = "";
  var videoPath = "";
  var imagePicker;
  List<String> tempData = [
    'standard1',
    'standard2',
    'standard3',
    '3dcartoon1',
    '3dcartoon2',
    '3dcartoon3',
    'disney1',
    'disney2',
    'disney3',
    'caricature1',
    'caricature2',
    'caricature3',
    'kpop1',
    'kpop2',
    'kpop3',
    'arcane',
    'simpson',
    'southpark',
    'rickandmorty',
    'baby',
    'villian',
    'glasses',
    'beauty_beard',
    'beautycartoon1',
    'beautycartoon2',
    'beautycartoon3',
    'fantacyart1',
    'fantacyart2',
    'fantacyart3',
    'naturalart1',
    'naturalart2',
    'naturalart3',
    'royalty1',
    'royalty2',
    'royalty3',
    'old1',
    'old2',
    'old3',
    'young1',
    'young2',
    'young3',
    'man1',
    'man2',
    'man3',
    'woman1',
    'woman2',
    'woman3'
  ];
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ChoosePhotoScreenController controller = Get.put(ChoosePhotoScreenController());
  var scrollController;
  var scrollController1;
  var itemPos = 0;
  late VideoPlayerController _videoPlayerController;
  Map<String, OfflineEffectModel> offlineEffect = {};
  @override
  void dispose() {
    Get.reset(clearRouteBindings: true);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller.setLastItemIndex(widget.pos);
    imagePicker = new ImagePicker();
    scrollController = ItemScrollController();
    scrollController1 = ItemScrollController();
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPos != ((widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index)) {
        controller.setLastItemIndex1((widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index);
        // scrollController1.scrollTo(
        //     index: (widget.pos == widget.list.length - 1)? widget.pos : itemPositionsListener.itemPositions.value.first.index,
        //     duration: Duration(milliseconds: 100),
        //     curve: Curves.easeInOutCubic);

        try {
          itemPos = (widget.pos == widget.list.length - 1) ? widget.pos : itemPositionsListener.itemPositions.value.first.index;
          // if(scrollController1.hasClients){
          scrollController1.scrollTo(
              index: (widget.pos == widget.list.length - 1)
                  ? widget.pos
                  : (itemPositionsListener.itemPositions.value.first.index > 0)
                      ? itemPositionsListener.itemPositions.value.first.index - 1
                      : 0,
              duration: Duration(milliseconds: 100),
              curve: Curves.easeInOutCubic);
          // }
        } catch (error) {
          print("error");
          print(error);
        }
      }
    });
  }

  FutureBuilder _buildPremiumBuilder() {
    return FutureBuilder(
        future: API.getLogin(false),
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
                TitleTextWidget(StringConstant.no_watermark, ColorConstant.HintColor, FontWeight.w400, 12.sp),
                SizedBox(
                  height: 1.5.h,
                ),
                GestureDetector(
                  onTap: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: "/PurchaseScreen"),
                          builder: (context) => PurchaseScreen(),
                        ))
                  },
                  child: RoundedBorderBtnWidget(StringConstant.go_premium),
                ),
                SizedBox(
                  height: 1.5.h,
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
                          TitleTextWidget(StringConstant.exit_msg, ColorConstant.BtnTextColor, FontWeight.w600, 16.sp),
                          SizedBox(
                            height: 0.3.h,
                          ),
                          TitleTextWidget(StringConstant.exit_msg1, ColorConstant.HintColor, FontWeight.w400, 10.sp),
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
                                    child: TitleTextWidget(StringConstant.exit_editing, ColorConstant.White, FontWeight.w600, 12.sp),
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
                              child: TitleTextWidget(StringConstant.cancel, ColorConstant.HintColor, FontWeight.w400, 12.sp),
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
                      margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Navigator.maybePop(context);
                            },
                            child: Image.asset(
                              ImagesConstant.ic_back_dark,
                              height: 10.w,
                              width: 10.w,
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
                                onTap: () async {
                                  var source = ImageSource.gallery;
                                  try {
                                    XFile image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                                    offlineEffect.clear();
                                    controller.updateImageFile(File(image.path));
                                    controller.changeIsPhotoSelect(true);
                                    controller.changeIsLoading(true);
                                    controller.changeIsPhotoDone(false);
                                    getCartoon(context);
                                  } on PlatformException catch (error) {
                                    if (error.code == "photo_access_denied") {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) => CupertinoAlertDialog(
                                                title: Text(
                                                  'PhotoLibrary Permission',
                                                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
                                                ),
                                                content: Text(
                                                  'This app needs photo library access to choose pictures for upload user profile photo',
                                                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                ),
                                                actions: <Widget>[
                                                  CupertinoDialogAction(
                                                    child: Text(
                                                      'Deny',
                                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                    ),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                  CupertinoDialogAction(
                                                    child: Text(
                                                      'Settings',
                                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      try {
                                                        openAppSettings();
                                                      } catch (err) {
                                                        print("err");
                                                        print(err);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ));
                                    }
                                  } catch (error) {
                                    CommonExtension().showToast("Try to select valid image");
                                  }
                                },
                                child: Image.asset(
                                  ImagesConstant.ic_gallery,
                                  height: 10.w,
                                  width: 10.w,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoSelect.value,
                              maintainState: true,
                              maintainAnimation: true,
                              maintainSize: true,
                              child: GestureDetector(
                                onTap: () async {
                                  var source = ImageSource.camera;
                                  try {
                                    XFile image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                                    offlineEffect.clear();
                                    controller.updateImageFile(File(image.path));
                                    controller.changeIsPhotoSelect(true);
                                    controller.changeIsLoading(true);
                                    controller.changeIsPhotoDone(false);
                                    getCartoon(context);
                                  } on PlatformException catch (error) {
                                    if (error.code == "camera_access_denied") {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) => CupertinoAlertDialog(
                                                title: Text(
                                                  'Camera Permission',
                                                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
                                                ),
                                                content: Text(
                                                  'This app needs camera access to take pictures for upload user profile photo',
                                                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                ),
                                                actions: <Widget>[
                                                  CupertinoDialogAction(
                                                    child: Text(
                                                      'Deny',
                                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                    ),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                  CupertinoDialogAction(
                                                    child: Text(
                                                      'Settings',
                                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      try {
                                                        openAppSettings();
                                                      } catch (err) {
                                                        print("err");
                                                        print(err);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ));
                                    }
                                  } catch (error) {
                                    CommonExtension().showToast("Try to select valid image");
                                  }
                                },
                                child: Image.asset(
                                  ImagesConstant.ic_camera,
                                  height: 10.w,
                                  width: 10.w,
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoDone.value,
                              child: SizedBox(
                                width: 2.w,
                              ),
                            ),
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoDone.value,
                              child: GestureDetector(
                                onTap: () async {
                                  if (controller.isVideo.value) {
                                    controller.changeIsLoading(true);
                                    await GallerySaver.saveVideo('https://ai.socialbook.io/resource/' + controller.videoUrl.value, true).then((value) async {
                                      controller.changeIsLoading(false);
                                      videoPath = value as String;
                                      if (value != "") {
                                        CommonExtension().showToast("Video Saved!");
                                      } else {
                                        CommonExtension().showToast("Oops Failed!");
                                      }
                                    });
                                  } else {
                                    await ImageGallerySaver.saveImage(base64Decode(image), quality: 100, name: "Cartoonizer_${DateTime.now().millisecondsSinceEpoch}");
                                    CommonExtension().showToast("Image Saved!");
                                  }
                                },
                                child: Image.asset(
                                  ImagesConstant.ic_download,
                                  height: 10.w,
                                  width: 10.w,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          Obx(
                            () => Visibility(
                              visible: controller.isPhotoDone.value,
                              child: GestureDetector(
                                onTap: () async {
                                  if (controller.isVideo.value) {
                                    controller.changeIsLoading(true);
                                    await GallerySaver.saveVideo('https://ai.socialbook.io/resource/' + controller.videoUrl.value, false).then((value) async {
                                      controller.changeIsLoading(false);
                                      videoPath = value as String;
                                      if (value != "") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              settings: RouteSettings(name: "/ShareScreen"),
                                              builder: (context) => ShareScreen(
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
                                            image: (controller.isVideo.value) ? videoPath : image,
                                            isVideo: controller.isVideo.value,
                                          ),
                                        ));
                                  }
                                },
                                child: Image.asset(
                                  ImagesConstant.ic_share,
                                  height: 10.w,
                                  width: 10.w,
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
                                              aspectRatio: _videoPlayerController.value.aspectRatio,
                                              child: VideoPlayer(_videoPlayerController),
                                            )
                                          : Image.memory(
                                              base64Decode(image),
                                              width: 100.w,
                                              height: 100.w,
                                            ),
                                    ),
                                    FutureBuilder(
                                      future: _getPrefs(),
                                      builder: (context, snapshot) {
                                        return Obx(
                                          () => Visibility(
                                            visible: (!(snapshot.data != null ? snapshot.data as bool : true) || controller.isLogin.value),
                                            child: GestureDetector(
                                              onTap: () => {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    settings: RouteSettings(name: "/SignupScreen"),
                                                    builder: (context) => SignupScreen(),
                                                  ),
                                                ).then((value) async {
                                                  controller.changeIsLogin((value != null) ? value as bool : true);
                                                })
                                              },
                                              child: RoundedBorderBtnWidget(StringConstant.signup_text),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildPremiumBuilder(),
                                    Visibility(
                                      visible: false /*controller.isRate.value*/,
                                      child: TitleTextWidget(StringConstant.rate_result, ColorConstant.BtnTextColor, FontWeight.w500, 12.sp),
                                    ),
                                    Visibility(
                                      visible: false /*controller.isRate.value*/,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 1.h),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                likeDislike(true);
                                              },
                                              child: SimpleShadow(
                                                child: Image.asset(
                                                  ImagesConstant.ic_emoji1,
                                                  height: 10.w,
                                                  width: 10.w,
                                                ),
                                                sigma: 5,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5.w,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                likeDislike(false);
                                              },
                                              child: SimpleShadow(
                                                child: Image.asset(
                                                  ImagesConstant.ic_emoji2,
                                                  height: 10.w,
                                                  width: 10.w,
                                                ),
                                                sigma: 5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1.5.h,
                                    ),
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  Obx(() => Visibility(
                                        visible: !controller.isPhotoSelect.value,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SimpleShadow(
                                                child: Image.asset(
                                                  ImagesConstant.ic_man,
                                                  height: 35.h,
                                                  width: 50.w,
                                                ),
                                                sigma: 7,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  var source = ImageSource.gallery;
                                                  try {
                                                    XFile image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                                                    offlineEffect.clear();
                                                    controller.updateImageFile(File(image.path));
                                                    controller.changeIsPhotoSelect(true);
                                                    controller.changeIsLoading(true);
                                                    controller.changeIsPhotoDone(false);
                                                    getCartoon(context);
                                                  } on PlatformException catch (error) {
                                                    if (error.code == "photo_access_denied") {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) => CupertinoAlertDialog(
                                                                title: Text(
                                                                  'PhotoLibrary Permission',
                                                                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
                                                                ),
                                                                content: Text(
                                                                  'This app needs photo library access to choose pictures for upload user profile photo',
                                                                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                                ),
                                                                actions: <Widget>[
                                                                  CupertinoDialogAction(
                                                                    child: Text(
                                                                      'Deny',
                                                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                                    ),
                                                                    onPressed: () => Navigator.of(context).pop(),
                                                                  ),
                                                                  CupertinoDialogAction(
                                                                    child: Text(
                                                                      'Settings',
                                                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                                    ),
                                                                    onPressed: () async {
                                                                      Navigator.pop(context);
                                                                      try {
                                                                        openAppSettings();
                                                                      } catch (err) {
                                                                        print("err");
                                                                        print(err);
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ));
                                                    }
                                                  } catch (error) {
                                                    CommonExtension().showToast("Try to select valid image");
                                                  }
                                                },
                                                child: ButtonWidget(StringConstant.choose_photo),
                                              ),
                                              SizedBox(height: 1.h),
                                              GestureDetector(
                                                onTap: () async {
                                                  var source = ImageSource.camera;
                                                  try {
                                                    XFile image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                                                    offlineEffect.clear();
                                                    controller.updateImageFile(File(image.path));
                                                    controller.changeIsPhotoSelect(true);
                                                    controller.changeIsLoading(true);
                                                    controller.changeIsPhotoDone(false);
                                                    getCartoon(context);
                                                  } on PlatformException catch (error) {
                                                    if (error.code == "camera_access_denied") {
                                                      showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) => CupertinoAlertDialog(
                                                                title: Text(
                                                                  'Camera Permission',
                                                                  style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
                                                                ),
                                                                content: Text(
                                                                  'This app needs camera access to take pictures for upload user profile photo',
                                                                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                                ),
                                                                actions: <Widget>[
                                                                  CupertinoDialogAction(
                                                                    child: Text(
                                                                      'Deny',
                                                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                                    ),
                                                                    onPressed: () => Navigator.of(context).pop(),
                                                                  ),
                                                                  CupertinoDialogAction(
                                                                    child: Text(
                                                                      'Settings',
                                                                      style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                                                    ),
                                                                    onPressed: () async {
                                                                      Navigator.pop(context);
                                                                      try {
                                                                        openAppSettings();
                                                                      } catch (err) {
                                                                        print("err");
                                                                        print(err);
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ));
                                                    }
                                                  } catch (error) {
                                                    CommonExtension().showToast("Try to select valid image");
                                                  }
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                                  child: TitleTextWidget(StringConstant.take_selfie, ColorConstant.HintColor, FontWeight.w400, 12.sp),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                  Obx(() => Visibility(
                                        visible: controller.isPhotoSelect.value,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                                child: Center(
                                                  child: Container(
                                                    width: 90.w,
                                                    child: Card(
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
                                                          color: Color.fromRGBO(0, 0, 0, 1),
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
                                        ),
                                      )),
                                ],
                              ),
                      ),
                    ),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () async {
                                print(controller.isChecked.value);
                                if (controller.isChecked.value) {
                                  controller.changeIsChecked(false);
                                } else {
                                  controller.changeIsChecked(true);
                                }
                              },
                              child: Image.asset(
                                controller.isChecked.value ? ImagesConstant.ic_checked : ImagesConstant.ic_unchecked,
                                width: 6.w,
                                height: 6.w,
                              ),
                            ),
                            SizedBox(
                              width: 1.5.w,
                            ),
                            TitleTextWidget(StringConstant.in_original, ColorConstant.BtnTextColor, FontWeight.w500, 12.sp),
                            SizedBox(
                              width: 2.w,
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Container(
                      height: 26.w,
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
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, int itemIndex) {
    return Padding(
      padding: EdgeInsets.all(1.w),
      child: ListView.builder(
        itemCount: widget.list[itemIndex].effects.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Obx(() => _buildListItem(context, index, itemIndex));
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index, int itemIndex) {
    return Card(
      elevation: 0,
      shape: (controller.lastSelectedIndex.value == index && controller.lastItemIndex.value == itemIndex)
          ? RoundedRectangleBorder(side: new BorderSide(color: ColorConstant.PrimaryColor, width: 0.5.w), borderRadius: BorderRadius.circular(3.w))
          : RoundedRectangleBorder(side: new BorderSide(color: ColorConstant.White, width: 0.5.w), borderRadius: BorderRadius.circular(3.w)),
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: GestureDetector(
          onTap: () async {
            controller.setLastSelectedIndex(index);
            controller.setLastItemIndex(itemIndex);
            controller.setLastItemIndex1(itemIndex);
            // if(scrollController1.hasClients) {
            scrollController1.scrollTo(index: itemIndex, duration: Duration(milliseconds: 100), curve: Curves.easeInOutCubic);
            // }
            if (controller.image.value != null) {
              controller.changeIsPhotoSelect(true);
              controller.changeIsLoading(true);
              getCartoon(context);
            }
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3.w),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: (widget.list[itemIndex].effects[index].endsWith("-transform"))
                    ? CachedNetworkImage(
                        imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" + widget.list[itemIndex].effects[index] + ".webp",
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
                      )
                    : CachedNetworkImage(
                        imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" + widget.list[itemIndex].effects[index] + ".jpg",
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
                      ),
              ),
              Visibility(
                visible: (widget.list[itemIndex].effects[index].endsWith("-transform")),
                child: Positioned(
                  right: 1.5.w,
                  top: 0.4.h,
                  child: Image.asset(
                    ImagesConstant.ic_video,
                    height: 5.w,
                    width: 5.w,
                  ),
                ),
              ),
              if (controller.isChecked.value && tempData.contains(widget.list[itemIndex].effects[index]))
                Positioned(
                  bottom: 0.4.h,
                  left: 1.5.w,
                  child: controller.image.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.w),
                          child: Image.file(
                            controller.image.value as File,
                            fit: BoxFit.fill,
                            height: 5.w,
                            width: 5.w,
                          ),
                        )
                      : SizedBox(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getCartoon(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      controller.changeIsLoading(false);
      CommonExtension().showToast(StringConstant.no_internet_msg);
    }

    var key = (controller.isChecked.value && tempData.contains(widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]))
        ? widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value] + "-original_face"
        : widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value];
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
        _videoPlayerController = VideoPlayerController.network('https://ai.socialbook.io/resource/' + controller.videoUrl.value)
          ..setLooping(true)
          ..initialize().then((value) async {
            controller.changeIsLoading(false);
          });
        _videoPlayerController.play();

        urlFinal = data.imageUrl;
        algoName = widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value];
        controller.changeIsPhotoDone(true);
        controller.changeIsVideo(true);
      } else {
        controller.changeIsLoading(false);
        image = data.data;
        urlFinal = data.imageUrl;
        algoName = widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value];
        controller.changeIsPhotoDone(true);
        controller.changeIsVideo(false);
      }
    } else {
      controller.changeIsRate(true);
      String b_name = "free-socialbook";
      String f_name = basename((controller.image.value as File).path);
      String c_type = "image/*";
      List<JsonValueModel> params = [];
      params.add(JsonValueModel("bucket", b_name));
      params.add(JsonValueModel("file_name", f_name));
      params.add(JsonValueModel("content_type", c_type));
      params.sort();
      final url = Uri.parse('https://socialbook.io/api/file/presigned_url?bucket=$b_name&file_name=$f_name&content_type=$c_type&s=${sToken(params)}');
      final response = await get(url);
      final Map parsed = json.decode(response.body.toString());
      try {
        var res = await put(Uri.parse(parsed['data']), body: (controller.image.value as File).readAsBytesSync());
        if (res.statusCode == 200) {
          var sharedPrefs = await SharedPreferences.getInstance();
          final headers = {"cookie": "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"};
          final tokenResponse = await get(Uri.parse('https://socialbook.io/api/tool/image/cartoonize/token'), headers: (sharedPrefs.getBool("isLogin") ?? false) ? headers : null);
          final Map tokenParsed = json.decode(tokenResponse.body.toString());
          if (tokenResponse.statusCode == 200) {
            if (tokenParsed['data'] == null) {
              var imageUrl = "https://free-socialbook.s3.us-west-2.amazonaws.com/$f_name";
              final headers = {"Content-type": "application/json", "cookie": "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"};
              List<JsonValueModel> params = [];
              params.add(JsonValueModel("querypics", imageUrl));
              params.add(JsonValueModel("is_data", "0"));
              params.add(JsonValueModel(
                  "algoname",
                  (controller.isChecked.value && tempData.contains(widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]))
                      ? widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value] + "-original_face"
                      : widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]));
              params.add(JsonValueModel("direct", "1"));
              params.sort();
              List<String> imageArray = ["$imageUrl"];

              var databody = jsonEncode(<String, dynamic>{
                'querypics': imageArray,
                'is_data': 0,
                'algoname': (controller.isChecked.value && tempData.contains(widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]))
                    ? widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value] + "-original_face"
                    : widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value],
                'direct': 1,
                's': sToken(params),
              });

              final cartoonizeResponse = await post(Uri.parse('https://ai.socialbook.io/api/image/cartoonize'), body: databody, headers: headers);
              // print(databody);
              // print(cartoonizeResponse.statusCode);
              // print(cartoonizeResponse.body.toString());
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
                  _videoPlayerController = VideoPlayerController.network('https://ai.socialbook.io/resource/' + controller.videoUrl.value)
                    ..setLooping(true)
                    ..initialize().then((value) async {
                      controller.changeIsLoading(false);
                    });
                  _videoPlayerController.play();

                  urlFinal = imageUrl;
                  algoName = widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value];
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(true);
                } else {
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                  controller.changeIsLoading(false);
                  image = parsed['data'];
                  urlFinal = imageUrl;
                  algoName = widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value];
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(false);
                  final headers = {"cookie": "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"};
                  get(Uri.parse('https://socialbook.io/api/log/cartoonize?algoname=${widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]}'),
                      headers: headers);
                }
              } else {
                controller.changeIsLoading(false);
                CommonExtension().showToast('Error while processing image');
              }
            } else {
              var imageUrl = "https://free-socialbook.s3.us-west-2.amazonaws.com/$f_name";
              var token = tokenParsed['data'];
              final headers = {"Content-type": "application/json", "cookie": "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"};
              List<JsonValueModel> params = [];
              params.add(JsonValueModel("querypics", imageUrl));
              params.add(JsonValueModel("is_data", "0"));
              params.add(JsonValueModel(
                  "algoname",
                  (controller.isChecked.value && tempData.contains(widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]))
                      ? widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value] + "-original_face"
                      : widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]));
              params.add(JsonValueModel("direct", "1"));
              params.add(JsonValueModel("token", token));
              params.sort();
              List<String> imageArray = ["$imageUrl"];

              var databody = jsonEncode(<String, dynamic>{
                'querypics': imageArray,
                'is_data': 0,
                'algoname': (controller.isChecked.value && tempData.contains(widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]))
                    ? widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value] + "-original_face"
                    : widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value],
                'direct': 1,
                'token': token,
                's': sToken(params),
              });
              final cartoonizeResponse = await post(Uri.parse('https://ai.socialbook.io/api/image/cartoonize/token'), body: databody, headers: headers);
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
                  _videoPlayerController = VideoPlayerController.network('https://ai.socialbook.io/resource/' + controller.videoUrl.value)
                    ..setLooping(true)
                    ..initialize().then((value) async {
                      controller.changeIsLoading(false);
                    });
                  _videoPlayerController.play();

                  urlFinal = imageUrl;
                  algoName = widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value];
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(true);
                } else {
                  offlineEffect.addIf(!offlineEffect.containsKey(key), key, OfflineEffectModel(data: parsed['data'], imageUrl: imageUrl, message: ""));
                  controller.changeIsLoading(false);
                  image = parsed['data'];
                  urlFinal = imageUrl;
                  algoName = widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value];
                  controller.changeIsPhotoDone(true);
                  controller.changeIsVideo(false);
                  final headers = {"cookie": "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"};
                  get(Uri.parse('https://socialbook.io/api/log/cartoonize?algoname=${widget.list[controller.lastItemIndex.value].effects[controller.lastSelectedIndex.value]}'),
                      headers: headers);
                }

                await API.getLogin(true);
              } else {
                controller.changeIsLoading(false);
                CommonExtension().showToast('Error while processing image');
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
        }
      } catch (e) {
        controller.changeIsLoading(false);
        throw ('Error while uploading image');
      }
    }
  }

  Future<void> likeDislike(bool like) async {
    controller.changeIsLoading(true);
    var sharedPrefs = await SharedPreferences.getInstance();
    final headers = {"Content-type": "application/json", "cookie": "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"};
    final headers1 = {
      "Content-type": "application/json",
    };
    List<JsonValueModel> params = [];
    params.add(JsonValueModel("type", "cartoonize"));
    params.add(JsonValueModel("like", "1"));
    params.add(JsonValueModel("url", urlFinal));
    params.add(JsonValueModel("algo", algoName));
    params.sort();
    var databody = jsonEncode(<String, dynamic>{
      'type': "cartoonize",
      'like': like ? 1 : -1,
      'url': urlFinal,
      'algo': algoName,
      's': sToken(params),
    });
    await post(Uri.parse('https://socialbook.io/api/tool/matting/evaluate'), body: databody, headers: (sharedPrefs.getBool("isLogin") ?? false) ? headers : headers1)
        .whenComplete(() async {
      controller.changeIsLoading(false);
      controller.changeIsRate(false);
    });
  }

  Future<bool> _getPrefs() async {
    var sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool("isLogin") ?? false;
  }

  Widget _buildSeparator() {
    return VerticalDivider(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      width: 1.w,
      indent: 3.h,
      endIndent: 3.h,
      thickness: 0.8.w,
    );
  }

  Widget _buildTextItem(BuildContext context, int index) {
    return Obx(() => GestureDetector(
          onTap: () async {
            controller.setLastItemIndex1(index);
            // if(scrollController.hasClients) {
            scrollController.scrollTo(index: index, duration: Duration(milliseconds: 100), curve: Curves.easeInOutCubic);
            // } else {
            //   scrollController.jumpTo(index: index);
            // }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: TitleTextWidget(
                (widget.list[index].display_name != "null") ? widget.list[index].display_name : widget.list[index].key,
                (index == controller.lastItemIndex1.value) ? ColorConstant.TextBlack : ColorConstant.LightTextColor,
                (index == controller.lastItemIndex1.value) ? FontWeight.w600 : FontWeight.w400,
                12.sp),
          ),
        ));
  }
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
                TitleTextWidget(StringConstant.signup_text1, ColorConstant.TextBlack, FontWeight.w600, 14.sp),
                SizedBox(
                  height: 1.h,
                ),
                TitleTextWidget(StringConstant.signup_text2, ColorConstant.HintColor, FontWeight.w400, 10.sp),
                SizedBox(
                  height: 2.h,
                ),
                GestureDetector(
                  onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(name: "/SignupScreen", arguments:"choose_photo"),
                        builder: (context) => SignupScreen(),
                      ),
                    )
                  },
                  child: RoundedBorderBtnWidget(StringConstant.sign_up),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
