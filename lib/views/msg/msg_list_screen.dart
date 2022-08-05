import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';
import 'package:cartoonizer/models/msg_entity.dart';
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

  @override
  void initState() {
    super.initState();
    delay(() => _refreshController.callRefresh());
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
    msgManager.readMsg(data);
    setState(() {
      data.read = true;
    });
  }

  onMsgClick(MsgEntity entity) {
    switch (entity.type) {
      case MsgType.notice:
        // TODO: Handle this case.
        break;
      case MsgType.effect:
        // TODO: Handle this case.
        break;
      case MsgType.comment:
        // TODO: Handle this case.
        break;
      case MsgType.UNDEFINED:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        blurAble: false,
        middle: TitleTextWidget(StringConstant.msgTitle, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
      ),
      body: EasyRefresh.custom(
        controller: _refreshController,
        enableControlFinishRefresh: true,
        enableControlFinishLoad: false,
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
