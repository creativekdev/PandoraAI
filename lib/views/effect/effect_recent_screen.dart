import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/effect_data_controller.dart';
import 'package:cartoonizer/controller/recent/recent_controller.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/video/effect_video_player.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/drawable/colorfill/ai_coloring.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/ai_drawable.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/widget/drawable.dart';
import 'package:cartoonizer/views/ai/edition/image_edition.dart';
import 'package:cartoonizer/views/ai/txt2img/txt2img.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/cartoonize.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph.dart';

class EffectRecentScreen extends StatefulWidget {
  EffectRecentScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => EffectRecentState();
}

class EffectRecentState extends State<EffectRecentScreen> with AutomaticKeepAliveClientMixin {
  RecentController recentController = Get.find();
  EffectDataController effectDataController = Get.find();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Events.recentlyLoading();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          S.of(context).recently,
          ColorConstant.BtnTextColor,
          FontWeight.w600,
          FontSizeConstants.topBarTitle,
        ),
      ),
      body: GetBuilder<RecentController>(
          init: recentController,
          builder: (_) {
            return _.recordList.isEmpty
                ? Text(
                    S.of(context).effectRecentEmptyHint,
                    style: TextStyle(
                      color: ColorConstant.White,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      fontSize: $(17),
                    ),
                    textAlign: TextAlign.center,
                  ).intoContainer(alignment: Alignment.center, margin: EdgeInsets.all($(25))).intoCenter()
                : MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: GridView.builder(
                      controller: scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: $(8),
                        mainAxisSpacing: $(8),
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        var data = _.recordList[index];
                        if (data is RecentEffectModel) {
                          if (data.itemList.first.isVideo) {
                            return EffectVideoPlayer(url: data.itemList.first.imageData ?? '').intoGestureDetector(onTap: () {
                              pickEffectItemAndOpen(context, data);
                            });
                          } else {
                            return Image.file(
                              File(data.itemList.first.imageData ?? ''),
                              fit: BoxFit.cover,
                            ).intoGestureDetector(onTap: () {
                              pickEffectItemAndOpen(context, data);
                            });
                          }
                        } else if (data is RecentStyleMorphModel) {
                          return Image.file(
                            File(data.itemList.first.imageData ?? ''),
                            fit: BoxFit.cover,
                          ).intoGestureDetector(onTap: () {
                            pickStyleMorphItemAndOpen(context, data);
                          });
                        } else if (data is RecentMetaverseEntity) {
                          return Image.file(
                            File(data.filePath.first),
                            fit: BoxFit.cover,
                          ).intoGestureDetector(onTap: () {
                            PermissionsUtil.checkPermissions().then((value) {
                              if (value) {
                                AnotherMe.open(context, entity: data, source: 'recently');
                              } else {
                                PermissionsUtil.permissionDenied(context);
                              }
                            });
                          });
                        } else if (data is RecentGroundEntity) {
                          return Image.file(
                            File(data.filePath!),
                            fit: BoxFit.cover,
                          ).intoGestureDetector(onTap: () {
                            Txt2img.open(context, source: 'recently', history: data);
                          });
                        } else if (data is DrawableRecord) {
                          return Image.file(
                            File(data.resultPaths.first),
                            fit: BoxFit.cover,
                          ).intoGestureDetector(onTap: () {
                            AiDrawable.open(context, source: 'recently', history: data);
                          });
                        } else if (data is RecentColoringEntity) {
                          return Image.file(
                            File(data.filePath!),
                            fit: BoxFit.cover,
                          ).intoGestureDetector(onTap: () {
                            AiColoring.open(context, source: 'recently', record: data);
                          });
                        } else if (data is RecentImageEditionEntity) {
                          return Image.file(
                            File(data.filePath!),
                            fit: BoxFit.cover,
                          ).intoGestureDetector(onTap: () {
                            ImageEdition.open(
                              context,
                              source: 'recently',
                              style: EffectStyle.All,
                              function: ImageEditionFunction.filter,
                              cardType: HomeCardType.imageEdition,
                              record: data,
                            );
                          });
                        }
                        return Container();
                      },
                      itemCount: _.recordList.length,
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                  );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;

  pickEffectItemAndOpen(BuildContext context, RecentEffectModel data) async {
    var pick = recentController.effectList.pick((e) => data.originalPath == e.originalPath);

    var fileExist = await File(pick!.originalPath ?? "").exists();
    Cartoonize.open(
      context,
      source: 'recently',
      record: fileExist ? pick : null,
      initKey: data.itemList.first.key,
    );
  }

  pickStyleMorphItemAndOpen(BuildContext context, RecentStyleMorphModel data) async {
    StyleMorph.open(context, 'recently', record: data, initKey: data.itemList.first.key);
  }
}
