import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/outline_widget.dart';
import 'package:cartoonizer/images-res.dart';

class AMOptContainer extends StatefulWidget {
  GestureTapCallback onChoosePhotoTap;

  // GestureTapCallback onShareTap;
  GestureTapCallback onSharePrintTap;

  GestureTapCallback onDownloadTap;
  GestureTapCallback onGenerateAgainTap;

  AMOptContainer({
    Key? key,
    required this.onChoosePhotoTap,
    required this.onDownloadTap,
    required this.onSharePrintTap,
    required this.onGenerateAgainTap,
    // required this.onShareTap,
  }) : super(key: key);

  @override
  State<AMOptContainer> createState() => AMOptContainerState();
}

class AMOptContainerState extends State<AMOptContainer> with SingleTickerProviderStateMixin {
  late GestureTapCallback onChoosePhotoTap;

  late GestureTapCallback onSharePrintTap;

  late GestureTapCallback onDownloadTap;
  late GestureTapCallback onGenerateAgainTap;
  late AnimationController _animationController;
  late CurvedAnimation _anim;
  Completer<void>? completer;

  @override
  void initState() {
    super.initState();
    onChoosePhotoTap = widget.onChoosePhotoTap;
    onSharePrintTap = widget.onSharePrintTap;
    onDownloadTap = widget.onDownloadTap;
    onGenerateAgainTap = widget.onGenerateAgainTap;
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _anim = CurvedAnimation(parent: _animationController, curve: Curves.elasticIn);
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        if (completer == null) {
          return;
        }
        if (!completer!.isCompleted) {
          completer?.complete();
        }
      }
    });
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> dismiss() async {
    completer = Completer();
    _animationController.reverse();
    return completer!.future;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: $(16)),
                Transform.translate(
                  offset: Offset(0, (1 - _animationController.value) * $(106)),
                  child: Image.asset(Images.ic_camera, width: $(24))
                      .intoContainer(
                        alignment: Alignment.center,
                        width: $(48),
                        height: $(48),
                      )
                      .intoGestureDetector(onTap: onChoosePhotoTap),
                ),
                SizedBox(width: $(16)),
                Transform.translate(
                  offset: Offset(0, (1 - _animationController.value) * $(106)),
                  child: Image.asset(Images.ic_share_print, width: $(24))
                      .intoContainer(
                        alignment: Alignment.center,
                        width: $(48),
                        height: $(48),
                      )
                      .intoGestureDetector(onTap: onSharePrintTap),
                ),
                SizedBox(width: $(16)),
                Transform.translate(
                  offset: Offset(0, (1 - _animationController.value) * $(106)),
                  child: Image.asset(Images.ic_download, width: $(24))
                      .intoContainer(
                        alignment: Alignment.center,
                        width: $(48),
                        height: $(48),
                      )
                      .intoGestureDetector(onTap: onDownloadTap),
                ),
                SizedBox(width: $(16)),
              ],
            ),
            SizedBox(height: $(10)),
            Transform.translate(
              offset: Offset(0, (1 - _animationController.value) * $(90)),
              child: OutlineWidget(
                radius: $(8),
                strokeWidth: $(2),
                gradient: LinearGradient(
                  colors: [Color(0xFF04F1F9), Color(0xFF7F97F3), Color(0xFFEC5DD8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Text(
                  S.of(context).generate_again,
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(17),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ).intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all($(10)),
                ),
              ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))).intoGestureDetector(onTap: onGenerateAgainTap),
            ),
            SizedBox(height: 6),
          ],
        ).intoContainer(width: ScreenUtil.screenSize.width);
      },
    );
  }
}
