import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/home_data_controller.dart';
import 'package:cartoonizer/Model/CategoryModel.dart';
import 'package:cartoonizer/Model/EffectModel.dart';
import 'package:cartoonizer/Widgets/indicator/line_tab_indicator.dart';
import 'package:cartoonizer/api.dart';

import '../SettingScreen.dart';
import 'home_recent_fragment.dart';
import 'home_tab_fragment.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final Connectivity _connectivity = Connectivity();
  late HomeDataController dataController;

  int currentIndex = 0;
  late PageController _pageController;
  late TabController _tabController;
  List<HomeTabConfig> tabConfig = [];

  @override
  void initState() {
    super.initState();
    API.getLogin(needLoad: true, context: context);
    dataController = Get.put(HomeDataController());
    _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile ||
          event ==
              ConnectivityResult
                  .wifi /* || event == ConnectivityResult.none*/) {
        setState(() {});
      }
    });
  }

  void _pageChange(int index) {
    setState(() {
      if (currentIndex != index) {
        currentIndex = index;
        _tabController.index = currentIndex;
      }
    });
  }

  void setIndex(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: GetBuilder<HomeDataController>(
          init: dataController,
          builder: (_) {
            if (_.loading) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (_.dataList == null) {
                return FutureBuilder(
                    future: getConnectionStatus(),
                    builder: (context, snapshot1) {
                      return Center(
                        child: TitleTextWidget(
                            (snapshot1.hasData && (snapshot1.data as bool))
                                ? StringConstant.empty_msg
                                : StringConstant.no_internet_msg,
                            ColorConstant.BtnTextColor,
                            FontWeight.w400,
                            12.sp),
                      );
                    });
              } else {
                tabConfig.clear();
                tabConfig.add(HomeTabConfig(
                    item: HomeTabFragment(controller: dataController),
                    title: 'Facetoon'));
                tabConfig.add(HomeTabConfig(
                    item: HomeTabFragment(controller: dataController),
                    title: 'Effects'));
                tabConfig.add(
                    HomeTabConfig(item: HomeRecentFragment(), title: 'Recent'));
                _pageController = PageController(initialPage: currentIndex);
                _tabController = TabController(
                    length: tabConfig.length,
                    vsync: this,
                    initialIndex: currentIndex);
                return Column(
                  children: [
                    navbar(context),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    TabBar(
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: LineTabIndicator(
                        space: $(2),
                        borderSide: BorderSide(
                            width: $(3), color: ColorConstant.PrimaryColor),
                      ),
                      isScrollable: true,
                      labelColor: ColorConstant.PrimaryColor,
                      labelPadding: EdgeInsets.only(left: $(10), right: $(10)),
                      labelStyle: TextStyle(
                          fontSize: $(14), fontWeight: FontWeight.bold),
                      unselectedLabelColor: ColorConstant.TextBlack,
                      unselectedLabelStyle: TextStyle(
                          fontSize: $(14), fontWeight: FontWeight.w500),
                      controller: _tabController,
                      onTap: (index) {
                        setIndex(index);
                      },
                      tabs: tabConfig
                          .map((e) => Text(e.title)
                              .intoContainer(padding: EdgeInsets.all($(8))))
                          .toList(),
                    ),
                    SizedBox(height: $(8)),
                    Expanded(
                        child: PageView.builder(
                      onPageChanged: _pageChange,
                      controller: _pageController,
                      itemBuilder: (BuildContext context, int index) {
                        return tabConfig[index].item;
                      },
                      itemCount: tabConfig.length,
                    )),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }

  Widget navbar(BuildContext context) => Container(
        margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: 10.w,
              width: 10.w,
            ),
            TitleTextWidget(StringConstant.home, ColorConstant.BtnTextColor,
                FontWeight.w600, 14.sp),
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
      );

  Future<bool> getConnectionStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return (connectivityResult != ConnectivityResult.none);
  }

  Future<List<EffectModel>> fetchCategory() async {
    var response = await API.get("/api/tool/cartoonize_config");
    List<EffectModel> list = [];
    if (response.statusCode == 200) {
      final Map<String, dynamic> parsed = json.decode(response.body.toString());
      final categoryResponse = CategoryModel.fromJson(parsed);
      list.addAll(categoryResponse.data.face);
    }
    return list;
  }
}

Widget cachedNetworkImagePlaceholder(BuildContext context, String url) =>
    Container(
      height: 41.w,
      width: 41.w,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

Widget cachedNetworkImageErrorWidget(BuildContext context, String url, error) =>
    Container(
      height: 41.w,
      width: 41.w,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
