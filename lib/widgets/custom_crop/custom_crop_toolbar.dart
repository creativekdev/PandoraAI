import 'package:cartoonizer/croppy/croppy.dart';
import 'package:flutter/material.dart';

import 'custom_image_aspect_ratio_toolbar.dart';

class CustomCropToolbar extends StatelessWidget {
  const CustomCropToolbar({
    super.key,
    required this.controller,
  });

  final CroppableImageController controller;

  @override
  Widget build(BuildContext context) {
    if (controller is! CupertinoCroppableImageController) {
      return CupertinoImageTransformationToolbar(controller: controller);
    }

    return ValueListenableBuilder(
      valueListenable: (controller as CupertinoCroppableImageController).toolbarNotifier,
      builder: (context, toolbar, child) {
        final Widget child = CustomImageAspectRatioToolbar(
          controller: controller as AspectRatioMixin,
        );
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: child,
        );
      },
    );
  }
}
