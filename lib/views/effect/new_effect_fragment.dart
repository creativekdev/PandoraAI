import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/badge.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/views/PurchaseScreen.dart';
import 'package:cartoonizer/views/StripeSubscriptionScreen.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/avatar/avatar.dart';
import 'package:cartoonizer/views/effect/effect_tab_state.dart';
import 'package:cartoonizer/views/msg/msg_list_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:cartoonizer/views/transfer/ChoosePhotoScreen.dart';

class NewEffectFragment extends StatefulWidget {
  AppTabId tabId;

  NewEffectFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<NewEffectFragment> createState() => NewEffectFragmentState();
}

class NewEffectFragmentState extends State<NewEffectFragment> with AppTabState, EffectTabState {
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
        if (_.loading) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (_.data == null) {
            return FutureBuilder(
                future: getConnectionStatus(),
                builder: (context, snapshot1) {
                  return Center(
                    child: TitleTextWidget((snapshot1.hasData && (snapshot1.data as bool)) ? S.of(context).empty_msg : S.of(context).no_internet_msg, ColorConstant.BtnTextColor,
                        FontWeight.w400, 12.sp),
                  ).intoGestureDetector(onTap: () {
                    _.loadData();
                    userManager.refreshUser();
                  });
                });
          } else {
            var list = _.data?.homeCards ?? [];
            return Stack(
              children: [
                ListView.builder(
                  padding: EdgeInsets.only(
                    top: 55 + ScreenUtil.getStatusBarHeight(),
                    bottom: ScreenUtil.getBottomPadding(context) + 70,
                  ),
                  itemBuilder: (context, index) {
                    var config = list[index];
                    var type = HomeCardTypeUtils.build(config.type);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TitleTextWidget(
                                type.title(),
                                ColorConstant.White,
                                FontWeight.w500,
                                $(17),
                                align: TextAlign.start,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white,
                              size: $(22),
                            ),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                        ).intoContainer(padding: EdgeInsets.only(left: $(15), right: $(8), bottom: $(8), top: $(18))),
                        ClipRRect(
                          child: CachedNetworkImageUtils.custom(
                            context: context,
                            useOld: true,
                            imageUrl: config.url,
                            fit: BoxFit.cover,
                            width: double.maxFinite,
                            placeholder: (context, url) => CircularProgressIndicator()
                                .intoContainer(
                                  width: $(25),
                                  height: $(25),
                                )
                                .intoCenter()
                                .intoContainer(
                                  width: double.maxFinite,
                                  height: $(150),
                                ),
                          ),
                          borderRadius: BorderRadius.circular($(8)),
                        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                      ],
                    ).intoGestureDetector(onTap: () {
                      switch (type) {
                        case HomeCardType.cartoonize:
                          Events.facetoonLoading(source: 'home_page');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: "/ChoosePhotoScreen"),
                              builder: (context) => ChoosePhotoScreen(
                                tabPos: 0,
                                pos: 0,
                                itemPos: 0,
                              ),
                            ),
                          ).then((value) {
                            userManager.refreshUser();
                          });
                          break;
                        case HomeCardType.anotherme:
                          AnotherMe.checkPermissions().then((value) {
                            if (value) {
                              AnotherMe.open(context, source: 'home_page');
                            } else {
                              showPhotoLibraryPermissionDialog(context);
                            }
                          });
                          break;
                        case HomeCardType.ai_avatar:
                          Avatar.openFromHome(context);
                          break;
                        case HomeCardType.UNDEFINED:
                          break;
                      }
                    });
                  },
                  itemCount: list.length ?? 0,
                ),
                header(context),
              ],
            );
          }
        }
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/MsgListScreen"),
                      builder: (context) => MsgListScreen(),
                    ),
                  );
                }, autoExec: true);
              }),
            ),
          ],
        ),
      );

  Future<bool> getConnectionStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return (connectivityResult != ConnectivityResult.none);
  }
}
