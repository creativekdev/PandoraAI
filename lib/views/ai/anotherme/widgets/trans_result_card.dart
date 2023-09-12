import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/photo_view/any_photo_pager.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';

abstract class TransResultController {
  bindData(File resultImage);

  Future<bool> showResult({bool anim = true});

  Future<bool> showOriginal({bool anim = false});
}

class TransResultNewCard extends StatelessWidget {
  double width;
  double height;
  File originalImage;
  File resultImage;
  Axis direction;
  double dividerSize;

  TransResultNewCard({
    Key? key,
    required this.width,
    required this.height,
    required this.originalImage,
    required this.direction,
    required this.resultImage,
    required this.dividerSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular($(8)),
          child: Image.file(
            originalImage,
            width: direction == Axis.vertical ? double.maxFinite : null,
            height: direction == Axis.horizontal ? double.maxFinite : null,
            fit: BoxFit.cover,
          ).hero(tag: AnotherMe.takeItemTag).intoGestureDetector(onTap: () {
            openImage(context, 0);
          }),
        ),
      ),
      SizedBox(
        width: direction == Axis.horizontal ? dividerSize : double.maxFinite,
        height: direction == Axis.vertical ? dividerSize : double.maxFinite,
      ),
      Expanded(
        child: ClipRRect(
            borderRadius: BorderRadius.circular($(6)),
            child: Image.file(
              resultImage,
              width: direction == Axis.vertical ? double.maxFinite : null,
              height: direction == Axis.horizontal ? double.maxFinite : null,
              fit: BoxFit.cover,
            ).hero(tag: resultImage.path).intoGestureDetector(onTap: () {
              openImage(context, 1);
            })),
      ),
    ];
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all($(10)),
      child: direction == Axis.vertical ? Column(children: children) : Row(children: children),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(colors: [
      //     Color(0xFF04F1F9),
      //     Color(0xFF7F97F3),
      //     Color(0xFFEC5DD8),
      //   ]),
      // ),
    );
  }

  void openImage(BuildContext context, final int index) async {
    Events.metaverseCompletePreview();
    List<AnyPhotoItem> images =
        [originalImage, resultImage].transfer((e, index) => AnyPhotoItem(type: AnyPhotoType.file, uri: e.path, tag: index == 0 ? AnotherMe.takeItemTag : null));
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => AnyGalleryPhotoViewWrapper(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index >= images.length ? 0 : index,
        ),
      ),
    );
  }
}
