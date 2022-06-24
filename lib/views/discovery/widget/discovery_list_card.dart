import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_comments_list_screen.dart';

import 'discovery_attr_holder.dart';

class DiscoveryListCard extends StatelessWidget with DiscoveryAttrHolder {
  DiscoveryListEntity data;
  late List<String> images;
  GestureTapCallback? onTap;

  DiscoveryListCard({
    Key? key,
    required this.data,
    this.onTap,
  }) : super(key: key) {
    images = data.images.split(',');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.all(Radius.circular($(6))),
          child: CachedNetworkImage(
              imageUrl: images[0],
              placeholder: (context, url) => loadingWidget(context),
              errorWidget: (context, url, error) => loadingWidget(context),
              cacheManager: CachedImageCacheManager()),
        ),
        Row(
          children: [
            buildAttr(context, iconRes: Images.ic_discovery_comment, value: data.comments, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => DiscoveryCommentsListScreen(socialPostId: data.id),
                  settings: RouteSettings(name: "/DiscoveryCommentsListScreen"),
                ),
              );
            }),
            buildAttr(context, iconRes: Images.ic_discovery_like, value: data.likes),
          ],
        ),
      ],
    ).intoGestureDetector(onTap: onTap);
  }

  Widget loadingWidget(BuildContext context) => Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
}
