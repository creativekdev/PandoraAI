import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_comments_list_screen.dart';

import 'discovery_attr_holder.dart';

class DiscoveryListCard extends StatefulWidget {
  DiscoveryListEntity data;
  GestureTapCallback? onTap;
  GestureTapCallback? onLikeTap;

  DiscoveryListCard({
    Key? key,
    required this.data,
    this.onTap,
    this.onLikeTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DiscoveryListCardState();
  }
}

class DiscoveryListCardState extends State<DiscoveryListCard> with DiscoveryAttrHolder {
  late DiscoveryListEntity data;
  late List<DiscoveryResource> resources;
  GestureTapCallback? onTap;
  GestureTapCallback? onLikeTap;
  Size? contentSize;

  @override
  initState() {
    super.initState();
    data = widget.data;
    onTap = widget.onTap;
    onLikeTap = widget.onLikeTap;
    resources = data.resourceList();
  }

  @override
  void didUpdateWidget(DiscoveryListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (data.id != oldWidget.data.id) {
      data = oldWidget.data;
      onTap = oldWidget.onTap;
      onLikeTap = oldWidget.onLikeTap;
      resources = data.resourceList();
      contentSize = null;
    }
  }

  Widget buildChild(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      borderRadius: BorderRadius.all(Radius.circular($(6))),
      child: resources.length > 0 ? buildResourceItem(resources[0]) : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        contentSize == null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        buildChild(context).listenSizeChanged(onSizeChanged: (size) {
                          if (size.height != 0) {
                            setState(() {
                              contentSize = size;
                            });
                          }
                        }),
                      ],
                    ),
                  ),
                  loadingWidget(context),
                ],
              ).intoContainer(height: $(80), width: double.maxFinite)
            : buildChild(context).intoContainer(width: contentSize!.width, height: contentSize!.height),
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
      );
    } else {
      return CachedNetworkImage(
        imageUrl: resource.url ?? '',
        cacheManager: CachedImageCacheManager(),
        // placeholder: (context, url) => loadingWidget(context),
        errorWidget: (context, url, error) => loadingWidget(context),
      );
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
