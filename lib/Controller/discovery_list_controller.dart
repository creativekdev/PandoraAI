import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/views/discovery/discovery_fragment.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class DiscoveryListController extends GetxController {
  TickerProviderStateMixin ticker;
  AppTabId tabId;

  DiscoveryListController({
    required this.ticker,
    required this.tabId,
  });

  EasyRefreshController easyRefreshController = EasyRefreshController();
  late List<DiscoveryFilterTab> tabList = [
    DiscoveryFilterTab(sort: DiscoverySort.newest, title: 'Newest'),
    DiscoveryFilterTab(sort: DiscoverySort.likes, title: 'Popular'),
  ];
  late DiscoveryFilterTab currentTab;
  late CartoonizerApi api;

  int page = 0;
  int pageSize = 10;

  List<ListData> dataList = [];
  bool listLoading = false;

  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onAppStateListener;
  late StreamSubscription onTabDoubleClickListener;
  late StreamSubscription onCreateCommentListener;
  late StreamSubscription onDeleteListener;
  late StreamSubscription onNsfwChangeListener;
  late StreamSubscription onNewPostEventListener;
  late TabController tabController;

  // late CardAdsMap cardAdsMap;
  double cardWidth = 150;
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    api = CartoonizerApi().bindController(this);
    tabController = TabController(length: tabList.length, vsync: ticker);
    currentTab = tabList[0];
    cardWidth = (ScreenUtil.screenSize.width - $(38)) / 2;
    scrollController = ScrollController();
    onNsfwChangeListener = EventBusHelper().eventBus.on<OnEffectNsfwChangeEvent>().listen((event) {
      update();
    });
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? true && !listLoading) {
        easyRefreshController.callRefresh();
      } else {
        for (var value in dataList) {
          if (!value.isAd) {
            value.data!.likeId = null;
          }
        }
        update();
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      var id = event.data!.key;
      var likeId = event.data!.value;
      for (var data in dataList) {
        if (!data.isAd) {
          if (data.data!.id == id) {
            data.data!.likeId = likeId;
            data.data!.likes++;
            update();
          }
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      for (var data in dataList) {
        if (!data.isAd) {
          if (data.data!.id == event.data) {
            data.data!.likeId = null;
            data.data!.likes--;
            update();
          }
        }
      }
    });
    onAppStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      update();
    });
    onTabDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (tabId.id() == event.data && !listLoading) {
        easyRefreshController.callRefresh();
      }
    });
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (event.data?.length == 1) {
        for (var value in dataList) {
          if (!value.isAd) {
            if (value.data!.id == event.data![0]) {
              value.data!.comments++;
              break;
            }
          }
        }
        update();
      }
    });
    onDeleteListener = EventBusHelper().eventBus.on<OnDeleteDiscoveryEvent>().listen((event) {
      for (var value in dataList) {
        if (!value.isAd && value.data!.id == event.data) {
          value.data!.removed = true;
          break;
        }
      }
      update();
    });
    onNewPostEventListener = EventBusHelper().eventBus.on<OnNewPostEvent>().listen((event) {
      onLoadFirstPage();
    });
    // cardAdsMap = CardAdsMap(
    //   width: cardWidth,
    //   onUpdated: () {
    //     update();
    //   },
    //   scale: 1,
    // );
    // cardAdsMap.init();
  }

  @override
  void onReady() {
    super.onReady();
    onLoadFirstPage();
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    easyRefreshController.dispose();
    onLoginEventListener.cancel();
    onLikeEventListener.cancel();
    onUnlikeEventListener.cancel();
    onAppStateListener.cancel();
    onTabDoubleClickListener.cancel();
    onCreateCommentListener.cancel();
    onDeleteListener.cancel();
    onNsfwChangeListener.cancel();
    onNewPostEventListener.cancel();
    // cardAdsMap.dispose();
  }

  Future<void> addToDataList(int page, List<DiscoveryListEntity> list) async {
    // if (!cardAdsMap.hasAdHolder(page + 1)) {
    //   cardAdsMap.addAdsCard(page + 1);
    // }
    for (int i = 0; i < list.length; i++) {
      var data = list[i];
      dataList.add(ListData(
        page: page,
        data: data,
        visible: dataList.pick((t) => t.data?.id == data.id) == null,
      ));
      if (i == 4) {
        dataList.add(ListData(isAd: true, page: page));
      }
    }
  }

  onLoadFirstPage() {
    listLoading = true;
    update();
    // cardAdsMap.init();
    api
        .listDiscovery(
      from: 0,
      pageSize: pageSize,
      sort: currentTab.sort,
    )
        .then((value) {
      delay(() {
        listLoading = false;
        update();
      }, milliseconds: 1000);
      easyRefreshController.finishRefresh();
      if (value != null) {
        page = 0;
        dataList.clear();
        var list = value.getDataList<DiscoveryListEntity>();
        addToDataList(page, list).whenComplete(() {
          update();
        });
        easyRefreshController.finishLoad(noMore: list.length != pageSize);
      }
    });
  }

  onLoadMorePage() {
    listLoading = true;
    update();
    api
        .listDiscovery(
      from: (page + 1) * pageSize,
      pageSize: pageSize,
      sort: currentTab.sort,
    )
        .then((value) {
      delay(() {
        listLoading = false;
        update();
      }, milliseconds: 1500);
      if (value == null) {
        easyRefreshController.finishLoad(noMore: false);
      } else {
        page++;
        var list = value.getDataList<DiscoveryListEntity>();
        addToDataList(page, list).whenComplete(() {
          update();
        });
        easyRefreshController.finishLoad(noMore: list.length != pageSize);
      }
    });
  }

  onTabClick(index) {
    if (listLoading) {
      return;
    }
    currentTab = tabList[index];
    easyRefreshController.callRefresh();
  }
}

class ListData {
  bool isAd;
  int page;
  DiscoveryListEntity? data;
  bool visible;

  ListData({
    this.isAd = false,
    this.data,
    required this.page,
    this.visible = true,
  });
}
