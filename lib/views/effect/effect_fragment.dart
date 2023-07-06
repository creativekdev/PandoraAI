import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/badge.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/effect/effect_tab_state.dart';
import 'package:cartoonizer/views/msg/msg_list_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../Widgets/router/routers.dart';
import '../../models/discovery_list_entity.dart';
import '../../models/enums/home_card_type.dart';
import '../../utils/utils.dart';
import '../home_new/home_detail_screen.dart';
import '../home_new/home_details_screen.dart';
import '../home_new/pai_content_view.dart';
import '../home_new/pai_recommend_view.dart';
import '../home_new/pai_sliver_view.dart';
import '../home_new/pai_swiper.dart';
import 'home_effect_skeletonView.dart';

class EffectFragment extends StatefulWidget {
  AppTabId tabId;

  EffectFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<EffectFragment> createState() => EffectFragmentState();
}

class EffectFragmentState extends State<EffectFragment> with AppTabState, EffectTabState {
  final Connectivity _connectivity = Connectivity();
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdPartManager = AppDelegate().getManager();
  EffectDataController dataController = Get.find();
  late AppTabId tabId;
  late StreamSubscription onUserStateChangeListener;
  late StreamSubscription onUserLoginListener;
  bool proVisible = false;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'home_fragment');
    tabId = widget.tabId;
    _connectivity.onConnectivityChanged.listen((event) {
      if (!mounted) return;
      if (event == ConnectivityResult.mobile || event == ConnectivityResult.wifi /* || event == ConnectivityResult.none*/) {
        if (dataController.data == null) {
          dataController.loadData();
        }
      }
    });
    onUserStateChangeListener = EventBusHelper().eventBus.on<UserInfoChangeEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        refreshProVisible();
      });
    });
    onUserLoginListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        refreshProVisible();
      });
    });

    refreshProVisible();
  }

  @override
  void onAttached() {
    super.onAttached();
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${tabId.id()}', currentTime);
  }

  refreshProVisible() {
    if (userManager.isNeedLogin) {
      proVisible = true;
    } else {
      if (userManager.user!.userSubscription.isEmpty) {
        proVisible = true;
      } else {
        proVisible = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EffectDataController>(
      init: dataController,
      builder: (_) {
        return Stack(
          children: [
            _.loading
                ? HomeEffectSkeletonView()
                : _.data == null
                    ? FutureBuilder(
                        future: getConnectionStatus(),
                        builder: (context, snapshot1) {
                          return Center(
                            child: TitleTextWidget((snapshot1.hasData && (snapshot1.data as bool)) ? S.of(context).empty_msg : S.of(context).no_internet_msg,
                                ColorConstant.BtnTextColor, FontWeight.w400, 12.sp),
                          ).intoGestureDetector(onTap: () {
                            _.loadData();
                            userManager.refreshUser();
                          });
                        })
                    : CustomScrollView(
                        slivers: [
                          SliverPadding(padding: EdgeInsets.only(top: ScreenUtil.getNavigationBarHeight() + ScreenUtil.getStatusBarHeight())),
                          SliverToBoxAdapter(
                            child: PaiSwiper(
                              entity: _.data?.homepage?.banners,
                              onClickItem: (index, data) {
                                HomeCardTypeUtils.jump(context: context, source: 'home_page', data: data);
                              },
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: PaiSliverView(
                              list: _.data?.homepage?.tools,
                              onClickItem: (data) {
                                HomeCardTypeUtils.jump(context: context, source: 'home_page', homeData: data);
                              },
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: PaiRecommendView(
                              list: _.data?.homepage?.features,
                              onClickItem: (data) {
                                HomeCardTypeUtils.jump(context: context, source: 'home_page', homeData: data);
                              },
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: PaiContentView(
                              height: $(172),
                              onTap: (String category, List<DiscoveryListEntity>? posts) {
                                Navigator.of(context).push<bool>(
                                  Right2LeftRouter(
                                    settings: RouteSettings(name: '/HomeDetailsScreen'),
                                    child: HomeDetailsScreen(
                                      posts: posts,
                                      category: category,
                                      source: "home_page",
                                    ),
                                  ),
                                );
                              },
                              onTapItem: (int index) {
                                Navigator.of(context).push<void>(Right2LeftRouter(
                                    settings: RouteSettings(name: '/HomeDetailScreen'),
                                    child: HomeDetailScreen(
                                      post: _.data!.homepage!.galleries[0]!.socialPosts[index]!,
                                      source: "home_page",
                                    )));
                              },
                              galleries: _.data?.homepage?.galleries[0],
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: PaiContentView(
                              height: $(96),
                              onTap: (String category, List<DiscoveryListEntity>? posts) {
                                Navigator.of(context).push<bool>(
                                  Right2LeftRouter(
                                    settings: RouteSettings(name: '/HomeDetailsScreen'),
                                    child: HomeDetailsScreen(
                                      posts: posts,
                                      category: category,
                                      source: "home_page",
                                    ),
                                  ),
                                );
                              },
                              onTapItem: (int index) {
                                Navigator.of(context).push<void>(Right2LeftRouter(
                                    settings: RouteSettings(name: '/HomeDetailScreen'),
                                    child: HomeDetailScreen(
                                      post: _.data!.homepage!.galleries[1]!.socialPosts[index]!,
                                      source: "home_page",
                                    )));
                              },
                              galleries: _.data?.homepage?.galleries[1],
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: PaiContentView(
                              height: $(172),
                              onTap: (String category, List<DiscoveryListEntity>? posts) {
                                Navigator.of(context).push<bool>(
                                  Right2LeftRouter(
                                    settings: RouteSettings(name: '/HomeDetailsScreen'),
                                    child: HomeDetailsScreen(
                                      posts: posts,
                                      category: category,
                                      source: "home_page",
                                    ),
                                  ),
                                );
                              },
                              onTapItem: (int index) {
                                Navigator.of(context).push<void>(
                                  Right2LeftRouter(
                                    settings: RouteSettings(name: '/HomeDetailScreen'),
                                    child: HomeDetailScreen(
                                      post: _.data!.homepage!.galleries[2]!.socialPosts[index]!,
                                      source: "home_page",
                                    ),
                                  ),
                                );
                              },
                              galleries: _.data?.homepage?.galleries[2],
                            ),
                          ),
                          SliverPadding(padding: EdgeInsets.only(bottom: $(80) + ScreenUtil.getBottomPadding(context)))
                        ],
                      ),
            header(context)
          ],
        );
      },
    ).intoContainer(color: Colors.black);
  }

  Widget header(BuildContext context) => ClipRect(
          child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: navbar(context).intoContainer(color: ColorConstant.BackgroundColorBlur).intoGestureDetector(
              onTap: () {},
            ),
      ));

  Widget navbar(BuildContext context) => Container(
        // margin: EdgeInsets.only(top: $(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppNavigationBar(
              backgroundColor: Colors.transparent,
              showBackItem: false,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).pro,
                    style: TextStyle(fontSize: $(14), color: Color(0xffffffff), fontWeight: FontWeight.w700),
                  )
                      .intoContainer(
                          width: $(45),
                          padding: EdgeInsets.symmetric(vertical: $(4)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular($(6)),
                            gradient: LinearGradient(
                              colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ))
                      .intoGestureDetector(onTap: () {
                    userManager.doOnLogin(context, logPreLoginAction: 'purchase_pro_click', callback: () {
                      PaymentUtils.pay(context, 'home_page');
                    });
                  }),
                ],
              ).intoContainer(margin: EdgeInsets.only(left: $(10))).offstage(offstage: !proVisible),
              middle: TitleTextWidget(S.of(context).home, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
              trailing: Obx(() => BadgeView(
                    type: BadgeType.fill,
                    count: AppDelegate.instance.getManager<MsgManager>().unreadCount.value,
                    child: Image.asset(
                      Images.ic_msg_icon,
                      width: $(26),
                      color: Colors.white,
                    ),
                  )).intoContainer(padding: EdgeInsets.all(4)).intoGestureDetector(onTap: () {
                userManager.doOnLogin(context, logPreLoginAction: 'msg_list_click', callback: () {
                  MsgListScreen.push(context);
                }, autoExec: true);
              }),
            ),
          ],
        ),
      );
}
