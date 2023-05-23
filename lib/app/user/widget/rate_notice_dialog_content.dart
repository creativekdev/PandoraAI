import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/utils/utils.dart';

import 'feedback_dialog.dart';

class RateNoticeDialogContent extends StatefulWidget {
  Function(bool value) onResult;

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleTextWidget(S.of(context).rate_pandora_ai, ColorConstant.White, FontWeight.w600, $(17)).intoContainer(
          padding: EdgeInsets.only(top: $(20), bottom: $(15), left: $(15), right: $(15)),
        ),
        TitleTextWidget(
          S.of(context).rate_description,
          ColorConstant.White,
          FontWeight.normal,
          $(14),
          maxLines: 10,
        ).intoContainer(
          padding: EdgeInsets.only(bottom: $(15), left: $(15), right: $(15)),
        ),
        Container(height: 1, color: ColorConstant.LineColor),
        Text(
          S.of(context).looveit,
          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(16)),
        )
            .intoContainer(
          width: double.maxFinite,
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: $(10)),
          alignment: Alignment.center,
        )
            .intoGestureDetector(onTap: () {
          if (mounted) {
            rateApp();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              onResult.call(true);
            }
          }
        }),
        Container(height: 1, color: ColorConstant.LineColor),
        Text(
          S.of(context).give_feedback,
          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(16)),
        )
            .intoContainer(
          width: double.maxFinite,
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: $(10)),
          alignment: Alignment.center,
        )
            .intoGestureDetector(onTap: () {
          FeedbackUtils.open(context).then((value) {
            if (value ?? false) {
              if (mounted) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  onResult.call(true);
                }
              }
            }
          });
        }),
        Container(height: 1, color: ColorConstant.LineColor),
        Text(
          S.of(context).no_thanks,
          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(16)),
        )
            .intoContainer(
          width: double.maxFinite,
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: $(10)),
          alignment: Alignment.center,
        )
            .intoGestureDetector(onTap: () {
          if (mounted) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              onResult.call(false);
            }
          }
        }),
      ],
    ).intoContainer(width: double.maxFinite).customDialogStyle();
  }
}