import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/models/enums/avatar_status.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'avatar_detail_screen.dart';

class AvatarAiListScreen extends StatefulWidget {
  const AvatarAiListScreen({Key? key}) : super(key: key);

  @override
  State<AvatarAiListScreen> createState() => _AvatarAiListScreenState();
}

class _AvatarAiListScreenState extends State<AvatarAiListScreen> {
  EasyRefreshController _refreshController = EasyRefreshController();
  late CartoonizerApi api;
  List<AvatarAiListEntity> dataList = [];
  late StreamSubscription listListen;
  late double imageSize;

  @override
  initState() {
    super.initState();
    logEvent(Events.avatar_list_loading);
    imageSize = ScreenUtil.screenSize.width / 3;
    listListen = EventBusHelper().eventBus.on<OnCreateAvatarAiEvent>().listen((event) {
      _refreshController.callRefresh();
    });
    api = CartoonizerApi().bindState(this);
    delay(() => _refreshController.callRefresh());
  }

  @override
  dispose() {
    super.dispose();
    listListen.cancel();
    api.unbind();
  }

  loadFirstPage() {
    api.listAllAvatarAi().then((value) {
      _refreshController.finishRefresh();
      if (value != null) {
        setState(() {
          dataList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          'Magic Avatars',
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
            'You will never have the same results!'
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
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AvatarIntroduceScreen()));
          })
        ],
      ).intoContainer(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    var data = dataList[index];
    var list = data.outputImages.length > 6 ? data.outputImages.sublist(0, 6) : data.outputImages;
    Widget item;
    bool ready = data.status == AvatarStatus.completed.value();
    if (ready) {
      item = Stack(
        children: [
          ...list.reversed.toList().transfer((e, index) => Positioned(
                child: ClipRRect(
                  child: CachedNetworkImageUtils.custom(context: context, imageUrl: e.url, width: imageSize, height: imageSize),
                  borderRadius: BorderRadius.circular($(8)),
                ).hero(tag: e.url),
                top: 0,
                left: index * ((ScreenUtil.screenSize.width - $(30) - imageSize) / (list.length - 1)),
              )),
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
      )
          .intoContainer(
        height: imageSize,
        margin: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: Colors.grey.shade900),
      )
          .intoGestureDetector(onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AvatarDetailScreen(
                  entity: data,
                )));
      });
    } else {
      item = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: $(20)),
          TitleTextWidget(
            'Please waiting, your photos will'
            'be generated in about 2 hours',
            ColorConstant.White,
            FontWeight.bold,
            $(18),
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
          color: Colors.grey.shade700,
        ),
      );
    }
    return item;
  }
}
