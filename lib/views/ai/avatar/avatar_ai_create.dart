import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_controller.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:cartoonizer/views/ai/avatar/dialog/upload_loading_dialog.dart';
import 'package:cartoonizer/views/ai/avatar/select_bio_style_screen.dart';

import 'dialog/add_photos_dialog.dart';
import 'avatar.dart';

class AvatarAiCreateScreen extends StatefulWidget {
  const AvatarAiCreateScreen({Key? key}) : super(key: key);

  @override
  State<AvatarAiCreateScreen> createState() => _AvatarAiCreateScreenState();
}

class _AvatarAiCreateScreenState extends State<AvatarAiCreateScreen> {
  AvatarAiController controller = Get.put(AvatarAiController());
  late double imageWidth;
  late double imageHeight;

  @override
  void initState() {
    super.initState();
    imageWidth = ScreenUtil.screenSize.width / 4;
    imageHeight = imageWidth * 1.25;
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<AvatarAiController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        backIcon: Image.asset(
          Images.ic_back,
          height: $(24),
          width: $(24),
        ).hero(tag: Avatar.logoBackTag),
        middle: TitleTextWidget('Upload photos', ColorConstant.White, FontWeight.w500, $(17)),
      ),
      body: GetBuilder<AvatarAiController>(
        builder: (controller) => LoadingOverlay(
            isLoading: controller.isLoading,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      buildIconText(context, title: 'Good photo examples', icon: Images.ic_checked),
                      SizedBox(height: 12),
                      TitleTextWidget(
                        'Close-up selfies, same person, adults, '
                        'variety of backgrounds, facial expressions, '
                        'head tilts and angles',
                        ColorConstant.White,
                        FontWeight.normal,
                        $(14),
                        maxLines: 5,
                        align: TextAlign.left,
                      ).intoContainer(
                        padding: EdgeInsets.symmetric(horizontal: $(15)),
                      ),
                      SizedBox(height: 12),
                      buildExamples(context, good: true),
                      SizedBox(height: 20),
                      buildIconText(context, title: 'Bad photo examples', icon: Images.ic_checked),
                      SizedBox(height: 12),
                      TitleTextWidget(
                        'Group shots, full-length, kids, covered faces,'
                        ' animals, monotonous pics, nudes',
                        ColorConstant.White,
                        FontWeight.normal,
                        $(14),
                        align: TextAlign.left,
                        maxLines: 5,
                      ).intoContainer(
                        padding: EdgeInsets.symmetric(horizontal: $(15)),
                      ),
                      SizedBox(height: 12),
                      buildExamples(context, good: false),
                    ],
                  ),
                )),
                TitleTextWidget(
                  'Group shots, full-length, kids, covered faces,'
                  ' animals, monotonous pics, nudes',
                  ColorConstant.White,
                  FontWeight.normal,
                  $(14),
                  align: TextAlign.center,
                  maxLines: 5,
                ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(30))),
                Text(
                  controller.pickPhotosText,
                  style: TextStyle(color: Colors.white),
                )
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(32)),
                    color: ColorConstant.BlueColor,
                  ),
                )
                    .intoGestureDetector(onTap: () {
                  if (controller.imageList.isEmpty) {
                    showTakePhotoOptDialog(context, controller);
                  } else {
                    if (controller.imageList.length >= controller.minSize && controller.imageList.length <= controller.maxSize) {
                      startUpload(context, controller);
                    } else {
                      showChosenDialog(context, controller);
                    }
                  }
                }),
              ],
            )),
        init: controller,
      ),
    );
  }

  startUpload(BuildContext context, AvatarAiController controller) {
    if (controller.uploadedList.length == controller.imageList.length) {
      SelectStyleScreen.push(context).then((value) {
        if (value != null) {
          startSubmit(context, controller, value);
        }
      });
    } else {
      showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => UploadLoadingDialog(controller: controller)).then((value) {
        if (value ?? false) {
          SelectStyleScreen.push(context).then((value) {
            if (value != null) {
              startSubmit(context, controller, value);
            }
          });
        }
      });
    }
  }

  startSubmit(BuildContext context, AvatarAiController controller, BioStyle style) {
    controller.submit().then((value) {
      if(value != null) {

      }
    });
  }

  void showChosenDialog(BuildContext context, AvatarAiController controller) {
    showDialog(
        context: context,
        builder: (_) {
          return AddPhotosDialog(controller: controller);
        });
  }

  Widget buildExamples(
    BuildContext context, {
    bool good = true,
  }) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: $(15)),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var image = CachedNetworkImageUtils.custom(
          context: context,
          imageUrl: imgUrl,
          width: imageWidth,
          height: imageHeight,
          fit: BoxFit.cover,
        );
        return buildListItem(context, index: index, checked: good, child: image);
      },
      itemCount: 4,
    ).intoContainer(height: imageHeight, width: ScreenUtil.screenSize.width);
  }

  Widget buildListItem(
    BuildContext context, {
    required int index,
    required bool checked,
    required Widget child,
  }) {
    return Stack(
      children: [
        child.intoContainer(
          width: imageWidth,
          height: imageHeight,
          margin: EdgeInsets.only(left: index == 0 ? 0 : $(12)),
        ),
        Positioned(
          child: Icon(
            checked ? Icons.check_box : Icons.disabled_by_default,
            size: $(22),
            color: checked ? ColorConstant.BlueColor : ColorConstant.Red,
          ),
          right: 4,
          bottom: 4,
        ),
      ],
    ).intoContainer(
      width: imageWidth,
      height: imageHeight,
    );
  }

  Widget buildIconText(
    BuildContext context, {
    required String title,
    required String icon,
  }) {
    return Row(
      children: [
        Image.asset(
          icon,
          width: $(18),
        ),
        Expanded(
            child: TitleTextWidget(
          title,
          ColorConstant.White,
          FontWeight.w500,
          $(17),
          align: TextAlign.left,
        ))
      ],
    ).intoContainer(
      padding: EdgeInsets.symmetric(horizontal: $(15)),
    );
  }
}

Future showTakePhotoOptDialog(BuildContext context, AvatarAiController controller) async => showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleTextWidget('Take photo now', ColorConstant.White, FontWeight.normal, $(17))
              .intoContainer(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: $(10)),
            color: Colors.transparent,
          )
              .intoGestureDetector(onTap: () {
            controller.pickImageFromCamera().then((value) {
              Navigator.of(context).pop();
            });
          }),
          Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
          TitleTextWidget('Choose from album', ColorConstant.White, FontWeight.normal, $(17))
              .intoContainer(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: $(10)),
            color: Colors.transparent,
          )
              .intoGestureDetector(onTap: () {
            controller.pickImageFromGallery().then((value) {
              Navigator.of(context).pop();
            });
          }),
          SizedBox(height: 10),
        ],
      ).intoContainer(
          padding: EdgeInsets.only(top: $(10), bottom: $(10)),
          decoration: BoxDecoration(
              color: ColorConstant.EffectFunctionGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular($(24)),
                topRight: Radius.circular($(24)),
              )));
    },
    backgroundColor: Colors.transparent);
