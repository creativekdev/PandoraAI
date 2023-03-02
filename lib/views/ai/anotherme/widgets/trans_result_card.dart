import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/photo_view/any_photo_pager.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/trans_result_video_build_dialog.dart';

class TransResultCard extends StatefulWidget {
  double width;
  double height;
  Function(TransResultController controller) onCreate;
  File originalImage;

  TransResultCard({
    Key? key,
    required this.onCreate,
    required this.width,
    required this.height,
    required this.originalImage,
  }) : super(key: key);

  @override
  State<TransResultCard> createState() => _TransResultCardState();
}

class _TransResultCardState extends State<TransResultCard> with TickerProviderStateMixin, TransResultController {
  late File originalImage;
  File? resultImage;
  late AnimationController animation;
  late CurvedAnimation alphaAnim;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    originalImage = widget.originalImage;
    width = widget.width;
    height = widget.height;
    animation = AnimationController(vsync: this, duration: Duration(milliseconds: 1800));
    alphaAnim = CurvedAnimation(parent: animation, curve: Curves.easeInQuint);
    widget.onCreate.call(this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: alphaAnim,
            builder: (context, child) => Opacity(
              opacity: 1 - alphaAnim.value,
              child: Image.file(
                originalImage,
                width: width,
                height: height,
                fit: BoxFit.contain,
                // ).hero(tag: AnotherMe.takeItemTag),
              ),
            ),
          ),
          resultImage == null
              ? SizedBox.shrink()
              : AnimatedBuilder(
                  animation: alphaAnim,
                  builder: (context, child) => Opacity(
                        opacity: alphaAnim.value,
                        child: Image.file(
                          resultImage!,
                          width: width,
                          height: height,
                          fit: BoxFit.contain,
                        ),
                      )),
        ],
      ),
    );
  }

  @override
  bindData(File resultImage) {
    setState(() {
      this.resultImage = resultImage;
    });
  }

  @override
  Future<bool> showOriginal({bool anim = false}) async {
    if (resultImage == null) {
      return false;
    }
    if (animation.isDismissed) {
      return false;
    }
    if (!anim) {
      animation.animateBack(0, duration: Duration(milliseconds: 1));
    } else {
      animation.reverse();
    }
    return true;
  }

  @override
  Future<bool> showResult({bool anim = true}) async {
    if (resultImage == null) {
      return false;
    }
    if (animation.isCompleted) {
      return false;
    }
    if (!anim) {
      animation.animateTo(0, duration: Duration(milliseconds: 1));
    } else {
      animation.forward();
    }
    return true;
  }
}

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
      padding: EdgeInsets.all($(12)),
      child: direction == Axis.vertical ? Column(children: children) : Row(children: children),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color(0xFF04F1F9),
          Color(0xFF7F97F3),
          Color(0xFFEC5DD8),
        ]),
      ),
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
