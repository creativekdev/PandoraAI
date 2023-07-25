import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/views/home_new/home_image_detail_card.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Common/Extension.dart';
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
              builder: (_) {
                return Listener(
                  onPointerUp: (PointerUpEvent event) {
                    if ((controller.posts?.length ?? 0) == (controller.index! + 1)) {
                      CommonExtension().showToast(S.of(context).last_one, gravity: ToastGravity.CENTER);
                    }
                  },
                  child: PageView.builder(
                    controller: controller.pageController,
                    itemBuilder: (BuildContext context, int index) {
                      var discoveryListEntity = controller.posts![index];
                      var resourceList = discoveryListEntity.resourceList();
                      var pick = resourceList.pick((t) => t.type == DiscoveryResourceType.image);
                      return HomeImageDetailCard(
                        width: ScreenUtil.screenSize.width,
                        height: ScreenUtil.screenSize.height,
                        url: pick?.url ?? '',
                        category: widget.title,
                      );
                    },
                    itemCount: controller.posts?.length ?? 0,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      controller.index = index;
                    },
                  ),
                );
              }),
          Positioned(
            top: ScreenUtil.getStatusBarHeight() + $(5),
            left: 0,
            child: GestureDetector(
              child: Image.asset(
                Images.ic_back,
                color: ColorConstant.White,
                width: $(24),
              ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(6), vertical: $(6))),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          Align(
            child: TitleTextWidget(
              widget.title.toUpperCaseFirst,
              ColorConstant.White,
              FontWeight.w500,
              $(17),
            ).intoContainer(margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight() + $(10))),
            alignment: Alignment.topCenter,
          ),
          Positioned(
              bottom: $(30) + ScreenUtil.getBottomPadding(context),
              child: HomeDetailUseButton(tap: () {
                HomeCardTypeUtils.jump(context: context, source: "${widget.source}_${controller.category}", data: controller.posts![widget.index]);
              })),
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

class HomeDetailUseButton extends StatefulWidget {
  HomeDetailUseButton({required this.tap});

  @override
  _HomeDetailUseButton createState() => _HomeDetailUseButton();
  final Function() tap;
}

class _HomeDetailUseButton extends State<HomeDetailUseButton> {
  Color _backgroundColor = ColorConstant.White;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _backgroundColor = ColorConstant.White.withOpacity(0.5);
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _backgroundColor = ColorConstant.White;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTap: widget.tap,
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
            FontWeight.w700,
            $(17),
          ),
        ],
      ).intoContainer(
        width: ScreenUtil.screenSize.width - $(96),
        padding: EdgeInsets.symmetric(vertical: $(12)),
        margin: EdgeInsets.symmetric(horizontal: $(48)),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular($(24)),
          // border: Border.all(
          //   color: ColorConstant.White,
          // ),
        ),
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
      borderRadius: BorderRadius.circular($(8)),
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
              child: Image.asset(
                Images.ic_swipe,
                color: ColorConstant.White,
                width: $(30),
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
