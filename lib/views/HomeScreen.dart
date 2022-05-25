import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/common/utils.dart';
import 'package:cartoonizer/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/api.dart';
import 'package:cartoonizer/widgets/applovin_banner.dart';

import 'StripeSubscriptionScreen.dart';
import 'ChoosePhotoScreen.dart';
import 'SettingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  UserModel? _user;

  Widget _cachedNetworkImagePlaceholder(BuildContext context, String url) => Container(
        height: 41.w,
        width: 41.w,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

  Widget _cachedNetworkImageErrorWidget(BuildContext context, String url, error) => Container(
        height: 41.w,
        width: 41.w,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

  @override
  void initState() {
    logEvent(Events.homepage_loading);
    super.initState();

    initStoreInfo(true);

    _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile || event == ConnectivityResult.wifi /* || event == ConnectivityResult.none*/) {
        setState(() {});
      }
    });
  }

  Future<void> initStoreInfo(bool needReload) async {
    _user = await API.getLogin(needLoad: true, context: context);
    if (needReload) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: FutureBuilder(
          future: fetchCategory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.hasError) {
                return FutureBuilder(
                    future: getConnectionStatus(),
                    builder: (context, snapshot1) {
                      return Center(
                        child: TitleTextWidget((snapshot1.hasData && (snapshot1.data as bool)) ? StringConstant.empty_msg : StringConstant.no_internet_msg,
                            ColorConstant.BtnTextColor, FontWeight.w400, 12.sp),
                      );
                    });
              } else {
                var list = snapshot.data as List<EffectModel>;

                return Column(
                  children: [
                    Container(
                      margin: EdgeConstants.TopBarEdgeInsets,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 30,
                          ),
                          TitleTextWidget(StringConstant.home, ColorConstant.BtnTextColor, FontWeight.w600, 18),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: "/SettingScreen"),
                                  builder: (context) => SettingScreen(),
                                ),
                              );
                              initStoreInfo(false);
                            },
                            child: Image.asset(
                              ImagesConstant.ic_user_round,
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: 5.h,
                    // ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => {_onEffectCategoryTap(list, index)},
                          child: Container(
                            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
                            child: _buildEffectCategoryCard(list, index),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildMERCAd(int index) {
    var showAds = isShowAds(_user);

    if (showAds && index == 2) {
      return Padding(
        padding: EdgeInsets.only(bottom: 2.h),
        child: BannerMaxView((listener) => null, BannerAdSize.mrec, AppLovinConfig.MERC_AD_ID),
      );
    }

    return Container();
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
                                  borderRadius: BorderRadius.all(Radius.circular(2.w)),
                                  child: list[index].key.toString() == "transform"
                                      ? CachedNetworkImage(
                                          imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" + list[index].key + ".webp",
                                          fit: BoxFit.fill,
                                          height: 41.w,
                                          width: 41.w,
                                          placeholder: _cachedNetworkImagePlaceholder,
                                          errorWidget: _cachedNetworkImageErrorWidget,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" + list[index].key + ".mobile.jpg",
                                          fit: BoxFit.fill,
                                          height: 41.w,
                                          width: 41.w,
                                          placeholder: _cachedNetworkImagePlaceholder,
                                          errorWidget: _cachedNetworkImageErrorWidget,
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
                                  borderRadius: BorderRadius.all(Radius.circular(2.w)),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: list[index].key.toString() == "transform"
                                      ? CachedNetworkImage(
                                          imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" + list[index].key + "1.webp",
                                          fit: BoxFit.fill,
                                          height: 41.w,
                                          width: 41.w,
                                          placeholder: _cachedNetworkImagePlaceholder,
                                          errorWidget: _cachedNetworkImageErrorWidget,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" + list[index].key + "1.jpg",
                                          fit: BoxFit.fill,
                                          height: 41.w,
                                          width: 41.w,
                                          placeholder: _cachedNetworkImagePlaceholder,
                                          errorWidget: _cachedNetworkImageErrorWidget,
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
                                    borderRadius: BorderRadius.all(Radius.circular(2.w)),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: list[index].key.toString() == "transform"
                                        ? CachedNetworkImage(
                                            imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" + list[index].key + "2.webp",
                                            fit: BoxFit.fill,
                                            height: 41.w,
                                            width: 41.w,
                                            placeholder: _cachedNetworkImagePlaceholder,
                                            errorWidget: _cachedNetworkImageErrorWidget,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" + list[index].key + "2.jpg",
                                            fit: BoxFit.fill,
                                            height: 41.w,
                                            width: 41.w,
                                            placeholder: _cachedNetworkImagePlaceholder,
                                            errorWidget: _cachedNetworkImageErrorWidget,
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
                                      borderRadius: BorderRadius.all(Radius.circular(2.w)),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: list[index].key.toString() == "transform"
                                          ? CachedNetworkImage(
                                              imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" + list[index].key + "3.webp",
                                              fit: BoxFit.fill,
                                              height: 41.w,
                                              width: 41.w,
                                              placeholder: _cachedNetworkImagePlaceholder,
                                              errorWidget: _cachedNetworkImageErrorWidget,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" + list[index].key + "3.jpg",
                                              fit: BoxFit.fill,
                                              height: 41.w,
                                              width: 41.w,
                                              placeholder: _cachedNetworkImagePlaceholder,
                                              errorWidget: _cachedNetworkImageErrorWidget,
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
                          (list[index].display_name.toString() == "null") ? list[index].key : list[index].display_name, ColorConstant.BtnTextColor, FontWeight.w600, 17,
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
    logEvent(Events.choose_home_cartoon_type, eventValues: {"category": list[index].key, "style": list[index].style});

    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) => ChoosePhotoScreen(list: list, pos: index),
      ),
    );

    initStoreInfo(false);
  }

  Future<bool> getConnectionStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return (connectivityResult != ConnectivityResult.none);
  }

  Future<List<EffectModel>> fetchCategory() async {
    var response = await API.get("/api/tool/cartoonize_config");
    List<EffectModel> list = [];
    if (response.statusCode == 200) {
      final Map<String, dynamic> parsed = json.decode(response.body.toString());
      var data = parsed["data"] ?? {};

      data.keys.forEach((style) {
        if (data[style] != null) {
          data[style].forEach((effect) {
            list.add(EffectModel.fromJson(effect, style));
          });
        }
      });
    }
    return list;
  }
}
