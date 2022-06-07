import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/home_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
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
  late RecentController recentController;

  int currentIndex = 0;
  late PageController _pageController;
  late TabController _tabController;
  List<HomeTabConfig> tabConfig = [];

  @override
  void initState() {
    super.initState();
    logEvent(Events.homepage_loading);
    API.getLogin(needLoad: true, context: context);
    dataController = Get.put(HomeDataController());
    recentController = Get.put(RecentController());
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
              if (_.data == null) {
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
                recentController.updateOriginData(_.data!);
                tabConfig.clear();
                for (var value in _.data!.keys) {
                  tabConfig.add(
                    HomeTabConfig(
                        item: HomeTabFragment(
                          dataList: _.data![value]!,
                          recentController: recentController,
                        ),
                        title: value),
                  );
                }
                tabConfig.add(HomeTabConfig(
                    item: HomeRecentFragment(controller: recentController),
                    title: 'Recent'));
                _pageController = PageController(initialPage: currentIndex);
                _tabController = TabController(
                    length: tabConfig.length,
                    vsync: this,
                    initialIndex: currentIndex);
                return Column(
                  children: [
                    navbar(context),
                    SizedBox(height: $(10)),
                    TabBar(
                      indicatorSize: TabBarIndicatorSize.label,
                      indicator: LineTabIndicator(
                        space: $(16),
                        borderSide: BorderSide(
                            width: $(3), color: ColorConstant.BlueColor),
                      ),
                      isScrollable: false,
                      labelColor: ColorConstant.PrimaryColor,
                      labelPadding: EdgeInsets.only(left: $(10), right: $(10)),
                      labelStyle: TextStyle(
                          fontSize: $(14), fontWeight: FontWeight.bold),
                      unselectedLabelColor: ColorConstant.PrimaryColor,
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
                    SizedBox(height: $(4)),
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
        margin: EdgeInsets.only(top: $(10), left: $(15), right: $(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: $(38),
              width: $(38),
            ),
            TitleTextWidget(StringConstant.home, ColorConstant.BtnTextColor,
                FontWeight.w600, $(18)),
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
                height: $(30),
                width: $(30),
              ).intoContainer(padding: EdgeInsets.all($(4))),
            ),
          ],
        ),
      );

  Future<bool> getConnectionStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return (connectivityResult != ConnectivityResult.none);
  }
}
