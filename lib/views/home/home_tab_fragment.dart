import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/applovin_banner.dart';
import 'package:cartoonizer/api.dart';
import 'package:cartoonizer/common/utils.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/home/home_effect_card_widget.dart';

class HomeTabFragment extends StatefulWidget {
  List<EffectModel> dataList;
  RecentController recentController;

  HomeTabFragment({
    Key? key,
    required this.dataList,
    required this.recentController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeTabFragmentState();
  }
}

class HomeTabFragmentState extends State<HomeTabFragment>
    with AutomaticKeepAliveClientMixin {
  List<EffectModel> dataList = [];
  late RecentController recentController;
  UserModel? _user;

  @override
  initState() {
    super.initState();
    dataList = widget.dataList;
    recentController = widget.recentController;
    initStoreInfo(true);
  }

  Future<void> initStoreInfo(bool needReload) async {
    _user = await API.getLogin(needLoad: true, context: context);
    if (needReload) {
      setState(() {});
    }
  }

  changeData(List<EffectModel> dataList) {
    setState(() {
      this.dataList = dataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) =>
          _buildEffectCategoryCard(context, dataList, index)
              .intoContainer(
        margin: EdgeInsets.only(
            left: $(20),
            right: $(20),
            top: index == 0 ? $(16) : $(8),
            bottom: $(8)),
      )
              .intoGestureDetector(onTap: () {
        _onEffectCategoryTap(dataList, index);
      }),
    );
  }

  Widget _buildEffectCategoryCard(
      BuildContext context, List<EffectModel> list, int index) {
    var data = list[index];
    return Column(
      children: [
        _buildMERCAd(index),
        HomeEffectCardWidget(data: data),
      ],
    );
  }

  _onEffectCategoryTap(List<EffectModel> list, int index) async {
    logEvent(Events.choose_home_cartoon_type,
        eventValues: {"category": list[index].key, "style": list[index].style});

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(list: list, pos: index),
      ),
    );
    recentController.onEffectUsed(list[index]);

    initStoreInfo(false);
  }

  Widget _buildMERCAd(int index) {
    var showAds = isShowAds(_user);

    if (showAds && index == 2) {
      return Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: BannerMaxView(
            (listener) => null, BannerAdSize.mrec, AppLovinConfig.MERC_AD_ID),
      );
    }

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}
