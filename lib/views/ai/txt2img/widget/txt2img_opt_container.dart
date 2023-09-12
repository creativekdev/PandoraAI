import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/outline_widget.dart';
import 'package:cartoonizer/images-res.dart';

class AGOptContainer extends StatefulWidget {
  GestureTapCallback onPrintTap;
  GestureTapCallback onShareDiscoveryTap;
  GestureTapCallback onDownloadTap;
  GestureTapCallback onGenerateAgainTap;
  GestureTapCallback onDisplayTap;
  bool displayText;

  AGOptContainer({
    Key? key,
    required this.onDisplayTap,
    required this.onDownloadTap,
    required this.onGenerateAgainTap,
    required this.onPrintTap,
    required this.onShareDiscoveryTap,
    required this.displayText,
  }) : super(key: key);

  @override
  State<AGOptContainer> createState() => AGOptContainerState();
}

class AGOptContainerState extends State<AGOptContainer> with SingleTickerProviderStateMixin {
  late GestureTapCallback onPrintTap;
  late GestureTapCallback onDownloadTap;
  late GestureTapCallback onGenerateAgainTap;
  late GestureTapCallback onShareDiscoveryTap;
  late GestureTapCallback onDisplayTap;
  late AnimationController _animationController;
  late CurvedAnimation _anim;
  late bool displayText;
  Completer<void>? completer;

  @override
  void initState() {
    super.initState();
    displayText = widget.displayText;
    onDisplayTap = widget.onDisplayTap;
    onPrintTap = widget.onPrintTap;
    onDownloadTap = widget.onDownloadTap;
    onGenerateAgainTap = widget.onGenerateAgainTap;
    onShareDiscoveryTap = widget.onShareDiscoveryTap;
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
  void didUpdateWidget(covariant AGOptContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    displayText = widget.displayText;
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
        return Transform.translate(
          offset: Offset(0, (1 - _animationController.value) * $(90)),
          child: child,
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: $(16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: $(5)),
                  Image.asset(
                    displayText ? Images.ic_checked : Images.ic_unchecked,
                    width: 17,
                    height: 17,
                  ),
                  SizedBox(width: $(10)),
                  TitleTextWidget(S.of(context).display_text, ColorConstant.BtnTextColor, FontWeight.w500, 14),
                  SizedBox(width: $(20)),
                ],
              ).intoGestureDetector(onTap: onDisplayTap),
              SizedBox(width: $(16)),
              Container(
                width: 1,
                height: $(20),
                color: ColorConstant.White,
              ),
              SizedBox(width: $(16)),
              Expanded(
                  child: Image.asset(
                Images.ic_download,
                width: $(24),
              )
                      .intoContainer(
                        padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(10)),
                      )
                      .intoGestureDetector(onTap: onDownloadTap)
                      .intoContainer(alignment: Alignment.center)),
              Expanded(
                child: Image.asset(
                  Images.ic_share_print,
                  width: $(24),
                )
                    .intoContainer(
                      padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(10)),
                    )
                    .intoGestureDetector(onTap: onPrintTap)
                    .intoContainer(alignment: Alignment.center),
              ),
              Expanded(
                child: Image.asset(
                  Images.ic_share_discovery,
                  width: $(24),
                )
                    .intoContainer(
                      padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(10)),
                    )
                    .intoGestureDetector(onTap: onShareDiscoveryTap)
                    .intoContainer(alignment: Alignment.center),
              ),
              SizedBox(width: $(16)),
            ],
          ),
          SizedBox(height: $(10)),
          OutlineWidget(
            radius: $(12),
            strokeWidth: $(2),
            gradient: LinearGradient(
              colors: [Color(0xFF04F1F9), Color(0xFF7F97F3), Color(0xFFEC5DD8)],
              end: Alignment.topLeft,
              begin: Alignment.bottomRight,
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
              height: $(48),
              alignment: Alignment.center,
              padding: EdgeInsets.all($(2)),
            ),
          ).intoGestureDetector(onTap: onGenerateAgainTap).intoContainer(width: ScreenUtil.screenSize.width, padding: EdgeInsets.symmetric(horizontal: $(15))),
        ],
      ),
    );
  }
}
