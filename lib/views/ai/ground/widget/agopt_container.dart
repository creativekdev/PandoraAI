import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/images-res.dart';

class AGOptContainer extends StatefulWidget {
  GestureTapCallback onShareTap;
  GestureTapCallback onDownloadTap;
  GestureTapCallback onGenerateAgainTap;

  AGOptContainer({
    Key? key,
    required this.onDownloadTap,
    required this.onGenerateAgainTap,
    required this.onShareTap,
  }) : super(key: key);

  @override
  State<AGOptContainer> createState() => AGOptContainerState();
}

class AGOptContainerState extends State<AGOptContainer> with SingleTickerProviderStateMixin {
  late GestureTapCallback onChoosePhotoTap;
  late GestureTapCallback onShareTap;
  late GestureTapCallback onDownloadTap;
  late GestureTapCallback onGenerateAgainTap;
  late AnimationController _animationController;
  late CurvedAnimation _anim;
  Completer<void>? completer;

  @override
  void initState() {
    super.initState();
    onShareTap = widget.onShareTap;
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
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: $(16)),
            Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      Images.ic_share,
                      width: $(24),
                    ),
                    SizedBox(width: 6),
                    TitleTextWidget(S.of(context).share, ColorConstant.White, FontWeight.normal, $(17)),
                  ],
                  mainAxisSize: MainAxisSize.min,
                )
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(12)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF601AFF), Color(0xFF9A26FF), Color(0xFFFF57CD)],
                      )),
                )
                    .intoGestureDetector(onTap: onShareTap)),
            SizedBox(width: $(16)),
            Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      Images.ic_download,
                      width: $(24),
                    ),
                    SizedBox(width: 6),
                    TitleTextWidget(S.of(context).download, ColorConstant.White, FontWeight.normal, $(17)),
                  ],
                  mainAxisSize: MainAxisSize.min,
                )
                    .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(12)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF5E18FF), Color(0xFF1F83FF), Color(0xFF00FFF8)],
                      )),
                )
                    .intoGestureDetector(onTap: onDownloadTap)),
            SizedBox(width: $(16)),
          ],
        ),
        SizedBox(height: 22),
        AnimatedBuilder(
          animation: _anim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _animationController.value) * $(90)),
              child: OutlineWidget(
                radius: $(12),
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
                  height: $(48),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all($(2)),
                ),
              ).intoGestureDetector(onTap: onGenerateAgainTap),
            ).intoContainer(width: ScreenUtil.screenSize.width, padding: EdgeInsets.symmetric(horizontal: $(15)));
          },
        ),
      ],
    );
  }
}
