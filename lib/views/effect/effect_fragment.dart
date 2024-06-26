import 'dart:ui';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/effect_data_controller.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/home_item.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/home_page_entity.dart';
import 'package:cartoonizer/views/ai/edition/image_edition.dart';
import 'package:cartoonizer/views/home_new/pai_content_facetoon_view.dart';
import 'package:cartoonizer/views/home_new/pai_home_ads_view.dart';
import 'package:cartoonizer/views/msg/msg_list_screen.dart';
import 'package:cartoonizer/views/payment/payment.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/badge.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/widgets/tabbar/app_tab_bar.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

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

class EffectFragmentState extends State<EffectFragment> with AppTabState, SingleTickerProviderStateMixin {
  final Connectivity _connectivity = Connectivity();
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdPartManager = AppDelegate().getManager();
  EffectDataController dataController = Get.find();
  late AppTabId tabId;
  late StreamSubscription onUserStateChangeListener;
  late StreamSubscription onUserLoginListener;
  bool proVisible = false;

  late ScrollController scrollController;
  double lastScrollPos = 0;
  bool lastScrollDown = false;

  late AnimationController animationController;
  late StreamSubscription onHomeScrollListener;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'home_fragment');
    tabId = widget.tabId;
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    onHomeScrollListener = EventBusHelper().eventBus.on<OnHomeScrollEvent>().listen((event) {
      var scrollDown = event.data;
      if (scrollDown == null || !mounted) {
        return;
      }
      if (scrollDown) {
        animationController.forward();
      } else if (!scrollDown) {
        animationController.reverse();
      }
    });
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
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.positions.isEmpty) {
        return;
      }
      if (scrollController.positions.length != 1) {
        return;
      }
      var newPos = scrollController.position.pixels;
      if (newPos < 0) {
        return;
      }
      if (newPos - lastScrollPos > 0) {
        if (!lastScrollDown) {
          lastScrollDown = true;
          EventBusHelper().eventBus.fire(OnHomeScrollEvent(data: lastScrollDown));
        }
      } else {
        if (lastScrollDown) {
          lastScrollDown = false;
          EventBusHelper().eventBus.fire(OnHomeScrollEvent(data: lastScrollDown));
        }
      }
      lastScrollPos = newPos;
    });
    refreshProVisible();
  }

  @override
  void dispose() {
    onHomeScrollListener.cancel();
    onUserLoginListener.cancel();
    onUserStateChangeListener.cancel();
    scrollController.dispose();
    animationController.dispose();
    super.dispose();
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
                        builder: (context, snapshot1) => Center(
                              child: TitleTextWidget((snapshot1.hasData && (snapshot1.data as bool)) ? S.of(context).empty_msg : S.of(context).no_internet_msg,
                                  ColorConstant.BtnTextColor, FontWeight.w400, 12.sp),
                            ).intoGestureDetector(onTap: () {
                              _.loadData();
                              userManager.refreshUser();
                            }))
                    : buildList(_.data!.homepage, _.data!.locale),
            header(context),
            addWidget(context),
          ],
        );
      },
    ).intoContainer(color: Colors.black);
  }

  Widget buildList(List<HomeItemEntity> homepage, Map<String, dynamic> locale) {
    return CustomScrollView(
      physics: ClampingScrollPhysics(),
      controller: scrollController,
      slivers: [
        SliverPadding(padding: EdgeInsets.only(top: kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight())),
        ...homepage.map((data) {
          switch (data.mHomeItem) {
            case HomeItem.ad:
              return SliverToBoxAdapter(
                child: PaiHomeAdsView(
                    data: data,
                    width: ScreenUtil.screenSize.width - 30.dp,
                    onTap: (data) {
                      HomeCardTypeUtils.jump(context: context, source: 'home_page_ads_${data.category.value()}', data: data);
                    }).intoContainer(padding: EdgeInsets.symmetric(horizontal: 15.dp), margin: EdgeInsets.only(top: 12.dp)),
              );
            case HomeItem.list:
              String title = locale["app_home"][data.key] ?? data.key?.localeValue(locale) ?? '';
              return SliverToBoxAdapter(
                child: PaiContentView(
                  height: 172.dp,
                  title: title,
                  onTap: (String category, List<DiscoveryListEntity>? posts, String title) {
                    Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        settings: RouteSettings(name: '/HomeDetailsScreen'),
                        builder: (context) => HomeDetailsScreen(
                          posts: posts,
                          category: category,
                          source: "home_page",
                          title: title,
                          records: data.records,
                        ),
                      ),
                    );
                  },
                  onTapItem: (int index, String category, List<DiscoveryListEntity>? posts, String title) {
                    Navigator.of(context).push<void>(MaterialPageRoute(
                        settings: RouteSettings(name: '/HomeDetailScreen'),
                        builder: (context) => HomeDetailScreen(
                              posts: posts!,
                              source: "home_page",
                              title: category,
                              index: index,
                              titleName: title,
                              records: data.records,
                            )));
                  },
                  data: data,
                ).intoContainer(margin: EdgeInsets.only(top: 12.dp)),
              );
            case HomeItem.banner:
              var banners = data.getDataList<DiscoveryListEntity>();
              return SliverToBoxAdapter(
                child: PaiSwiper(
                  entity: banners,
                  onClickItem: (index, data) {
                    HomeCardTypeUtils.jump(context: context, source: 'home_page_banner_${data.category.value()}', data: data);
                  },
                ).intoContainer(margin: EdgeInsets.only(top: 12.dp)),
              );
            case HomeItem.tool:
              var tools = data.getDataList<HomePageHomepageTools>();
              for (var element in tools) {
                element.title = element.categoryString?.localeValue(locale) ?? '';
              }
              return SliverToBoxAdapter(
                child: PaiSliverView(
                  list: tools,
                  onClickItem: (data) {
                    HomeCardTypeUtils.jump(context: context, source: 'home_page_tools_${data.category.value()}', homeData: data);
                  },
                ).intoContainer(margin: EdgeInsets.only(top: 12.dp)),
              );
            case HomeItem.feature:
              return SliverToBoxAdapter(
                child: PaiRecommendView(
                  data: data,
                  locale: locale,
                  onClickItem: (data) {
                    HomeCardTypeUtils.jump(context: context, source: 'home_page_recommend_${data.category.value()}', homeData: data);
                  },
                ).intoContainer(margin: EdgeInsets.only(top: 12.dp)),
              );
            case HomeItem.gallery:
              String title = locale["app_home"][data.key] ?? data.key?.localeValue(locale) ?? '';
              return SliverToBoxAdapter(
                child: PaiContentFacetoonView(
                  height: ScreenUtil.screenSize.width,
                  width: ScreenUtil.screenSize.width,
                  title: title,
                  data: data,
                  onAllTap: (String category, List<DiscoveryListEntity>? posts, String title) {
                    Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        settings: RouteSettings(name: '/HomeDetailsScreen'),
                        builder: (context) => HomeDetailsScreen(
                          posts: posts,
                          category: category,
                          source: "home_page",
                          title: title,
                          records: data.records,
                          skipDetail: true,
                        ),
                      ),
                    );
                  },
                  onTapItem: (int index, String category, List<DiscoveryListEntity>? posts, String title) {
                    HomeCardTypeUtils.jump(context: context, source: "home_page_$category", data: posts![index]);
                  },
                ).intoContainer(margin: EdgeInsets.only(top: 12.dp)),
              );
            case HomeItem.UNDEFINED:
              return SliverToBoxAdapter(child: SizedBox.shrink());
          }
        }).toList(),
        SliverPadding(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding() + 15.dp)),
      ],
    );
  }

  Widget header(BuildContext context) => ClipRect(
          child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: navbar(context).intoContainer(color: ColorConstant.BackgroundColorBlur).intoGestureDetector(onTap: () {}),
      ));

  Widget navbar(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TitleTextWidget(S.of(context).home, ColorConstant.BtnTextColor, FontWeight.bold, 20.sp),
              Expanded(child: Container()),
              Obx(() => BadgeView(
                    type: BadgeType.fill,
                    count: AppDelegate.instance.getManager<MsgManager>().unreadCount.value,
                    child: Image.asset(
                      Images.ic_msg_icon,
                      width: 26.sp,
                      color: Colors.white,
                    ),
                  )).intoContainer(padding: EdgeInsets.all(2), margin: EdgeInsets.only(right: 12.dp)).intoGestureDetector(onTap: () {
                userManager.doOnLogin(context, logPreLoginAction: 'msg_list_click', callback: () {
                  MsgListScreen.push(context);
                }, autoExec: true);
              }),
              Text(
                S.of(context).pro,
                style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600),
              )
                  .intoContainer(
                      width: 55.dp,
                      padding: EdgeInsets.symmetric(vertical: 4.dp),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 15.dp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32.dp),
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
          ).intoContainer(padding: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight(), left: 15.dp, bottom: 4.dp))
        ],
      );

  Widget addWidget(BuildContext context) => Align(
        child: AnimatedBuilder(
            animation: animationController!,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (58.dp + ScreenUtil.getBottomPadding() + AppTabBarHeight) * (animationController?.value ?? 0) + 1),
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    Image.asset(
                      Images.ic_home_add,
                      color: Color.fromARGB(250, 14, 16, 17),
                      width: 60.dp,
                      height: 58.dp,
                    ),
                    Positioned(
                      child: Image.asset(Images.ic_home_add_child, width: 44.dp),
                      left: 8.dp,
                      right: 8.dp,
                      top: 8.dp,
                    ),
                  ],
                )
                    .intoContainer(
                  margin: EdgeInsets.only(bottom: AppTabBarHeight + ScreenUtil.getBottomPadding()),
                )
                    .intoGestureDetector(onTap: () {
                  ImageEdition.open(context, source: 'home_add_btn', style: EffectStyle.All, function: ImageEditionFunction.effect, cardType: HomeCardType.imageEdition);
                }),
              );
            }),
        alignment: Alignment.bottomCenter,
      );
}
