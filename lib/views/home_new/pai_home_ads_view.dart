import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/home_page_entity.dart';
import 'package:cartoonizer/widgets/visibility_holder.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class PaiHomeAdsView extends StatefulWidget {
  final HomeItemEntity data;
  final double width;
  final Function(DiscoveryListEntity data) onTap;

  const PaiHomeAdsView({super.key, required this.data, required this.width, required this.onTap});

  @override
  State<PaiHomeAdsView> createState() => _PaiHomeAdsViewState();
}

class _PaiHomeAdsViewState extends State<PaiHomeAdsView> {
  late HomeItemEntity data;
  List<DiscoveryListEntity> posts = [];
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late double width;
  double height = 100.dp;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    posts = data.getDataList<DiscoveryListEntity>();
    width = widget.width;
    if (posts.isNotEmpty) {
      DiscoveryListEntity post = posts.first;
      imageUrl = post.resourceList().first.url!;
      var scale = cacheManager.imageScaleOperator.getScale(imageUrl!);
      if (scale == null) {
        SyncCachedNetworkImage(url: imageUrl!).getImage().then((value) {
          if (!mounted) {
            return;
          }
          double s = value.image.width / value.image.height;
          cacheManager.imageScaleOperator.setScale(imageUrl!, s);
          height = width / s;
          safeSetState(() {});
        });
      } else {
        height = width / scale;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return SizedBox.shrink();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular($(8)),
      child: VisibilityImageHolder(
        url: imageUrl!,
        width: width,
        height: height,
      ),
    ).intoGestureDetector(onTap: () {
      widget.onTap.call(posts.first);
    }).intoContainer(margin: EdgeInsets.symmetric(vertical: 12.dp));
  }
}
