import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/banner_ads_holder.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/effect/effect_tab_state.dart';
import 'package:cartoonizer/views/transfer/ChoosePhotoScreen.dart';

import 'widget/effect_face_card_widget.dart';

class EffectFaceFragment extends StatefulWidget {
  List<EffectModel> dataList;
  RecentController recentController;
  bool hasOriginalFace;
  String tabString;
  int tabId;
  double headerHeight;

  EffectFaceFragment({
    Key? key,
    required this.tabId,
    required this.dataList,
    required this.recentController,
    this.hasOriginalFace = true,
    required this.tabString,
    required this.headerHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectFaceFragmentState();
  }
}

class EffectFaceFragmentState extends State<EffectFaceFragment> with AutomaticKeepAliveClientMixin, AppTabState, EffectTabState {
  List<EffectModel> dataList = [];
  late RecentController recentController;
  late BannerAdsHolder bannerAdsHolder;
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late StreamSubscription appStateListener;
  late StreamSubscription tabOnDoubleClickListener;
  ScrollController scrollController = ScrollController();
  double marginTop = $(118);
  late bool nsfwOpen;

  @override
  initState() {
    super.initState();
    nsfwOpen = cacheManager.getBool(CacheManager.nsfwOpen);
    marginTop = widget.headerHeight + $(8);
    recentController = widget.recentController;
    dataList = widget.dataList;
    bannerAdsHolder = BannerAdsHolder(
      this,
      onUpdated: () {
        setState(() {});
      },
      adId: AdMobConfig.BANNER_AD_ID,
      horizontalPadding: $(50),
    );
    delay(() {
      bannerAdsHolder.initHolder();
    });
    appStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    tabOnDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (event.data == widget.tabId) {
        scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.linear);
      }
    });
  }

  void refreshUserInfo() {
    userManager.refreshUser(context: context).then((value) {
      setState(() {});
    });
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
  void dispose() {
    super.dispose();
    bannerAdsHolder.onDispose();
    appStateListener.cancel();
    tabOnDoubleClickListener.cancel();
  }

  changeData(List<EffectModel> dataList) {
    setState(() {
      this.dataList = dataList;
    });
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
        itemBuilder: (context, index) => _buildEffectCategoryCard(context, dataList, index, width)
            .intoContainer(
              margin: EdgeInsets.only(
                left: $(15),
                right: $(15),
                top: index == 0 ? (marginTop + $(8)) : 6,
                bottom: index == dataList.length - 1 ? ($(15) + AppTabBarHeight) : $(8),
              ),
            )
            .intoGestureDetector(
              onTap: () => _onEffectCategoryTap(dataList, index),
            ),
        itemCount: dataList.length,
      ),
    );
  }

  Widget _buildEffectCategoryCard(
    BuildContext context,
    List<EffectModel> list,
    int index,
    double parentWidth,
  ) {
    var data = list[index];
    int adIndex = widget.tabString == 'face' ? 1 : 2;
    if (index == adIndex) {
      return Column(
        children: [
          _buildMERCAd(),
          EffectFaceCardWidget(
            nsfwShown: !nsfwOpen && data.nsfw,
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
            data: data,
            parentWidth: parentWidth,
          ),
        ],
      );
    } else {
      return EffectFaceCardWidget(
        nsfwShown: !nsfwOpen && data.nsfw,
        data: data,
        parentWidth: parentWidth,
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
      );
    }
  }

  _onEffectCategoryTap(List<EffectModel> list, int index, {int? itemPos}) async {
    logEvent(Events.choose_home_cartoon_type, eventValues: {
      "category": list[index].key,
      "style": list[index].style,
      "page": widget.tabString,
    });
    EffectDataController effectDataController = Get.find();

    EffectModel effectModel = list[index];
    if (itemPos == null) {
      itemPos = effectModel.getDefaultPos();
    }
    var effectItem = effectModel.effects.values.toList()[itemPos];
    var tabPos = effectDataController.tabList.findPosition((data) => data.key == widget.tabString)!;
    var categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel.key)!;
    var itemP = effectDataController.tabItemList.findPosition((data) => data.data.key == effectItem.key)!;
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
