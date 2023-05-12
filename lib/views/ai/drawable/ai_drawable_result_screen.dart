import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/photo_view/any_photo_pager.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/ai_draw_api.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/drawable/ai_drawable.dart';
import 'package:cartoonizer/views/ai/drawable/widget/drawable.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';

class AiDrawableResultScreen extends StatefulWidget {
  DrawableController drawableController;
  String filePath;
  double scale;
  String photoType;

  AiDrawableResultScreen({
    Key? key,
    required this.drawableController,
    required this.filePath,
    required this.scale,
    required this.photoType,
  }) : super(key: key);

  @override
  State<AiDrawableResultScreen> createState() => _AiDrawableResultScreenState();
}

class _AiDrawableResultScreenState extends AppState<AiDrawableResultScreen> {
  late DrawableController drawableController;
  late String filePath;
  late double scale;
  late double imageWidth;
  late double imageHeight;
  late String photoType;
  String? resultFilePath;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  UserManager userManager = AppDelegate.instance.getManager();
  UploadImageController uploadImageController = Get.put(UploadImageController());
  RecentController recentController = Get.find();
  late AiDrawApi api;
  late double itemSize;

  @override
  void initState() {
    super.initState();
    api = AiDrawApi().bindState(this);
    scale = widget.scale;
    photoType = widget.photoType;
    drawableController = widget.drawableController;
    filePath = widget.filePath;
    imageWidth = (ScreenUtil.screenSize.width - $(64)) / 2;
    imageHeight = imageWidth / scale;
    itemSize = (ScreenUtil.screenSize.width - $(88)) / 4;
    delay(() {
      if (drawableController.resultFilePaths.isNotEmpty) {
        resultFilePath = drawableController.resultFilePaths.first;
        setState(() {});
      } else {
        generate();
      }
    });
  }

  @override
  dispose() {
    api.unbind();
    drawableController.resultFilePaths = [];
    Get.delete<UploadImageController>();
    super.dispose();
  }

  generate() async {
    SimulateProgressBarController progressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(context, needUploadProgress: true, controller: progressBarController, config: SimulateProgressBarConfig.aiDraw(context)).then((value) {
      if (value == null) {
        Navigator.of(context).pop();
      } else if (value.result) {
        setState(() {});
        Events.aidrawCompleteSuccess();
      } else {
        Navigator.of(context).pop();
      }
    });

    File compressedImage = await imageCompressAndGetFile(File(filePath), imageSize: 512);

    var imageInfo = await SyncFileImage(file: compressedImage).getImage();

    var rootPath = cacheManager.storageOperator.recordAiDrawDir.path;

    uploadImageController.uploadCompressedImage(compressedImage, cache: false).then((value) async {
      if (value) {
        progressBarController.uploadComplete();
        api
            .draw(
          text: drawableController.text.value,
          directoryPath: rootPath,
          width: imageInfo.image.width,
          height: imageInfo.image.height,
          initImage: uploadImageController.imageUrl.value,
        )
            .then((value) {
          if (value != null) {
            recentController.onAiDrawUsed(DrawableRecord(
                text: drawableController.text.value, activePens: drawableController.activePens, checkMatePens: drawableController.checkmatePens, resultPaths: value.filePath));
            drawableController.resultFilePaths = value.filePath;
            resultFilePath = drawableController.resultFilePaths.first;
            progressBarController.loadComplete();
          } else {
            progressBarController.onError();
          }
        });
      } else {
        progressBarController.onError();
      }
    });
  }

