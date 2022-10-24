import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/banner_ads_holder.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/transfer/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/effect/effect_tab_state.dart';

import '../../Widgets/dialog/dialog_widget.dart';
import 'widget/effect_full_body_card_widget.dart';

class EffectFullBodyFragment extends StatefulWidget {
  List<EffectModel> dataList;
  RecentController recentController;
  String tabString;
  int tabId;

  EffectFullBodyFragment({
    Key? key,
    required this.tabId,
    required this.recentController,
    required this.dataList,
    required this.tabString,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectFullBodyFragmentState();
  }
}

class EffectFullBodyFragmentState extends State<EffectFullBodyFragment> with AutomaticKeepAliveClientMixin, AppTabState, EffectTabState {
  List<EffectModel> effectModelList = [];
  List<List<EffectItemListData>> dataList = [];
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late RecentController recentController;
  late BannerAdsHolder bannerAdsHolder;
  late StreamSubscription appStateListener;
  late StreamSubscription tabOnDoubleClickListener;
  ScrollController scrollController = ScrollController();
  double marginTop = $(110);
  late bool nsfwOpen;

  @override
  initState() {
    super.initState();
    nsfwOpen = cacheManager.getBool(CacheManager.nsfwOpen);
    marginTop = $(110) + ScreenUtil.getStatusBarHeight();
    effectModelList = widget.dataList;
    recentController = widget.recentController;
    bannerAdsHolder = BannerAdsHolder(
      this,
      onUpdated: () {
        setState(() {});
      },
      adId: AdMobConfig.BANNER_AD_ID,
      horizontalPadding: $(35),
    );
    appStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      setState(() {});
    });
    tabOnDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (event.data == widget.tabId) {
        scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });
    delay(() {
      buildDataList();
    });
  }

  void refreshUserInfo() {
    userManager.refreshUser(context: context).then((value) {
      setState(() {});
    });
  }

  buildDataList() {
    List<EffectItemListData> allItemList = [];
    for (var value in effectModelList) {
      var items = value.effects.values.toList();
      for (int i = 0; i < items.length; i++) {
        allItemList.add(EffectItemListData(
          key: value.key,
          uniqueKey: '${value.key}${items[i].key}',
          pos: i,
          item: items[i],
        ));
      }
    }
    dataList.clear();
    allItemList.forEach((element) {
      if (dataList.isNotEmpty && dataList.last.length < 2) {
        dataList.last.add(element);
      } else {
        dataList.add([element]);
      }
    });
    setState(() {});
    bannerAdsHolder.initHolder();
  }

  @override
  void dispose() {
    super.dispose();
    bannerAdsHolder.onDispose();
    appStateListener.cancel();
    tabOnDoubleClickListener.cancel();
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
  onEffectClick(PushExtraEntity pushExtraEntity) {
    EffectItemListData? data;
    for (var list in dataList) {
      if (data != null) {
        break;
      }
      for (var value in list) {
        if (value.key == pushExtraEntity.category && value.item!.key == pushExtraEntity.effect) {
          data = value;
          break;
        }
      }
    }
    if (data != null) {
      _onEffectCategoryTap(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var width = ScreenUtil.getCurrentWidgetSize(context).width - $(30);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) => _buildEffectCategoryCard(context, dataList, index, width).intoContainer(
          margin: EdgeInsets.only(
            right: $(15),
            left: $(15),
            top: index == 0 ? (marginTop + $(8)) : $(8),
            bottom: index == dataList.length - 1 ? ($(8) + AppTabBarHeight) : $(8),
          ),
        ),
        itemCount: dataList.length,
      ),
    );
  }

  Widget _buildEffectCategoryCard(
    BuildContext context,
    List<List<EffectItemListData>> list,
    int index,
    double parentWidth,
  ) {
    var data = list[index];
    if (index == 2) {
      return Column(
        children: [
          _buildMERCAd(),
          EffectFullBodyCardWidget(
            onNsfwTap: () {
              showOpenNsfwDialog(context).then((result) {
                if (result ?? false) {
                  setState(() {
                    nsfwOpen = true;
                    cacheManager.setBool(CacheManager.nsfwOpen, true);
                  });
                }
              });
            },
            nsfwShown: nsfwOpen,
            data: data,
            parentWidth: parentWidth,
            onTap: (item) {
              _onEffectCategoryTap(item);
            },
          ),
        ],
      );
    } else {
      return EffectFullBodyCardWidget(
        onNsfwTap: () {
          showOpenNsfwDialog(context).then((result) {
            if (result ?? false) {
              setState(() {
                nsfwOpen = true;
                cacheManager.setBool(CacheManager.nsfwOpen, true);
              });
            }
          });
        },
        nsfwShown: nsfwOpen,
        data: data,
        parentWidth: parentWidth,
        onTap: (item) {
          _onEffectCategoryTap(item);
        },
      );
    }
  }

  _onEffectCategoryTap(EffectItemListData data) async {
    EffectDataController effectDataController = Get.find();
    EffectModel? effectModel;
    for (int i = 0; i < effectModelList.length; i++) {
      var model = effectModelList[i];
      if (model.key == data.key) {
        effectModel = model;
        break;
      }
    }
    if (effectModel == null) {
      return;
    }
    var effectItem = data.item!;
    var tabPos = effectDataController.tabList.findPosition((data) => data.key == widget.tabString)!;
    var categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel!.key)!;
    var itemP = effectDataController.tabItemList.findPosition((data) => data.data.key == effectItem.key)!;

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

  Widget _buildMERCAd() {
    if (isShowAdsNew()) {
      if (thirdpartManager.appBackground) {
        return const SizedBox();
      } else {
        return bannerAdsHolder.buildAdWidget() ?? SizedBox();
      }
    }

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}
