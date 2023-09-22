import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/views/discovery/discovery_detail_screen.dart';
import 'package:cartoonizer/views/discovery/discovery_list_controller.dart';
import 'package:cartoonizer/views/discovery/widget/discovery_list_card.dart';
import 'package:cartoonizer/views/discovery/widget/showReportMenu.dart';
import 'package:cartoonizer/views/discovery/widget/show_report_dialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DiscoveryListPageWidget extends StatefulWidget {
  AppTabId tabId;

  DiscoveryListPageWidget({super.key, required this.tabId});

  @override
  State<DiscoveryListPageWidget> createState() => _DiscoveryListPageWidgetState();
}

class _DiscoveryListPageWidgetState extends State<DiscoveryListPageWidget> with AutomaticKeepAliveClientMixin {
  EasyRefreshController easyRefreshController = EasyRefreshController();
  UserManager userManager = AppDelegate().getManager();
  late AppTabId tabId;

  late StreamSubscription onTabDoubleClickListener;
  late StreamSubscription onSwitchTabListener;
  DiscoveriesController controller = Get.put(DiscoveriesController());

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
  }

  @override
  void dispose() {
    onSwitchTabListener.cancel();
    onTabDoubleClickListener.cancel();
    Get.delete<DiscoveriesController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<DiscoveriesController>(
      builder: (controller) {
        return Column(
          children: [
            buildHeader(controller),
            Expanded(child: buildList(controller)),
          ],
        );
      },
      init: controller,
    );
  }

  Widget buildHeader(DiscoveriesController controller) {
    return Stack(
      children: [
        Listener(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: ClampingScrollPhysics(),
            controller: controller.tagController,
            padding: EdgeInsets.only(left: $(15), right: $(30)),
            child: Row(
              children: controller.tags.transfer((e, index) {
                bool checked = controller.currentTag == e;
                return Text(
                  e.tagTitle(),
                  style: TextStyle(
                    color: checked ? Color(0xff3e60ff) : Colors.white.withOpacity(0.8),
                    fontSize: $(13),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                  ),
                )
                    .intoContainer(
                  margin: EdgeInsets.only(left: index == 0 ? 0 : $(4)),
                  padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(7)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: checked ? Colors.transparent : Color(0xFF37373B),
                    border: Border.all(color: checked ? ColorConstant.DiscoveryBtn : Colors.transparent, width: 1),
                  ),
                )
                    .intoGestureDetector(onTap: () {
                  if (controller.listLoading) {
                    return;
                  }
                  if (controller.currentTag == e) {
                    controller.currentTag = null;
                  } else {
                    controller.currentTag = e;
                  }
                  easyRefreshController.callRefresh();
                });
              }),
            ),
          ).intoContainer(padding: EdgeInsets.only(top: 8)),
          onPointerDown: (details) {
            controller.isTagScrolling = true;
          },
          onPointerCancel: (details) {
            controller.isTagScrolling = false;
          },
          onPointerUp: (details) {
            controller.isTagScrolling = false;
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Image.asset(
            Images.ic_discovery_tag_more,
            width: $(16),
          )
              .intoContainer(
            padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(6)),
            margin: EdgeInsets.only(top: 8),
            color: ColorConstant.BackgroundColor,
          )
              .intoGestureDetector(onTap: () {
            controller.tagController.animateTo(controller.tagController.offset + ScreenUtil.screenSize.width, duration: Duration(milliseconds: 300), curve: Curves.linear);
          }).visibility(visible: !controller.isTagScrolling && !controller.isScrollEnd),
        ),
      ],
    )
        .intoContainer(width: ScreenUtil.screenSize.width, height: $(52), alignment: Alignment.center, padding: EdgeInsets.only(bottom: $(8)))
        .blur()
        .ignore(ignoring: controller.listLoading);
  }

  Widget buildList(DiscoveriesController controller) {
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
        SliverList(
            delegate: SliverChildBuilderDelegate(
          (context, index) {
            var data = controller.dataList[index];
            if (data.data is DiscoveryListEntity) {
              if (data.visible) {
                return Obx(() => DiscoveryListCard(
                      data: data.data! as DiscoveryListEntity,
                      liked: data.liked.value,
                      hasLine: index != 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => DiscoveryDetailScreen(discoveryEntity: data.data!, liked: data.liked.value, prePage: 'discovery'),
                            settings: RouteSettings(name: "/DiscoveryDetailScreen"),
                          ),
                        );
                      },
                      longPressCallback: (details) async {
                        PopmenuUtil.showPopMenu(
                            context,
                            details,
                            LongPressItem(
                                text: S.of(context).Report,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  controller.onLongPressAction(data.data, context);
                                }));
                      },
                      onCommentTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => DiscoveryDetailScreen(discoveryEntity: data.data!, liked: data.liked.value, prePage: 'discovery', autoComment: true),
                            settings: RouteSettings(name: "/DiscoveryDetailScreen"),
                          ),
                        );
                      },
                      onLikeTap: (liked) async {
                        if (userManager.isNeedLogin) {
                          userManager.doOnLogin(context, logPreLoginAction: data.data!.likeId == null ? 'pre_discovery_like' : 'pre_discovery_unlike');
                          return liked;
                        }
                        bool result;
                        controller.likeLocalAddAlready.value = true;
                        if (liked) {
                          data.liked.value = false;
                          data.data!.likes--;
                          result = false;
                          controller.api.discoveryUnLike(data.data!.id, data.data!.likeId!).then((value) {
                            if (value == null) {
                              controller.likeLocalAddAlready.value = false;
                            }
                          });
                        } else {
                          data.liked.value = true;
                          data.data!.likes++;
                          result = true;
                          controller.api.discoveryLike(data.data!.id, source: 'discovery_page', style: getStyle(data.data!)).then((value) {
                            if (value == null) {
                              controller.likeLocalAddAlready.value = false;
                            }
                          });
                        }
                        return result;
                      },
                      ignoreLikeBtn: controller.likeLocalAddAlready.value,
                    ));
              } else {
                return SizedBox.shrink();
              }
            } else {
              return SizedBox.shrink();
            }
          },
          childCount: controller.dataList.length,
        )),
      ],
    );
  }

  String getStyle(
    DiscoveryListEntity discoveryEntity,
  ) {
    var style = discoveryEntity.getStyle(context);
    return style ?? '';
  }

  @override
  bool get wantKeepAlive => true;
}

