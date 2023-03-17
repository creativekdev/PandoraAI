import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/nsfw_card.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';

import 'discovery_attr_holder.dart';

const double higherImageScale = 0.64; //170/265
const double lowerImageScale = 1.56; //365/170
const double squareImageScale = 1;

class DiscoveryListCard extends StatelessWidget with DiscoveryAttrHolder {
  late DiscoveryListEntity data;
  late List<DiscoveryResource> resources;
  GestureTapCallback? onTap;
  GestureTapCallback? onLikeTap;
  GestureTapCallback onNsfwTap;
  GestureLongPressCallback? onLongPress;
  late double width;
  GlobalKey<FutureLoadingImageState>? imageKey;
  bool nsfwShown;

  DiscoveryListCard({
    Key? key,
    required this.data,
    this.onTap,
    this.onLongPress,
    this.onLikeTap,
    required this.width,
    this.imageKey,
    required this.nsfwShown,
    required this.onNsfwTap,
  }) : super(key: key) {
    resources = data.resourceList();
  }

  @override
  Widget build(BuildContext context) {
    // if (nsfwShown) {
    //   return Stack(
    //     children: [
    //       ClipRRect(
    //         clipBehavior: Clip.antiAliasWithSaveLayer,
    //         borderRadius: BorderRadius.all(Radius.circular($(6))),
    //         child: resources.length > 0 ? buildResourceItem(context, resources[0], height: width) : Container(),
    //       ),
    //       Container(width: width, height: width).blur(),
    //       NsfwCard(
    //         width: width,
    //         height: width,
    //         onTap: onNsfwTap,
    //       ),
    //     ],
    //   );
    // }
    return Column(
      children: [
        ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.all(Radius.circular($(6))),
          child: resources.length > 0 ? buildResourceItem(context, resources[0]) : Container(),
        ),
        Row(
          children: [
            buildAttr(context, iconRes: Images.ic_discovery_comment, value: data.comments),
            buildAttr(
              context,
              iconRes: data.likeId == null ? Images.ic_discovery_like : Images.ic_discovery_liked,
              iconColor: data.likeId == null ? ColorConstant.White : ColorConstant.Red,
              value: data.likes,
              onTap: onLikeTap,
            ),
          ],
        ),
      ],
    ).intoGestureDetector(onTap: onTap, onLongPress: onLongPress);
  }

  Widget buildResourceItem(BuildContext context, DiscoveryResource resource, {double? height}) {
    if (resource.type == DiscoveryResourceType.video.value()) {
      return EffectVideoPlayer(
        url: resource.url ?? '',
      ).intoContainer(height: width);
    } else {
      return CachedNetworkImageUtils.custom(
          key: imageKey,
          context: context,
          imageUrl: resource.url ?? '',
          width: width,
          useCachedScale: true,
          height: height,
          placeholder: (context, url) {
            return CircularProgressIndicator()
                .intoContainer(
                  width: $(25),
                  height: $(25),
                )
                .intoCenter()
                .intoContainer(width: width, height: width);
          },
          errorWidget: (context, url, error) {
            return CircularProgressIndicator()
                .intoContainer(
                  width: $(25),
                  height: $(25),
                )
                .intoCenter()
                .intoContainer(width: width, height: width);
          });
    }
  }
}
