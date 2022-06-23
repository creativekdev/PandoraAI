import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/widget/user_info_header_widget.dart';

import 'widget/discovery_attr_holder.dart';

class DiscoveryEffectDetailScreen extends StatefulWidget {
  DiscoveryListEntity data;

  DiscoveryEffectDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryEffectDetailState();
}

class DiscoveryEffectDetailState extends State<DiscoveryEffectDetailScreen> with DiscoveryAttrHolder {
  late DiscoveryListEntity data;
  late List<String> images;
  Size? imageSize;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    images = data.images.split(",");
    if (images.isEmpty) {
      CommonExtension().showToast("Oops Failed!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppNavigationBar(backgroundColor: Colors.black),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserInfoHeaderWidget(
              avatar: data.userAvatar,
              name: data.userName,
            ).intoContainer(margin: EdgeInsets.only(left: $(15), right: $(15), top: $(30), bottom: $(15))),
            Text(
              data.text,
              style: TextStyle(
                color: ColorConstant.White,
                fontSize: $(15),
                fontFamily: 'Poppins',
              ),
            ).intoContainer(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(15)),
            ),
            Row(
              children: [
                Expanded(
                    child: CachedNetworkImage(
                  imageUrl: images[0],
                  cacheManager: CachedImageCacheManager(),
                ).listenSizeChanged(onSizeChanged: (size) {
                  setState(() {
                    imageSize = size;
                  });
                })),
                SizedBox(width: $(4)),
                Expanded(
                  child: (images.length > 1 && imageSize != null)
                      ? CachedNetworkImage(
                          imageUrl: images[1],
                          fit: BoxFit.cover,
                          cacheManager: CachedImageCacheManager(),
                        ).intoContainer(
                          width: imageSize!.width,
                          height: imageSize!.height,
                        )
                      : Container(),
                ),
              ],
            ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
            Row(
              children: [
                buildAttr(context, iconRes: Images.ic_tab_discovery_normal, value: data.likes),
                buildAttr(context, iconRes: Images.ic_tab_discovery_normal, value: data.comments),
              ],
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(6))),
            Text(
              'Use the same template',
              style: TextStyle(
                color: ColorConstant.White,
                fontSize: $(16),
                fontFamily: 'Poppins',
              ),
            )
                .intoContainer(
                  padding: EdgeInsets.all($(13)),
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: ColorConstant.DiscoveryBtn,
                    borderRadius: BorderRadius.circular($(8)),
                  ),
                )
                .intoGestureDetector(onTap: () {})
                .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(25))),
          ],
        ),
      ),
    );
  }
}