class DiscoveriesController extends GetxController {
  late AppApi api;
  bool _isTagScrolling = false;

  bool get isTagScrolling => _isTagScrolling;

  set isTagScrolling(bool value) {
    if (_isTagScrolling == value) {
      return;
    }
    _isTagScrolling = value;
    update();
  }

  bool _isScrollEnd = false;

  bool get isScrollEnd => _isScrollEnd;

  set isScrollEnd(bool value) {
    if (_isScrollEnd == value) {
      return;
    }
    _isScrollEnd = value;
    update();
  }

  late ScrollController tagController;

  List<HomeCardType> tags = [
    HomeCardType.stylemorph,
    HomeCardType.imageEdition,
    HomeCardType.lineart,
    HomeCardType.anotherme,
    HomeCardType.txt2img,
    HomeCardType.scribble,
    HomeCardType.cartoonize,
    HomeCardType.ai_avatar,
  ];
  HomeCardType? _currentTag;

  HomeCardType? get currentTag => _currentTag;

  set currentTag(HomeCardType? data) {
    _currentTag = data;
    update();
  }

  int page = 0;
  int pageSize = 10;
  List<ListData> dataList = [];
  bool listLoading = false;

  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onAppStateListener;
  late StreamSubscription onCreateCommentListener;
  late StreamSubscription onDeleteListener;
  late StreamSubscription onNewPostEventListener;
  late StreamSubscription networkListener;
  late TabController tabController;

  late ScrollController scrollController;
  Rx<bool> likeLocalAddAlready = false.obs;

  double lastScrollPos = 0;
  bool lastScrollDown = false;

  @override
  void onInit() {
    super.onInit();
    api = AppApi().bindController(this);
    tagController = ScrollController();
    tagController.addListener(() {
      isScrollEnd = tagController.offset == tagController.position.maxScrollExtent;
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

    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      // Check if the event data is null or true and the list is not loading.
      if (event.data ?? true && !listLoading) {
        // Call the EasyRefresh controller's callRefresh() method to retrieve the latest data from the server.
        onLoadFirstPage();
      } else {
        // Set the likeId property to null for each data item in the data list.
        for (var value in dataList) {
          if (value.data is DiscoveryListEntity) {
            value.data!.likeId = null;
          }
        }
        // Update the view.
        update();
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      // Get the ID and like ID from the event data.
      var id = event.data!.key;
      var likeId = event.data!.value;
      // For each data item in the data list, check if the ID matches the event ID.
      // If so, update the likeId and likes properties, and update the view.
      for (var data in dataList) {
        if (data.data!.id == id) {
          data.data!.likeId = likeId;
          data.liked.value = true;
          if (likeLocalAddAlready.value) {
            likeLocalAddAlready.value = false;
          } else {
            data.data!.likes++;
          }
          update();
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      // For each data item in the data list, check if the ID matches the event ID.
      // If so, set the likeId property to null, decrement the likes property, and update the view.
      for (var data in dataList) {
        if (data.data!.id == event.data) {
          data.data!.likeId = null;
          data.liked.value = false;
          if (likeLocalAddAlready.value) {
            likeLocalAddAlready.value = false;
          } else {
            data.data!.likes--;
          }
          update();
        }
      }
    });

    // When the app state changes, update the view.
    onAppStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      update();
    });

    // If there is 1 comment, loop through the data list and increment the comments property for the data item with the matching ID.
    // Update the view.
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (event.data?.length == 1) {
        for (var value in dataList) {
          if (value.data!.id == event.data![0]) {
            value.data!.comments++;
            break;
          }
        }
        update();
      }
    });

