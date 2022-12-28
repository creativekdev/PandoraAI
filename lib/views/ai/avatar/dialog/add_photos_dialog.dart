import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_controller.dart';

class AddPhotosDialog extends StatelessWidget {
  AvatarAiController controller;

  AddPhotosDialog({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AvatarAiController>(
      builder: (controller) {
        return Column(
          children: [
            SizedBox(height: $(27)),
            Image.asset(
              Images.ic_warning,
              width: $(28),
              color: ColorConstant.Red,
            ).intoContainer(
                padding: EdgeInsets.all($(10)),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(64),
                    border: Border.all(
                      color: ColorConstant.Red,
                      width: 1.5,
                    ))),
            SizedBox(height: $(12)),
            TitleTextWidget(
              S.of(context).not_enough_photos,
              ColorConstant.Red,
              FontWeight.w500,
              $(18),
              maxLines: 5,
            ),
            SizedBox(height: $(20)),
            TitleTextWidget(
              S
                  .of(context)
                  .choose_photo_not_enough_desc
                  .replaceAll(
                    '%selected',
                    '${controller.imageList.length}',
                  )
                  .replaceAll('%minSize', '${controller.minSize}'),
              ColorConstant.White,
              FontWeight.normal,
              $(14),
              maxLines: 5,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
            SizedBox(height: 12),
            TitleTextWidget(
              S.of(context).choose_photo_more_photos.replaceAll(
                    "%d",
                    '${controller.minSize - controller.imageList.length}',
                  ),
              ColorConstant.White,
              FontWeight.normal,
              $(14),
              maxLines: 5,
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
            SizedBox(height: 6),
            Divider(
              height: 1,
              color: ColorConstant.LineColor,
            ),
            TitleTextWidget(
              S.of(context).cancel,
              ColorConstant.BlueColor,
              FontWeight.w500,
              $(17),
            ).intoContainer(padding: EdgeInsets.symmetric(vertical: 10), width: double.maxFinite, color: Colors.transparent).intoGestureDetector(onTap: () {
              Navigator.of(context).pop(false);
            }),
            Divider(
              height: 1,
              color: ColorConstant.LineColor,
            ),
            TitleTextWidget(
              S.of(context).select_more_photos,
              ColorConstant.BlueColor,
              FontWeight.w500,
              $(17),
            ).intoContainer(padding: EdgeInsets.symmetric(vertical: 10), width: double.maxFinite, color: Colors.transparent).intoGestureDetector(onTap: () {
              controller.pickImageFromGallery(context).then((value) {
                if (controller.imageList.length >= controller.minSize) {
                  Navigator.of(context).pop(true);
                }
              });
            }),
          ],
          mainAxisSize: MainAxisSize.min,
        );
      },
      init: controller,
    )
        .intoContainer(
          margin: EdgeInsets.symmetric(horizontal: $(35), vertical: $(15)),
          decoration: BoxDecoration(color: ColorConstant.BackgroundColor, borderRadius: BorderRadius.circular(8)),
        )
        .intoCenter()
        .intoMaterial(color: Colors.transparent);
  }

  Widget item(
    BuildContext context,
    File file, {
    GestureTapCallback? onDeleteTap,
  }) {
    return Stack(
      children: [
        Image.file(
          file,
          width: double.maxFinite,
          height: double.maxFinite,
          fit: BoxFit.cover,
        ),
        Positioned(
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: $(14),
          )
              .intoContainer(padding: EdgeInsets.all(2), decoration: BoxDecoration(color: Color(0x77000000), borderRadius: BorderRadius.circular(32)))
              .intoGestureDetector(onTap: onDeleteTap),
          top: 2,
          right: 2,
        ),
      ],
    );
  }
}
