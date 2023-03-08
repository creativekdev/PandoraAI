import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/models/enums/avatar_status.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'avatar.dart';
import 'avatar_detail_screen.dart';

class AvatarAiListScreen extends StatefulWidget {
  String source;

  AvatarAiListScreen({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  State<AvatarAiListScreen> createState() => _AvatarAiListScreenState();
}

class _AvatarAiListScreenState extends AppState<AvatarAiListScreen> with SingleTickerProviderStateMixin {
  EasyRefreshController _refreshController = EasyRefreshController();
  AvatarAiManager avatarAiManager = AppDelegate().getManager();
  List<AvatarAiListEntity> dataList = [];
  late StreamSubscription listListen;
  late double imageSize;
  late TabController tabController;
  List<AvatarStatus> statusList = [
    AvatarStatus.UNDEFINED,
    AvatarStatus.pending,
    AvatarStatus.generating,
    AvatarStatus.completed,
    AvatarStatus.bought,
  ];
  int currentIndex = 0;
  late String source;

  @override
  initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'avatar_ai_list_screen');
    Events.avatarResultShow();
    source = widget.source;
    avatarAiManager.listPageAlive = true;
    imageSize = (ScreenUtil.screenSize.width - $(32)) / 3;
    listListen = EventBusHelper().eventBus.on<OnCreateAvatarAiEvent>().listen((event) {
      _refreshController.callRefresh();
    });
    tabController = TabController(
      initialIndex: currentIndex,
      length: statusList.length,
      vsync: this,
    );
    delay(() => _refreshController.callRefresh());
  }

  @override
  dispose() {
    avatarAiManager.listPageAlive = false;
    super.dispose();
    listListen.cancel();
  }

