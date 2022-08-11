import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';

class MyDiscoveryListCard extends StatelessWidget {
  int time;
  List<DiscoveryListEntity> dataList;

  double imgWidth;
  int rows = 0;
  double height = 0;
  Function(DiscoveryListEntity data) onItemClick;

  MyDiscoveryListCard({
    required this.dataList,
    required this.time,
    required this.imgWidth,
    required this.onItemClick,
    Key? key,
  }) : super(key: key) {
    rows = dataList.length ~/ 3;
    if (dataList.length % 3 != 0) {
      rows++;
    }
    height = imgWidth * rows;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        time.dateMonth,
        style: TextStyle(
          color: ColorConstant.White,
          fontFamily: 'Poppins',
          fontSize: $(14),
        ),
      ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(16), vertical: $(8))),
      GridView.count(
        crossAxisCount: 3,
        physics: NeverScrollableScrollPhysics(),
        children: dataList
            .map((e) => buildResourceItem(e.resourceList()[0]).intoGestureDetector(onTap: () {
                  onItemClick.call(e);
                }))
            .toList(),
      ).intoContainer(height: height, margin: EdgeInsets.only(left: $(75), right: $(15))),
    ]);
  }

  Widget buildResourceItem(DiscoveryResource resource) {
    if (resource.type == DiscoveryResourceType.video.value()) {
      return EffectVideoPlayer(
        url: resource.url ?? '',
      ).intoContainer(height: imgWidth, width: imgWidth, padding: EdgeInsets.all(3));
    } else {
      return CachedNetworkImageUtils.custom(
        imageUrl: resource.url ?? '',
        width: imgWidth,
        height: imgWidth,
        errorWidget: (context, url, error) => Container(
          color: ColorConstant.CardColor,
        ),
      ).intoContainer(padding: EdgeInsets.all(3));
    }
  }
}
