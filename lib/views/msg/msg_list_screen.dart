import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/views/ai/avatar/avatar.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:cartoonizer/views/msg/msg_card.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class MsgListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MsgListState();
  }
}

class MsgListState extends AppState<MsgListScreen> {
  EasyRefreshController _refreshController = EasyRefreshController();
  MsgManager msgManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late CartoonizerApi api;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Events.noticeLoading();
    api = CartoonizerApi().bindState(this);
    delay(() => _refreshController.callRefresh());
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    _refreshController.dispose();
  }

  loadFirstPage() => msgManager.loadFirstPage().then((value) {
        _refreshController.finishRefresh();
        _refreshController.finishLoad(noMore: value);
        setState(() {});
      });

  loadMorePage() => msgManager.loadMorePage().then((value) {
        _refreshController.finishLoad(noMore: value);
        setState(() {});
      });

  asyncReadMsg(MsgEntity data) {
    if (data.read) {
      return;
    }
    msgManager.readMsg(data);
    setState(() {
      data.read = true;
    });
  }

  onMsgClick(MsgEntity entity) {
    switch (entity.msgType) {
      case MsgType.like_social_post:
      case MsgType.comment_social_post:
        showLoading().whenComplete(() {
          api.getDiscoveryDetail(entity.targetId).then((value) {
            hideLoading().whenComplete(() {
              if (value != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => DiscoveryEffectDetailScreen(
                            discoveryEntity: value,
                            prePage: 'msg_page',
                            dataType: 'msg_page',
                          )),
                );
              }
            });
          });
        });
        break;
      case MsgType.like_social_post_comment:
      case MsgType.comment_social_post_comment:
        showLoading().whenComplete(() {
          api.getDiscoveryDetail(entity.targetId).then((value) {
            hideLoading().whenComplete(() {
              if (value != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => DiscoveryEffectDetailScreen(
                            discoveryEntity: value,
                            prePage: 'msg_page',
                            dataType: 'msg_page',
                          )),
                );
              }
            });
          });
        });
        break;
      case MsgType.ai_avatar_completed:
        showLoading().whenComplete(() {
          AppDelegate.instance.getManager<AvatarAiManager>().listAllAvatarAi().then((value) {
            hideLoading().whenComplete(() {
              Avatar.open(context, source: 'msgList');
            });
          });
        });
        break;
      case MsgType.UNDEFINED:
        break;
    }
  }

  readAll() {
    showLoading().whenComplete(() {
      msgManager.readAll().then((value) {
        hideLoading().whenComplete(() {
          setState(() {});
        });
      });
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.CardColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.CardColor,
        blurAble: false,
        middle: TitleTextWidget(S.of(context).msgTitle, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
        trailing: TitleTextWidget(S.of(context).read_all, ColorConstant.White, FontWeight.normal, $(15)).intoGestureDetector(
          onTap: () {
            readAll();
          },
        ).visibility(visible: msgManager.unreadCount != 0),
        scrollController: scrollController,
      ),
      body: EasyRefresh.custom(
        scrollController: scrollController,
        controller: _refreshController,
        enableControlFinishRefresh: true,
        enableControlFinishLoad: false,
        emptyWidget: msgManager.msgList.isEmpty ? TitleTextWidget(S.of(context).no_messages_yet, ColorConstant.White, FontWeight.normal, $(16)).intoCenter() : null,
        onRefresh: () async => loadFirstPage(),
        onLoad: () async => loadMorePage(),
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                var data = msgManager.msgList[index];
                return MsgCard(
                  data: data,
                  onTap: () {
                    asyncReadMsg(data);
                    onMsgClick(data);
                  },
                );
              },
              childCount: msgManager.msgList.length,
            ),
          ),
        ],
      ),
    );
  }
}
