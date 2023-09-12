import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/views/ai/avatar/avatar.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'widgets/msg_card.dart';

class MsgSystemList extends StatefulWidget {
  MsgSystemList({
    Key? key,
  }) : super(key: key);

  @override
  MsgSystemListState createState() {
    return MsgSystemListState();
  }
}

class MsgSystemListState extends AppState<MsgSystemList> with AutomaticKeepAliveClientMixin {
  EasyRefreshController refreshController = EasyRefreshController();
  ScrollController scrollController = ScrollController();
  MsgManager msgManager = AppDelegate().getManager();

  int page = 0;
  int pageSize = 20;

  List<MsgEntity> dataList = [];
  late StreamSubscription onUserListener;

  @override
  initState() {
    super.initState();
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
    msgManager.loadMsgList(page: 0, pageSize: pageSize, actions: MsgTab.system.types).then((value) {
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
    msgManager.loadMsgList(page: page + 1, pageSize: pageSize, actions: MsgTab.system.types).then((value) {
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
              return MsgCard(
                data: data,
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

  onMsgClick(MsgListController controller, MsgEntity entity) {
    switch (entity.msgType) {
      case MsgType.ai_avatar_completed:
        controller.readMsg(entity);
        showLoading().whenComplete(() {
          AppDelegate.instance.getManager<AvatarAiManager>().listAllAvatarAi().then((value) {
            hideLoading().whenComplete(() {
              Avatar.open(context, source: 'msgList');
            });
          });
        });
        break;
      case MsgType.like_social_post:
      case MsgType.comment_social_post:
      case MsgType.like_social_post_comment:
      case MsgType.comment_social_post_comment:
      case MsgType.UNDEFINED:
        break;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
