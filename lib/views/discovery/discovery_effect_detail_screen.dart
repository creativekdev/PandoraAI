import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/photo_view/photo_pager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/discovery/discovery_comments_list_screen.dart';
import 'package:cartoonizer/views/discovery/user_discovery_screen.dart';
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
      appBar: AppNavigationBar(
        backgroundColor: Colors.black,
        middle: TitleTextWidget(StringConstant.discoveryDetails, ColorConstant.BtnTextColor, FontWeight.w600, $(18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserInfoHeaderWidget(
              avatar: data.userAvatar,
              name: data.userName,
            ).intoGestureDetector(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => UserDiscoveryScreen(userId: data.userId),
                  settings: RouteSettings(name: "/UserDiscoveryScreen"),
                ),
              );
            }).intoContainer(margin: EdgeInsets.only(left: $(15), right: $(15), top: $(25), bottom: 0)),
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
                }).intoGestureDetector(onTap: () => open(context, 0))),
                SizedBox(width: $(2)),
                Expanded(
                  child: (images.length > 1 && imageSize != null)
                      ? CachedNetworkImage(
                          imageUrl: images[1],
                          fit: BoxFit.cover,
                          cacheManager: CachedImageCacheManager(),
                        )
                          .intoContainer(
                            width: imageSize!.width,
                            height: imageSize!.height,
                          )
                          .intoGestureDetector(onTap: () => open(context, 1))
                      : Container(),
                ),
              ],
            ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
            Row(
              children: [
                buildAttr(context, iconRes: Images.ic_discovery_comment, value: data.comments, axis: Axis.horizontal, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => DiscoveryCommentsListScreen(socialPostId: data.id),
                      settings: RouteSettings(name: "/DiscoveryCommentsListScreen"),
                    ),
                  );
                }),
                SizedBox(width: $(15)),
                buildAttr(context, iconRes: Images.ic_discovery_like, value: data.likes, axis: Axis.horizontal),
              ],
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(6))),
            OutlineWidget(
              strokeWidth: $(2),
              radius: $(6),
              gradient: LinearGradient(
                colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) => LinearGradient(
                  colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(Offset.zero & bounds.size),
                blendMode: BlendMode.srcATop,
                child: TitleTextWidget(
                  StringConstant.discoveryDetailsUseSameTemplate,
                  Color(0xffffffff),
                  FontWeight.w700,
                  $(16),
                ).intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(12)),
                ),
              ),
            )
                .intoGestureDetector(
                  onTap: () {},
                )
                .intoContainer(
                  margin: EdgeInsets.only(left: $(15), right: $(15), top: $(45), bottom: $(20)),
                ),
          ],
        ),
      ),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => GalleryPhotoViewWrapper(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
