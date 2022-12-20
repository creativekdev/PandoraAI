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
import 'package:common_utils/common_utils.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'avatar.dart';
import 'avatar_detail_screen.dart';
import 'dialog/submit_avatar_dialog.dart';
import 'select_bio_style_screen.dart';

class AvatarAiListScreen extends StatefulWidget {
  const AvatarAiListScreen({Key? key}) : super(key: key);

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
    AvatarStatus.completed,
    AvatarStatus.bought,
  ];
  int currentIndex = 0;

  @override
  initState() {
    super.initState();
    avatarAiManager.listPageAlive = true;
    logEvent(Events.avatar_list_loading);
    imageSize = (ScreenUtil.screenSize.width - $(30)) / 3;
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
          Avatar.intro(context);
        }),
        child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: TabBar(
              indicatorColor: Colors.transparent,
              tabs: statusList
                  .map((e) => Text(e.title()).intoContainer(
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
        childHeight: $(32),
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
      ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))),
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
        var trainingList = trainingImage.length > 6 ? trainingImage.sublist(0, 6) : trainingImage;

        item = ClipRRect(
          child: Stack(
            children: [
              Wrap(
                children: trainingList.transfer(
                  (data, index) => CachedNetworkImageUtils.custom(
                    context: context,
                    imageUrl: data,
                    width: imageSize,
                    height: imageSize,
                  ),
                ),
              ),
              Container(
                color: Color(0xaa000000),
              ),
              Align(
                child: TitleTextWidget(
                  'Please waiting, your photos will '
                  'be generated in about 2 hours. We\'ll '
                  'send you an email with a link to '
                  'your AI avatars when it\'s done!',
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
        )
            .intoContainer(
              height: imageSize * 1.5,
            )
            .intoContainer(
              margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(8)),
                color: Colors.grey.shade900,
              ),
            );
        break;
      case AvatarStatus.completed:
      case AvatarStatus.subscribed:
        var coverImage = data.coverImage();
        var list = coverImage.length > 6 ? coverImage.sublist(0, 6) : coverImage;
        item = ClipRRect(
          child: Stack(
            children: [
              Wrap(
                children: list.transfer(
                  (data, index) => CachedNetworkImageUtils.custom(
                    context: context,
                    imageUrl: data,
                    width: imageSize,
                    height: imageSize,
                  ),
                ),
              ),
            ],
          ),
          borderRadius: BorderRadius.circular($(8)),
        )
            .intoContainer(
          height: imageSize * 1.5,
          margin: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)),
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
              'Packages purchased',
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
                      '${AppDelegate.instance.getManager<UserManager>().user!.aiAvatarCredit}'
                      ' unique avatars',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: $(17),
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '10 variations of 10 styles',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: $(13),
                        color: Color(0xff939398),
                      ),
                    ),
                  ],
                )),
                Text(
                  'Create',
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
          margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(8)),
            color: Colors.grey.shade900,
          ),
        )
            .intoGestureDetector(onTap: () {
          Avatar.intro(context);
        });
        break;
      case AvatarStatus.UNDEFINED:
        item = Container();
        break;
    }
    return item;
  }
}
