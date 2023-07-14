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
          ),
          GetBuilder<HomeDetailController>(
              init: controller,
              builder: (context) {
                if (!controller.isShowedGuide) {
                  return SwipeGuideAnimation();
                }
                return SizedBox();
              }),
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

class SwipeGuideAnimation extends StatefulWidget {
  @override
  _SwipeGuideAnimationState createState() => _SwipeGuideAnimationState();
}

class _SwipeGuideAnimationState extends State<SwipeGuideAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        _animationController.forward();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(
            color: Colors.black45,
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: $(150)),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0.0, ScreenUtil.screenSize.height * _animation.value * 0.3),
                  child: child,
                );
              },
              child: Icon(
                Icons.swipe_up_outlined,
                color: ColorConstant.White,
                size: $(30),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: $(150)),
              child: TitleTextWidget(S.of(context).swipe_up_for_more, ColorConstant.White, FontWeight.w600, $(14)),
            ),
          ),
        ],
      ),
    );
  }
}
