import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';

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
                ).hero(tag: AnotherMe.takeItemTag)),
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
    if (originalImage == null || resultImage == null) {
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
    if (originalImage == null || resultImage == null) {
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
