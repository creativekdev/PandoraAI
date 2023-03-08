import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/ground/ai_ground_controller.dart';
import 'package:cartoonizer/views/transfer/pick_photo_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../models/ai_ground_style_entity.dart';

class AiGroundScreen extends StatefulWidget {
  const AiGroundScreen({Key? key}) : super(key: key);

  @override
  State<AiGroundScreen> createState() => _AiGroundScreenState();
}

class _AiGroundScreenState extends AppState<AiGroundScreen> {
  AiGroundController aiGroundController = Get.put(AiGroundController());
  UploadImageController uploadImageController = Get.put(UploadImageController());

  late double imageSize;

  @override
  void initState() {
    super.initState();
    imageSize = (ScreenUtil.screenSize.width - 40) / 2.5;
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<AiGroundController>();
    Get.delete<UploadImageController>();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          'Text-Image',
          ColorConstant.White,
          FontWeight.w600,
          $(17),
        ),
      ),
      body: GetBuilder<AiGroundController>(
        init: aiGroundController,
        builder: (controller) {
          List<AiGroundStyleEntity>? styleShownList = controller.styleMap?[controller.categoryList?[controller.selectedCategoryIndex]];
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Enter prompt',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: $(15),
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.White,
                          ),
                        ),
                        SizedBox(width: $(6)),
                        Text(
                          '${aiGroundController.editingController.text.length}/${aiGroundController.maxLength}',
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
                            'Enter a prompt to inspire the generation process. Below are some suggestions to help you get started.',
                            style: TextStyle(fontSize: $(13), color: Color(0xFF2778FF)),
                          ),
                        ),
                      ],
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                    SizedBox(height: 12),
                    TextField(
                      controller: aiGroundController.editingController,
                      decoration: InputDecoration(
                        hintText: 'Describe the image you want to see',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(color: ColorConstant.White),
                      maxLines: 6,
                      maxLength: aiGroundController.maxLength,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return Container();
                      },
                      onChanged: (text) {
                        aiGroundController.update();
                      },
                    ).intoContainer(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular($(4)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(6)),
                        margin: EdgeInsets.symmetric(horizontal: $(15))),
                    controller.promptList == null
                        ? CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter().intoContainer(height: $(56))
                        : ListView.builder(
                            padding: EdgeInsets.only(left: $(15), top: $(12), bottom: $(12)),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Text(
                                controller.promptList![index],
                                style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(17), fontWeight: FontWeight.w500),
                              )
                                  .intoContainer(
                                padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(4)),
                                decoration: BoxDecoration(color: Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(32)),
                                margin: EdgeInsets.only(right: $(15)),
                              )
                                  .intoGestureDetector(onTap: () {
                                controller.onPromptClick(controller.promptList![index]);
                              });
                            },
                            itemCount: controller.promptList!.length,
                          ).intoContainer(height: $(56)),
                    OrLine()
                        .intoContainer(
                          margin: EdgeInsets.only(
                            left: $(15),
                            right: $(15),
                            top: $(32),
                            bottom: $(24),
                          ),
                        )
                        .intoMaterial(color: Colors.transparent),
                    TitleTextWidget('Choose your style (Optional)', ColorConstant.White, FontWeight.w600, $(17)).intoContainer(
                        margin: EdgeInsets.only(
                      left: $(15),
                      right: $(15),
                    )),
                    controller.styleMap == null
                        ? CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter().intoContainer(height: $(56))
                        : ScrollablePositionedList.builder(
                            padding: EdgeInsets.only(left: $(15), right: $(7)),
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.styleMap!.length,
                            itemBuilder: (context, index) {
                              bool checked = controller.selectedCategoryIndex == index;
                              return Text(
                                controller.categoryList![index].toUpperCaseFirst,
                                style: TextStyle(fontFamily: 'Poppins', fontSize: $(17), color: ColorConstant.White),
                              )
                                  .intoContainer(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: checked ? Color(0xff3E60FF) : Color(0xff2c2c2e), borderRadius: BorderRadius.circular($(6))),
                                      padding: EdgeInsets.symmetric(horizontal: $(16)),
                                      margin: EdgeInsets.only(right: $(8), top: $(12), bottom: $(12)))
                                  .intoGestureDetector(onTap: () {
                                if (!checked) {
                                  controller.selectedCategoryIndex = index;
                                  controller.selectedStyle = null;
                                  controller.scrollController.jumpTo(0);
                                  controller.update();
                                }
                              });
                            }).intoContainer(height: 64),
                    controller.styleMap == null
                        ? Container()
                        : GridView.builder(
                            controller: controller.scrollController,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.3,
                              crossAxisSpacing: $(2),
                              mainAxisSpacing: $(2),
                            ),
                            padding: EdgeInsets.only(left: $(12), right: $(7)),
                            scrollDirection: Axis.horizontal,
                            itemCount: styleShownList!.length,
                            itemBuilder: (context, index) {
                              var data = styleShownList[index];
                              bool checked = controller.selectedStyle == data;
                              return Column(
                                children: [
                                  ClipRRect(
                                    child: CachedNetworkImageUtils.custom(
                                      context: context,
                                      imageUrl: data.url!,
                                      width: imageSize - $(4),
                                      height: imageSize - $(4),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular($(6)),
                                  ).intoContainer(
                                    padding: EdgeInsets.all(2),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: checked ? Color(0xff3E60FF) : Colors.transparent, borderRadius: BorderRadius.circular($(6))),
                                  ),
                                  SizedBox(height: $(3)),
                                  Text(
                                    data.name,
                                    style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ).intoGestureDetector(onTap: () {
                                if (!checked) {
                                  controller.selectedStyle = data;
                                  controller.update();
                                } else {
                                  controller.selectedStyle = null;
                                  controller.update();
                                }
                              });
                            }).intoContainer(height: imageSize * 2.6),
                    OrLine()
                        .intoContainer(
                          margin: EdgeInsets.only(
                            left: $(15),
                            right: $(15),
                            top: $(32),
                            bottom: $(24),
                          ),
                        )
                        .intoMaterial(color: Colors.transparent),
                    TitleTextWidget('Reference image (Optional)', ColorConstant.White, FontWeight.w600, $(17)).intoContainer(
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
                            'The image you select will be used as a reference for the final',
                            style: TextStyle(fontSize: $(13), color: Color(0xFF2778FF)),
                          ),
                        ),
                      ],
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                    SizedBox(height: 12),
                    GetBuilder<UploadImageController>(
                      builder: (uploadController) {
                        return DottedBorder(
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
                                            'Upload Image',
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
                                              uploadImageController.updateImageUrl('');
                                              uploadImageController.update();
                                            }),
                                            top: 2,
                                            right: 2,
                                          )
                                        ],
                                      ).intoContainer(
                                        width: double.maxFinite,
                                        height: $(150),
                                        alignment: Alignment.center,
                                      ))
                                .intoGestureDetector(onTap: () {
                              PickAlbumScreen.pickImage(context, count: 1, switchAlbum: true).then((value) async {
                                if (value != null && value.isNotEmpty) {
                                  File? source = await value.first.file;
                                  if (source != null) {
                                    showLoading().whenComplete(() async {
                                      File compressedImage = await imageCompressAndGetFile(source, imageSize: 768);
                                      await uploadController.uploadCompressedImage(compressedImage);
                                      uploadController.update();
                                      hideLoading();
                                    });
                                  }
                                }
                              });
                            }));
                      },
                      init: uploadImageController,
                    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
                    SizedBox(height: $(80) + ScreenUtil.getBottomPadding(context)),
                  ],
                ),
              ),
              Positioned(
                child: Text(
                  'Play Ground',
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
                      controller.onPlayClick(context, uploadImageController.imageUrl.value);
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

class OrLine extends StatelessWidget {
  const OrLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            color: ColorConstant.DividerColor,
            thickness: 0.1.h,
          ),
        ),
        SizedBox(width: 3.w),
        TitleTextWidget(S.of(context).or, ColorConstant.loginTitleColor, FontWeight.w500, 12),
        SizedBox(width: 3.w),
        Expanded(
          child: Divider(
            color: ColorConstant.DividerColor,
            thickness: 0.1.h,
          ),
        ),
      ],
    );
  }
}
