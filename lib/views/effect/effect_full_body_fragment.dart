import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/banner_ads_holder.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/effect/tab_user_ex.dart';

import 'widget/effect_full_body_card_widget.dart';

class EffectFullBodyFragment extends StatefulWidget {
  List<EffectModel> dataList;
  RecentController recentController;
  String tabString;

  EffectFullBodyFragment({
    Key? key,
    required this.recentController,
    required this.dataList,
    required this.tabString,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectFullBodyFragmentState();
  }
}

class EffectFullBodyFragmentState extends State<EffectFullBodyFragment> with AutomaticKeepAliveClientMixin, TabUserHolder {
  List<EffectModel> effectModelList = [];
  List<List<EffectItemListData>> dataList = [];
  Widget? adWidget;
  late RecentController recentController;
  late BannerAdsHolder bannerAdsHolder;

  @override
  initState() {
    super.initState();
    effectModelList = widget.dataList;
    recentController = widget.recentController;
    bannerAdsHolder = BannerAdsHolder(
      this,
      closeable: false,
      onUpdated: () {
        setState(() {});
      },
      adId: AdMobConfig.BANNER_AD_ID,
    );
    delay(() {
      buildDataList();
      initStoreInfo(context).then((value) {
        setState(() {});
      });
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
    bannerAdsHolder.onReady(horizontalPadding: $(35));
  }

  @override
  void dispose() {
    super.dispose();
    bannerAdsHolder.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var width = ScreenUtil.getCurrentWidgetSize(context).width - $(30);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemBuilder: (context, index) => _buildEffectCategoryCard(context, dataList, index, width).intoContainer(
          margin: EdgeInsets.only(
            right: $(15),
            left: $(15),
            top: index == 0?$(132):$(8),
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
        data: data,
        parentWidth: parentWidth,
        onTap: (item) {
          _onEffectCategoryTap(item);
        },
      );
    }
  }

  _onEffectCategoryTap(EffectItemListData data) async {
    EffectModel? effectModel;
    int index = 0;
    for (int i = 0; i < effectModelList.length; i++) {
      var model = effectModelList[i];
      if (model.key == data.key) {
        effectModel = model;
        index = i;
        break;
      }
    }
    if (effectModel == null) {
      return;
    }

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
          list: effectModelList,
          pos: index,
          itemPos: data.pos,
          hasOriginalCheck: false,
        ),
      ),
    );

    initStoreInfo(context);
  }

  Widget _buildMERCAd() {
    var showAds = isShowAds(user);

    if (showAds) {
      return bannerAdsHolder.buildBannerAd();
    }

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}