  loadFirstPage() {
    avatarAiManager.listAllAvatarAi().then((value) {
      _refreshController.finishRefresh();
      if (value != null) {
        setState(() {
          dataList = value;
        });
        if (value.isEmpty) {
          Avatar.intro(context, source: source);
        }
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        trailing: Icon(
          Icons.add,
          color: Colors.white,
          size: $(19),
        )
            .intoContainer(
                alignment: Alignment.center,
                width: $(24),
                height: $(24),
                decoration: BoxDecoration(
                  color: ColorConstant.BlueColor,
                  borderRadius: BorderRadius.circular(32),
                ))
            .intoGestureDetector(onTap: () {
          Avatar.intro(context, source: source);
        }),
        child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: TabBar(
              indicatorColor: Colors.transparent,
              isScrollable: true,
              tabs: statusList
                  .map((e) => Text(
                        e.title(context),
                        style: TextStyle(fontSize: $(13)),
                      ).intoContainer(
                          padding: EdgeInsets.symmetric(
                        vertical: 6,
                      )))
                  .toList(),
              controller: tabController,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
            )),
        childHeight: $(34),
      ),
      body: EasyRefresh.custom(
        enableControlFinishRefresh: true,
        enableControlFinishLoad: false,
        onRefresh: () async => loadFirstPage(),
        controller: _refreshController,
        slivers: [
          SliverList(
              delegate: SliverChildBuilderDelegate(
            (context, index) => buildItem(context, index),
            childCount: dataList.length,
          ))
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    var data = dataList[index];
    var status = AvatarStatusUtils.build(data.status);
    var currentStatus = statusList[currentIndex];
    if (currentStatus != AvatarStatus.UNDEFINED) {
      if (status == AvatarStatus.subscribed && currentStatus == AvatarStatus.completed) {
      } else if (status != currentStatus) {
        return Container();
      }
    }
    Widget item;
    switch (status) {
      case AvatarStatus.pending:
      case AvatarStatus.processing:
        var trainingImage = data.trainingImage();
        var trainingList = trainingImage.length > 5 ? trainingImage.sublist(0, 5) : trainingImage;
        item = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              child: Stack(
                children: [
                  Row(
                    children: trainingList.transfer(
                      (data, index) => CachedNetworkImageUtils.custom(
                        useOld: true,
                        context: context,
                        imageUrl: data,
                        width: imageSize * 0.6,
                        height: $(168),
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xaa000000),
                  ),
                  Align(
                    child: TitleTextWidget(
                      S.of(context).pandora_waiting_desc.replaceAll(
                            "%d",
                            '${avatarAiManager.config?.data.pendingTime ?? 120}',
                          ),
                      ColorConstant.White,
                      FontWeight.normal,
                      $(12),
                      maxLines: 10,
                    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: 40)),
                    alignment: Alignment.center,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular($(8)),
            ).intoContainer(height: $(168)),
            SizedBox(height: 6),
            Text(
              data.name,
              style: TextStyle(
                color: ColorConstant.White,
                fontFamily: 'Poppins',
                fontSize: $(15),
              ),
            ).intoContainer(margin: EdgeInsets.symmetric(horizontal: 10)),
            Text(
              '${data.imageCount}${S.of(context).avatars}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: 'Poppins',
                fontSize: $(13),
              ),
            ).intoContainer(margin: EdgeInsets.symmetric(horizontal: 10)),
            SizedBox(height: 8),
          ],
        ).intoContainer(
          margin: EdgeInsets.only(
            left: $(16),
            right: $(16),
            top: $(12),
          ),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(8)),
            color: Colors.grey.shade900,
          ),
        );
        break;
      case AvatarStatus.completed:
      case AvatarStatus.subscribed:
      case AvatarStatus.generating:
        var coverImage = data.coverImage();
        var list = coverImage.length > 5 ? coverImage.sublist(0, 5) : coverImage;
        item = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              child: Row(
                children: list.transfer(
                  (data, index) => CachedNetworkImageUtils.custom(
                    context: context,
                    imageUrl: data,
                    width: imageSize * 0.6,
                    height: $(168),
                  ),
                ),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular($(8)),
                topRight: Radius.circular($(8)),
              ),
            ),
            SizedBox(height: 6),
            Text(
              data.name,
              style: TextStyle(
                color: ColorConstant.White,
                fontFamily: 'Poppins',
                fontSize: $(15),
              ),
            ).intoContainer(margin: EdgeInsets.symmetric(horizontal: 10)),
            Text(
              '${data.imageCount}${S.of(context).avatars}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontFamily: 'Poppins',
                fontSize: $(13),
              ),
            ).intoContainer(margin: EdgeInsets.symmetric(horizontal: 10)),
            SizedBox(height: 8),
          ],
        )
            .intoContainer(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular($(8)),
          ),
          margin: EdgeInsets.only(
            left: $(16),
            right: $(16),
            top: $(12),
          ),
        )
            .intoGestureDetector(onTap: () {
          showLoading().whenComplete(() {
            avatarAiManager.getAvatarAiDetail(token: data.token).then((value) {
              hideLoading().whenComplete(() {
                if (value != null) {
                  Navigator.of(context).push(Right2LeftRouter(child: AvatarDetailScreen(entity: value)));
                }
              });
            });
          });
        });
        break;
      case AvatarStatus.bought:
        item = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).packages_purchased,
              style: TextStyle(fontSize: $(10)),
            ).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(0xfffed700),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular($(8)),
                    bottomRight: Radius.circular($(8)),
                  ),
                )),
            SizedBox(height: $(12)),
            Row(
              children: [
                SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppDelegate.instance.getManager<UserManager>().user!.aiAvatarCredit} ${S.of(context).unique_avatars}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: $(17),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      S.of(context).variations_of_styles,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: $(13),
                        color: Color(0xff939398),
                      ),
                    ),
                  ],
                )),
                Text(
                  S.of(context).create,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: $(15),
                  ),
                ).intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: $(32), vertical: $(10)),
                    decoration: BoxDecoration(
                      color: ColorConstant.BlueColor,
                      borderRadius: BorderRadius.circular($(8)),
                    )),
                SizedBox(width: 12),
              ],
            ),
            SizedBox(height: $(20)),
          ],
        )
            .intoContainer(
          margin: EdgeInsets.only(
            left: $(16),
            right: $(16),
            top: $(12),
          ),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(8)),
            color: Colors.grey.shade900,
          ),
        )
            .intoGestureDetector(onTap: () {
          Avatar.intro(context, source: source);
        });
        break;
      case AvatarStatus.UNDEFINED:
        return Container();
    }
    return item.intoContainer(
      padding: EdgeInsets.only(
        bottom: index == dataList.length - 1 ? ScreenUtil.getBottomPadding(context, padding: $(32)) : 0,
      ),
    );
  }
}
