import 'dart:io';

import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class SwitchImageCard extends StatefulWidget {
  File origin;
  File? result;
  Size? imageStackSize;

  SwitchImageCard({
    Key? key,
    required this.origin,
    required this.result,
    this.imageStackSize,
  }) : super(key: key);

  @override
  State<SwitchImageCard> createState() => _SwitchImageCardState();
}

class _SwitchImageCardState extends State<SwitchImageCard> {
  late File origin;
  late File? result;
  bool showOrigin = false;
  double? originImageScale;
  Size? imageStackSize;
  double imagePosBottom = 0;
  double imagePosRight = 0;

  @override
  void initState() {
    super.initState();
    origin = widget.origin;
    result = widget.result;
    update();
  }

  @override
  void didUpdateWidget(covariant SwitchImageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    origin = widget.origin;
    result = widget.result;
    update();
  }

  update() {
    imageStackSize = widget.imageStackSize;
    SyncFileImage(file: origin).getImage().then((value) {
      originImageScale = value.image.width / value.image.height;
      calculatePosY();
    });
  }

  calculatePosY() {
    if (originImageScale == null || imageStackSize == null) {
      return;
    }
    double sizeScale = imageStackSize!.width / imageStackSize!.height;
    if (originImageScale! > sizeScale) {
      var height = imageStackSize!.width / originImageScale!;
      imagePosBottom = (imageStackSize!.height - height) / 2;
      imagePosRight = 0;
    } else {
      var width = imageStackSize!.height * originImageScale!;
      imagePosRight = (imageStackSize!.width - width) / 2;
      imagePosBottom = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var originImage = Stack(
      fit: StackFit.expand,
      children: [
        Image.file(origin, fit: BoxFit.fill),
        Image.file(
          origin,
          fit: BoxFit.contain,
        ).intoCenter().blur(),
      ],
    );
    if (result == null) {
      return originImage;
    }
    var showFile = showOrigin ? origin : result!;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(showFile, fit: BoxFit.fill),
        Image.file(
          showFile,
          fit: BoxFit.contain,
        ).intoCenter().blur(),
        Positioned(
          child: Listener(
            onPointerDown: (details) {
              setState(() {
                showOrigin = true;
              });
            },
            onPointerCancel: (details) {
              setState(() {
                showOrigin = false;
              });
            },
            onPointerUp: (details) {
              setState(() {
                showOrigin = false;
              });
            },
            child: Image.asset(
              Images.ic_switch_images,
              width: $(28),
            ).intoContainer(padding: EdgeInsets.all($(10))).intoMaterial(
                  color: Color(0x66000000),
                  borderRadius: BorderRadius.circular($(32)),
                ),
          ),
          bottom: imagePosBottom + $(12),
          right: imagePosRight + $(12),
        )
      ],
    );
    return const Placeholder();
  }
}
