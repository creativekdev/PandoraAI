import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/input_text.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class SubmitInvitedCodeScreen extends StatefulWidget {
  const SubmitInvitedCodeScreen({Key? key}) : super(key: key);

  @override
  State<SubmitInvitedCodeScreen> createState() => _SubmitInvitedCodeScreenState();
}

class _SubmitInvitedCodeScreenState extends AppState<SubmitInvitedCodeScreen> {
  TextEditingController controller = TextEditingController();
  var userManager = AppDelegate.instance.getManager<UserManager>();
  var aiManager = AppDelegate.instance.getManager<AvatarAiManager>();
  late CartoonizerApi api;
  FocusNode node = FocusNode();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'submit_invitation_code_screen');
    api = CartoonizerApi().bindState(this);
    delay(() {
      FocusScope.of(context).requestFocus(node);
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.MineBackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.MineBackgroundColor,
        middle: TitleTextWidget(S.of(context).invited_code, ColorConstant.White, FontWeight.w500, $(17)),
      ),
      body: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleTextWidget(S.of(context).please_input_invited_code, ColorConstant.DiscoveryCommentGrey, FontWeight.w400, $(14)),
              SizedBox(height: $(12)),
              InputText(
                controller: controller,
                autofocus: false,
                focusNode: node,
                style: TextStyle(
                  fontSize: $(15),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.White,
                ),
                decoration: InputDecoration(
                  hintText: S.of(context).input_invited_code,
                  hintStyle: TextStyle(
                    color: ColorConstant.HintColor,
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                ),
              ).intoContainer(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                decoration: BoxDecoration(
                  color: ColorConstant.InputContent,
                  borderRadius: BorderRadius.circular($(6)),
                ),
              ),
              SizedBox(height: $(80)),
            ],
          ).intoContainer(
              margin: EdgeInsets.only(left: $(15), right: $(15), top: $(15)),
              padding: EdgeInsets.all($(15)),
              decoration: BoxDecoration(
                color: Color(0xff17181a),
                borderRadius: BorderRadius.circular($(8)),
              )),
          Text(
            S.of(context).submit,
            style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(18)),
          )
              .intoContainer(
                  margin: EdgeInsets.only(left: $(15), right: $(15), bottom: $(15) + ScreenUtil.getBottomPadding(context), top: $(24)),
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  decoration: BoxDecoration(
                    color: ColorConstant.DiscoveryBtn,
                    borderRadius: BorderRadius.circular($(8)),
                  ))
              .intoGestureDetector(onTap: () {
            submit();
          }),
        ],
      ),
    ).blankAreaIntercept();
  }

  submit() {
    var text = controller.text;
    if (TextUtil.isEmpty(text)) {
      CommonExtension().showToast(S.of(context).please_input_invited_code);
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    showLoading().whenComplete(() {
      api.submitInvitedCode(text).then((value) {
        hideLoading().whenComplete(() {
          if (value != null) {
            var socialUserInfo = userManager.user!;
            socialUserInfo.isReferred = true;
            userManager.user = socialUserInfo;
            userManager.refreshUser();
            var content = aiManager.config?.locale[value];
            if (TextUtil.isEmpty(content)) {
              CommonExtension().showToast(S.of(context).successful);
              Navigator.of(context).pop();
            } else {
              showDialog(context: context, builder: (_) => _SuccessDialog(content: content));
            }
          }
        });
      });
    });
  }
}

class _SuccessDialog extends StatefulWidget {
  String content;

  _SuccessDialog({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> {
  late double w;
  late double h;

  @override
  void initState() {
    super.initState();
    w = ScreenUtil.screenSize.width - $(58);
    h = w / 632 * 664;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: $(28)),
            Text(
              S.of(context).congratulations,
              style: TextStyle(
                color: Color(0xff000000),
                fontSize: $(17),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ).intoContainer(
                foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
                Color(0xFFC15C2D),
                Color(0xFFEFA763),
                Color(0xFFC15C2D),
              ]),
              backgroundBlendMode: BlendMode.lighten,
            )),
            Text(
              widget.content,
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: $(15), height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 4,
            ).intoContainer(width: w * 0.56, alignment: Alignment.center, height: $(70), margin: EdgeInsets.only(bottom: $(12))),
            Text(
              S.of(context).invitation_desc,
              style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.InputContent, fontSize: $(14), height: 1.2),
              textAlign: TextAlign.center,
            ).intoContainer(width: w * 0.56),
            Expanded(child: SizedBox()),
            Text(
              S.of(context).try_it_now,
              style: TextStyle(fontSize: $(15), fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            )
                .intoContainer(
                    width: w * 0.75,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: $(25)),
                    padding: EdgeInsets.symmetric(vertical: $(8)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFF4C57B),
                            Color(0xFFF2B05F),
                          ],
                        )))
                .intoGestureDetector(onTap: () {
              onTryClick();
            }),
          ],
        )
            .intoContainer(
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_invitation_dialog_bg))),
                margin: EdgeInsets.symmetric(horizontal: $(29)),
                width: w,
                height: h)
            .intoCenter()
            .intoMaterial(
              color: Colors.transparent,
            ),
        onWillPop: () async {
          return false;
        });
  }

  void onTryClick() {
    EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.HOME.id()]));
    Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
  }
}
