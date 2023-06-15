import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_detail_screen.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:cartoonizer/views/social/comments/metagram_comments_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'widgets/msg_discovery_card.dart';

class MsgDiscoveryList extends StatefulWidget {
  MsgTab tab;

  MsgDiscoveryList({
    Key? key,
    required this.tab,
  }) : super(key: key);

  @override
  MsgDiscoveryListState createState() {
    return MsgDiscoveryListState();
  }
}

class MsgDiscoveryListState extends AppState<MsgDiscoveryList> with AutomaticKeepAliveClientMixin {
  EasyRefreshController refreshController = EasyRefreshController();
  ScrollController scrollController = ScrollController();

  MsgManager msgManager = AppDelegate().getManager();
  late MsgTab tab;
  int page = 0;
  int pageSize = 20;

  List<MsgDiscoveryEntity> dataList = [];
  late StreamSubscription onUserListener;

  @override
  initState() {
    super.initState();
    tab = widget.tab;
    onUserListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? false) {
        refreshController.callRefresh();
      } else {
        dataList.clear();
        setState(() {});
      }
    });
    delay(() {
      refreshController.callRefresh();
    });
  }

  @override
  void dispose() {
    onUserListener.cancel();
    super.dispose();
  }

  loadFirstPage() {
    msgManager.loadMsgDiscoveryEntity(page: 0, pageSize: pageSize, tab: tab).then((value) {
      refreshController.finishRefresh();
      if (value != null) {
        page = 0;
        dataList = value;
        setState(() {});
        refreshController.finishLoad(noMore: dataList.length != pageSize);
      }
    });
  }

  loadMorePage() {
    msgManager.loadMsgDiscoveryEntity(page: page + 1, pageSize: pageSize, tab: tab).then((value) {
      if (value != null) {
        page++;
        dataList.addAll(value);
        setState(() {});
        refreshController.finishLoad(noMore: dataList.length != pageSize);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return build2(context);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return EasyRefresh.custom(
      scrollController: scrollController,
      controller: refreshController,
      enableControlFinishRefresh: true,
      enableControlFinishLoad: false,
      emptyWidget: dataList.isEmpty
          ? TitleTextWidget(S.of(context).no_messages_yet, ColorConstant.White, FontWeight.normal, $(16))
              .intoContainer(height: ScreenUtil.getCurrentWidgetSize(context).height, alignment: Alignment.center)
          : null,
      onRefresh: () async => loadFirstPage(),
      onLoad: () async => loadMorePage(),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              var data = dataList[index];
              return MsgDiscoveryCard(
                data: data,
                tab: tab,
                onTap: () {
                  onMsgClick(Get.find<MsgListController>(), data);
                },
              );
            },
            childCount: dataList.length,
          ),
        ),
      ],
    );
  }

  onMsgClick(MsgListController controller, MsgDiscoveryEntity entity) {
    showLoading().whenComplete(() {
      controller.api
          .getDiscoveryDetail(
        entity.getPostId(),
        needRetry: false,
      )
          .then((value) {
        if (value != null) {
          if (value.socialPostPageId == null) {
            hideLoading().whenComplete(() {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DiscoveryDetailScreen(
                    discoveryEntity: value,
                    prePage: 'msg_page',
                  ),
                  settings: RouteSettings(name: "/DiscoveryDetailScreen"),
                ),
              );
            });
          } else {
            controller.api.getMetagramItem(entity.getPostId(), needRetry: false).then((value) {
              hideLoading().whenComplete(() {
                if (value != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    settings: RouteSettings(name: "/MetagramCommentsScreen"),
                    builder: (context) => MetagramCommentsScreen(
                      data: value,
                    ),
                  ));
                }
              });
            });
          }
        }
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}
