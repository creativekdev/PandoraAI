import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/banner_ads_holder.dart';
import 'package:cartoonizer/common/utils.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/home/widget/home_face_card_widget.dart';

import 'home_tab_user_ex.dart';

class HomeFaceFragment extends StatefulWidget {
  List<EffectModel> dataList;
  RecentController recentController;
  bool hasOriginalFace;
  String tabString;

  HomeFaceFragment({
    Key? key,
    required this.dataList,
    required this.recentController,
    this.hasOriginalFace = true,
    required this.tabString,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeFaceFragmentState();
  }
}

class HomeFaceFragmentState extends State<HomeFaceFragment> with AutomaticKeepAliveClientMixin, HomeTabUserHolder {
  List<EffectModel> dataList = [];
  late RecentController recentController;
  late BannerAdsHolder bannerAdsHolder;

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
    );
    delay(() {
      bannerAdsHolder.onReady(horizontalPadding: $(50));
      initStoreInfo(context).then((value) {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    bannerAdsHolder.onDispose();
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
    return ListView.builder(
      itemBuilder: (context, index) => _buildEffectCategoryCard(context, dataList, index, width)
          .intoContainer(margin: EdgeInsets.only(left: $(20), right: $(20), top: index == 0 ? $(16) : $(8), bottom: $(8)))
          .intoGestureDetector(
            onTap: () => _onEffectCategoryTap(dataList, index),
          ),
      itemCount: dataList.length,
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
          HomeFaceCardWidget(
            data: data,
            parentWidth: parentWidth,
          ),
        ],
      );
    } else {
      return HomeFaceCardWidget(
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
      return bannerAdsHolder.buildBannerAd();
    }

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}
