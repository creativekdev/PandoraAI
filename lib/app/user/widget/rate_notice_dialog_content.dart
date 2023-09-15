import 'package:cartoonizer/app/user/widget/feedback_dialog.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';

class RateNoticeDialogContent extends StatefulWidget {
  final Function(bool value) onResult;

  RateNoticeDialogContent({
    Key? key,
    required this.onResult,
  }) : super(key: key);

  @override
  State<RateNoticeDialogContent> createState() => _RateNoticeDialogContentState();
}

class _RateNoticeDialogContentState extends State<RateNoticeDialogContent> {
  late Function(bool value) onResult;

  @override
  void initState() {
    super.initState();
    onResult = widget.onResult;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }),
        Container(
          width: $(300),
          height: $(309),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Images.ic_rate_bg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleTextWidget(S.of(context).rate_pandora_ai, Colors.white, FontWeight.w800, $(18)).intoContainer(
                padding: EdgeInsets.only(top: $(75), bottom: $(16), left: $(15), right: $(15)),
              ),
              TitleTextWidget(
                S.of(context).rate_description,
                Color(0xFFC4C6EE),
                FontWeight.normal,
                $(12),
                maxLines: 10,
              ).intoContainer(
                padding: EdgeInsets.only(bottom: $(16), left: $(15), right: $(15)),
              ),
              Container(
                width: $(270),
                height: $(130),
                decoration: BoxDecoration(
                    color: Color(0xFF15172A),
                    borderRadius: BorderRadius.circular($(8)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: $(1),
                    )),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  RateItem(
                    title: S.of(context).rate_bad,
                    isSelected: false,
                    img: Images.ic_rate_bad,
                  ).intoGestureDetector(onTap: () {
                    if (mounted) {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                        onResult.call(false);
                      }
                    }
                  }),
                  RateItem(
                    title: S.of(context).rate_average,
                    isSelected: false,
                    img: Images.ic_rate_average,
                  ).intoGestureDetector(onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                      onResult.call(true);
                      FeedbackUtils.open(context);
                    }
                  }),
                  RateItem(
                    title: S.of(context).rate_good,
                    isSelected: true,
                    img: Images.ic_rate_good,
                  ).intoGestureDetector(onTap: () {
                    rateApp();
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                      onResult.call(true);
                    }
                  })
                ]),
              )
            ],
          ),
        ).intoCenter(),
      ],
    ).intoMaterial(
      color: Colors.transparent,
    );
  }
}

class RateItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final String img;

  RateItem({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.img,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          img,
          width: isSelected ? $(48) : $(40),
        ).intoContainer(padding: EdgeInsets.only(bottom: isSelected ? $(12) : $(16), top: isSelected ? $(22) : $(26))),
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
                    colors: isSelected
                        ? [
                            ColorConstant.ColorLinearStart,
                            ColorConstant.ColorLinearEnd,
                          ]
                        : [ColorConstant.White, ColorConstant.White])
                .createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: $(12),
              fontWeight: FontWeight.w500,
            ),
          ),
        )
      ],
    );
  }
}
