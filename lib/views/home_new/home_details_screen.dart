import 'dart:convert';

import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/views/home_new/home_detail_screen.dart';

import '../../Common/importFile.dart';
import '../../Widgets/app_navigation_bar.dart';
import '../../Widgets/cacheImage/cached_network_image_utils.dart';
import '../../Widgets/router/routers.dart';
import '../../models/discovery_list_entity.dart';
import 'home_details_controller.dart';

class HomeDetailsScreen extends StatefulWidget {
  const HomeDetailsScreen({
    Key? key,
    required this.source,
    required this.category,
    this.posts,
  }) : super(key: key);
  final String source;
  final String category;
  final List<DiscoveryListEntity>? posts;

  @override
  State<HomeDetailsScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends AppState<HomeDetailsScreen> {
  HomeDetailsController controller = HomeDetailsController();

  @override
  void initState() {
    super.initState();
    controller.posts = widget.posts;
    controller.category = widget.category;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        middle: TitleTextWidget(
          widget.category.toUpperCaseFirst,
          ColorConstant.White,
          FontWeight.w500,
          $(17),
        ),
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: $(8)),
        child: GetBuilder<HomeDetailsController>(
          init: controller,
          builder: (controller) {
            return GridView.builder(
              shrinkWrap: true,
              controller: controller.scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //设置列数
                crossAxisCount: 2,
                mainAxisSpacing: $(8),
                crossAxisSpacing: $(8),
                childAspectRatio: widget.category == 'cartoonize' ? 1 : (ScreenUtil.screenSize.width - $(30)) / (2 * $(300)),
              ),
              itemCount: controller.posts?.length,
              itemBuilder: (context, index) {
                var data = controller.posts![index];
                return HomeDetailItem(data).intoGestureDetector(onTap: () {
                  // Events.printGoodsSelectClick(source: widget.source, goodsId: data.id.toString());
                  Navigator.of(context).push<void>(Right2LeftRouter(
                      settings: RouteSettings(name: '/HomeDetailScreen'),
                      child: HomeDetailScreen(
                        post: data,
                        source: widget.source,
                      )));
                });
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<HomeDetailsController>();
  }
}

class HomeDetailItem extends StatelessWidget {
  HomeDetailItem(this.post);

  final DiscoveryListEntity post;

  @override
  Widget build(BuildContext context) {
    List<dynamic> resources = jsonDecode(post.resources) as List<dynamic>;

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        $(8),
      ),
      child: CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: resources.first["url"],
        width: (ScreenUtil.screenSize.width - $(30)) / 2,
        height: $(300),
        fit: BoxFit.cover,
      ),
    );
  }
}
