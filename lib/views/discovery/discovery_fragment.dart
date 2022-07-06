import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache_manager.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'widget/discovery_list_card.dart';

class DiscoveryFragment extends StatefulWidget {
  AppTabId tabId;

  DiscoveryFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryFragmentState();
}

class DiscoveryFragmentState extends AppState<DiscoveryFragment> with AutomaticKeepAliveClientMixin, AppTabState {
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  UserManager userManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  int page = 0;
  int pageSize = 10;
  late CartoonizerApi api;
  List<DiscoveryListEntity> dataList = [];
  Size? navbarSize;
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late AppTabId tabId;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    tabId = widget.tabId;
    delay(() {
      _easyRefreshController.callRefresh();
    });
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? true) {
        _easyRefreshController.callRefresh();
      } else {
        for (var value in dataList) {
          value.likeId = null;
        }
        setState(() {});
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      var id = event.data!.key;
      var likeId = event.data!.value;
      for (var data in dataList) {
        if (data.id == id) {
          data.likeId = likeId;
          data.likes++;
          setState(() {});
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      for (var data in dataList) {
        if (data.id == event.data) {
          data.likeId = null;
          data.likes--;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    _easyRefreshController.dispose();
    onLoginEventListener.cancel();
    onLikeEventListener.cancel();
    onUnlikeEventListener.cancel();
  }

  @override
  void onAttached() {
    super.onAttached();
    userManager.refreshUser();
    var lastTime = cacheManager.getInt('${CacheManager.keyLastTabAttached}_${tabId.id()}');
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastTime > 5000) {
      logEvent(Events.tab_discovery_loading);
    }
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${tabId.id()}', currentTime);
  }

  onLoadFirstPage() => api
          .listDiscovery(
        page: 0,
        pageSize: pageSize,
      )
          .then((value) {
        _easyRefreshController.finishRefresh();
        if (value != null) {
          page = 0;
          var list = value.getDataList<DiscoveryListEntity>();
          setState(() {
            dataList = list;
          });
        }
        _easyRefreshController.finishLoad(noMore: dataList.length != pageSize);
      });

  onLoadMorePage() => api
          .listDiscovery(
        page: page + 1,
        pageSize: pageSize,
      )
          .then((value) {
        if (value == null) {
          _easyRefreshController.finishLoad(noMore: false);
        } else {
          page++;
          var list = value.getDataList<DiscoveryListEntity>();
          setState(() {
            dataList.addAll(list);
          });
          _easyRefreshController.finishLoad(noMore: list.length != pageSize);
        }
      });

  onLikeTap(DiscoveryListEntity entity) => showLoading().whenComplete(() {
        if (entity.likeId == null) {
          api.discoveryLike(entity.id).then((value) {
            hideLoading();
          });
        } else {
          api.discoveryUnLike(entity.id, entity.likeId!).then((value) {
            hideLoading();
          });
        }
      });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return build2(context);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
          showBackItem: false,
          blurAble: true,
          backgroundColor: ColorConstant.BackgroundColorBlur,
          middle: TitleTextWidget(
            StringConstant.tabDiscovery,
            ColorConstant.BtnTextColor,
            FontWeight.w600,
            $(18),
          )),
      body: EasyRefresh(
        controller: _easyRefreshController,
        enableControlFinishRefresh: true,
        enableControlFinishLoad: false,
        emptyWidget: dataList.isEmpty ? TitleTextWidget('Don\'t found any Discovery yet', ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
        onRefresh: () async => onLoadFirstPage(),
        onLoad: () async => onLoadMorePage(),
        child: WaterfallFlow.builder(
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: $(8),
            mainAxisSpacing: $(8),
          ),
          itemBuilder: (context, index) => DiscoveryListCard(
            data: dataList[index],
            width: (ScreenUtil.screenSize.width-$(36))/2,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => DiscoveryEffectDetailScreen(data: dataList[index]),
                settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
              ),
            ),
            onLikeTap: () {
              userManager.doOnLogin(context, callback: () {
                onLikeTap(dataList[index]);
              }, autoExec: false);
            },
          ).intoContainer(margin: EdgeInsets.only(top: $(index < 2 ? 10 : 0))),
          itemCount: dataList.length,
        ),
      ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
    );
  }

  Widget navbar(BuildContext context) => ClipRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppNavigationBar(
                    showBackItem: false,
                    blurAble: true,
                    backgroundColor: ColorConstant.BackgroundColorBlur,
                    middle: TitleTextWidget(
                      StringConstant.tabDiscovery,
                      ColorConstant.BtnTextColor,
                      FontWeight.w600,
                      $(18),
                    )).listenSizeChanged(onSizeChanged: (size) {
                  setState(() => navbarSize = size);
                }),
              ],
            )),
      );

  @override
  bool get wantKeepAlive => true;
}
