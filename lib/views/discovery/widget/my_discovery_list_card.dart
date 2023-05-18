import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:skeletons/skeletons.dart';

class MyDiscoveryListCard extends StatelessWidget {
  int time;
  List<DiscoveryListEntity> dataList;
  var thirdpartManager = AppDelegate.instance.getManager<ThirdpartManager>();

  double imgWidth;
  int rows = 0;
  double height = 0;
  Function(DiscoveryListEntity data) onItemClick;
  bool hasYear;
  late List<DiscoveryListEntity> activeList;

  MyDiscoveryListCard({
    required this.dataList,
    required this.time,
    required this.imgWidth,
    required this.onItemClick,
    required this.hasYear,
    Key? key,
  }) : super(key: key) {
    activeList = dataList.filter((t) => !t.removed);
    rows = activeList.length ~/ 3;
    if (activeList.length % 3 != 0) {
      rows++;
    }
    height = imgWidth * rows;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: $(24)),
          Container(
            height: 1,
            color: ColorConstant.LineColor,
            margin: EdgeInsets.symmetric(horizontal: $(16)),
          ),
          Text(
            time.dateYear,
            style: TextStyle(
              color: ColorConstant.White,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: $(20),
            ),
          ).intoContainer(padding: EdgeInsets.only(left: $(16), right: $(16), top: $(16))),
        ],
      ).visibility(visible: hasYear),
      Text(
        time.dateMonth.intl,
        style: TextStyle(
          color: ColorConstant.White,
          fontFamily: 'Poppins',
          fontSize: $(14),
        ),
      ).intoContainer(padding: EdgeInsets.only(left: $(16), right: $(16), bottom: $(8))),
      GridView.count(
        crossAxisCount: 3,
        physics: NeverScrollableScrollPhysics(),
        children: activeList
            .map((e) => buildResourceItem(context, e.resourceList().last).intoGestureDetector(onTap: () {
                  onItemClick.call(e);
                }))
            .toList(),
      ).intoContainer(height: height, margin: EdgeInsets.only(left: $(75), right: $(15))),
    ]);
  }

  Widget buildResourceItem(BuildContext context, DiscoveryResource resource) {
    if (resource.type == DiscoveryResourceType.video.value()) {
      return EffectVideoPlayer(
        url: resource.url ?? '',
      ).intoContainer(height: imgWidth, width: imgWidth, padding: EdgeInsets.all(3));
    } else {
      return CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: resource.url ?? '',
        width: imgWidth,
        height: imgWidth,
        placeholder: (context, url) => SkeletonAvatar(style: SkeletonAvatarStyle(width: imgWidth, height: imgWidth)),
        errorWidget: (context, url, error) => Container(
          color: ColorConstant.CardColor,
        ),
      ).intoContainer(padding: EdgeInsets.all(3));
    }
  }
}
