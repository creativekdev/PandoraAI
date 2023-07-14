import 'dart:convert';

import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/utils/string_ex.dart';

import '../../Common/importFile.dart';
import '../../Widgets/cacheImage/cached_network_image_utils.dart';
import '../../images-res.dart';
import '../../models/discovery_list_entity.dart';
import '../../models/enums/home_card_type.dart';
import 'home_detail_controller.dart';

class HomeDetailScreen extends StatefulWidget {
  const HomeDetailScreen({Key? key, required this.posts, required this.source, required this.title, required this.index}) : super(key: key);
  final List<DiscoveryListEntity> posts;
  final String title;
  final String source;
  final int index;

  @override
  State<HomeDetailScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends AppState<HomeDetailScreen> {
  late HomeDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = HomeDetailController(index: widget.index, posts: widget.posts, categoryVaule: widget.title);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          GetBuilder<HomeDetailController>(
              init: controller,
              builder: (context) {
                return PageView.builder(
                  controller: controller.pageController,
                  itemBuilder: (BuildContext context, int index) {
                    List<dynamic> resources = jsonDecode(controller.posts![index].resources) as List<dynamic>;
                    return CachedNetworkImageUtils.custom(
                      useOld: true,
                      context: context,
                      imageUrl: resources.first["url"],
                      height: ScreenUtil.screenSize.height,
                      fit: BoxFit.cover,
                    );
                  },
                  itemCount: controller.posts?.length ?? 0,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    controller.index = index;
                  },
                );
              }),
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
            top: ScreenUtil.getStatusBarHeight() + $(5),
            left: $(45),
            right: $(45),
            child: GestureDetector(
              child: TitleTextWidget(
                widget.title.toUpperCaseFirst,
                ColorConstant.White,
                FontWeight.w500,
                $(17),
              ),
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
              HomeCardTypeUtils.jump(context: context, source: "${widget.source}_${controller.category}", data: controller.posts![widget.index]);
            }),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<HomeDetailController>();
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
