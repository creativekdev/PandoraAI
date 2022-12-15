import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Common/images-res.dart' as exampleRes;
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_controller.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:cartoonizer/views/ai/avatar/dialog/upload_loading_dialog.dart';
import 'package:cartoonizer/views/ai/avatar/select_bio_style_screen.dart';

import 'dialog/add_photos_dialog.dart';
import 'avatar.dart';
import 'dialog/submit_avatar_dialog.dart';

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
    logEvent(Events.avatar_create_loading);
    imageWidth = ScreenUtil.screenSize.width / 5;
    imageHeight = imageWidth;
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
                      shaderMask(
                          context: context,
                          child: Text(
                            'Upload photos',
                            style: TextStyle(
                              color: ColorConstant.White,
                              fontSize: $(26),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          )),
                      SizedBox(height: 20),
                      buildIconText(
                        context,
                        title: 'Good photo examples',
                        icon: Images.ic_avatar_good_example,
                      ),
                      SizedBox(height: 12),
                      TitleTextWidget(
                        'Show your shoulders, close-up selfies, same person in the photos, '
                        'variety of loation/backgrounds/angels, different facial expressions. ',
                        ColorConstant.White,
                        FontWeight.normal,
                        $(14),
                        maxLines: 5,
                        align: TextAlign.left,
                      ).intoContainer(
                        padding: EdgeInsets.symmetric(horizontal: $(15)),
                      ),
                      SizedBox(height: 12),
                      buildExamples(context, [
                        exampleRes.Images.good_1,
                        exampleRes.Images.good_2,
                        exampleRes.Images.good_3,
                        exampleRes.Images.good_4,
                        exampleRes.Images.good_5,
                        exampleRes.Images.good_6,
                      ]),
                      SizedBox(height: 20),
                      buildIconText(
                        context,
                        title: 'Bad photo examples',
                        icon: Images.ic_avatar_bad_example,
                      ),
                      SizedBox(height: 12),
                      TitleTextWidget(
                        'Group shots, only photos looking INTO the camera, covered faces/sunglasses,'
                        'monotonous pics, nudes, kids(ONLY 18+ ADULTS)',
                        ColorConstant.White,
                        FontWeight.normal,
                        $(14),
                        align: TextAlign.left,
                        maxLines: 5,
                      ).intoContainer(
                        padding: EdgeInsets.symmetric(horizontal: $(15)),
                      ),
                      SizedBox(height: 12),
                      buildExamples(context, [
                        exampleRes.Images.bad_1,
                        exampleRes.Images.bad_2,
                        exampleRes.Images.bad_3,
                        exampleRes.Images.bad_4,
                        exampleRes.Images.bad_5,
                        exampleRes.Images.bad_6,
                      ]),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: '',
                          children: [
                            WidgetSpan(
                              child: Image.asset(
                                Images.ic_warning,
                                width: $(15),
                                color: Color(0xffFFCC00),
                              ),
                            ),
                            TextSpan(
                              text: 'We only use your photos to train the AI model and render your avatars'
                                  'Both the input photos and the AI model will be deleted from our servers within 24 hours.'
                                  'You will have the option to keep the AI model as a premium service.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: ColorConstant.White,
                                fontSize: $(14),
                              ),
                            )
                          ],
                        ),
                      ).intoContainer(
                          padding: EdgeInsets.only(
                            top: $(20),
                            left: $(20),
                            right: $(20),
                            bottom: $(25),
                          ),
                          margin: EdgeInsets.only(
                            top: $(20),
                            left: $(15),
                            right: $(15),
                            bottom: $(10),
                          ),
                          decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular($(12)))),
                    ],
                  ),
                )),
                Text(
                  controller.pickPhotosText,
                  style: TextStyle(color: Colors.white, fontSize: $(17)),
                )
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(8)),
                    color: ColorConstant.BlueColor,
                  ),
                )
                    .intoGestureDetector(onTap: () {
                  if (controller.imageList.isEmpty) {
                    showTakePhotoOptDialog(context, controller).then((value) {
                      if (value ?? false) {
                        if (controller.imageList.length >= controller.minSize && controller.imageList.length <= controller.maxSize) {
                          startUpload(context, controller);
                        } else {
                          showChosenDialog(context, controller);
                        }
                      }
                    });
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
      ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))),
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
    SubmitAvatarDialog.push(context, name: controller.name ?? '').then((value) {
      controller.name = value;
      if (value != null) {
        controller
            .submit(
          style: style,
          name: controller.name!,
        )
            .then((value) {
          if (value != null) {
            showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                      backgroundColor: ColorConstant.BackgroundColor,
                      title: TitleTextWidget('Successful', ColorConstant.White, FontWeight.w600, $(16)),
                      content: TitleTextWidget('Your photos will be generated in about 2 hours', ColorConstant.White, FontWeight.w600, $(14), maxLines: 3),
                      actions: [
                        TitleTextWidget('Ok', ColorConstant.BlueColor, FontWeight.w600, $(16)).intoGestureDetector(onTap: () {
                          Navigator.of(context).pop(true);
                        }),
                      ],
                    )).then((value) {
              Navigator.pop(context, true);
            });
          }
        });
      }
    });
  }

  void showChosenDialog(BuildContext context, AvatarAiController controller) {
    showDialog<bool>(
        context: context,
        builder: (_) {
          return AddPhotosDialog(controller: controller);
        }).then((value) {
      if (value ?? false) {
        startUpload(context, controller);
      }
    });
  }

  Widget buildExamples(BuildContext context, List<String> examples) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: $(15)),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return buildListItem(context,
            index: index,
            child: Image.asset(
              examples[index],
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
            ));
      },
      itemCount: examples.length,
    ).intoContainer(height: imageHeight, width: ScreenUtil.screenSize.width);
  }

  Widget buildListItem(
    BuildContext context, {
    required int index,
    required Widget child,
  }) {
    return ClipRRect(
      child: child,
      borderRadius: BorderRadius.circular($(6)),
    ).intoContainer(
      width: imageWidth,
      height: imageHeight,
      margin: EdgeInsets.only(left: index == 0 ? 0 : $(8)),
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
        SizedBox(width: $(10)),
        Expanded(
            child: shaderMask(
                context: context,
                child: TitleTextWidget(
                  title,
                  ColorConstant.White,
                  FontWeight.w500,
                  $(17),
                  align: TextAlign.left,
                )))
      ],
    ).intoContainer(
      padding: EdgeInsets.symmetric(horizontal: $(15)),
    );
  }
}

Future<bool?> showTakePhotoOptDialog(BuildContext context, AvatarAiController controller) async => showModalBottomSheet<bool>(
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
              Navigator.of(context).pop(value);
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
              Navigator.of(context).pop(value);
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
