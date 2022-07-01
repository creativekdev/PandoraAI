import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/refresh/headers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_list_card.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class UserDiscoveryScreen extends StatefulWidget {
  int userId;
  String? title;

  UserDiscoveryScreen({
    Key? key,
    required this.userId,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserDiscoveryState();
  }
}

class UserDiscoveryState extends AppState<UserDiscoveryScreen> {
  late int userId;
  late String title;
  late String emptyText;
  UserManager userManager = AppDelegate.instance.getManager();
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  int page = 0;
  int pageSize = 10;
  late CartoonizerApi api;
  List<DiscoveryListEntity> dataList = [];
  Size? navbarSize;

  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;

  @override
  void initState() {
    super.initState();
    logEvent(Events.user_discovery_loading);
    userId = widget.userId;
    title = widget.title ?? StringConstant.tabDiscovery;
    emptyText = widget.title == null ? 'This user has not posted anything' : 'You have not posted anything';
    api = CartoonizerApi().bindState(this);
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
    delay(() {
      _easyRefreshController.callRefresh();
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

  onLoadFirstPage() => api
          .listDiscovery(
        page: 0,
        pageSize: pageSize,
        userId: userId,
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
        userId: userId,
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

  _onLikeTap(DiscoveryListEntity entity) => showLoading().whenComplete(() {
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
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          EasyRefresh(
            header: CartoonizerMaterialHeader(),
            controller: _easyRefreshController,
            enableControlFinishRefresh: true,
            enableControlFinishLoad: false,
            emptyWidget: dataList.isEmpty ? TitleTextWidget(emptyText, ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
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
                width: (ScreenUtil.screenSize.width - $(38)) / 2,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => DiscoveryEffectDetailScreen(data: dataList[index]),
                    settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
                  ),
                ),
                onLikeTap: () {
                  userManager.doOnLogin(context, callback: () {
                    _onLikeTap(dataList[index]);
                  }, autoExec: false);
                },
              ).intoContainer(margin: EdgeInsets.only(top: index < 2 ? ((navbarSize?.height ?? 70) + $(10)) : 0)),
              itemCount: dataList.length,
            ),
          ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
          navbar(context),
        ],
      ),
    );
  }

  Widget navbar(BuildContext context) => ClipRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppNavigationBar(
                    blurAble: true,
                    backgroundColor: ColorConstant.BackgroundColorBlur,
                    middle: TitleTextWidget(
                      title,
                      ColorConstant.BtnTextColor,
                      FontWeight.w600,
                      $(18),
                    )).listenSizeChanged(onSizeChanged: (size) {
                  setState(() => navbarSize = size);
                }),
              ],
            )),
      );
}