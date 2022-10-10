import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'effect_fragment.dart';
import 'widget/effect_full_body_card_widget.dart';

class EffectRecentScreen extends StatefulWidget {
  EffectRecentScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => EffectRecentState();
}

class EffectRecentState extends State<EffectRecentScreen> with AutomaticKeepAliveClientMixin {
  RecentController recentController = Get.find();
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var cardWidth = (ScreenUtil.getCurrentWidgetSize(context).width - $(38)) / 2;
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          StringConstant.recently,
          ColorConstant.BtnTextColor,
          FontWeight.w600,
          FontSizeConstants.topBarTitle,
        ),
      ),
      body: GetBuilder<RecentController>(
          init: recentController,
          builder: (_) {
            return _.dataList.isEmpty
                ? Text(
                    StringConstant.effectRecentEmptyHint,
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
                    child: WaterfallFlow.builder(
                      cacheExtent: ScreenUtil.screenSize.height,
                      controller: scrollController,
                      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: $(8),
                      ),
                      itemBuilder: (context, index) {
                        var data = _.dataList[index];
                        return CachedNetworkImageUtils.custom(
                                context: context,
                                imageUrl: data.item!.imageUrl,
                                width: cardWidth,
                                placeholder: (context, url) {
                                  return CircularProgressIndicator()
                                      .intoContainer(
                                        width: $(25),
                                        height: $(25),
                                      )
                                      .intoCenter()
                                      .intoContainer(width: cardWidth, height: cardWidth);
                                },
                                errorWidget: (context, url, error) {
                                  return CircularProgressIndicator()
                                      .intoContainer(
                                        width: $(25),
                                        height: $(25),
                                      )
                                      .intoCenter()
                                      .intoContainer(width: cardWidth, height: cardWidth);
                                })
                            .intoContainer(
                          margin: EdgeInsets.only(
                            top: $(8),
                            bottom: index == _.dataList.length - 1 ? AppTabBarHeight : $(0),
                          ),
                        )
                            .intoGestureDetector(onTap: () {
                          _onEffectCategoryTap(_.recentModelList, data);
                        });
                      },
                      itemCount: _.dataList.length,
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                    // child: ListView.builder(
                    //   controller: scrollController,
                    //   itemCount: _.dataList.length,
                    //   itemBuilder: (context, index) => EffectFullBodyCardWidget(
                    //     parentWidth: width,
                    //     data: _.dataList[index],
                    //     onTap: (data) {
                    //       _onEffectCategoryTap(_.recentModelList, _.dataList, data);
                    //     },
                    //   ).intoContainer(
                    //     margin: EdgeInsets.only(
                    //       left: $(15),
                    //       right: $(15),
                    //       top: $(8),
                    //       bottom: index == _.dataList.length - 1 ? ($(8) + AppTabBarHeight) : $(8),
                    //     ),
                    //   ),
                    // ),
                  );
          }),
    );
  }

  _onEffectCategoryTap(List<EffectModel> originList, EffectItemListData data) {
    EffectModel? effectModel;
    int index = 0;
    for (int i = 0; i < originList.length; i++) {
      var model = originList[i];
      var list = model.effects.values.toList();
      bool find = false;
      for (int j = 0; j < list.length; j++) {
        var item = list[j];
        if ('${model.key}${item.key}' == data.uniqueKey) {
          effectModel = model;
          index = i;
          find = true;
          break;
        }
      }
      if (find) {
        break;
      }
    }
    if (effectModel == null) {
      return;
    }
    logEvent(Events.choose_home_cartoon_type, eventValues: {
      "category": effectModel.key,
      "style": effectModel.style,
      "page": "recent",
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(
          list: originList,
          pos: index,
          itemPos: 0,
          entrySource: EntrySource.fromRecent,
          tabString: 'recent',
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
