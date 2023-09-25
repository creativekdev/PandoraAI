import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/croppy/src/model/crop_image_result.dart';
import 'package:cartoonizer/croppy/src/model/croppable_image_data.dart';
import 'package:cartoonizer/croppy/src/widgets/common/animated_croppable_image_viewport.dart';
import 'package:cartoonizer/croppy/src/widgets/common/croppable_image_page_animator.dart';
import 'package:cartoonizer/croppy/src/widgets/cupertino/default_cupertino_croppable_image_controller.dart';
import 'package:cartoonizer/croppy/src/widgets/material/handles/material_image_cropper_handles.dart';

import '../../app/app.dart';
import '../../app/cache/cache_manager.dart';

class CropScreen extends StatelessWidget {
  static Future<XFile?> crop(
    BuildContext context, {
    required XFile image,
    Brightness brightness = Brightness.dark,
  }) async {
    return Navigator.of(context).push<XFile>(MaterialPageRoute(
        settings: RouteSettings(name: '/CropScreen'),
        builder: (_) => CropScreen(
              imageProvider: FileImage(File(image.path)),
              initialData: null,
            )));
  }

  CropScreen({
    super.key,
    required this.imageProvider,
    required this.initialData,
    this.heroTag,
    // this.onCropped,
  });

  final ImageProvider imageProvider;
  final CroppableImageData? initialData;
  final Object? heroTag;
  CacheManager cacheManager = AppDelegate.instance.getManager();

  @override
  Widget build(BuildContext context) {
    return DefaultCupertinoCroppableImageController(
      imageProvider: imageProvider,
      initialData: initialData,
      builder: (context, controller) {
        return CroppableImagePageAnimator(
          controller: controller,
          heroTag: heroTag,
          builder: (context, overlayOpacityAnimation) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: ColorConstant.BackgroundColor,
                actions: [
                  Builder(
                    builder: (context) => TextButton(
                      child: Text(
                        S.of(context).ok1,
                        style: TextStyle(
                          color: ColorConstant.White,
                          fontSize: 16.sp,
                        ),
                      ),
                      onPressed: () async {
                        // Enable the Hero animations
                        CroppableImagePageAnimator.of(context)?.setHeroesEnabled(true);

                        // Crop the image
                        CropImageResult result = await controller.crop();
                        String filePath = cacheManager.storageOperator.tempDir.path + 'crop-screen${DateTime.now().millisecondsSinceEpoch}.png';
                        var file = File(filePath);
                        if (file.existsSync()) {
                          file.deleteSync();
                        }
                        var bytes = await result.uiImage.toByteData(format: ImageByteFormat.png);
                        await file.writeAsBytes(bytes!.buffer.asUint8List());
                        if (context.mounted) {
                          Navigator.of(context).pop(XFile(filePath));
                        }
                      },
                    ),
                  ),
                ],
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: AnimatedCroppableImageViewport(
                    controller: controller,
                    cropHandlesBuilder: (context) => MaterialImageCropperHandles(
                      controller: controller,
                      gesturePadding: 16.0,
                    ),
                    overlayOpacityAnimation: overlayOpacityAnimation,
                    gesturePadding: 16.0,
                    heroTag: heroTag,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
