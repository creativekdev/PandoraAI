import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Controller/home_data_controller.dart';

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

  HomeTabFragment({
    Key? key,
    required this.dataList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeTabFragmentState();
  }
}

class HomeTabFragmentState extends State<HomeTabFragment>
    with AutomaticKeepAliveClientMixin {
  List<EffectModel> dataList = [];
  UserModel? _user;

  @override
  initState() {
    super.initState();
    dataList = widget.dataList;
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
      itemBuilder: (context, index) => _buildEffectCategoryCard(dataList, index)
          .intoContainer(
        margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
      )
          .intoGestureDetector(onTap: () {
        _onEffectCategoryTap(dataList, index);
      }),
    );
  }

  Widget _buildEffectCategoryCard(List<EffectModel> list, int index) {
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
                padding: EdgeInsets.all(3.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 1.5.w),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2.w)),
                                  child:
                                      list[index].key.toString() == "transform"
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                      list[index].key +
                                                      ".webp",
                                              fit: BoxFit.fill,
                                              height: 41.w,
                                              width: 41.w,
                                              placeholder:
                                                  cachedNetworkImagePlaceholder,
                                              errorWidget:
                                                  cachedNetworkImageErrorWidget,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                      list[index].key +
                                                      ".mobile.jpg",
                                              fit: BoxFit.fill,
                                              height: 41.w,
                                              width: 41.w,
                                              placeholder:
                                                  cachedNetworkImagePlaceholder,
                                              errorWidget:
                                                  cachedNetworkImageErrorWidget,
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 0.w),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2.w)),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child:
                                      list[index].key.toString() == "transform"
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                      list[index].key +
                                                      "1.webp",
                                              fit: BoxFit.fill,
                                              height: 41.w,
                                              width: 41.w,
                                              placeholder:
                                                  cachedNetworkImagePlaceholder,
                                              errorWidget:
                                                  cachedNetworkImageErrorWidget,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                      list[index].key +
                                                      "1.jpg",
                                              fit: BoxFit.fill,
                                              height: 41.w,
                                              width: 41.w,
                                              placeholder:
                                                  cachedNetworkImagePlaceholder,
                                              errorWidget:
                                                  cachedNetworkImageErrorWidget,
                                            ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (list[index].key.toString() != "transform")
                      SizedBox(
                        height: 1.5.w,
                      ),
                    if (list[index].key.toString() != "transform")
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 1.5.w),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(2.w)),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: list[index].key.toString() ==
                                            "transform"
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                    list[index].key +
                                                    "2.webp",
                                            fit: BoxFit.fill,
                                            height: 41.w,
                                            width: 41.w,
                                            placeholder:
                                                cachedNetworkImagePlaceholder,
                                            errorWidget:
                                                cachedNetworkImageErrorWidget,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl:
                                                "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                    list[index].key +
                                                    "2.jpg",
                                            fit: BoxFit.fill,
                                            height: 41.w,
                                            width: 41.w,
                                            placeholder:
                                                cachedNetworkImagePlaceholder,
                                            errorWidget:
                                                cachedNetworkImageErrorWidget,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (list[index].effects.length >= 3)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(right: 0.w),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(2.w)),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: list[index].key.toString() ==
                                              "transform"
                                          ? CachedNetworkImage(
                                              imageUrl:
                                                  "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                      list[index].key +
                                                      "3.webp",
                                              fit: BoxFit.fill,
                                              height: 41.w,
                                              width: 41.w,
                                              placeholder:
                                                  cachedNetworkImagePlaceholder,
                                              errorWidget:
                                                  cachedNetworkImageErrorWidget,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl:
                                                  "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                      list[index].key +
                                                      "3.jpg",
                                              fit: BoxFit.fill,
                                              height: 41.w,
                                              width: 41.w,
                                              placeholder:
                                                  cachedNetworkImagePlaceholder,
                                              errorWidget:
                                                  cachedNetworkImageErrorWidget,
                                            ),
                                    ),
                                  ],
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
