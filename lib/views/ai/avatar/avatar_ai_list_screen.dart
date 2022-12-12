import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'avatar.dart';
import 'avatar_detail_screen.dart';

class AvatarAiListScreen extends StatefulWidget {
  const AvatarAiListScreen({Key? key}) : super(key: key);

  @override
  State<AvatarAiListScreen> createState() => _AvatarAiListScreenState();
}

class _AvatarAiListScreenState extends State<AvatarAiListScreen> {
  EasyRefreshController _refreshController = EasyRefreshController();
  late CartoonizerApi api;

  @override
  initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    delay(() => _refreshController.callRefresh());
  }

  @override
  dispose() {
    super.dispose();
    api.unbind();
  }

  loadFirstPage() {
    api.listAllAvatarAi().then((value) {
      _refreshController.finishRefresh();
      if (value != null) {}
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
                childCount: 1,
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
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AvatarIntroduceScreen()));
          })
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    Widget item;
    bool ready = true;
    if (ready) {
      item = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleTextWidget('Pack #$index', ColorConstant.White, FontWeight.bold, $(18)),
          TitleTextWidget('50 avatars', ColorConstant.White, FontWeight.normal, $(15)),
          SizedBox(height: $(40)),
        ],
      )
          .intoContainer(
              margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
              padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)),
              width: double.maxFinite,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular($(8)),
                  image: DecorationImage(
                    image: AssetImage(Images.ic_choose_photo_initial_header),
                    fit: BoxFit.cover,
                  )))
          .intoGestureDetector(onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AvatarDetailScreen(
                  token: '',//todo
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
