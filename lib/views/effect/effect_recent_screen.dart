import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/transfer/ChoosePhotoScreen.dart';

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
                            return Image.memory(
                              base64Decode(data.itemList.first.imageData ?? ''),
                              fit: BoxFit.cover,
                            ).intoGestureDetector(onTap: () {
                              pickEffectItemAndOpen(context, data);
                            });
                          }
                        } else if (data is RecentMetaverseEntity) {
                          return Image.file(
                            File(data.filePath.first),
                            fit: BoxFit.cover,
                          ).hero(tag: data.filePath.first).intoGestureDetector(onTap: () {
                            AnotherMe.open(context, entity: data);
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
    var key = data.itemList.first.key!;
    var tabPos = effectDataController.data!.tabPos(key);
    EffectModel? effectModel;
    EffectItem? effectItem;
    for (var value in effectDataController.data!.allEffectList()) {
      var item = value.effects.values.toList().pick((t) => t.key == key);
      if (item != null) {
        effectItem = item;
        effectModel = value;
        break;
      }
    }
    if (effectModel == null || effectItem == null) {
      return;
    }
    var categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel!.key)!;
    var itemP = effectDataController.tabItemList.findPosition((data) => data.data.key == effectItem!.key)!;
    logEvent(Events.choose_home_cartoon_type, eventValues: {
      "category": effectModel.key,
      "style": effectModel.style,
      "page": "recent",
    });
    var pick = recentController.effectList.pick((e) => data.originalPath == e.originalPath);
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(
          tabPos: tabPos,
          pos: categoryPos,
          itemPos: itemP,
          recentEffectModel: pick,
        ),
      ),
    );
    AppDelegate.instance.getManager<UserManager>().refreshUser(context: context).then((value) {
      setState(() {});
    });
  }
}
