import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/utils/cacheImage/image_cache_manager.dart';

import '../../Common/importFile.dart';
import '../../Common/utils.dart';
import '../../Widgets/applovin_banner.dart';
import '../../api.dart';
import '../../config.dart';
import '../../models/EffectModel.dart';
import '../../models/UserModel.dart';
import '../ChoosePhotoScreen.dart';
import 'HomeScreen.dart';

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

  Widget _imageWidget(BuildContext context, {required String url}) =>
      CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.fill,
        height: $(150),
        width: $(150),
        placeholder: cachedNetworkImagePlaceholder,
        errorWidget: cachedNetworkImageErrorWidget,
        cacheManager: CachedImageCacheManager(),
      );

  Widget _buildEffectCategoryCard(
      BuildContext context, List<EffectModel> list, int index) {
    var data = list[index];
    return Column(
      children: [
        _buildMERCAd(index),
        Card(
          color: ColorConstant.CardColor,
          elevation: 1.h,
          shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all($(6)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all($(6)),
                            child: ClipRRect(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2.w)),
                              child: _imageWidget(context,
                                  url: data.getShownUrl()),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all($(6)),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2.w)),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: _imageWidget(context,
                                  url: data.getShownUrl(pos: 1)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (list[index].key.toString() != "transform")
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all($(6)),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2.w)),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: _imageWidget(context,
                                    url: data.getShownUrl(pos: 2)),
                              ),
                            ),
                          ),
                          if (list[index].effects.length >= 3)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all($(6)),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2.w)),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: _imageWidget(context,
                                      url: data.getShownUrl(pos: 3)),
                                ),
                              ),
                            ),
                        ],
                      )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 3.w, right: 3.w, bottom: 3.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TitleTextWidget(
                          (list[index].display_name.toString() == "null")
                              ? list[index].key
                              : list[index].display_name,
                          ColorConstant.BtnTextColor,
                          FontWeight.w600,
                          17,
                          align: TextAlign.start),
                    ),
                    Image.asset(
                      ImagesConstant.ic_next,
                      height: 50,
                      width: 50,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
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
