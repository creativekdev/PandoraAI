import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/photo_view/any_photo_pager.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/switch_image_card.dart';
import 'package:cartoonizer/api/ai_draw_api.dart';
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
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/ai_drawable.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/widget/drawable.dart';
import 'package:cartoonizer/views/print/print.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';

class AiDrawableResultScreen extends StatefulWidget {
  DrawableController drawableController;
  String filePath;
  double scale;
  String photoType;
  String source;

  AiDrawableResultScreen({
    Key? key,
    required this.drawableController,
    required this.filePath,
    required this.scale,
    required this.source,
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
  late String source;
  late String photoType;
  String? resultFilePath;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  UserManager userManager = AppDelegate.instance.getManager();
  UploadImageController uploadImageController = Get.find();
  RecentController recentController = Get.find();
  late AiDrawApi api;
  late double itemSize;

  @override
  void initState() {
    super.initState();
    api = AiDrawApi().bindState(this);
    scale = widget.scale;
    source = widget.source;
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
    super.dispose();
  }

  generate() async {
    SimulateProgressBarController progressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(context, needUploadProgress: true, controller: progressBarController, config: SimulateProgressBarConfig.aiDraw(context)).then((value) {
      if (value == null) {
        Navigator.of(context).pop();
      } else if (value.result) {
        setState(() {});
        Events.aidrawCompleteSuccess(source: source, photoType: photoType);
      } else {
        Navigator.of(context).pop();
      }
    });

    File originalFile = File(filePath);

    var imageInfo = await SyncFileImage(file: originalFile).getImage();

    var rootPath = cacheManager.storageOperator.recordAiDrawDir.path;
    uploadImageController.upload(file: originalFile, cache: false).then((value) async {
      if (TextUtil.isEmpty(value)) {
        progressBarController.onError();
      } else {
        progressBarController.uploadComplete();
        api
            .draw(
          text: drawableController.text.value,
          directoryPath: rootPath,
          width: imageInfo.image.width,
          height: imageInfo.image.height,
          initImage: value!,
          onFailed: (response) {
            uploadImageController.deleteUploadData(originalFile);
          },
        )
            .then((value) {
          if (value != null) {
            recentController.onAiDrawUsed(DrawableRecord(
              text: drawableController.text.value,
              activePens: drawableController.activePens,
              checkMatePens: drawableController.checkmatePens,
              resultPaths: value.filePath,
              cameraFilePath: filePath,
            ));
            drawableController.resultFilePaths = value.filePath;
            resultFilePath = drawableController.resultFilePaths.first;
            progressBarController.loadComplete();
            // 增加次数判断，看是否显示rate_us
            UserManager userManager = AppDelegate.instance.getManager();
            userManager.rateNoticeOperator.onSwitch(Get.context!, true);
          } else {
            progressBarController.onError();
          }
        });
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
        trailing: Image.asset(Images.ic_share, height: $(24), width: $(24)).intoGestureDetector(
          onTap: () => shareOut(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SwitchImageCard(origin: File(filePath), result: File(resultFilePath!)),
          ),
          SizedBox(height: 10),
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
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Images.ic_download, height: $(24), width: $(24))
                  .intoGestureDetector(
                    onTap: () => savePhoto(context),
                  )
                  .intoContainer(
                    padding: EdgeInsets.all($(15)),
                    margin: EdgeInsets.symmetric(horizontal: $(20)),
                  ),
              Image.asset(Images.ic_share_print, height: $(24), width: $(24))
                  .intoGestureDetector(
                    onTap: () => toPrint(context),
                  )
                  .intoContainer(
                    padding: EdgeInsets.all($(15)),
                    margin: EdgeInsets.symmetric(horizontal: $(20)),
                  ),
              Image.asset(Images.ic_share_discovery, height: $(24), width: $(24))
                  .intoGestureDetector(
                    onTap: () => shareToDiscovery(context),
                  )
                  .intoContainer(
                    padding: EdgeInsets.all($(15)),
                    margin: EdgeInsets.symmetric(horizontal: $(20)),
                  ),
            ],
          ),
        ],
      ),
    ).intoContainer(
        padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context) + $(15)),
        height: ScreenUtil.screenSize.height,
        width: ScreenUtil.screenSize.width,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(Images.ic_another_me_trans_bg), fit: BoxFit.fill),
        ));
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

  toPrint(BuildContext context) {
    if (TextUtil.isEmpty(resultFilePath)) {
      return;
    }
    Print.open(context, source: 'scribble', file: File(resultFilePath!));
  }

  savePhoto(BuildContext context) async {
    await showLoading();
    // var uint8list = await ImageUtils.printAiDrawData(File(filePath), File(resultFilePath!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    // var list = uint8list.toList();
    // var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    // var imgPath = path + '${DateTime.now().millisecondsSinceEpoch}.png';
    // await File(imgPath).writeAsBytes(list);
    await GallerySaver.saveImage(resultFilePath!, albumName: saveAlbumName);
    await hideLoading();
    Events.aidrawCompleteDownload(type: 'image');
    CommonExtension().showImageSavedOkToast(context);
  }

  shareOut(BuildContext context) async {
    await showLoading();
    if (TextUtil.isEmpty(resultFilePath)) {
      return;
    }
    var uint8list = await ImageUtils.printAiDrawData(File(filePath), File(resultFilePath!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    await hideLoading();
    ShareScreen.startShare(context, backgroundColor: Color(0x77000000), style: 'AI_Draw', image: base64Encode(uint8list), isVideo: false, originalUrl: null, effectKey: 'AI_Draw',
        onShareSuccess: (platform) {
      Events.aidrawCompleteShare(source: source, platform: platform, type: photoType);
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  shareToDiscovery(BuildContext context) {
    var originalFile = File(filePath);
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_ai_draw', callback: () async {
      var file = File(resultFilePath!);
      var forward = () {
        ShareDiscoveryScreen.push(
          context,
          effectKey: 'scribble',
          originalUrl: uploadImageController.imageUrl(originalFile).value,
          image: base64Encode(file.readAsBytesSync()),
          isVideo: false,
          category: HomeCardType.scribble,
        ).then((value) {
          if (value ?? false) {
            Events.aidrawCompleteShare(source: source, platform: 'discovery', type: photoType);
            showShareSuccessDialog(context);
          }
        });
      };
      showLoading().whenComplete(() {
        uploadImageController.upload(file: originalFile, cache: false).then((value) {
          hideLoading().whenComplete(() {
            if (!TextUtil.isEmpty(value)) {
              forward.call();
            }
          });
        });
      });
    }, autoExec: true);
  }
}
