import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/txt2img/txt2img_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dotted_border/dotted_border.dart';

import 'txt2img_result_screen.dart';

class Txt2imgScreen extends StatefulWidget {
  RecentGroundEntity? history;
  Txt2imgInitData? initData;
  String source;

  Txt2imgScreen({
    Key? key,
    this.history,
    required this.source,
    this.initData,
  }) : super(key: key);

  @override
  State<Txt2imgScreen> createState() => _Txt2imgScreenState();
}

class _Txt2imgScreenState extends AppState<Txt2imgScreen> {
  late Txt2imgController txt2imgController;

  late double imageSize;
  late StreamSubscription onStyleListUpdated;
  RecentGroundEntity? history;
  String? initStyle;

  @override
  void initState() {
    super.initState();
    Events.txt2imgShow(source: widget.source);
    txt2imgController = Txt2imgController();
    imageSize = (ScreenUtil.screenSize.width - 40) / 2.7;
    onStyleListUpdated = EventBusHelper().eventBus.on<OnTxt2imgStyleUpdateEvent>().listen((event) {
      if (initStyle != null) {
        txt2imgController.selectedStyle = txt2imgController.styleList.pick((t) => t.name == initStyle);
      } else if (history != null) {
        txt2imgController.selectedStyle = txt2imgController.styleList.pick((t) => t.name == history?.styleKey);
      }
      txt2imgController.update();
    });
    history = widget.history;
    if (widget.initData != null) {
      initFromDiscovery(widget.initData!);
    } else if (history != null) {
      txt2imgController.editingController.text = history?.prompt ?? '';
      txt2imgController.filePath = history!.filePath;
      txt2imgController.parameters = history!.parameters;
      if (txt2imgController.styleList.isNotEmpty) {
        txt2imgController.selectedStyle = txt2imgController.styleList.pick((t) => t.name == history?.styleKey);
      }
      delay(() {
        var forward = () {
          Navigator.of(context).push(
            FadeRouter(
              settings: RouteSettings(name: '/Txt2imgResultScreen'),
              child: Txt2imgResultScreen(controller: txt2imgController),
            ),
          );
        };
        if (!TextUtil.isEmpty(history!.initImageFilePath)) {
          var file = File(history!.initImageFilePath!);
          if (file.existsSync()) {
            txt2imgController.initFile = file;
            showLoading().whenComplete(() {
              imageCompressAndGetFile(file, imageSize: Get.find<EffectDataController>().data?.imageMaxl ?? 512).then((value) {
                txt2imgController.uploadImageController.uploadCompressedImage(value).then((value) {
                  hideLoading().whenComplete(() {
                    forward.call();
                    txt2imgController.uploadImageController.update();
                  });
                });
              });
            });
          } else {
            forward.call();
          }
        } else {
          forward.call();
        }
      });
    }
  }

  void initFromDiscovery(Txt2imgInitData initData) {
    var reg = RegExp(r'\(art by (.+)\)$');
    RegExpMatch? match = reg.firstMatch(initData.prompt ?? '');
    if (match != null && match.group(1) != null) {
      initStyle = match.group(1);
      String? prompt = initData.prompt?.replaceAll(match.group(0) ?? '', '');
      txt2imgController.editingController.text = prompt ?? '';
      if (txt2imgController.styleList.isNotEmpty) {
        txt2imgController.selectedStyle = txt2imgController.styleList.pick((t) => t.name == initStyle);
      }
    } else {
      txt2imgController.editingController.text = initData.prompt ?? '';
    }
    var imageScale = txt2imgController.imageScaleList.pick((t) => t.width == initData.width && t.height == initData.height);
    if (imageScale != null) {
      txt2imgController.imageScale = imageScale;
    }
  }

