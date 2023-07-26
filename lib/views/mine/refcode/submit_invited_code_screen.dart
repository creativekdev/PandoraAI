import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/indicator/line_tab_indicator.dart';
import 'package:cartoonizer/Widgets/input_text.dart';
import 'package:cartoonizer/Widgets/separator.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/user_ref_link_entity.dart';
import 'package:cartoonizer/utils/ref_code_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/mine/refcode/refcode_controller.dart';
import 'package:cartoonizer/views/mine/refcode/referred_card.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibration/vibration.dart';

class SubmitInvitedCodeScreen extends StatefulWidget {
  static Future<bool?> push(BuildContext context, {String? code}) async {
    var result = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (c) => SubmitInvitedCodeScreen(
        code: code,
      ),
      settings: RouteSettings(name: "/SubmitInvitedCodeScreen"),
    ));
    AppDelegate.instance.getManager<CacheManager>().setString(CacheManager.lastRefLink, null);
    return result;
  }

  String? code;

  SubmitInvitedCodeScreen({this.code, Key? key}) : super(key: key);

  @override
  State<SubmitInvitedCodeScreen> createState() => _SubmitInvitedCodeScreenState();
}

class _SubmitInvitedCodeScreenState extends AppState<SubmitInvitedCodeScreen> with SingleTickerProviderStateMixin {
  RefCodeController refCodeController = Get.put(RefCodeController());
  FocusNode node = FocusNode();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'submit_invitation_code_screen');
    judgeInvitationCode();
    refCodeController.tabController = TabController(length: refCodeController.tabList.length, vsync: this);
    if (widget.code != null) {
      refCodeController.inputText = widget.code!;
    }
    delay(() {
      FocusScope.of(context).requestFocus(node);
    });
  }

  @override
  void dispose() {
    Get.delete<RefCodeController>();
    super.dispose();
  }

  submit(RefCodeController controller) {
    showLoading().whenComplete(() {
      controller.submit(context).then((value) {
        hideLoading().whenComplete(() {
          if (value) {
            var socialUserInfo = controller.userManager.user!;
            socialUserInfo.isReferred = true;
            controller.userManager.user = socialUserInfo;
            controller.userManager.refreshUser();
            var content = controller.aiManager.config?.locale[value];
            controller.update();
            controller.userManager.refreshUser().then((value) {
              try {
                var find = Get.find<RefCodeController>();
                find.update();
              } catch (e) {}
            });
            if (TextUtil.isEmpty(content)) {
              CommonExtension().showToast(S.of(context).successful);
              // Navigator.of(context).pop();
            } else {
              showDialog(context: context, builder: (_) => _SuccessDialog(content: content)).then((value) {});
            }
          }
        });
      });
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.MineBackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: Color(0xff17181a),
        middle: TitleTextWidget(S.of(context).invited_code, ColorConstant.White, FontWeight.w500, $(17)),
      ),
      body: GetBuilder<RefCodeController>(
        init: refCodeController,
        builder: (controller) {
          return Column(
            children: [
              Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: TabBar(
                  indicator: LineTabIndicator(
                    borderSide: BorderSide(width: 4.0, color: ColorConstant.DiscoveryBtn),
                    strokeCap: StrokeCap.square,
                    width: $(50),
                  ),
                  isScrollable: false,
                  tabs: controller.tabList
                      .map((e) => Text(e.title(context),
                          style: TextStyle(
                            fontSize: $(13),
                            fontFamily: 'Poppins',
                          )).intoContainer(padding: EdgeInsets.symmetric(vertical: 8)))
                      .toList(),
                  controller: controller.tabController,
                  onTap: (index) {
                    controller.currentIndex = index;
                  },
                ),
              )
                  .intoContainer(
                    padding: EdgeInsets.only(bottom: $(6)),
                    color: Color(0xff17181a),
                  )
                  .visibility(visible: !controller.referred),
              Expanded(child: controller.currentIndex == 0 && !controller.referred ? buildInputContainer(controller) : buildMyCode(controller)),
            ],
          );
        },
      ),
    ).blankAreaIntercept();
  }

  Widget buildInputContainer(RefCodeController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: $(8)),
        TitleTextWidget(S.of(context).please_input_invited_code, ColorConstant.White, FontWeight.w400, $(14)),
        SizedBox(height: $(16)),
        InputText(
          controller: controller.textEditingController,
          autofocus: false,
          focusNode: node,
          onChanged: (text) {
            var pickRefCode = RefCodeUtils.pickRefCode(text);
            if (pickRefCode != null) {
              controller.inputText = pickRefCode;
            } else {
              controller.refreshInputEnable();
            }
          },
          style: TextStyle(
            fontSize: $(15),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: ColorConstant.White,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ).intoContainer(
          padding: EdgeInsets.symmetric(horizontal: $(15)),
          decoration: BoxDecoration(
            color: Color(0xff292929),
            borderRadius: BorderRadius.circular($(6)),
          ),
        ),
        SubmitButton(
          S.of(context).submit,
          margin: EdgeInsets.only(top: $(24)),
          color: controller.inputEnable ? ColorConstant.DiscoveryBtn : ColorConstant.LineColor,
          onTap: () {
            if (controller.inputEnable) {
              submit(controller);
            }
          },
        ),
      ],
    )
        .intoContainer(
            margin: EdgeInsets.all($(16)),
            padding: EdgeInsets.all($(16)),
            decoration: BoxDecoration(
              color: Color(0xff17181a),
              borderRadius: BorderRadius.circular($(8)),
            ))
        .intoContainer(
          height: double.maxFinite,
          alignment: Alignment.topCenter,
        );
  }

  Widget buildMyCode(RefCodeController controller) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ReferredCard(),
          FutureBuilder<UserRefLinkEntity?>(
              future: controller.userManager.getRefCode(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter().intoContainer(width: double.maxFinite, height: $(80));
                }
                if (snapshot.data == null) {
                  return Text(
                    S.of(context).get_ref_code_failed,
                    style: TextStyle(
                      fontSize: $(15),
                      color: ColorConstant.DiscoveryBtn,
                      fontFamily: 'Poppins',
                    ),
                  )
                      .intoCenter()
                      .intoContainer(
                          width: double.maxFinite,
                          height: $(120),
                          decoration: BoxDecoration(color: Color(0xff17181a), borderRadius: BorderRadius.circular($(8))),
                          margin: EdgeInsets.all($(16)))
                      .intoGestureDetector(onTap: () {
                    controller.update();
                  });
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).ref_code,
                      style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(16), fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: $(16)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            snapshot.data!.code,
                            style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(15)),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ).intoContainer(
                              padding: EdgeInsets.symmetric(vertical: $(9)),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xff292929),
                                borderRadius: BorderRadius.circular($(6)),
                              )),
                        ),
                        SizedBox(width: $(12)),
                        Icon(
                          Icons.copy_rounded,
                          color: Colors.white,
                          size: $(24),
                        ).intoContainer(padding: EdgeInsets.all($(8))).intoGestureDetector(onTap: () {
                          var link = REF_CODE_LINK + snapshot.data!.code;
                          Vibration.hasVibrator().then((value) {
                            if (value ?? false) {
                              Vibration.vibrate(duration: 50);
                            }
                          });
                          Share.share(link);
                        }),
                      ],
                    ).intoContainer(
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(12)),
                      decoration: BoxDecoration(color: Color(0xff17181a), borderRadius: BorderRadius.circular($(8))),
                    ),
                    SizedBox(height: $(32)),
                  ],
                ).intoContainer(
                  width: double.maxFinite,
                  margin: EdgeInsets.symmetric(horizontal: $(16)),
                );
              }),
          SizedBox(height: $(26)),
          Separator(
            color: Color(0xffd5d5d5),
            degree: 1,
            dashSize: 2,
            space: 8,
          ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(16))),
          SizedBox(height: $(23)),
          TitleTextWidget(
            S.of(context).explain,
            ColorConstant.White,
            FontWeight.w500,
            $(16),
          ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(16))),
          SizedBox(height: $(16)),
          TitleTextWidget(
            S.of(context).ref_code_desc,
            Color(0xb2ffffff),
            FontWeight.normal,
            $(14),
            maxLines: 999,
            align: TextAlign.start,
          ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(16))),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
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
        return true;
      },
    );
  }

  void onTryClick() {
    EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.HOME.id()]));
    Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
  }
}
