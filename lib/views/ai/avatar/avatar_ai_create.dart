import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_controller.dart';
import 'package:cartoonizer/views/ai/avatar/dialog/upload_loading_dialog.dart';
import 'package:cartoonizer/views/ai/avatar/pay/pay_avatar_screen.dart';

import 'avatar.dart';
import 'dialog/add_photos_dialog.dart';

class AvatarAiCreateScreen extends StatefulWidget {
  final String name;
  final String style;

  const AvatarAiCreateScreen({
    Key? key,
    required this.name,
    required this.style,
  }) : super(key: key);

  @override
  State<AvatarAiCreateScreen> createState() => _AvatarAiCreateScreenState();
}

class _AvatarAiCreateScreenState extends State<AvatarAiCreateScreen> {
  late AvatarAiController controller;
  AvatarAiManager manager = AppDelegate().getManager();
  late double imageWidth;
  late double imageHeight;

  @override
  void initState() {
    super.initState();
    logEvent(Events.avatar_create_loading);
    controller = AvatarAiController(
      name: widget.name,
      style: widget.style,
    );
    Get.put(controller);
    imageWidth = ScreenUtil.screenSize.width / 5;
    imageHeight = imageWidth;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    Get.delete<AvatarAiController>();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AvatarAiController>(
      builder: (controller) {
        var result = LoadingOverlay(
            isLoading: controller.isLoading,
            child: Scaffold(
                backgroundColor: ColorConstant.BackgroundColor,
                appBar: AppNavigationBar(
                  backgroundColor: ColorConstant.BackgroundColor,
                  backAction: () {
                    showBackDialog(context, controller).then((value) {
                      if (value ?? false) {
                        Navigator.of(context).pop();
                      }
                    });
                  },
                  backIcon: Image.asset(
                    Images.ic_back,
                    height: $(24),
                    width: $(24),
                  ).hero(tag: Avatar.logoBackTag),
                ),
                body: Column(
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
                                S.of(context).upload_photos,
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
                            title: S.of(context).good_photo_examples,
                            icon: Images.ic_avatar_good_example,
                          ),
                          SizedBox(height: 12),
                          TitleTextWidget(
                            S.of(context).good_photo_description,
                            ColorConstant.White,
                            FontWeight.normal,
                            $(14),
                            maxLines: 5,
                            align: TextAlign.left,
                          ).intoContainer(
                            padding: EdgeInsets.symmetric(horizontal: $(15)),
                          ),
                          SizedBox(height: 12),
                          FutureBuilder(
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {
                                return buildExamples(context, []);
                              }
                              var data = snapshot.data as AvatarConfig;
                              List<String> goodImages = data.goodImages(controller.style);
                              return buildExamples(context, goodImages);
                            },
                            future: manager.getConfig(),
                          ),
                          SizedBox(height: 20),
                          buildIconText(
                            context,
                            title: S.of(context).bad_photo_examples,
                            icon: Images.ic_avatar_bad_example,
                          ),
                          SizedBox(height: 12),
                          TitleTextWidget(
                            S.of(context).bad_photo_description,
                            ColorConstant.White,
                            FontWeight.normal,
                            $(14),
                            align: TextAlign.left,
                            maxLines: 5,
                          ).intoContainer(
                            padding: EdgeInsets.symmetric(horizontal: $(15)),
                          ),
                          SizedBox(height: 12),
                          FutureBuilder(
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {
                                return buildExamples(context, []);
                              }
                              var data = snapshot.data as AvatarConfig;
                              List<String> badImages = data.badImages(controller.style);
                              return buildExamples(context, badImages);
                            },
                            future: manager.getConfig(),
                          ),
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
                                  text: S.of(context).pandora_transfer_tips,
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
                      controller.pickPhotosText(context),
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
                        controller.pickImageFromGallery(context).then((value) {
                          if (value) {
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
                )));
        if (controller.hasChosen) {
          return WillPopScope(
              child: result,
              onWillPop: () async {
                showBackDialog(context, controller).then((value) {
                  if (value ?? false) {
                    Navigator.of(context).pop();
                  }
                });
                return false;
              });
        }
        return result;
      },
      init: controller,
    ).intoContainer(
      padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context)),
    );
  }

  Future<bool?> showBackDialog(BuildContext context, AvatarAiController controller) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).pandora_create_exit_dips,
            style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
            textAlign: TextAlign.center,
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
          Row(
            children: [
              Expanded(
                  child: Text(
                S.of(context).ok,
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: ColorConstant.BlueColor),
              )
                      .intoContainer(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(color: ColorConstant.LineColor, width: 1),
                            right: BorderSide(color: ColorConstant.LineColor, width: 1),
                          )))
                      .intoGestureDetector(onTap: () async {
                Navigator.pop(context, true);
              })),
              Expanded(
                  child: Text(
                S.of(context).cancel,
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: ColorConstant.BlueColor),
              )
                      .intoContainer(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(color: ColorConstant.LineColor, width: 1),
                          )))
                      .intoGestureDetector(onTap: () {
                Navigator.pop(context, false);
              })),
            ],
          ),
        ],
      )
          .intoMaterial(
            color: ColorConstant.EffectFunctionGrey,
            borderRadius: BorderRadius.circular($(16)),
          )
          .intoContainer(
            padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
            margin: EdgeInsets.symmetric(horizontal: $(35)),
          )
          .intoCenter(),
    );
  }

  startUpload(BuildContext context, AvatarAiController controller) {
    var forward = (){
      if (controller.uploadedList.length == controller.imageList.length) {
        startSubmit(context, controller);
      } else {
        showDialog<bool>(context: context, barrierDismissible: false, builder: (_) => UploadLoadingDialog(controller: controller)).then((value) {
          if (value ?? false) {
            startSubmit(context, controller);
          }
        });
      }
    };
    var userManager = AppDelegate.instance.getManager<UserManager>();
    if (userManager.user!.aiAvatarCredit > 0) {
      forward.call();
    } else {
      // user not pay yet. to introduce page. and get pay status to edit page.
      PayAvatarPage.push(context).then((payStatus) {
        if (payStatus ?? false) {
          forward.call();
        }
      });
    }
  }

  startSubmit(BuildContext context, AvatarAiController controller) {
    controller.submit().then((value) {
      if (value != null) {
        showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                  backgroundColor: ColorConstant.BackgroundColor,
                  title: Column(
                    children: [
                      Image.asset(
                        Images.ic_avatar_success,
                        width: $(28),
                        color: Color(0xff34C759),
                      ).intoContainer(
                        padding: EdgeInsets.all($(10)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(64),
                          border: Border.all(
                            color: Color(0xff34C759),
                            width: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      TitleTextWidget(S.of(context).successful, Color(0xff34C759), FontWeight.w600, $(16)),
                    ],
                  ),
                  content: TitleTextWidget(S.of(context).pandora_create_spend.replaceAll('%d', '2'), ColorConstant.White, FontWeight.w600, $(14), maxLines: 3),
                  actions: [
                    TitleTextWidget(
                      S.of(context).ok,
                      ColorConstant.BlueColor,
                      FontWeight.w600,
                      $(17),
                    )
                        .intoContainer(
                      width: double.maxFinite,
                      color: Colors.transparent,
                    )
                        .intoGestureDetector(onTap: () {
                      Navigator.of(context).pop(true);
                    }),
                  ],
                )).then((value) {
          Navigator.pop(context, true);
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
            child: CachedNetworkImageUtils.custom(
              context: context,
              imageUrl: examples[index],
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
            // controller.pickImageFromCamera().then((value) {
            //   Navigator.of(context).pop(value);
            // });
          }),
          Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
          TitleTextWidget('Choose from album', ColorConstant.White, FontWeight.normal, $(17))
              .intoContainer(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: $(10)),
            color: Colors.transparent,
          )
              .intoGestureDetector(onTap: () {
            controller.pickImageFromGallery(context).then((value) {
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
