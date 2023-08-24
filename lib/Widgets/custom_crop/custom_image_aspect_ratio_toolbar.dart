import 'package:cartoonizer/croppy/croppy.dart';
import 'package:cartoonizer/images-res.dart';

import '../../Common/importFile.dart';
import '../progress/circle_progress_bar.dart';

class CustomImageAspectRatioToolbar extends StatelessWidget {
  const CustomImageAspectRatioToolbar({
    super.key,
    required this.controller,
  });

  final AspectRatioMixin controller;

  CropAspectRatio? get _aspectRatio => controller.currentAspectRatio;

  String _convertAspectRatioToString(CropAspectRatio? aspectRatio) {
    if (aspectRatio == null) {
      return 'FREEFORM';
    }

    final width = aspectRatio.width;
    final height = aspectRatio.height;

    final imageSize = controller.data.imageSize;

    if ((width == imageSize.width && height == imageSize.height) || (width == imageSize.height && height == imageSize.width) || (width == -1 && height == -1)) {
      return 'ORIGINAL';
    }
    return '$width:$height';
  }

  List<Widget> _buildAspectRatioChips(BuildContext context) {
    final aspectRatios = controller.allowedAspectRatios;
    final imageSize = controller.data.imageSize;
    // final displayedAspectRatios = <CropAspectRatio?>[];
    //
    // displayedAspectRatios.insert(0, CropAspectRatio(width: imageSize.width.toInt(), height: imageSize.height.toInt()));
    //
    // displayedAspectRatios.addAll(aspectRatios);

    return aspectRatios
        .map(
          (aspectRatio) => _AspectRatioChipWidget(
            aspectRatio: _convertAspectRatioToString(aspectRatio),
            isSelected: aspectRatio == _aspectRatio,
            rWidth: aspectRatio?.width ?? -1,
            rHeight: aspectRatio?.height ?? -1,
            isHorizontal: aspectRatio?.isHorizontal ?? true,
            onTap: () {
              controller.currentAspectRatio = aspectRatio;
            },
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.aspectRatioNotifier,
      builder: (context, _, __) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: $(23.0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildAspectRatioChips(context),
          ),
        ),
      ),
    );
  }
}

class _AspectRatioChipWidget extends StatelessWidget {
  const _AspectRatioChipWidget({
    required this.aspectRatio,
    required this.onTap,
    this.isSelected = false,
    required this.rWidth,
    required this.rHeight,
    required this.isHorizontal,
  });

  final String aspectRatio;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHorizontal;
  final int rWidth;
  final int rHeight;

  @override
  Widget build(BuildContext context) {
    double width = $(18);
    double height = $(18);
    if (aspectRatio != "ORIGINAL") {
      if (isHorizontal) {
        width = $(18) * rWidth / rHeight;
      } else {
        height = $(18) * rHeight / rWidth;
      }
    }
    return Container(
      width: $(60),
      height: $(60),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AppCircleProgressBar(
                size: $(44),
                backgroundColor: Color(0xffa2a2a2).withOpacity(0.3),
                progress: isSelected ? 1 : 0,
                ringWidth: 1.4,
                loadingColors: [
                  Color(0xFFE31ECD),
                  Color(0xFF243CFF),
                  Color(0xFFE31ECD),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(4)),
                      border: Border.all(
                        style: BorderStyle.solid,
                        color: Color(0xffa2a2a2).withOpacity(0.3),
                        width: 1,
                      )),
                ),
              ),
              Align(
                child: buildIcon(aspectRatio, context, isSelected),
                alignment: Alignment.center,
              ),
            ],
          ),
        ],
      ).intoGestureDetector(onTap: onTap),
    );
  }

  Widget buildIcon(String aspectRatio, BuildContext context, bool check) {
    if (aspectRatio == "ORIGINAL") {
      return Image.asset(
        Images.ic_crop_original,
        width: $(16),
        color: Colors.white,
      );
    } else {
      return Text(
        aspectRatio,
        style: TextStyle(
          color: Colors.white,
          fontSize: $(12),
        ),
      );
    }
  }
}
