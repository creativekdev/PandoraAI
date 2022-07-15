import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/image_scale_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_comments_list_screen.dart';

import 'discovery_attr_holder.dart';

const double higherImageScale = 0.64; //170/265
const double lowerImageScale = 1.56; //365/170
const double squareImageScale = 1;

class DiscoveryListCard extends StatefulWidget {
  late DiscoveryListEntity data;
  GestureTapCallback? onTap;
  GestureTapCallback? onLikeTap;
  late double width;

  DiscoveryListCard({
    Key? key,
    required this.data,
    this.onTap,
    this.onLikeTap,
    required this.width,
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
  late double width;
  bool loading = true;

  ImageScaleManager scaleManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    super.initState();
    data = widget.data;
    resources = data.resourceList();
    onTap = widget.onTap;
    onLikeTap = widget.onLikeTap;
    width = widget.width;
    loading = true;
  }

  @override
  void didUpdateWidget(DiscoveryListCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    data = widget.data;
    resources = data.resourceList();
    if (oldWidget.data.id != data.id) {
      onTap = widget.onTap;
      onLikeTap = widget.onLikeTap;
      width = widget.width;
      loading = true;
    }
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
      double? scale = scaleManager.getScale(resource.url ?? '');
      if (scale == null) {
        scale = squareImageScale;
      }
      var cachedNetworkImageProvider = CachedNetworkImageProvider(
        resource.url ?? '',
        cacheManager: CachedImageCacheManager(),
        errorListener: () {
          resource.url ?? '';
        },
      );
      var resolve = cachedNetworkImageProvider.resolve(ImageConfiguration.empty);
      resolve.addListener(ImageStreamListener((image, synchronousCall) {
        var imageScale = image.image.width / image.image.height;
        if (imageScale < 0.9) {
          imageScale = lowerImageScale;
        } else if (imageScale > 1.1) {
          imageScale = higherImageScale;
        } else {
          imageScale = squareImageScale;
        }
        if (scale != imageScale) {
          scaleManager.setScale(resource.url ?? '', imageScale);
        }
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      }));
      double height = width * scale;
      return Stack(
        children: [
          Image(image: cachedNetworkImageProvider, fit: BoxFit.cover, width: width, height: height),
          Center(child: CircularProgressIndicator()).intoContainer(width: width, height: height).offstage(offstage: !loading),
        ],
      );
    }
  }
}
