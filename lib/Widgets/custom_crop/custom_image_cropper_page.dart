import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/croppy/croppy.dart';

import '../../images-res.dart';
import '../app_navigation_bar.dart';
import 'custom_crop_toolbar.dart';

const kCupertinoImageCropperBackgroundColor = Color(0xFF0A0A0A);

class MyImageCropperPage extends StatelessWidget {
  const MyImageCropperPage({
    super.key,
    required this.controller,
    required this.shouldPopAfterCrop,
    this.gesturePadding = 3.0,
    this.heroTag,
  });

  final CroppableImageController controller;
  final double gesturePadding;
  final Object? heroTag;
  final bool shouldPopAfterCrop;

  @override
  Widget build(BuildContext context) {
    return CroppableImagePageAnimator(
      controller: controller,
      heroTag: heroTag,
      builder: (context, overlayOpacityAnimation) {
        return Scaffold(
          backgroundColor: kCupertinoImageCropperBackgroundColor,
          // navigationBar: CupertinoImageCropperAppBar(
          //   controller: controller,
          // ),
          appBar: AppNavigationBar(
            backAction: () {
              Navigator.of(context).pop();
            },
            trailing: Image.asset(Images.ic_edit_submit, width: $(22), height: $(22))
                .intoContainer(
              padding: EdgeInsets.all($(8)),
              color: Colors.transparent,
            )
                .intoGestureDetector(onTap: () async {
              CroppableImagePageAnimator.of(context)?.setHeroesEnabled(true);

              final result = await controller.crop();

              if (context.mounted && shouldPopAfterCrop) {
                Navigator.of(context).pop(result);
              }
            }),
          ),
          body: Column(
            children: [
              Expanded(
                child: RepaintBoundary(
                  child: AnimatedCroppableImageViewport(
                    controller: controller,
                    overlayOpacityAnimation: overlayOpacityAnimation,
                    gesturePadding: gesturePadding,
                    heroTag: heroTag,
                    cropHandlesBuilder: (context) => CupertinoImageCropHandles(
                      controller: controller,
                      gesturePadding: gesturePadding,
                    ),
                  ),
                ),
              ),
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: overlayOpacityAnimation,
                  builder: (context, _) => Opacity(
                    opacity: overlayOpacityAnimation.value,
                    child: Container(
                      height: $(140) + ScreenUtil.getBottomPadding(context),
                      padding: EdgeInsets.only(top: $(7)),
                      alignment: Alignment.topCenter,
                      width: ScreenUtil.screenSize.width,
                      child: CustomCropToolbar(
                        controller: controller,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
