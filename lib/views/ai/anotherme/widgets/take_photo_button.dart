import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/progress/circle_progress_bar.dart';

typedef BoolCallback = Future<bool> Function();

class TakePhotoButton extends StatefulWidget {
  Function onTakePhoto;
  BoolCallback onTakeVideoStart;
  Function onTakeVideoEnd;
  double size;
  int maxSecond;

  TakePhotoButton({
    Key? key,
    required this.size,
    required this.onTakePhoto,
    required this.onTakeVideoStart,
    required this.onTakeVideoEnd,
    required this.maxSecond,
  }) : super(key: key);

  @override
  State<TakePhotoButton> createState() => _TakePhotoButtonState();
}

class _TakePhotoButtonState extends State<TakePhotoButton> with SingleTickerProviderStateMixin {
  late Function onTakePhoto;
  late BoolCallback onTakeVideoStart;
  late Function onTakeVideoEnd;
  late double size;
  late int maxSecond;

  late AnimationController animationController;

  int? downStamp;
  int? longTapStamp;
  bool onTapDown = false;

  @override
  void initState() {
    super.initState();
    loadData();
    animationController = AnimationController(vsync: this, duration: Duration(seconds: maxSecond));
  }

  @override
  void didUpdateWidget(covariant TakePhotoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  loadData() {
    maxSecond = widget.maxSecond;
    size = widget.size;
    onTakePhoto = widget.onTakePhoto;
    onTakeVideoStart = widget.onTakeVideoStart;
    onTakeVideoEnd = widget.onTakeVideoEnd;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        setState(() {
          onTapDown = true;
        });
        return;
        downStamp = DateTime.now().millisecondsSinceEpoch;
        delay(() {
          if (downStamp == null) {
            return;
          }
          onTakeVideoStart.call().then((value) {
            if (value) {
              longTapStamp = DateTime.now().millisecondsSinceEpoch;
              animationController.forward();
            } else {
              downStamp = null;
              longTapStamp = null;
            }
          });
        }, milliseconds: 200);
      },
      onPointerUp: (event) {
        setState(() {
          onTapDown = false;
        });
        return;
        if (downStamp == null) {
          return;
        }
        if (longTapStamp == null) {
          onTakePhoto.call();
          downStamp = null;
        } else {
          onTakeVideoEnd.call();
          animationController.stop();
        }
      },
      onPointerCancel: (event) {
        setState(() {
          onTapDown = false;
        });
        return;
        if (longTapStamp != null) {
          onTakeVideoEnd.call();
          animationController.stop();
          downStamp = null;
          longTapStamp = null;
        }
      },
      child: Stack(
        children: [
          Container(
            width: size - 8 - (onTapDown ? 4 : 0),
            height: size - 8 - (onTapDown ? 4 : 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(64),
            ),
          ).intoContainer(
            padding: EdgeInsets.all(4 + (onTapDown ? 2 : 0)),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(64)),
          ),
          AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return AppCircleProgressBar(
                  size: size - 4,
                  ringWidth: 4,
                  progress: animationController.value,
                  backgroundColor: Colors.transparent,
                  loadingColors: [
                    Colors.green,
                    Colors.green,
                  ],
                ).intoContainer(padding: EdgeInsets.all(2));
              }),
        ],
      )
          .intoContainer(
        width: size,
        height: size,
      )
          .intoGestureDetector(onTap: () {
        onTakePhoto.call();
      }),
    );
  }
}
