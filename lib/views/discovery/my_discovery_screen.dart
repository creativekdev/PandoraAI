import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/views/discovery/discovery_detail_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:skeletons/skeletons.dart';

import 'widget/my_discovery_list_card.dart';

class MyDiscoveryScreen extends StatefulWidget {
  int userId;
  String? title;

  MyDiscoveryScreen({
    Key? key,
    required this.userId,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyDiscoveryState();
  }
}

class MyDiscoveryState extends AppState<MyDiscoveryScreen> {
  EasyRefreshController _refreshController = EasyRefreshController();
  UserManager userManager = AppDelegate.instance.getManager();
  late CartoonizerApi api;
  int page = 0;
  int size = 20;
  Map<int, List<DiscoveryListEntity>> dataMap = {};
  late int userId;
  String title = '';
  String emptyText = '';
  late double imgWidth;
  ScrollController scrollController = ScrollController();

  late StreamSubscription onDeleteListen;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onCreateCommentListener;
  bool listLoading = false;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    Posthog().screenWithUser(screenName: 'user_discovery_list_screen');
    delay(() {
      setState(() {
        title = widget.title ?? S.of(context).tabDiscovery;
        emptyText = widget.title == null ? S.of(context).this_user_has_not_posted_anything : S.of(context).you_have_not_posted_anything;
      });
    });
    api = CartoonizerApi().bindState(this);
    delay(() => loadFirstPage());
    imgWidth = (ScreenUtil.screenSize.width - $(90)) / 3;
    onDeleteListen = EventBusHelper().eventBus.on<OnDeleteDiscoveryEvent>().listen((event) {
      bool find = false;
      for (var value in dataMap.values) {
        if (find) {
          break;
        }
        for (var element in value) {
          if (element.id == event.data) {
            element.removed = true;
            find = true;
            break;
          }
        }
      }
      setState(() {});
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      // Get the ID and like ID from the event data.
      var id = event.data!.key;
      var likeId = event.data!.value;
      // For each data item in the data list, check if the ID matches the event ID.
      // If so, update the likeId and likes properties, and update the view.
      for (var value in dataMap.values) {
        for (var data in value) {
          if (data.id == id) {
            data.likeId = likeId;
            data.likes++;
            setState(() {});
          }
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      // For each data item in the data list, check if the ID matches the event ID.
      // If so, set the likeId property to null, decrement the likes property, and update the view.
      for (var value in dataMap.values) {
        for (var data in value) {
          if (data.id == event.data) {
            data.likeId = null;
            data.likes--;
            setState(() {});
          }
        }
      }
    });
    // If there is 1 comment, loop through the data list and increment the comments property for the data item with the matching ID.
    // Update the view.
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (event.data?.length == 1) {
        for (var value in dataMap.values) {
          for (var data in value) {
            if (data.id == event.data![0]) {
              data.comments++;
              break;
            }
          }
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    api.unbind();
    _refreshController.dispose();
    onDeleteListen.cancel();
    onLikeEventListener.cancel();
    onUnlikeEventListener.cancel();
    onCreateCommentListener.cancel();
    super.dispose();
  }

  loadFirstPage() {
    setState(() {
      listLoading = true;
    });
    api
        .listDiscovery(
      from: 0,
      pageSize: size,
      userId: userId,
      sort: DiscoverySort.newest,
    )
        .then((value) {
      _refreshController.finishRefresh();
      setState(() {
        listLoading = false;
      });
      if (value != null) {
        page = 0;
        var list = value.getDataList<DiscoveryListEntity>();
        dataMap = {};
        addToGroup(list);
        _refreshController.finishLoad(noMore: list.length != size);
      }
    });
  }

  loadMorePage() => api
          .listDiscovery(
        from: (page + 1) * size,
        pageSize: size,
        userId: userId,
        sort: DiscoverySort.newest,
      )
          .then((value) {
        if (value == null) {
          _refreshController.finishLoad(noMore: false);
        } else {
          page++;
          var list = value.getDataList<DiscoveryListEntity>();
          addToGroup(list);
          _refreshController.finishLoad(noMore: list.length != size);
        }
      });

  addToGroup(List<DiscoveryListEntity> discoveryList) {
    for (var value in discoveryList) {
      var dateTime = DateUtil.getDateTime(value.created);
      if (dateTime == null) {
        continue;
      }
      int month = dateTime.month;
      int year = dateTime.year;
      int key = year * 100 + month;
      var list = dataMap[key];
      if (list == null) {
        dataMap[key] = [];
        list = dataMap[key];
      }
      list!.add(value);
    }
    setState(() {});
  }

  Widget skeletons() {
    return SkeletonListView(
      itemCount: 3,
      item: SkeletonItem(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonAvatar(
            style: SkeletonAvatarStyle(width: $(52), height: $(34)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Wrap(
              runSpacing: $(5),
              spacing: $(5),
              children: [1, 1, 1, 1, 1]
                  .map((e) => SkeletonAvatar(
                        style: SkeletonAvatarStyle(width: imgWidth - $(8), height: imgWidth - $(8)),
                      ))
                  .toList(),
            ).intoContainer(margin: EdgeInsets.only(top: $(40))),
          )
        ],
      )).intoContainer(margin: EdgeInsets.only(top: $(12))),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(title, ColorConstant.White, FontWeight.w600, $(18)),
        scrollController: scrollController,
      ),
      body: Stack(
        children: [
          EasyRefresh.custom(
            scrollController: scrollController,
            onRefresh: () async => loadFirstPage(),
            onLoad: () async => loadMorePage(),
            controller: _refreshController,
            enableControlFinishRefresh: true,
            enableControlFinishLoad: false,
            emptyWidget: !listLoading && dataMap.isEmpty ? TitleTextWidget(emptyText, ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var keyValue = pickItem(index);
                    bool hasYear = false;
                    if (index != 0) {
                      var lasKeyValue = pickItem(index - 1);
                      if (!lasKeyValue.key.isSameYear(keyValue.key)) {
                        hasYear = true;
                      }
                    }
                    return MyDiscoveryListCard(
                      hasYear: hasYear,
                      time: keyValue.key,
                      dataList: keyValue.value,
                      imgWidth: imgWidth,
                      onItemClick: (data) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => DiscoveryDetailScreen(discoveryEntity: data, prePage: 'my-discovery'),
                            settings: RouteSettings(name: "/DiscoveryDetailScreen"),
                          ),
                        );
                      },
                    ).intoContainer(margin: EdgeInsets.only(top: index == 0 ? $(15) : 0));
                  },
                  childCount: dataMap.length,
                ),
              ),
            ],
          ),
          skeletons()
              .intoContainer(
                height: ScreenUtil.screenSize.height - $(55) - ScreenUtil.getStatusBarHeight(),
              )
              .offstage(offstage: !listLoading || !dataMap.isEmpty),
        ],
      ),
    );
  }

  MapEntry<int, List<DiscoveryListEntity>> pickItem(int index) {
    var list = dataMap.keys.toList();
    int key = list[index];
    return MapEntry(key, dataMap[key]!);
  }
}