  void openImage(BuildContext context, final int index) async {
    Events.aidrawCompletePreview();
    List<AnyPhotoItem> images = [
      AnyPhotoItem(
        type: AnyPhotoType.file,
        uri: filePath,
        tag: AiDrawable.localImageTag,
      ),
      AnyPhotoItem(
        type: AnyPhotoType.file,
        uri: resultFilePath!,
      ),
    ];
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => AnyGalleryPhotoViewWrapper(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index >= images.length ? 0 : index,
        ),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    if (TextUtil.isEmpty(resultFilePath)) {
      return Container();
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Image.asset(Images.ic_ai_draw_top),
                      Text(
                        '@${userManager.user?.getShownName() ?? 'Pandora User'}',
                        style: TextStyle(
                          color: ColorConstant.White,
                          fontFamily: 'Poppins',
                          fontSize: $(14),
                          fontWeight: FontWeight.bold,
                        ),
                      ).marginOnly(left: $(16), top: $(50)),
                    ],
                  ),
                  Expanded(
                    child: Image.asset(
                      Images.ic_mt_result_middle,
                      fit: BoxFit.fill,
                      width: double.maxFinite,
                    ),
                  ),
                  Image.asset(Images.ic_mt_result_bottom),
                ],
              ),
              Stack(
                children: [
                  Align(
                    child: Row(
                      children: [
                        Expanded(
                          child: Image.file(
                            File(filePath),
                            width: imageWidth,
                            height: imageHeight,
                            fit: BoxFit.fill,
                          ).hero(tag: AiDrawable.localImageTag).intoGestureDetector(onTap: () {
                            openImage(context, 0);
                          }),
                        ),
                        SizedBox(width: $(4)),
                        Expanded(
                          child: Image.file(
                            File(resultFilePath!),
                            width: imageWidth,
                            height: imageHeight,
                            fit: BoxFit.cover,
                          ).hero(tag: resultFilePath!).intoGestureDetector(onTap: () {
                            openImage(context, 1);
                          }),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                  ),
                  Align(
                    child: Image.asset(
                      Images.ic_ai_draw_arrow,
                      width: $(18),
                    ),
                    alignment: Alignment.center,
                  ),
                ],
              ).intoContainer(
                // margin: EdgeInsets.only(top: $(95)),
                padding: EdgeInsets.symmetric(horizontal: $(16)),
              ),
            ],
          ).intoContainer(
            margin: EdgeInsets.symmetric(horizontal: $(10), vertical: $(10)),
          )),
          Row(
            children: drawableController.resultFilePaths.transfer((e, index) => ClipRRect(
                  child: Image(
                    image: FileImage(File(e)),
                    width: itemSize,
                    height: itemSize,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular($(4)),
                )
                    .intoContainer(
                  decoration: BoxDecoration(
                    border: Border.all(color: resultFilePath == e ? ColorConstant.DiscoveryBtn : Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular($(6)),
                  ),
                  margin: EdgeInsets.only(left: index == 0 ? 0 : $(4)),
                )
                    .intoGestureDetector(onTap: () {
                  setState(() {
                    resultFilePath = e;
                  });
                })),
          ).intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(8)),
              margin: EdgeInsets.symmetric(horizontal: $(16), vertical: $(10)),
              decoration: BoxDecoration(
                color: Color(0x2bffffff),
                borderRadius: BorderRadius.circular($(8)),
              )),
          Row(
            children: [
              Expanded(
                  child: buildButton(context, icon: Images.ic_share_discovery, text: S.of(context).tabDiscovery)
                      .intoContainer(
                          alignment: Alignment.center,
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(vertical: $(10)),
                          margin: EdgeInsets.symmetric(horizontal: $(7.5)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular($(12)),
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF57CD), Color(0xFF9A26FF), Color(0xFF601AFF)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )))
                      .intoGestureDetector(onTap: () {
                AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_ai_draw', callback: () async {
                  var file = File(resultFilePath!);
                  var forward = () {
                    ShareDiscoveryScreen.push(
                      context,
                      effectKey: DiscoveryCategory.scribble.name,
                      originalUrl: uploadImageController.imageUrl.value,
                      image: base64Encode(file.readAsBytesSync()),
                      isVideo: false,
                      category: DiscoveryCategory.scribble,
                    ).then((value) {
                      if (value ?? false) {
                        Events.aidrawCompleteShare(source: photoType == 'recently' ? 'recently' : 'ai_draw', platform: 'discovery', type: 'image');
                        showShareSuccessDialog(context);
                      }
                    });
                  };
                  if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
                    File compressedImage = await imageCompressAndGetFile(File(filePath), imageSize: 512);
                    showLoading().whenComplete(() {
                      uploadImageController.uploadCompressedImage(compressedImage, cache: false).then((value) {
                        hideLoading().whenComplete(() {
                          if (value) {
                            forward.call();
                          }
                        });
                      });
                    });
                  } else {
                    forward.call();
                  }
                }, autoExec: true);
              })),
              Expanded(
                child: buildButton(context, icon: Images.ic_share, text: S.of(context).share)
                    .intoContainer(
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        padding: EdgeInsets.symmetric(vertical: $(10)),
                        margin: EdgeInsets.symmetric(horizontal: $(7.5)),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular($(12)),
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF57CD), Color(0xFF9A26FF), Color(0xFF601AFF)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )))
                    .intoGestureDetector(onTap: () async {
                  await showLoading();
                  if (TextUtil.isEmpty(resultFilePath)) {
                    return;
                  }
                  var uint8list = await ImageUtils.printAiDrawData(File(filePath), File(resultFilePath!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                  await hideLoading();
                  ShareScreen.startShare(context,
                      backgroundColor: Color(0x77000000),
                      style: 'AI_Draw',
                      image: base64Encode(uint8list),
                      isVideo: false,
                      originalUrl: null,
                      effectKey: 'AI_Draw', onShareSuccess: (platform) {
                    Events.aidrawCompleteShare(source: photoType == 'recently' ? 'recently' : 'ai_draw', platform: platform, type: 'image');
                  });
                  AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                }),
              ),
            ],
          ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(7.5), vertical: $(15))),
          buildButton(
            context,
            icon: Images.ic_download,
            text: S.of(context).download,
          )
              .intoContainer(
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  margin: EdgeInsets.symmetric(horizontal: $(15)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(12)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00FFF8),
                          Color(0xFF1F83FF),
                          Color(0xFF5E18FF),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )))
              .intoGestureDetector(onTap: () async {
            await showLoading();
            var uint8list = await ImageUtils.printAiDrawData(File(filePath), File(resultFilePath!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
            var list = uint8list.toList();
            var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
            var imgPath = path + '${DateTime.now().millisecondsSinceEpoch}.png';
            await File(imgPath).writeAsBytes(list);
            await GallerySaver.saveImage(imgPath, albumName: saveAlbumName);
            await hideLoading();
            Events.aidrawCompleteDownload(type: 'image');
            CommonExtension().showImageSavedOkToast(context);
            delay(() {
              UserManager userManager = AppDelegate.instance.getManager();
              userManager.rateNoticeOperator.onSwitch(context);
            }, milliseconds: 2000);
          }),
        ],
      ),
    ).intoContainer(
        padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(25)),
        height: ScreenUtil.screenSize.height,
        width: ScreenUtil.screenSize.width,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_another_me_trans_bg), fit: BoxFit.fill)));
  }

  Widget buildButton(BuildContext context, {required String icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          icon,
          width: $(24),
        ),
        SizedBox(width: $(9)),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: $(17),
          ),
        )
      ],
    );
  }
}
