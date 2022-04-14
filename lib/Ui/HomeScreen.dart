import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Model/CategoryModel.dart';
import 'package:cartoonizer/Model/EffectModel.dart';
import 'package:cartoonizer/api.dart';
import 'package:http/http.dart';

import 'PurchaseScreen.dart';
import 'ChoosePhotoScreen.dart';
import 'SettingScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();

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
    super.initState();
    API.getLogin(needLoad: true, context: context);
    _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile || event == ConnectivityResult.wifi /* || event == ConnectivityResult.none*/) {
        setState(() {});
      }
    });
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
                      margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 10.w,
                            width: 10.w,
                          ),
                          TitleTextWidget(StringConstant.home, ColorConstant.BtnTextColor, FontWeight.w600, 14.sp),
                          GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(name: "/SettingScreen"),
                                    builder: (context) => SettingScreen(),
                                  ))
                            },
                            child: Image.asset(
                              ImagesConstant.ic_user_round,
                              height: 10.w,
                              width: 10.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: (snapshot.data as List<EffectModel>).length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(name: "/PurchaseScreen"),
                                  builder: (context) => PurchaseScreen(),
                                ))
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       settings: RouteSettings(name: "/ChoosePhotoScreen"),
                            //       builder: (context) => ChoosePhotoScreen(list: (snapshot.data as List<EffectModel>), pos: index),
                            //     ))
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 2.h),
                            child: Card(
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
                                                      child: (snapshot.data as List<EffectModel>)[index].key.toString() == "transform"
                                                          ? CachedNetworkImage(
                                                              imageUrl:
                                                                  "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" + (snapshot.data as List<EffectModel>)[index].key + ".webp",
                                                              fit: BoxFit.fill,
                                                              height: 41.w,
                                                              width: 41.w,
                                                              placeholder: _cachedNetworkImagePlaceholder,
                                                              errorWidget: _cachedNetworkImageErrorWidget,
                                                            )
                                                          : CachedNetworkImage(
                                                              imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                                  (snapshot.data as List<EffectModel>)[index].key +
                                                                  ".mobile.jpg",
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
                                                      child: (snapshot.data as List<EffectModel>)[index].key.toString() == "transform"
                                                          ? CachedNetworkImage(
                                                              imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                                  (snapshot.data as List<EffectModel>)[index].key +
                                                                  "1.webp",
                                                              fit: BoxFit.fill,
                                                              height: 41.w,
                                                              width: 41.w,
                                                              placeholder: _cachedNetworkImagePlaceholder,
                                                              errorWidget: _cachedNetworkImageErrorWidget,
                                                            )
                                                          : CachedNetworkImage(
                                                              imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                                  (snapshot.data as List<EffectModel>)[index].key +
                                                                  "1.jpg",
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
                                                        child: (snapshot.data as List<EffectModel>)[index].key.toString() == "transform"
                                                            ? CachedNetworkImage(
                                                                imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                                    (snapshot.data as List<EffectModel>)[index].key +
                                                                    "2.webp",
                                                                fit: BoxFit.fill,
                                                                height: 41.w,
                                                                width: 41.w,
                                                                placeholder: _cachedNetworkImagePlaceholder,
                                                                errorWidget: _cachedNetworkImageErrorWidget,
                                                              )
                                                            : CachedNetworkImage(
                                                                imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                                    (snapshot.data as List<EffectModel>)[index].key +
                                                                    "2.jpg",
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
                                                          child: (snapshot.data as List<EffectModel>)[index].key.toString() == "transform"
                                                              ? CachedNetworkImage(
                                                                  imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/video/" +
                                                                      (snapshot.data as List<EffectModel>)[index].key +
                                                                      "3.webp",
                                                                  fit: BoxFit.fill,
                                                                  height: 41.w,
                                                                  width: 41.w,
                                                                  placeholder: _cachedNetworkImagePlaceholder,
                                                                  errorWidget: _cachedNetworkImageErrorWidget,
                                                                )
                                                              : CachedNetworkImage(
                                                                  imageUrl: "https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/" +
                                                                      (snapshot.data as List<EffectModel>)[index].key +
                                                                      "3.jpg",
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
                                              ((snapshot.data as List<EffectModel>)[index].display_name.toString() == "null")
                                                  ? (snapshot.data as List<EffectModel>)[index].key
                                                  : (snapshot.data as List<EffectModel>)[index].display_name,
                                              ColorConstant.BtnTextColor,
                                              FontWeight.w600,
                                              14.sp,
                                              align: TextAlign.start),
                                        ),
                                        Image.asset(
                                          ImagesConstant.ic_next,
                                          height: 14.w,
                                          width: 14.w,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  Future<bool> getConnectionStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return (connectivityResult != ConnectivityResult.none);
  }

  Future<List<EffectModel>> fetchCategory() async {
    var response = await get(Uri.parse('https://socialbook.io/api/tool/cartoonize_config'));
    List<EffectModel> list = [];
    if (response.statusCode == 200) {
      final Map<String, dynamic> parsed = json.decode(response.body.toString());
      final categoryResponse = CategoryModel.fromJson(parsed);
      list.addAll(categoryResponse.data.face);
    }
    return list;
  }
}
