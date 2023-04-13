import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/badge.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/views/msg/msg_discovery_list.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:cartoonizer/views/msg/msg_system_list.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class MsgListScreen extends StatefulWidget {
  static Future push(BuildContext context) async {
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MsgListScreen(),
      settings: RouteSettings(name: "/MsgListScreen"),
    ));
  }

  @override
  MsgListState createState() {
    return MsgListState();
  }
}

class MsgListState extends AppState<MsgListScreen> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'msg_list_screen');
    AppDelegate.instance.getManager<MsgManager>().loadUnreadCount();
    pageController = PageController(keepPage: true, initialPage: 0);
    var controller = Get.find<MsgListController>();
    controller.readAll(controller.tabList[controller.tabIndex]);
    Events.noticeLoading();
  }

  @override
  void dispose() {
    var controller = Get.find<MsgListController>();
    controller.tabIndex = 0;
    super.dispose();
  }

  asyncReadMsg(MsgListController controller, MsgEntity data) {
    if (data.read) {
      return;
    }
    controller.readMsg(data);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GetBuilder<MsgListController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstant.CardColor,
          appBar: AppNavigationBar(
            backgroundColor: Color(0xff232528),
            blurAble: false,
            middle: TitleTextWidget(S.of(context).msgTitle, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
            trailing: Obx(() => TitleTextWidget(S.of(context).read_all, ColorConstant.White, FontWeight.normal, $(15)).intoGestureDetector(
                  onTap: () {
                    showLoading().whenComplete(() {
                      controller.readAll(null).then((value) {
                        hideLoading();
                      });
                    });
                  },
                ).visibility(visible: controller.msgManager.unreadCount != 0)),
          ),
          body: Column(
            children: [
              Divider(height: 1, color: ColorConstant.LineColor),
              buildTabList(context, controller),
              Expanded(child: buildContent(context, controller)),
            ],
          ),
        );
      },
      init: Get.find<MsgListController>(),
    );
  }

  Widget buildTabList(BuildContext context, MsgListController controller) {
    return Row(
      children: controller.tabList.transfer((e, index) {
        bool checked = index == controller.tabIndex;
        return Expanded(
            child: Column(
          children: [
            Obx(() {
              int count = 0;
              switch (controller.tabList[index]) {
                case MsgTab.like:
                  count = controller.msgManager.likeCount.value;
                  break;
                case MsgTab.comment:
                  count = controller.msgManager.commentCount.value;
                  break;
                case MsgTab.system:
                  count = controller.msgManager.systemCount.value;
                  break;
              }
              return BadgeView(
                type: BadgeType.fill,
                count: count,
                child: Image.asset(
                  e.iconRes,
                  width: $(26),
                ).intoContainer(
                  padding: EdgeInsets.all($(8)),
                  decoration: BoxDecoration(color: checked ? e.selectedColor : Color(0xff5d5d5d), borderRadius: BorderRadius.circular($(32))),
                ),
              );
            }),
            SizedBox(height: $(4)),
            TitleTextWidget(e.title, checked ? ColorConstant.White : Color(0xff5d5d5d), FontWeight.normal, $(14)),
          ],
        ).intoGestureDetector(onTap: () {
          if (controller.tabIndex != index) {
            pageController.jumpToPage(index);
          }
          controller.tabIndex = index;
          if (controller.tabList[index] != MsgTab.system) {
            controller.readAll(controller.tabList[index]);
          }
        }));
      }).toList(),
    ).intoContainer(padding: EdgeInsets.only(top: $(8), bottom: $(8)), color: Color(0xff232528));
  }

  Widget buildContent(BuildContext context, MsgListController controller) {
    return PageView(
      children: [
        MsgDiscoveryList(tab: controller.tabList[0]),
        MsgDiscoveryList(tab: controller.tabList[1]),
        MsgSystemList(),
      ],
      onPageChanged: (index) {
        controller.tabIndex = index;
      },
      controller: pageController,
    );
  }
}
