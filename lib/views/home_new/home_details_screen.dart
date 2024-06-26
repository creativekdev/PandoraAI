import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/views/home_new/home_detail_screen.dart';

import '../../common/importFile.dart';
import '../../widgets/app_navigation_bar.dart';
import '../../widgets/cacheImage/cached_network_image_utils.dart';
import '../../models/discovery_list_entity.dart';
import 'home_details_controller.dart';

class HomeDetailsScreen extends StatefulWidget {
  const HomeDetailsScreen({
    Key? key,
    required this.source,
    required this.category,
    this.posts,
    required this.title,
    required this.records,
    this.skipDetail = false,
  }) : super(key: key);
  final String source;
  final String category;
  final List<DiscoveryListEntity>? posts;
  final String title;
  final int records;
  final bool skipDetail;

  @override
  State<HomeDetailsScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends AppState<HomeDetailsScreen> {
  HomeDetailsController controller = Get.put(HomeDetailsController());

  @override
  void initState() {
    super.initState();
    controller.posts = widget.posts;
    controller.category = widget.category;
    controller.records = widget.records;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        middle: TitleTextWidget(
          widget.title,
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
                childAspectRatio: widget.title.toLowerCase() == 'facetoon' ? 1 : (ScreenUtil.screenSize.width - $(30)) / (2 * $(300)),
              ),
              itemCount: controller.posts?.length,
              itemBuilder: (context, index) {
                var data = controller.posts![index];
                return HomeDetailItem(data, widget.category).intoGestureDetector(onTap: () {
                  // Events.printGoodsSelectClick(source: widget.source, goodsId: data.id.toString());
                  if (widget.skipDetail) {
                    HomeCardTypeUtils.jump(context: context, source: "${widget.source}_${widget.category}", data: controller.posts![index]);
                  } else {
                    Navigator.of(context).push<void>(MaterialPageRoute(
                        settings: RouteSettings(name: '/HomeDetailScreen'),
                        builder: (context) => HomeDetailScreen(
                              posts: controller.posts!,
                              title: widget.category,
                              source: widget.source,
                              index: index,
                              records: widget.records,
                              titleName: widget.title,
                            )));
                  }
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
  HomeDetailItem(this.post, this.category);

  final String category;

  final DiscoveryListEntity post;

  @override
  Widget build(BuildContext context) {
    List<DiscoveryResource> list = post.resourceList().toList();
    DiscoveryResource? resource = list.firstWhereOrNull((element) => element.type == DiscoveryResourceType.image);
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        $(8),
      ),
      child: CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: resource?.url ?? '',
        // width: (ScreenUtil.screenSize.width - $(30)) / 2,
        // height: category == "facetoon" ? (ScreenUtil.screenSize.width - $(30)) / 2 : $(300),
        fit: BoxFit.cover,
      ),
    );
  }
}
