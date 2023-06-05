import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/nsfw_card.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/ChoosePhotoScreen.dart';

import '../../Widgets/tabbar/app_tab_bar.dart';

class ActivityFragment extends StatefulWidget {
  AppTabId tabId;

  ActivityFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ActivityFragmentState();
}

class ActivityFragmentState extends AppState<ActivityFragment> with AutomaticKeepAliveClientMixin, AppTabState, SingleTickerProviderStateMixin {
  late AppTabId tabId;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  EffectDataController dataController = Get.find();
  late bool nsfwOpen;
  late double cardWidth;
  late double marginTop;

  @override
  void initState() {
    super.initState();
    marginTop = $(59) + ScreenUtil.getStatusBarHeight();
    nsfwOpen = cacheManager.getBool(CacheManager.nsfwOpen);
    tabId = widget.tabId;
    cardWidth = (ScreenUtil.screenSize.width - $(38)) / 2;
  }

  @override
  onAttached() {
    super.onAttached();
    var nsfw = cacheManager.getBool(CacheManager.nsfwOpen);
    if (nsfwOpen != nsfw) {
      setState(() {
        nsfwOpen = nsfw;
      });
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            GetBuilder<EffectDataController>(
                init: dataController,
                builder: (_) {
                  var dataList = dataController.randomList.filter(
                    (t) => t.item!.tagList.contains(dataController.data?.campaignTab?.tag),
                  );
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: $(15)),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: $(6),
                      crossAxisSpacing: $(6),
                    ),
                    itemBuilder: (context, index) {
                      var data = dataList[index];
                      var nsfwShown = data.item!.isNsfw && !nsfwOpen;
                      return (data.item!.imageUrl.contains('mp4')
                              ? Stack(
                                  children: [
                                    EffectVideoPlayer(url: data.item!.imageUrl),
                                    Positioned(
                                      right: $(5),
                                      top: $(5),
                                      child: Image.asset(
                                        ImagesConstant.ic_video,
                                        height: $(24),
                                        width: $(24),
                                      ),
                                    ),
                                    (nsfwShown) ? Container(width: cardWidth, height: cardWidth).blur() : Container(),
                                    (nsfwShown)
                                        ? NsfwCard(
                                            width: cardWidth,
                                            height: cardWidth,
                                            onTap: () {
                                              showOpenNsfwDialog(context).then((result) {
                                                if (result ?? false) {
                                                  setState(() {
                                                    nsfwOpen = true;
                                                    cacheManager.setBool(CacheManager.nsfwOpen, true);
                                                  });
                                                }
                                              });
                                            },
                                          )
                                        : Container(width: 0, height: 0),
                                  ],
                                ).intoContainer(width: cardWidth, height: cardWidth)
                              : Stack(
                                  children: [
                                    CachedNetworkImageUtils.custom(
                                        useOld: true,
                                        context: context,
                                        imageUrl: data.item!.imageUrl,
                                        width: cardWidth,
                                        height: nsfwShown ? cardWidth : null,
                                        fit: BoxFit.contain,
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
                                        }),
                                    (nsfwShown) ? Container(width: cardWidth, height: cardWidth).blur() : Container(),
                                    (nsfwShown)
                                        ? NsfwCard(
                                            width: cardWidth,
                                            height: cardWidth,
                                            onTap: () {
                                              showOpenNsfwDialog(context).then((result) {
                                                if (result ?? false) {
                                                  setState(() {
                                                    nsfwOpen = true;
                                                    cacheManager.setBool(CacheManager.nsfwOpen, true);
                                                  });
                                                }
                                              });
                                            },
                                          )
                                        : Container(width: 0, height: 0),
                                  ],
                                ).intoContainer(width: cardWidth, height: cardWidth))
                          .intoContainer(
                            margin: EdgeInsets.only(
                              top: index < 2 ? marginTop : 0,
                              bottom: index == dataList.length - 1 ? (AppTabBarHeight + $(15)) : $(0),
                            ),
                          )
                          .intoGestureDetector(onTap: () => _onEffectCategoryTap(data, dataController));
                    },
                    itemCount: dataList.length,
                  );
                }),
            header(context),
          ],
        ));
  }

  _onEffectCategoryTap(EffectItemListData data, EffectDataController effectDataController) async {
    EffectCategory? effectModel;
    var effectList = effectDataController.data!.datas[0].children;
    for (int i = 0; i < effectList.length; i++) {
      var value = effectList[i];
      if (data.key == value.key) {
        effectModel = EffectCategory.fromJson(value.toJson(), effectDataController.data!.locale);
        break;
      }
    }
    if (effectModel == null) {
      return;
    }
    var tabPos = effectDataController.tabList.findPosition((data) => data.key == 'template')!;
    var categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel!.key)!;
    var itemP = effectDataController.tabItemList.findPosition((d) => d.data.key == data.item!.key)!;

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(
          tabPos: tabPos,
          pos: categoryPos,
          itemPos: itemP,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return build2(context);
  }

  Widget header(BuildContext context) => ClipRect(
          child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppNavigationBar(
              backgroundColor: Colors.transparent,
              showBackItem: false,
              middle: TitleTextWidget(dataController.data?.campaignTab?.title ?? S.of(context).app_name, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
            ),
          ],
        ).intoContainer(color: Color(0xaa161719)).intoGestureDetector(
            onTap: () {},
            onDoubleTap: Platform.isIOS
                ? () {
                    EventBusHelper().eventBus.fire(OnTabDoubleClickEvent(data: tabId.id()));
                  }
                : null),
      ));

  @override
  bool get wantKeepAlive => true;
}
