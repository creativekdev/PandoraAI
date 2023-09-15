import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';

import '../../../images-res.dart';

class FeedbackUtils {
  static Future<bool?> open(BuildContext context) async {
    CacheManager cacheManager = AppDelegate().getManager();
    var timeStamp = cacheManager.getInt(CacheManager.lastFeedback);
    if (DateUtils.isSameDay(DateTime.fromMillisecondsSinceEpoch(timeStamp), DateTime.now())) {
      CommonExtension().showToast(S.of(context).feedback_out_date);
      return false;
    } else {
      return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => _FeedbackDialog(),
      );
    }
  }
}

class _FeedbackDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FeedbackDialogState();
  }
}

class _FeedbackDialogState extends AppState<_FeedbackDialog> {
  late AppApi api;
  late TextEditingController textEditingController;
  CacheManager cacheManager = AppDelegate().getManager();

  @override
  void initState() {
    super.initState();
    api = AppApi().bindState(this);
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
  }

  submit() {
    var content = textEditingController.text.trim();
    if (content.isEmpty) {
      CommonExtension().showToast(S.of(context).feedback_empty);
      return;
    }
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: "pre_feedback", callback: () {
      showLoading().whenComplete(() {
        api.feedback(content).then((value) {
          hideLoading().whenComplete(() {
            if (value != null) {
              cacheManager.setInt(CacheManager.lastFeedback, DateTime.now().millisecondsSinceEpoch);
              CommonExtension().showToast(S.of(context).feedback_thanks);
              Navigator.pop(context, true);
            }
          });
        });
      });
    }, autoExec: true);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        TitleTextWidget(S.of(context).give_feedback, ColorConstant.White, FontWeight.w600, $(17)).intoContainer(
          padding: EdgeInsets.only(top: $(25), bottom: $(26), left: $(107), right: $(63)),
        ),
        TextField(
          controller: textEditingController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: S.of(context).input_feedback,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: ColorConstant.InputContent,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: $(4)),
            isDense: false,
          ),
          style: TextStyle(
            color: ColorConstant.White,
            fontSize: $(15),
            fontFamily: 'Poppins',
            height: 1,
          ),
          minLines: 5,
          maxLines: 5,
        ).intoContainer(
          padding: EdgeInsets.all($(10)),
          margin: EdgeInsets.symmetric(horizontal: $(15)),
          decoration: BoxDecoration(
              color: Color(0xff15172A),
              borderRadius: BorderRadius.circular($(8)),
              border: Border.all(
                color: Color(0xFFFFFFFF).withOpacity(0.1),
                width: $(1),
              )),
        ),
        // Text(
        //   S.of(context).submit,
        //   style: TextStyle(color: ColorConstant.White, fontFamily: 'Poppins', fontSize: $(17)),
        // )
        //     .intoContainer(
        //         alignment: Alignment.center,
        //         width: double.maxFinite,
        //         decoration: BoxDecoration(borderRadius: BorderRadius.circular($(18)), color: ColorConstant.White),
        //         padding: EdgeInsets.symmetric(vertical: $(5)),
        //         margin: EdgeInsets.only(
        //           top: $(20),
        //           bottom: $(20),
        //           left: $(15),
        //           right: $(15),
        //         ))
        //     .intoGestureDetector(onTap: () {
        //   submit();
        // }),
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(colors: [
              ColorConstant.ColorLinearStart,
              ColorConstant.ColorLinearEnd,
            ]).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: Text(
            S.of(context).submit,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: $(17),
              fontWeight: FontWeight.w500,
            ),
          ),
        )
            .intoContainer(
                alignment: Alignment.center,
                width: double.maxFinite,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular($(18)), color: ColorConstant.White),
                padding: EdgeInsets.symmetric(vertical: $(5)),
                margin: EdgeInsets.only(
                  top: $(20),
                  bottom: $(20),
                  left: $(15),
                  right: $(15),
                ))
            .intoGestureDetector(onTap: () {
          submit();
        })
      ],
    )
        .intoContainer(
            width: $(300),
            height: $(260),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.ic_feed_bg),
              ),
            ))
        .customDialogStyle(
          color: Colors.transparent,
        );
  }
}
