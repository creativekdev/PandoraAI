import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';

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
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleTextWidget(S.of(context).give_feedback, ColorConstant.White, FontWeight.w600, $(17)).intoContainer(
          padding: EdgeInsets.only(top: $(25), bottom: $(15), left: $(15), right: $(15)),
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
          decoration: BoxDecoration(color: Color(0xff33363a), borderRadius: BorderRadius.circular($(6))),
        ),
        Text(
          S.of(context).submit,
          style: TextStyle(color: ColorConstant.White, fontFamily: 'Poppins', fontSize: $(17)),
        )
            .intoContainer(
                alignment: Alignment.center,
                width: double.maxFinite,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular($(6)), color: ColorConstant.BlueColor),
                padding: EdgeInsets.symmetric(vertical: $(10)),
                margin: EdgeInsets.only(
                  top: $(15),
                  bottom: $(20),
                  left: $(15),
                  right: $(15),
                ))
            .intoGestureDetector(onTap: () {
          submit();
        }),
      ],
    ).customDialogStyle();
  }
}
