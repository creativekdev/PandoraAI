import 'dart:convert';

import 'package:cartoonizer/Widgets/state/app_state.dart';

import '../../Common/importFile.dart';
import '../../Widgets/cacheImage/cached_network_image_utils.dart';
import '../../images-res.dart';
import '../../models/discovery_list_entity.dart';
import '../../models/enums/home_card_type.dart';

class HomeDetailScreen extends StatefulWidget {
  const HomeDetailScreen({Key? key, required this.post, required this.source}) : super(key: key);
  final DiscoveryListEntity post;
  final String source;

  @override
  State<HomeDetailScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends AppState<HomeDetailScreen> {
  @override
  Widget buildWidget(BuildContext context) {
    List<dynamic> resources = jsonDecode(widget.post.resources) as List<dynamic>;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          CachedNetworkImageUtils.custom(
            context: context,
            imageUrl: resources.first["url"],
            height: ScreenUtil.screenSize.height,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: ScreenUtil.getStatusBarHeight() + $(5),
            left: $(15),
            child: GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
                color: ColorConstant.White,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            bottom: $(49),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Images.ic_use,
                  width: 20,
                  height: 20,
                  color: ColorConstant.BackgroundColor,
                ),
                SizedBox(width: $(8)),
                TitleTextWidget(
                  S.of(context).use_style,
                  ColorConstant.BackgroundColor,
                  FontWeight.w500,
                  $(17),
                ),
              ],
            )
                .intoContainer(
              width: ScreenUtil.screenSize.width - $(96),
              height: $(48),
              margin: EdgeInsets.symmetric(horizontal: $(48)),
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(
                  $(24),
                ),
                border: Border.all(
                  color: ColorConstant.White,
                ),
              ),
            )
                .intoGestureDetector(onTap: () {
              HomeCardTypeUtils.jump(context: context, source: "${widget.source}_${widget.post.category}", data: widget.post);
            }),
          )
        ],
      ),
    );
  }
}

class HomeDetailItem extends StatelessWidget {
  HomeDetailItem(this.imageUrl);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        $(8),
      ),
      child: CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: imageUrl,
        width: (ScreenUtil.screenSize.width - $(20)) / 2,
        height: $(300),
        fit: BoxFit.fill,
      ),
    );
  }
}
