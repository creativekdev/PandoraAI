import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/user/widget/feedback_dialog.dart';
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
          height: $(260),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Images.ic_rate_bg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleTextWidget(S.of(context).rate_pandora_ai, Colors.black, FontWeight.w900, $(20)).intoContainer(
                padding: EdgeInsets.only(top: $(28), bottom: $(14), left: $(15), right: $(15)),
              ),
              TitleTextWidget(
                S.of(context).rate_description,
                Color(0xFF271C6F),
                FontWeight.normal,
                $(12),
                maxLines: 10,
              ).intoContainer(
                padding: EdgeInsets.only(bottom: $(14), left: $(15), right: $(15)),
              ),
              Container(
                width: $(270),
                height: $(130),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: [0.0, 1.0],
                    colors: [
                      Color.fromRGBO(210, 224, 252, 1.0),
                      Color.fromRGBO(222, 212, 250, 1.0),
                    ],
                    begin: Alignment(-0.07, 0.05), // UnitPoint(x: 0.07, y: -0.05)
                    end: Alignment(1.02, 1.0), // UnitPoint(x: 1.02, y: 1)
                  ),
                  borderRadius: BorderRadius.circular($(8)),
                ),
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
                    // FeedbackUtils.open(context).then((value) {
                    //   if (value ?? false) {
                    //     if (mounted) {
                    //       if (Navigator.canPop(context)) {
                    //         Navigator.pop(context);
                    //         onResult.call(true);
                    //       }
                    //     }
                    //   }
                    // });
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
        TitleTextWidget(
          title,
          isSelected ? ColorConstant.White : Color(0xFF271C6F),
          FontWeight.normal,
          $(12),
        ).intoContainer(
          alignment: Alignment.center,
          width: $(65),
          height: $(26),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular($(13)),
                  gradient: LinearGradient(
                    stops: [0.0, 0.15, 0.31, 0.47, 0.63, 0.77, 0.93],
                    colors: [
                      Color.fromRGBO(31, 239, 245, 1.0), // Color(red: 0.12, green: 0.94, blue: 0.96)
                      Color.fromRGBO(102, 173, 243, 1.0), // Color(red: 0.4, green: 0.67, blue: 0.95)
                      Color.fromRGBO(127, 148, 243, 1.0), // Color(red: 0.5, green: 0.58, blue: 0.95)
                      Color.fromRGBO(151, 140, 235, 1.0), // Color(red: 0.59, green: 0.55, blue: 0.92)
                      Color.fromRGBO(174, 125, 229, 1.0), // Color(red: 0.68, green: 0.49, blue: 0.9)
                      Color.fromRGBO(209, 107, 221, 1.0),
                      Color.fromRGBO(222, 97, 216, 1.0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                )
              : BoxDecoration(),
        ),
      ],
    );
  }
}
