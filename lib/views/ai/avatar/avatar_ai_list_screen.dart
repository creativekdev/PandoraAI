import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/widgets/router/routers.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/models/enums/avatar_status.dart';
import 'package:common_utils/common_utils.dart';
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
  List<AvatarAiListEntity> shownList = [];
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
  late TimerUtil timer;

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
    timer = TimerUtil()
      ..setInterval(60000)
      ..setOnTimerTickCallback(
        (millisUntilFinished) {
          var manager = AppDelegate.instance.getManager<UserManager>();
          if (!manager.isNeedLogin) {
            loadFirstPage();
          }
        },
      );
  }

  @override
  dispose() {
    avatarAiManager.listPageAlive = false;
    timer.cancel();
    super.dispose();
    listListen.cancel();
  }

  refreshShownList() {
    timer.cancel();
    var status = statusList[currentIndex];
    shownList = dataList.filter((t) {
      var tStatus = AvatarStatusUtils.build(t.status);
      if (status == AvatarStatus.UNDEFINED) {
        return true;
      }
      switch (status) {
        case AvatarStatus.pending:
        case AvatarStatus.processing:
          if (tStatus == AvatarStatus.pending || tStatus == AvatarStatus.processing) {
            return true;
          } else {
            return false;
          }
        case AvatarStatus.generating:
        case AvatarStatus.bought:
          return tStatus == status;
        case AvatarStatus.completed:
        case AvatarStatus.subscribed:
          if (tStatus == AvatarStatus.completed || tStatus == AvatarStatus.subscribed) {
            return true;
          } else {
            return false;
          }
        case AvatarStatus.UNDEFINED:
          return false;
      }
    });
    if (shownList.exist((t) => t.status == AvatarStatus.pending.value() || t.status == AvatarStatus.processing.value() || t.status == AvatarStatus.generating.value())) {
      delay(() {
        if (mounted && !timer.isActive()) {
          timer.startTimer();
        }
      }, milliseconds: 60000);
    }
  }

  loadFirstPage() {
    avatarAiManager.listAllAvatarAi().then((value) {
      _refreshController.finishRefresh();
      if (value != null) {
        setState(() {
          dataList = value;
          refreshShownList();
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
      backgroundColor: Colors.black,
      appBar: AppNavigationBar(
        backgroundColor: Colors.black,
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
                  refreshShownList();
                });
              },
            )),
        childHeight: $(34),
      ),
      body: Stack(
        children: [
          EasyRefresh.custom(
            enableControlFinishRefresh: true,
            enableControlFinishLoad: false,
            onRefresh: () async => loadFirstPage(),
            controller: _refreshController,
            emptyWidget: shownList.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        Images.ic_no_avatar,
                        width: $(114),
                      ),
                      SizedBox(height: $(8)),
                      Text(
                        'You have no related orders',
                        style: TextStyle(
                            color: Color(0xFF939398),
                            fontFamily: ''
                                'Poppins',
                            fontSize: $(13)),
                      )
                    ],
                  ).intoCenter()
                : null,
            slivers: [
              SliverList(
                  delegate: SliverChildBuilderDelegate(
                (context, index) => buildItem(context, index),
                childCount: shownList.length,
              ))
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Text(
              S.of(context).create_new_avatars,
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.normal, fontSize: $(17)),
            )
                .intoContainer(
                    width: ScreenUtil.screenSize.width - $(30),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: $(8), horizontal: $(15)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(8)),
                      color: ColorConstant.DiscoveryBtn,
                    ))
                .intoCenter()
                .intoContainer(
                    color: Color(0x99000000),
                    padding: EdgeInsets.only(
                      top: $(18),
                      bottom: ScreenUtil.getBottomPadding(context) + $(10),
                      left: $(25),
                      right: $(25),
                    ))
                .intoGestureDetector(onTap: () {
              Avatar.intro(context, source: source);
            }).blur(),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    var data = shownList[index];
    var status = AvatarStatusUtils.build(data.status);
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
                        useOld: false,
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
                  Navigator.of(context).push(
                    Right2LeftRouter(
                      settings: RouteSettings(name: '/AvatarDetailScreen'),
                      child: AvatarDetailScreen(entity: value),
                    ),
                  );
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
        bottom: index == shownList.length - 1 ? ScreenUtil.getBottomPadding(context) + $(90) : 0,
      ),
    );
  }
}
