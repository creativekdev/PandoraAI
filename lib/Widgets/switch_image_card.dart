import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class SwitchImageCard extends StatefulWidget {
  File origin;
  File? result;

  SwitchImageCard({
    Key? key,
    required this.origin,
    required this.result,
  }) : super(key: key);

  @override
  State<SwitchImageCard> createState() => _SwitchImageCardState();
}

class _SwitchImageCardState extends State<SwitchImageCard> {
  late File origin;
  late File? result;
  bool showOrigin = false;

  @override
  void initState() {
    super.initState();
    origin = widget.origin;
    result = widget.result;
  }

  @override
  void didUpdateWidget(covariant SwitchImageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    origin = widget.origin;
    result = widget.result;
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
          bottom: $(12),
          right: $(12),
        )
      ],
    );
    return const Placeholder();
  }
}
