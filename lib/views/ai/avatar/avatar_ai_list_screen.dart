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

class _AvatarAiListScreenState extends AppState<AvatarAiListScreen> {
  EasyRefreshController _refreshController = EasyRefreshController();
  AvatarAiManager avatarAiManager = AppDelegate().getManager();
  List<AvatarAiListEntity> dataList = [];
  late StreamSubscription listListen;
  late double imageSize;

  @override
  initState() {
    super.initState();
    avatarAiManager.listPageAlive = true;
    logEvent(Events.avatar_list_loading);
    imageSize = ScreenUtil.screenSize.width / 3;
    listListen = EventBusHelper().eventBus.on<OnCreateAvatarAiEvent>().listen((event) {
      _refreshController.callRefresh();
    });
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
        middle: TitleTextWidget(
          'Pandora Avatars',
          ColorConstant.White,
          FontWeight.w600,
          $(18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: EasyRefresh.custom(
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
          )),
          TitleTextWidget(
            (AppDelegate().getManager<UserManager>().user?.aiAvatarCredit ?? 0) > 0
                ? 'You have purchased already, '
                : 'You will never have the same results!'
                    ' Every time AI generates unique avatars.',
            ColorConstant.White,
            FontWeight.normal,
            $(15),
            maxLines: 2,
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20))),
          TitleTextWidget(
            'Create new avatars',
            ColorConstant.White,
            FontWeight.w500,
            $(16),
          )
              .intoContainer(
            decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(8))),
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: $(12), horizontal: $(15)),
            padding: EdgeInsets.symmetric(vertical: $(10)),
          )
              .intoGestureDetector(onTap: () {
            createTap(context);
          })
        ],
      ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))),
    );
  }

  Future<Null> createTap(BuildContext context) {
    return SubmitAvatarDialog.push(context, name: '').then((name) {
      if (!TextUtil.isEmpty(name)) {
        SelectStyleScreen.push(
          context,
        ).then((style) {
          if (style != null) {
            Avatar.create(context, name: name!, style: style);
          }
        });
      }
    });
  }

  Widget buildItem(BuildContext context, int index) {
    var data = dataList[index];
    var coverImage = data.coverImage();
    var list = coverImage.length > 6 ? coverImage.sublist(0, 6) : coverImage;
    Widget item;
    var status = AvatarStatusUtils.build(data.status);
    switch (status) {
      case AvatarStatus.pending:
      case AvatarStatus.processing:
        item = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: $(20)),
            TitleTextWidget(
              'Please waiting, your photos will '
              'be generated in about 2 hours',
              ColorConstant.White,
              FontWeight.bold,
              $(17),
              maxLines: 2,
            ),
            SizedBox(height: $(20)),
          ],
        ).intoContainer(
          margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
          padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(8)),
            color: Colors.grey.shade900,
          ),
        );
        break;
      case AvatarStatus.completed:
      case AvatarStatus.subscribed:
        item = ClipRRect(
          child: Stack(
            children: [
              ...list.reversed.toList().transfer((e, index) => Positioned(
                    child: CachedNetworkImageUtils.custom(context: context, imageUrl: e, width: imageSize, height: imageSize),
                    top: 0,
                    left: index * ((ScreenUtil.screenSize.width - $(30) - imageSize) / (list.length - 1)),
                  )),
              Container(
                width: ScreenUtil.screenSize.width - $(30),
                height: imageSize,
                color: Color(0x37000000),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleTextWidget(data.name, ColorConstant.White, FontWeight.w600, $(17)),
                  TitleTextWidget('${data.imageCount} avatars', ColorConstant.White, FontWeight.normal, $(15)),
                ],
              ).intoContainer(
                margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
                padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)),
                width: ScreenUtil.screenSize.width - $(30),
              ),
            ],
          ),
          borderRadius: BorderRadius.circular($(8)),
        )
            .intoContainer(
          height: imageSize,
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
      case AvatarStatus.UNDEFINED:
        item = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: $(20)),
            TitleTextWidget(
              'Thank you for purchasing\n Pandora Avatars. ',
              ColorConstant.White,
              FontWeight.bold,
              $(17),
              maxLines: 2,
            ),
            SizedBox(height: $(20)),
          ],
        )
            .intoContainer(
          margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
          padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(8)),
            color: Colors.grey.shade900,
          ),
        )
            .intoGestureDetector(onTap: () {
          createTap(context);
        });
        break;
    }
    return item;
  }
}
