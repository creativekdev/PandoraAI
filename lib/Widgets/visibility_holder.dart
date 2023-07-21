import 'package:cartoonizer/common/importFile.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VisibilityHolder extends StatefulWidget {
  final String keyString;
  final Widget child;
  final Widget placeHolder;

  const VisibilityHolder({
    super.key,
    required this.child,
    required this.keyString,
    required this.placeHolder,
  });

  @override
  State<VisibilityHolder> createState() => _VisibilityHolderState();
}

class _VisibilityHolderState extends State<VisibilityHolder> {
  bool visible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(widget.keyString),
        child: visible ? widget.child : widget.placeHolder,
        onVisibilityChanged: (info) {
          var _visible = info.visibleFraction != 0;
          if (visible != _visible) {
            setState(() {
              visible = _visible;
            });
          }
        });
  }
}
