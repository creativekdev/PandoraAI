import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/applovin_banner.dart';
import 'package:cartoonizer/common/utils.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/views/ChoosePhotoScreen.dart';
import 'package:cartoonizer/views/home/widget/home_face_card_widget.dart';

import 'home_tab_user_ex.dart';

class HomeFaceFragment extends StatefulWidget {
  List<EffectModel> dataList;

  HomeFaceFragment({
    Key? key,
    required this.dataList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeFaceFragmentState();
  }
}

class HomeFaceFragmentState extends State<HomeFaceFragment> with AutomaticKeepAliveClientMixin, HomeTabUserHolder {
  List<EffectModel> dataList = [];

  @override
  initState() {
    super.initState();
    dataList = widget.dataList;
    delay(() {
      initStoreInfo(context).then((value) {
        setState(() {});
      });
    });
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
      itemCount: dataList.length,
      itemBuilder: (context, index) => _buildEffectCategoryCard(context, dataList, index, width)
          .intoContainer(
        margin: EdgeInsets.only(left: $(20), right: $(20), top: index == 0 ? $(16) : $(8), bottom: $(8)),
      )
          .intoGestureDetector(onTap: () {
        _onEffectCategoryTap(dataList, index);
      }),
    );
  }

  Widget _buildEffectCategoryCard(
    BuildContext context,
    List<EffectModel> list,
    int index,
    double parentWidth,
  ) {
    var data = list[index];
    return Column(
      children: [
        _buildMERCAd(index),
        HomeFaceCardWidget(
          data: data,
          parentWidth: parentWidth,
        ),
      ],
    );
  }

  _onEffectCategoryTap(List<EffectModel> list, int index) async {
    logEvent(Events.choose_home_cartoon_type, eventValues: {"category": list[index].key, "style": list[index].style});

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(list: list, pos: index),
      ),
    );

    initStoreInfo(context);
  }

  Widget _buildMERCAd(int index) {
    var showAds = isShowAds(user);

    if (showAds && index == 2) {
      return Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: BannerMaxView((listener) => null, BannerAdSize.mrec, AppLovinConfig.MERC_AD_ID),
      );
    }

    return Container();
  }

  @override
  bool get wantKeepAlive => true;
}
