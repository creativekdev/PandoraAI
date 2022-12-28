import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'discovery_effect_detail_screen.dart';
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
  late StreamSubscription onDeleteListen;
  late CartoonizerApi api;
  int page = 0;
  int size = 20;
  Map<int, List<DiscoveryListEntity>> dataMap = {};
  late int userId;
  late String title;
  late String emptyText;
  late double imgWidth;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    logEvent(Events.user_discovery_loading);
    userId = widget.userId;
    title = widget.title ?? S.of(context).tabDiscovery;
    emptyText = widget.title == null ? 'This user has not posted anything' : 'You have not posted anything';
    api = CartoonizerApi().bindState(this);
    delay(() => _refreshController.callRefresh());
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
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    _refreshController.dispose();
    onDeleteListen.cancel();
  }

  loadFirstPage() => api
          .listDiscovery(
        from: 0,
        pageSize: size,
        userId: userId,
        sort: DiscoverySort.newest,
      )
          .then((value) {
        _refreshController.finishRefresh();
        if (value != null) {
          page = 0;
          var list = value.getDataList<DiscoveryListEntity>();
          dataMap = {};
          addToGroup(list);
          _refreshController.finishLoad(noMore: list.length != size);
        }
      });

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

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(title, ColorConstant.White, FontWeight.w600, $(18)),
        scrollController: scrollController,
      ),
      body: EasyRefresh.custom(
        scrollController: scrollController,
        onRefresh: () async => loadFirstPage(),
        onLoad: () async => loadMorePage(),
        controller: _refreshController,
        enableControlFinishRefresh: true,
        enableControlFinishLoad: false,
        emptyWidget: dataMap.isEmpty ? TitleTextWidget(emptyText, ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
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
                        builder: (BuildContext context) => DiscoveryEffectDetailScreen(discoveryEntity: data),
                        settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
                      ),
                    );
                  },
                );
              },
              childCount: dataMap.length,
            ),
          ),
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
