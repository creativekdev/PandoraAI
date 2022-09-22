import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';
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

class EffectRandomFragmentState extends State<EffectRandomFragment> with AutomaticKeepAliveClientMixin, AppTabState {
  late RecentController recentController;
  late EffectDataController dataController;
  ScrollController scrollController = ScrollController();
  double marginTop = $(110);
  late CardAdsMap adsMap;
  late double cardWidth;
  final double adScale = 1.55;
  late StreamSubscription appStateListener;
  late StreamSubscription tabOnDoubleClickListener;
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  UserManager userManager = AppDelegate.instance.getManager();

  @override
  initState() {
    super.initState();
    marginTop = $(110) + ScreenUtil.getStatusBarHeight();
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
        scale: adScale);
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
    dataController.buildRandomList(up: true);
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
  Widget build(BuildContext context) {
    super.build(context);
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GetBuilder<EffectDataController>(
          init: dataController,
          builder: (_) {
            List<_ListData> dataList = addToDataList(_.randomList);
            return WaterfallFlow.builder(
              cacheExtent: ScreenUtil.screenSize.height,
              controller: scrollController,
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: $(8),
              ),
              itemBuilder: (context, index) {
                var data = dataList[index];
                if (data.isAd) {
                  return _buildMERCAd(index ~/ 10);
                }
                return CachedNetworkImageUtils.custom(
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
                        })
                    .intoContainer(
                  margin: EdgeInsets.only(
                    top: index < 2 ? marginTop : $(8),
                    bottom: index == dataList.length - 1 ? AppTabBarHeight : $(0),
                  ),
                )
                    .intoGestureDetector(onTap: () {
                  _onEffectCategoryTap(data.data!, _);
                });
              },
              itemCount: dataList.length,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15)));
          },
        ));
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
            height: cardWidth * adScale,
          );
        }
      }
    }
    return Container();
  }

  _onEffectCategoryTap(EffectItemListData data, EffectDataController effectDataController) async {
    EffectModel? effectModel;
    var effectList = effectDataController.data!.effectList('template');
    for (var value in effectList) {
      if (data.key == value.key) {
        effectModel = EffectModel.fromJson(value.toJson());
        break;
      }
    }
    if (effectModel == null) {
      return;
    }
    effectModel.effects = {'${data.item!.key}': data.item!};
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
          list: [effectModel!],
          pos: 0,
          itemPos: 0,
          hasOriginalCheck: false,
          tabString: widget.tabString,
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
