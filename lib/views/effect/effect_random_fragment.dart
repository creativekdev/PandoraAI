import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/transfer/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/effect/effect_tab_state.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class EffectRandomFragment extends StatefulWidget {
  RecentController recentController;
  EffectDataController dataController;
  String tabString;
  int tabId;

  EffectRandomFragment({
    Key? key,
    required this.tabId,
    required this.recentController,
    required this.tabString,
    required this.dataController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectRandomFragmentState();
  }
}

class EffectRandomFragmentState extends State<EffectRandomFragment> with AutomaticKeepAliveClientMixin, AppTabState, EffectTabState {
  late RecentController recentController;
  late EffectDataController dataController;
  ScrollController scrollController = ScrollController();
  double marginTop = $(118);
  late CardAdsMap adsMap;
  late double cardWidth;
  late StreamSubscription appStateListener;
  late StreamSubscription tabOnDoubleClickListener;
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  UserManager userManager = AppDelegate.instance.getManager();

  @override
  initState() {
    super.initState();
    marginTop = $(118) + ScreenUtil.getStatusBarHeight();
    dataController = widget.dataController;
    recentController = widget.recentController;
    cardWidth = (ScreenUtil.screenSize.width - $(38)) / 2;
    adsMap = CardAdsMap(
      width: cardWidth,
      onUpdated: () {
        if (mounted) {
          setState(() {});
        }
      },
      autoHeight: true,
    );
    adsMap.init();
    appStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      setState(() {});
    });
    tabOnDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (event.data == widget.tabId) {
        scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });
  }

  @override
  onAttached() {
    super.onAttached();
    dataController.changeRandomTabViewing(true);
  }

  @override
  onDetached() {
    super.onDetached();
    dataController.changeRandomTabViewing(false);
    dataController.buildRandomList();
  }

  @override
  dispose() {
    super.dispose();
    adsMap.dispose();
    appStateListener.cancel();
    tabOnDoubleClickListener.cancel();
  }

  addToDataList(List<EffectItemListData> list) {
    List<_ListData> result = [];
    for (int i = 0; i < list.length; i++) {
      int page = i ~/ 10;
      if (!adsMap.hasAdHolder(page + 2)) {
        adsMap.addAdsCard(page + 2);
      }
      var data = list[i];
      result.add(_ListData(
        page: page,
        data: data,
        visible: true,
      ));
      if (i == 4 + page * 10) {
        result.add(_ListData(isAd: true, page: page));
      }
    }
    return result;
  }

  @override
  onEffectClick(PushExtraEntity pushExtraEntity) {
    for (var value in dataController.randomList) {
      if (value.key == pushExtraEntity.category && value.item!.key == pushExtraEntity.effect) {
        _onEffectCategoryTap(value, dataController);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Obx(() {
        List<_ListData> dataList = addToDataList(dataController.randomList);
        return WaterfallFlow.builder(
          cacheExtent: ScreenUtil.screenSize.height,
          controller: scrollController,
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: $(6),
          ),
          itemBuilder: (context, index) {
            var data = dataList[index];
            if (data.isAd) {
              return _buildMERCAd(index ~/ 10);
            }
            return (data.data!.item!.imageUrl.contains('mp4')
                    ? Stack(
                        children: [
                          EffectVideoPlayer(url: data.data!.item!.imageUrl),
                          Positioned(
                            right: $(5),
                            top: $(5),
                            child: Image.asset(
                              ImagesConstant.ic_video,
                              height: $(24),
                              width: $(24),
                            ),
                          ),
                        ],
                      ).intoContainer(width: cardWidth, height: cardWidth)
                    : CachedNetworkImageUtils.custom(
                        context: context,
                        imageUrl: data.data!.item!.imageUrl,
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
                        }))
                .intoContainer(
              margin: EdgeInsets.only(
                top: index < 2 ? marginTop : $(6),
                bottom: index == dataList.length - 1 ? AppTabBarHeight : $(0),
              ),
            )
                .intoGestureDetector(onTap: () {
              _onEffectCategoryTap(data.data!, dataController);
            });
          },
          itemCount: dataList.length,
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15)));
      }),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildMERCAd(int page) {
    var showAds = isShowAdsNew();

    if (showAds) {
      var appBackground = thirdpartManager.appBackground;
      if (appBackground) {
        return const SizedBox();
      } else {
        var result = adsMap.buildBannerAd(page);
        if (result != null) {
          return result.intoContainer(
            margin: EdgeInsets.only(top: $(8), bottom: $(8)),
            width: cardWidth,
          );
        }
      }
    }
    return Container();
  }

  _onEffectCategoryTap(EffectItemListData data, EffectDataController effectDataController) async {
    EffectModel? effectModel;
    var effectList = effectDataController.data!.effectList('template');
    for (int i = 0; i < effectList.length; i++) {
      var value = effectList[i];
      if (data.key == value.key) {
        effectModel = EffectModel.fromJson(value.toJson());
        break;
      }
    }
    if (effectModel == null) {
      return;
    }
    var tabPos = effectDataController.tabList.findPosition((data) => data.key == widget.tabString)!;
    var categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel!.key)!;
    var itemP = effectDataController.tabItemList.findPosition((d) => d.data.key == data.item!.key)!;

    logEvent(Events.choose_home_cartoon_type, eventValues: {
      "category": effectModel.key,
      "style": effectModel.style,
      "page": widget.tabString,
    });

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

    refreshUserInfo();
  }

  void refreshUserInfo() {
    userManager.refreshUser(context: context).then((value) {
      setState(() {});
    });
  }
}

class _ListData {
  bool isAd;
  int page;
  EffectItemListData? data;
  bool visible;

  _ListData({
    this.isAd = false,
    this.data,
    required this.page,
    this.visible = true,
  });
}
