import 'dart:io';

import 'package:cartoonizer/widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/img_utils.dart';

class SwitchImageCard extends StatefulWidget {
  File origin;
  File? result;
  bool containsOrigin;
  GlobalKey? cropKey;

  SwitchImageCard({
    Key? key,
    required this.origin,
    required this.result,
    this.containsOrigin = false,
    this.cropKey,
  }) : super(key: key);

  @override
  State<SwitchImageCard> createState() => _SwitchImageCardState();
}

class _SwitchImageCardState extends State<SwitchImageCard> {
  File? origin;
  File? result;
  bool showOrigin = false;
  bool containsOrigin = false;
  Size resultSize = Size(1, 1);
  Size currentSize = Size(1, 1);
  Rect targetCoverRect = Rect.fromLTWH(0, 0, 1, 1);
  GlobalKey? cropKey;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    cropKey = widget.cropKey;
    containsOrigin = widget.containsOrigin;
    if (origin != widget.origin) {
      origin = widget.origin;
    }
    if (result?.path != widget.result?.path) {
      result = widget.result;
      if (result != null) {
        SyncFileImage(file: result!).getImage().then((value) {
          if (mounted) {
            setState(() {
              resultSize = Size(value.image.width.toDouble(), value.image.height.toDouble());
              currentSize = ScreenUtil.getCurrentWidgetSize(context);
              targetCoverRect = ImageUtils.getTargetCoverRect(currentSize, resultSize);
            });
          }
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant SwitchImageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.origin != origin || widget.result != result || widget.containsOrigin != containsOrigin) {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    var originImage = Stack(
      fit: StackFit.expand,
      children: [
        Image.file(origin!, fit: BoxFit.fill),
        Image.file(
          origin!,
          fit: BoxFit.contain,
        ).intoCenter().blur(),
      ],
    );
    if (result == null) {
      return originImage;
    }
    File showFile = showOrigin ? origin! : result!;
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
          bottom: $(12),
          right: $(12),
        ),
        if (!showOrigin && containsOrigin)
          Positioned(
            left: (currentSize.width - targetCoverRect.width) / 2 + $(15),
            bottom: (currentSize.height - targetCoverRect.height) / 2 + $(15),
            child: Container(
              width: $(65),
              height: $(65),
              child: RepaintBoundary(
                key: cropKey,
                child: ClipOval(
                  child: Image.file(origin!, fit: BoxFit.cover),
                ),
              ),
            ),
          )
      ],
    );
    return const Placeholder();
  }
}