  @override
  void dispose() {
    onStyleListUpdated.cancel();
    txt2imgController.dispose();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          'AI Artist',
          ColorConstant.White,
          FontWeight.w600,
          $(17),
        ),
      ),
      body: GetBuilder<Txt2imgController>(
        init: txt2imgController,
        builder: (controller) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          S.of(context).text_2_image_prompt_title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: $(15),
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.White,
                          ),
                        ),
                        SizedBox(width: $(6)),
                        Text(
                          '${txt2imgController.editingController.text.length}/${txt2imgController.maxLength}',
                          style: TextStyle(color: Color(0xff858585)),
                        )
                      ],
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12))),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          Images.ic_text_image_tips,
                          width: $(16),
                        ),
                        SizedBox(width: $(4)),
                        Expanded(
                          child: Text(
                            S.of(context).text_2_image_input_tips,
                            style: TextStyle(fontSize: $(13), color: Color(0xFF2778FF)),
                          ),
                        ),
                      ],
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                    SizedBox(height: 12),
                    TextField(
                      controller: txt2imgController.editingController,
                      decoration: InputDecoration(
                        hintText: S.of(context).text_2_image_input_hint,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(color: ColorConstant.White),
                      maxLines: 4,
                      maxLength: txt2imgController.maxLength,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return currentLength != 0
                            ? Image.asset(
                                Images.ic_prompt_clear,
                                width: $(16),
                              ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(6), vertical: $(6))).intoGestureDetector(onTap: () {
                                controller.editingController.text = '';
                                controller.update();
                              })
                            : SizedBox(height: $(28), width: 1);
                      },
                      onChanged: (text) {
                        txt2imgController.update();
                      },
                    ).intoContainer(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular($(4)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(6)),
                        margin: EdgeInsets.symmetric(horizontal: $(15))),
                    ListView.builder(
                      padding: EdgeInsets.only(left: $(15), top: $(12), bottom: $(12)),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Text(
                          controller.promptList[index],
                          style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(14), fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        )
                            .intoContainer(
                          constraints: BoxConstraints(maxWidth: $(160)),
                          padding: EdgeInsets.only(left: $(15), right: $(15), top: $(5), bottom: $(3)),
                          decoration: BoxDecoration(color: Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(32)),
                          margin: EdgeInsets.only(right: $(15)),
                        )
                            .intoGestureDetector(onTap: () {
                          controller.onPromptClick(controller.promptList[index]);
                        });
                      },
                      itemCount: controller.promptList.length,
                    ).intoContainer(height: $(56)),
                    TitleTextWidget(
                      S.of(context).choose_your_scale,
                      ColorConstant.White,
                      FontWeight.w600,
                      $(15),
                    ).intoContainer(
                      margin: EdgeInsets.only(left: $(15), right: $(15)),
                    ),
                    Row(
                      children: controller.imageScaleList.transfer(
                        (e, index) {
                          var size = e.getSize($(20));
                          return Expanded(
                            child: Container(
                                    width: size.width,
                                    height: size.height,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular($(4)),
                                      color: controller.imageScale == e ? ColorConstant.DiscoveryBtn : Colors.transparent,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ))
                                .intoContainer(
                                    alignment: Alignment.center,
                                    width: double.maxFinite,
                                    margin: EdgeInsets.symmetric(horizontal: $(4), vertical: $(4)),
                                    height: $(32),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular($(6)),
                                      color: controller.imageScale == e ? ColorConstant.DiscoveryBtn : Colors.transparent,
                                    ))
                                .intoGestureDetector(onTap: () {
                              if (controller.imageScale == e) {
                                return;
                              }
                              controller.imageScale = e;
                              controller.update();
                            }),
                          );
                        },
                      ),
                    ).intoContainer(
                        margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(8)),
                        decoration: BoxDecoration(
                          color: Color(0x11ffffff),
                          borderRadius: BorderRadius.circular($(8)),
                        )),
                    Row(
                      children: controller.imageScaleList.transfer(
                        (e, index) => Expanded(
                          child: Text(
                            e.scaleString,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: $(14),
                            ),
                            textAlign: TextAlign.center,
                          ).intoGestureDetector(onTap: () {
                            if (controller.imageScale == e) {
                              return;
                            }
                            controller.imageScale = e;
                            controller.update();
                          }),
                        ),
                      ),
                    ).intoContainer(
                      padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(8)),
                    ),
                    TitleTextWidget(
                      S.of(context).choose_your_style,
                      ColorConstant.White,
                      FontWeight.w600,
                      $(15),
                    ).intoContainer(
                      margin: EdgeInsets.only(left: $(15), right: $(15)),
                    ),
                    controller.styleList.isEmpty
                        ? CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter().intoContainer(height: $(56))
                        : GridView.builder(
                            controller: controller.scrollController,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              mainAxisSpacing: $(2),
                              crossAxisSpacing: $(2),
                            ),
                            padding: EdgeInsets.only(left: $(12), right: $(7)),
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.styleList.length + 1,
                            itemBuilder: (context, i) {
                              if (i == 0) {
                                bool checked = controller.selectedStyle == null;
                                return Column(
                                  children: [
                                    ClipRRect(
                                      child: Image.asset(
                                        Images.ic_txt2img_no_style,
                                        fit: BoxFit.contain,
                                      ).intoContainer(
                                          padding: EdgeInsets.all((imageSize - $(6)) / 3.6),
                                          width: imageSize - $(6),
                                          height: imageSize - $(9),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF2C2C2E),
                                          )),
                                      borderRadius: BorderRadius.circular($(6)),
                                    ).intoContainer(
                                      padding: EdgeInsets.all($(2.5)),
                                      margin: EdgeInsets.only(top: 2, bottom: 2, left: 3, right: 3),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: checked ? Color(0xff3E60FF) : Color(0xffd5d5d5), borderRadius: BorderRadius.circular($(8))),
                                    ),
                                    SizedBox(height: $(3)),
                                    Text(
                                      'No Style',
                                      style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ).intoGestureDetector(onTap: () {
                                  if (!checked) {
                                    controller.selectedStyle = null;
                                    controller.update();
                                  }
                                });
                              }
                              int index = i - 1;
                              var data = controller.styleList[index];
                              bool checked = controller.selectedStyle == data;
                              return Column(
                                children: [
                                  ClipRRect(
                                    child: CachedNetworkImageUtils.custom(
                                      context: context,
                                      imageUrl: data.url!.appendHash,
                                      width: imageSize,
                                      height: imageSize - $(6),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular($(6)),
                                  ).intoContainer(
                                    padding: EdgeInsets.all(3),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: checked ? Color(0xff3E60FF) : Colors.transparent, borderRadius: BorderRadius.circular($(6))),
                                  ),
                                  SizedBox(height: $(3)),
                                  Text(
                                    data.name,
                                    style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ).intoGestureDetector(onTap: () {
                                if (!checked) {
                                  controller.selectedStyle = data;
                                  controller.update();
                                }
                              });
                            }).intoContainer(
                            height: imageSize * 2.5,
                            margin: EdgeInsets.only(top: $(15)),
                          ),
                    TitleTextWidget(S.of(context).reference_image, ColorConstant.White, FontWeight.w600, $(15)).intoContainer(
                        margin: EdgeInsets.only(
                      left: $(15),
                      right: $(15),
                    )),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          Images.ic_text_image_tips,
                          width: $(16),
                        ),
                        SizedBox(width: $(4)),
                        Expanded(
                          child: Text(
                            S.of(context).reference_image_tips,
                            style: TextStyle(fontSize: $(13), color: Color(0xFF2778FF)),
                          ),
                        ),
                      ],
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                    SizedBox(height: 12),
                    GetBuilder<UploadImageController>(
                      builder: (uploadController) => DottedBorder(
                              radius: Radius.circular($(6)),
                              color: ColorConstant.White,
                              strokeWidth: 1.5,
                              dashPattern: [5, 5],
                              child: (TextUtil.isEmpty(uploadController.imageUrl.value)
                                  ? Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          Images.ic_ai_ground_upload,
                                          width: $(20),
                                        ),
                                        SizedBox(width: $(4)),
                                        Text(
                                          S.of(context).upload_image,
                                          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
                                        ),
                                      ],
                                    ).intoContainer(
                                      padding: EdgeInsets.symmetric(vertical: $(50)),
                                      width: double.maxFinite,
                                    )
                                  : Stack(
                                      children: [
                                        CachedNetworkImageUtils.custom(context: context, imageUrl: uploadController.imageUrl.value, height: $(150), fit: BoxFit.contain),
                                        Positioned(
                                          child: Icon(
                                            Icons.close,
                                            size: $(18),
                                            color: ColorConstant.White,
                                          )
                                              .intoContainer(
                                                  padding: EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(16),
                                                    color: Color(0x99000000),
                                                  ))
                                              .intoGestureDetector(onTap: () {
                                            txt2imgController.uploadImageController.updateImageUrl('');
                                            txt2imgController.uploadImageController.update();
                                          }),
                                          top: 2,
                                          right: 2,
                                        )
                                      ],
                                    ).intoContainer(
                                      width: double.maxFinite,
                                      height: $(150),
                                      color: Colors.transparent,
                                      alignment: Alignment.center,
                                    )))
                          .intoGestureDetector(onTap: () {
                        PickAlbumScreen.pickImage(context, count: 1, switchAlbum: true).then((value) async {
                          if (value != null && value.isNotEmpty) {
                            File? source = await value.first.file;
                            if (source != null) {
                              controller.initFile = source;
                              showLoading().whenComplete(() async {
                                File compressedImage = await imageCompressAndGetFile(source, imageSize: Get.find<EffectDataController>().data?.imageMaxl ?? 512);
                                await uploadController.uploadCompressedImage(compressedImage);
                                uploadController.update();
                                hideLoading();
                              });
                            }
                          }
                        });
                      }),
                      init: txt2imgController.uploadImageController,
                    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
                    SizedBox(height: $(80) + ScreenUtil.getBottomPadding(context)),
                  ],
                ),
              ),
              Positioned(
                child: Text(
                  S.of(context).generate,
                  style: TextStyle(color: Colors.white, fontSize: $(17), fontFamily: 'Poppins'),
                )
                    .intoContainer(
                      width: ScreenUtil.screenSize.width - $(30),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: $(10)),
                      decoration: BoxDecoration(
                        color: ColorConstant.DiscoveryBtn,
                        borderRadius: BorderRadius.circular($(6)),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: $(15)),
                    )
                    .intoGestureDetector(onTap: () {
                      controller.filePath = null;
                      var text = controller.editingController.text.trim();
                      if (TextUtil.isEmpty(text)) {
                        CommonExtension().showToast(S.of(context).text2img_prompt_empty_hint);
                        return;
                      }
                      Navigator.of(context).push(
                        FadeRouter(
                          settings: RouteSettings(name: '/Txt2imgResultScreen'),
                          child: Txt2imgResultScreen(controller: txt2imgController),
                          opaque: false,
                        ),
                      );
                    })
                    .intoContainer(
                      color: Color(0xaa111111),
                      padding: EdgeInsets.only(top: $(15), bottom: $(15) + ScreenUtil.getBottomPadding(context)),
                    )
                    .blur(),
                bottom: 0,
              ),
            ],
            fit: StackFit.expand,
          );
        },
      ),
    );
  }
}

class Txt2imgInitData {
  String? prompt;
  int? width;
  int? height;

  Txt2imgInitData();
}
