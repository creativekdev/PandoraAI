import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/banner_ads_holder.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';

import 'tab_user_ex.dart';
import 'widget/effect_face_card_widget.dart';

class EffectFaceFragment extends StatefulWidget {
  List<EffectModel> dataList;
  RecentController recentController;
  bool hasOriginalFace;
  String tabString;
  int tabId;

  EffectFaceFragment({
    Key? key,
    required this.tabId,
    required this.dataList,
    required this.recentController,
    this.hasOriginalFace = true,
    required this.tabString,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectFaceFragmentState();
  }
}

class EffectFaceFragmentState extends State<EffectFaceFragment> with AutomaticKeepAliveClientMixin, TabUserHolder {
  List<EffectModel> dataList = [];
  late RecentController recentController;
  late BannerAdsHolder bannerAdsHolder;
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  late StreamSubscription appStateListener;
  late StreamSubscription tabOnDoubleClickListener;
  ScrollController scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    recentController = widget.recentController;
    dataList = widget.dataList;
    bannerAdsHolder = BannerAdsHolder(
      this,
      closeable: false,
      onUpdated: () {
        setState(() {});
      },
      adId: AdMobConfig.BANNER_AD_ID,
    );
    delay(() {
      bannerAdsHolder.onReady(horizontalPadding: $(50));
      initStoreInfo(context).then((value) {
        setState(() {});
      });
    });
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
    var width = ScreenUtil.getCurrentWidgetSize(context).width - $(40);
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
                top: index == 0 ? $(125) : 0,
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
    if (index == 2) {
      return Column(
        children: [
          _buildMERCAd(),
          EffectFaceCardWidget(
            data: data,
            parentWidth: parentWidth,
          ),
        ],
      );
    } else {
      return EffectFaceCardWidget(
        data: data,
        parentWidth: parentWidth,
      );
    }
  }

  _onEffectCategoryTap(List<EffectModel> list, int index) async {
    logEvent(Events.choose_home_cartoon_type, eventValues: {
      "category": list[index].key,
      "style": list[index].style,
      "page": widget.tabString,
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(
          list: list,
          pos: index,
          hasOriginalCheck: widget.hasOriginalFace,
        ),
      ),
    );

    initStoreInfo(context);
  }

  Widget _buildMERCAd() {
    var showAds = isShowAds(user);

    if (showAds) {
      if (thirdpartManager.appBackground) {
        return const SizedBox();
      } else {
        return bannerAdsHolder.buildBannerAd();
      }
    }

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}
