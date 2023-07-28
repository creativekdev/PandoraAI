import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/camera/pai_camera_screen.dart';
import 'package:cartoonizer/Widgets/gallery/crop_screen.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/switch_image_card.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/drawable/colorfill/ai_coloring_controller.dart';
import 'package:cartoonizer/views/print/print.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class AiColoringScreen extends StatefulWidget {
  String source;
  RecentColoringEntity record;
  String photoType;

  AiColoringScreen({
    Key? key,
    required this.source,
    required this.record,
    required this.photoType,
  }) : super(key: key);

  @override
  State<AiColoringScreen> createState() => _AiColoringScreenState();
}

class _AiColoringScreenState extends AppState<AiColoringScreen> {
  late AiColoringController controller;
  late UploadImageController uploadImageController = Get.find();
  UserManager userManager = AppDelegate().getManager();

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'ai_coloring_screen');
    controller = Get.put(AiColoringController(
      source: widget.source,
      photoType: widget.photoType,
      record: widget.record,
      recentController: Get.find<RecentController>(),
      uploadImageController: uploadImageController,
    ));
    delay(() {
      if (TextUtil.isEmpty(controller.resultPath)) {
        controller.generate(context);
      }
    });
  }

  @override
  void dispose() {
    Get.delete<AiColoringController>();
    Get.delete<AiColoringController>();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GetBuilder<AiColoringController>(
      init: Get.find<AiColoringController>(),
      builder: (controller) {
        return (Scaffold(
            backgroundColor: ColorConstant.BackgroundColor,
            appBar: AppNavigationBar(
              backgroundColor: ColorConstant.BackgroundColor,
              trailing: Image.asset(
                Images.ic_more,
                height: $(24),
                width: $(24),
                color: Colors.white,
              )
                  .intoContainer(
                alignment: Alignment.centerRight,
                width: ScreenUtil.screenSize.width,
              )
                  .intoGestureDetector(onTap: () {
                LiPopMenu.showLinePop(
                  context,
                  listData: [
                    ListPopItem(
                        text: S.of(context).share_to_discovery,
                        icon: Images.ic_share_discovery,
                        onTap: () {
                          shareToDiscovery(context, controller);
                        }),
                    ListPopItem(
                        text: S.of(context).share_out,
                        icon: Images.ic_share,
                        onTap: () {
                          shareOut(context, controller);
                        }),
                  ],
                );
              }),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SwitchImageCard(
                    origin: controller.originFile,
                    result: controller.resultFile,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Images.ic_camera, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => pickPhoto(context, controller),
                        )
                        .intoContainer(
                          padding: EdgeInsets.all($(15)),
                          margin: EdgeInsets.symmetric(horizontal: $(20)),
                        ),
                    Image.asset(Images.ic_share_print, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => toPrint(context, controller),
                        )
                        .intoContainer(
                          padding: EdgeInsets.all($(15)),
                          margin: EdgeInsets.symmetric(horizontal: $(20)),
                        ),
                    Image.asset(Images.ic_download, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => savePhoto(context, controller),
                        )
                        .intoContainer(
                          padding: EdgeInsets.all($(15)),
                          margin: EdgeInsets.symmetric(horizontal: $(20)),
                        ),
                  ],
                ),
                OutlineWidget(
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
                    padding: EdgeInsets.all($(2)),
                  ),
                )
                    .intoGestureDetector(onTap: () {
                      controller.generate(context);
                    })
                    .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(8)))
                    .visibility(visible: !TextUtil.isEmpty(controller.resultPath)),
                SizedBox(
                  height: ScreenUtil.getBottomPadding(context),
                )
              ],
            )));
      },
    );
  }

  pickPhoto(BuildContext context, AiColoringController controller) {
    PAICamera.takePhoto(context).then((value) async {
      if (value != null) {
        var xFile = await CropScreen.crop(context, image: value.xFile, brightness: Brightness.dark);
        String r;
        if (xFile != null) {
          r = xFile.path;
        } else {
          r = value.xFile.path;
        }
        controller.photoType = value.source;
        CacheManager cacheManager = AppDelegate().getManager();
        var path = await ImageUtils.onImagePick(r, cacheManager.storageOperator.recordAiColoringDir.path);
        controller.changeOriginFile(context, File(path));
      }
    });
  }

  pickPhotoFromCamera(BuildContext context, AiColoringController controller) async {
    var pickImage = await ImagePicker().pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear, imageQuality: 100);
    if (pickImage != null) {
      var xFile = await CropScreen.crop(context, image: pickImage, brightness: Brightness.dark);
      var r;
      if (xFile != null) {
        r = File(xFile.path);
      } else {
        r = File(pickImage.path);
      }
      controller.photoType = 'camera';
      CacheManager cacheManager = AppDelegate().getManager();
      var path = await ImageUtils.onImagePick(r.path, cacheManager.storageOperator.recordAiColoringDir.path);
      controller.changeOriginFile(context, File(path));
      // XFile? result = await CropScreen.crop(context, image: pickImage, brightness: Brightness.light);
    }
  }

  pickPhotoFromAlbum(BuildContext context, AiColoringController controller) async {
    var files = await PickAlbumScreen.pickImage(
      context,
      count: 1,
      switchAlbum: true,
    );
    if (files != null && files.isNotEmpty) {
      var medium = files.first;
      var file = await medium.originFile;
      if (file != null) {
        var xFile = await CropScreen.crop(context, image: XFile(file.path), brightness: Brightness.dark);
        var r;
        if (xFile != null) {
          r = File(xFile.path);
        } else {
          r = file;
        }
        CacheManager cacheManager = AppDelegate().getManager();
        var path = await ImageUtils.onImagePick(r.path, cacheManager.storageOperator.recordAiColoringDir.path);
        controller.photoType = 'gallery';
        controller.changeOriginFile(context, File(path));
        // XFile? result = await CropScreen.crop(context, image: XFile(file.path), brightness: Brightness.light);
      }
    }
  }

  toPrint(BuildContext context, AiColoringController controller) async {
    if (TextUtil.isEmpty(controller.resultPath)) {
      return;
    }
    Print.open(context, source: 'aicoloring', file: File(controller.resultPath!));
  }

  savePhoto(BuildContext context, AiColoringController controller) async {
    if (TextUtil.isEmpty(controller.resultPath)) {
      return;
    }
    await showLoading();
    GallerySaver.saveImage(controller.resultPath!, albumName: saveAlbumName);
    await hideLoading();
    CommonExtension().showImageSavedOkToast(context);
    Events.aiColoringCompleteDownload(type: 'image');
  }

  shareOut(BuildContext context, AiColoringController controller) async {
    if (TextUtil.isEmpty(controller.resultPath)) {
      return;
    }
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var uint8list = await ImageUtils.printAiColoringData(controller.originFile, File(controller.resultPath!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    ShareScreen.startShare(context, backgroundColor: Color(0x77000000), style: 'lineart', image: base64Encode(uint8list), isVideo: false, originalUrl: null, effectKey: 'lineart',
        onShareSuccess: (platform) {
      Events.aiColoringCompleteShare(source: controller.photoType, platform: platform, type: 'image');
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  shareToDiscovery(BuildContext context, AiColoringController controller) async {
    if (TextUtil.isEmpty(controller.resultPath)) {
      return;
    }
    String? imageUrl = uploadImageController.imageUrl(controller.originFile).value;
    if (TextUtil.isEmpty(imageUrl)) {
      await showLoading();
      imageUrl = await uploadImageController.upload(file: controller.originFile);
      if (TextUtil.isEmpty(imageUrl)) {
        await hideLoading();
        return;
      } else {
        await hideLoading();
      }
    }
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_stylemorph', callback: () {
      var file = File(controller.resultPath!);
      ShareDiscoveryScreen.push(
        context,
        effectKey: 'lineart',
        originalUrl: imageUrl,
        image: base64Encode(file.readAsBytesSync()),
        isVideo: false,
        category: HomeCardType.lineart,
      ).then((value) {
        if (value ?? false) {
          Events.aiColoringCompleteShare(source: controller.photoType, platform: 'discovery', type: 'image');
          showShareSuccessDialog(context);
        }
      });
    }, autoExec: true);
  }
}
