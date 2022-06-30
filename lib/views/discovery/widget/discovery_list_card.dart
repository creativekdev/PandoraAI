import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_comments_list_screen.dart';

import 'discovery_attr_holder.dart';

class DiscoveryListCard extends StatelessWidget with DiscoveryAttrHolder {
  DiscoveryListEntity data;
  late List<DiscoveryResource> resources;
  GestureTapCallback? onTap;
  GestureTapCallback? onLikeTap;
  double width;

  DiscoveryListCard({
    Key? key,
    required this.data,
    this.onTap,
    this.onLikeTap,
    required this.width,
  }) : super(key: key) {
    resources = data.resourceList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.all(Radius.circular($(6))),
          child: resources.length > 0 ? buildResourceItem(resources[0]) : Container(),
        ),
        Row(
          children: [
            buildAttr(context, iconRes: Images.ic_discovery_comment, value: data.comments, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => DiscoveryCommentsListScreen(
                    discoveryEntity: data,
                  ),
                  settings: RouteSettings(name: "/DiscoveryCommentsListScreen"),
                ),
              );
            }),
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
    ).intoGestureDetector(onTap: onTap);
  }

  Widget buildResourceItem(DiscoveryResource resource) {
    if (resource.type == DiscoveryResourceType.video.value()) {
      return EffectVideoPlayer(
        url: resource.url ?? '',
      ).intoContainer(height: width);
    } else {
      return CachedNetworkImage(
        imageUrl: resource.url ?? '',
        cacheManager: CachedImageCacheManager(),
        placeholder: (context, url) => loadingWidget(context),
        errorWidget: (context, url, error) => loadingWidget(context),
      ).intoContainer(constraints: BoxConstraints(minHeight: $(40), minWidth: width, maxHeight: $(700), maxWidth: $(400)));
    }
  }

  Widget loadingWidget(BuildContext context) => Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
}
