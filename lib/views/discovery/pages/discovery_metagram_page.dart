import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/socialmedia_connector_api.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_list_controller.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_mg_list_card.dart';
import 'package:cartoonizer/views/social/metagram.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class DiscoveryMetagramPage extends StatefulWidget {
  AppTabId tabId;

  DiscoveryMetagramPage({super.key, required this.tabId});

  @override
  State<DiscoveryMetagramPage> createState() => _DiscoveryMetagramPageState();
}

class _DiscoveryMetagramPageState extends State<DiscoveryMetagramPage> with AutomaticKeepAliveClientMixin {
  EasyRefreshController easyRefreshController = EasyRefreshController();
  late AppTabId tabId;

  late StreamSubscription onTabDoubleClickListener;
  late StreamSubscription onSwitchTabListener;
  DiscoveryMetagramController controller = Get.put(DiscoveryMetagramController());

  @override
  void initState() {
    super.initState();
    tabId = widget.tabId;
    onSwitchTabListener = EventBusHelper().eventBus.on<OnTabSwitchEvent>().listen((event) {
      if ((event.data?.length ?? 0) == 2) {
        if (event.data!.first == tabId.id()) {
          easyRefreshController.callRefresh();
        }
      }
    });
    onTabDoubleClickListener = EventBusHelper().eventBus.on<OnTabDoubleClickEvent>().listen((event) {
      if (tabId.id() == event.data) {
        easyRefreshController.callRefresh();
      }
    });
    delay(() => easyRefreshController.callRefresh());
  }

  @override
  void dispose() {
    onSwitchTabListener.cancel();
    onTabDoubleClickListener.cancel();
    Get.delete<DiscoveryMetagramController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<DiscoveryMetagramController>(
      builder: (controller) {
        return EasyRefresh.custom(
          controller: easyRefreshController,
          scrollController: controller.scrollController,
          enableControlFinishRefresh: true,
          enableControlFinishLoad: false,
          cacheExtent: 1000,
          emptyWidget: controller.dataList.isEmpty ? TitleTextWidget('There are no posts yet', ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
          onRefresh: () async {
            controller.onLoadFirstPage().then((value) {
              easyRefreshController.finishRefresh();
              easyRefreshController.finishLoad(noMore: value);
            });
          },
          onLoad: () async {
            controller.onLoadMorePage().then((value) {
              easyRefreshController.finishLoad(noMore: value);
            });
          },
          slivers: [
            SliverWaterfallFlow(
                gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: $(15),
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var data = controller.dataList[index];
                    if (data.data is SocialPostPageEntity) {
                      return DiscoveryMgListCard(
                        width: (ScreenUtil.screenSize.width - $(45)) / 2,
                        data: data.data! as SocialPostPageEntity,
                        onTap: () {
                          Metagram.open(context, source: 'discovery_page', socialPostPage: data.data!);
                        },
                      ).marginOnly(top: $(15));
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                  childCount: controller.dataList.length,
                )),
          ],
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: 15.dp));
      },
      init: controller,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DiscoveryMetagramController extends GetxController {
  late SocialMediaConnectorApi socialMediaConnectorApi;
  int page = 0;
  int pageSize = 10;
  List<ListData> dataList = [];

  late ScrollController scrollController;
  late StreamSubscription onAppStateListener;
  late StreamSubscription networkListener;

  double lastScrollPos = 0;
  bool lastScrollDown = false;

  @override
  void onInit() {
    super.onInit();
    socialMediaConnectorApi = SocialMediaConnectorApi().bindController(this);
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

    // When the app state changes, update the view.
    onAppStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      update();
    });
    networkListener = EventBusHelper().eventBus.on<OnNetworkStateChangeEvent>().listen((event) {
      if (dataList.isEmpty) {
        if (event.data != ConnectivityResult.none) {
          onLoadFirstPage();
        }
      }
    });
  }

  @override
  void dispose() {
    socialMediaConnectorApi.unbind();
    onAppStateListener.cancel();
    networkListener.cancel();
    super.dispose();
  }

  /// This function adds data to the data list.
  Future<void> addToDataList(int page, List<dynamic> list) async {
    for (int i = 0; i < list.length; i++) {
      /// Get the current item in the list and create a new ListData object with a page number
      /// and a reference to the data item.
      var data = list[i];
      dataList.add(ListData(page: page, data: data, liked: false, visible: true));
    }
  }

  /// This function loads the first page of data.
  /// return noMore
  Future<bool> onLoadFirstPage() async {
    var value = await socialMediaConnectorApi.listAllMetagrams(from: 0, size: pageSize);
    delay(() {
      update();
    }, milliseconds: 1500);
    if (value != null) {
      Events.discoveryLoading();
      page = 0;
      dataList.clear();
      var list = value.getDataList<SocialPostPageEntity>();
      addToDataList(page, list).whenComplete(() {
        update();
      });
      return false;
    } else {
      return false;
    }
  }

  Future<bool> onLoadMorePage() async {
    var value = await socialMediaConnectorApi.listAllMetagrams(from: (page + 1) * pageSize, size: pageSize);
    delay(() {
      update();
    }, milliseconds: 1500);
    if (value == null) {
      return false;
    } else {
      page++;
      var list = value.getDataList<SocialPostPageEntity>();
      addToDataList(page, list).whenComplete(() {
        update();
      });
      return list.length != pageSize;
    }
  }
}
