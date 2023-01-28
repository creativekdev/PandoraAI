import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class AMOptContainer extends StatefulWidget {
  GestureTapCallback onChoosePhotoTap;
  GestureTapCallback onShareTap;
  GestureTapCallback onShareDiscoveryTap;
  GestureTapCallback onDownloadTap;
  GestureTapCallback onGenerateAgainTap;

  AMOptContainer({
    Key? key,
    required this.onChoosePhotoTap,
    required this.onDownloadTap,
    required this.onShareDiscoveryTap,
    required this.onGenerateAgainTap,
    required this.onShareTap,
  }) : super(key: key);

  @override
  State<AMOptContainer> createState() => AMOptContainerState();
}

class AMOptContainerState extends State<AMOptContainer> with SingleTickerProviderStateMixin {
  late GestureTapCallback onChoosePhotoTap;
  late GestureTapCallback onShareTap;
  late GestureTapCallback onShareDiscoveryTap;
  late GestureTapCallback onDownloadTap;
  late GestureTapCallback onGenerateAgainTap;
  late AnimationController _animationController;
  late CurvedAnimation _anim;
  Completer<void>? completer;

  @override
  void initState() {
    super.initState();
    onChoosePhotoTap = widget.onChoosePhotoTap;
    onShareTap = widget.onShareTap;
    onShareDiscoveryTap = widget.onShareDiscoveryTap;
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
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Transform.translate(
              offset: Offset(-(1 - _animationController.value) * $(62), 0),
              child: Image.asset(
                Images.ic_camera,
                width: $(24),
              )
                  .intoContainer(
                      alignment: Alignment.center,
                      width: $(48),
                      height: $(48),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Color(0x88000000),
                      ))
                  .intoGestureDetector(onTap: onChoosePhotoTap),
            ),
            SizedBox(width: $(16)),
            Expanded(
              child: Transform.translate(
                offset: Offset(0, (1 - _animationController.value) * $(90)),
                child: Text(
                  S.of(context).generate_again,
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(17),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .intoContainer(
                      height: $(48),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Color(0x88000000),
                      ),
                    )
                    .intoGestureDetector(onTap: onGenerateAgainTap),
              ),
            ),
            SizedBox(width: $(16)),
            Column(
              children: [
                Transform.translate(
                  offset: Offset((1 - _animationController.value) * $(62), 0),
                  child: Image.asset(
                    Images.ic_share,
                    width: $(24),
                  )
                      .intoContainer(
                          alignment: Alignment.center,
                          width: $(48),
                          height: $(48),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Color(0x88000000),
                          ))
                      .intoGestureDetector(onTap: onShareTap),
                ),
                SizedBox(height: $(16)),
                Transform.translate(
                  offset: Offset((1 - _animationController.value) * $(62), 0),
                  child: Image.asset(
                    Images.ic_share_discovery,
                    width: $(24),
                  )
                      .intoContainer(
                          alignment: Alignment.center,
                          width: $(48),
                          height: $(48),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Color(0x88000000),
                          ))
                      .intoGestureDetector(onTap: onShareDiscoveryTap),
                ),
                SizedBox(height: $(16)),
                Transform.translate(
                  offset: Offset((1 - _animationController.value) * $(62), 0),
                  child: Image.asset(
                    Images.ic_download,
                    width: $(24),
                  )
                      .intoContainer(
                          alignment: Alignment.center,
                          width: $(48),
                          height: $(48),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Color(0x88000000),
                          ))
                      .intoGestureDetector(onTap: onDownloadTap),
                ),
              ],
            ).intoContainer(width: $(48)),
          ],
        ).intoContainer(width: ScreenUtil.screenSize.width, padding: EdgeInsets.symmetric(horizontal: $(15)));
      },
    );
  }
}