    // Loop through the data list and mark the data item with the matching ID as removed.
    // Update the view.
    onDeleteListener = EventBusHelper().eventBus.on<OnDeleteDiscoveryEvent>().listen((event) {
      for (var value in dataList) {
        if (value.data!.id == event.data) {
          value.data!.removed = true;
          break;
        }
      }
      update();
    });

    // Create an event listener that listens for new post events and calls the onLoadFirstPage() method.
    onNewPostEventListener = EventBusHelper().eventBus.on<OnNewPostEvent>().listen((event) {
      onLoadFirstPage();
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
  void onReady() {
    super.onReady();
    onLoadFirstPage();
  }

  @override
  void dispose() {
    api.unbind();
    tagController.dispose();
    onLoginEventListener.cancel();
    onLikeEventListener.cancel();
    onUnlikeEventListener.cancel();
    onAppStateListener.cancel();
    onCreateCommentListener.cancel();
    onDeleteListener.cancel();
    onNewPostEventListener.cancel();
    networkListener.cancel();
    super.dispose();
  }

  /// This function adds data to the data list.
  Future<void> addToDataList(int page, List<dynamic> list) async {
    for (int i = 0; i < list.length; i++) {
      /// Get the current item in the list and create a new ListData object with a page number
      /// and a reference to the data item.
      var data = list[i];
      dataList.add(ListData(
        page: page,
        data: data,
        liked: data.likeId != null,
        visible: dataList.pick((t) => t.data?.id == data.id) == null,
      ));
    }
  }

  /// This function loads the first page of data.
  /// return noMore
  Future<bool> onLoadFirstPage() async {
    listLoading = true;
    update();
    var value = await api.listDiscovery(
      from: 0,
      pageSize: pageSize,
      sort: DiscoverySort.newest,
      category: currentTag?.value(),
    );
    delay(() {
      listLoading = false;
      update();
    }, milliseconds: 1500);
    if (value != null) {
      Events.discoveryLoading();
      page = 0;
      dataList.clear();
      var list = value.getDataList<DiscoveryListEntity>();
      addToDataList(page, list).whenComplete(() {
        update();
      });
      return list.length != pageSize;
    } else {
      return false;
    }
  }

  Future<bool> onLoadMorePage() async {
    listLoading = true;
    update();
    var value = await api.listDiscovery(
      from: (page + 1) * pageSize,
      pageSize: pageSize,
      sort: DiscoverySort.newest,
      category: currentTag?.value(),
    );
    delay(() {
      listLoading = false;
      update();
    }, milliseconds: 1500);
    if (value == null) {
      return false;
    } else {
      page++;
      var list = value.getDataList<DiscoveryListEntity>();
      addToDataList(page, list).whenComplete(() {
        update();
      });
      return list.length != pageSize;
    }
  }

  void onLongPressAction(DiscoveryListEntity data, BuildContext context) {
    UserManager userManager = AppDelegate.instance.getManager();
    userManager.doOnLogin(context, logPreLoginAction: 'loginNormal', currentPageRoute: '/DiscoveryListScreen', callback: () {
      reportAction(data, context);
    });
  }

  reportAction(DiscoveryListEntity data, BuildContext context) {
    CacheManager manager = CacheManager().getManager();
    UserManager userManager = AppDelegate.instance.getManager();
    final String posts = manager.getString("${CacheManager.reportOfPosts}_${userManager.user?.id}");
    if (posts.contains("${data.id.toString()},")) {
      CommonExtension().showToast(S.of(context).HaveReport, gravity: ToastGravity.CENTER);
      return;
    }
    api.postReport(data.id).then((value) {
      if (posts.isEmpty) {
        manager.setString("${CacheManager.reportOfPosts}_${userManager.user?.id}", "${data.id.toString()},");
      } else {
        manager.setString("${CacheManager.reportOfPosts}_${userManager.user?.id}", "$posts${data.id.toString()},");
      }
      showReportDialog(context);
    });
  }
}
