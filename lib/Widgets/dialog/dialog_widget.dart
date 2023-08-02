import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/camera/pai_camera_screen.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:flutter/cupertino.dart';

extension DialogWidgetEx on Widget {
  Widget customDialogStyle({Color color = ColorConstant.EffectFunctionGrey}) {
    return this
        .intoMaterial(
          color: color,
          borderRadius: BorderRadius.circular($(16)),
        )
        .intoContainer(
          padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
          margin: EdgeInsets.symmetric(horizontal: $(25)),
        )
        .intoCenter();
  }
}

Future<bool?> showOpenNsfwDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).scary_content_alert_open_it,
          style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
          textAlign: TextAlign.center,
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
        Row(
          children: [
            Expanded(
                child: Text(
              S.of(context).cancel,
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
            )
                    .intoContainer(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                          top: BorderSide(color: ColorConstant.LineColor, width: 1),
                          right: BorderSide(color: ColorConstant.LineColor, width: 1),
                        )))
                    .intoGestureDetector(onTap: () async {
              Navigator.pop(context, false);
            })),
            Expanded(
                child: Text(
              S.of(context).show_it,
              style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.red),
            )
                    .intoContainer(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border(
                          top: BorderSide(color: ColorConstant.LineColor, width: 1),
                        )))
                    .intoGestureDetector(onTap: () {
              Navigator.pop(context, true);
            })),
          ],
        ),
      ],
    )
        .intoMaterial(
          color: ColorConstant.EffectFunctionGrey,
          borderRadius: BorderRadius.circular($(16)),
        )
        .intoContainer(
          padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
          margin: EdgeInsets.symmetric(horizontal: $(35)),
        )
        .intoCenter(),
  );
}

showShareSuccessDialog(BuildContext context) {
  showDialog<bool>(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.of(context).your_post_has_been_submitted_successfully,
          style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
          textAlign: TextAlign.center,
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(20))),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                S.of(context).see_it_now,
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: ColorConstant.BlueColor),
              )
                  .intoContainer(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                        top: BorderSide(color: ColorConstant.LineColor, width: 1),
                      )))
                  .intoGestureDetector(onTap: () {
                EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.DISCOVERY.id(), 0]));
                Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
              }),
            ),
            Container(
              height: $(44),
              width: 1,
              color: ColorConstant.LineColor,
            ),
            Expanded(
              child: Text(
                S.of(context).ok,
                style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: ColorConstant.BlueColor),
              )
                  .intoContainer(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border(
                        top: BorderSide(color: ColorConstant.LineColor, width: 1),
                      )))
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop();
              }),
            ),
          ],
        ),
      ],
    )
        .intoMaterial(
          color: ColorConstant.EffectFunctionGrey,
          borderRadius: BorderRadius.circular($(16)),
        )
        .intoContainer(
          padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
          margin: EdgeInsets.symmetric(horizontal: $(35)),
        )
        .intoCenter(),
  );
}

/// openAppSettingsOnGalleryRequireFailed
showPhotoLibraryPermissionDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(
              S.of(context).permissionPhotoLibrary,
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
            ),
            content: Text(
              S.of(context).permissionPhotoLibraryContent,
              style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text(
                  S.of(context).permissionPhotoToSettings,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    openAppSettings();
                  } catch (err) {
                    print("err");
                    print(err);
                  }
                },
              ),
            ],
          ));
}

/// openAppSettingsOnCameraRequireFailed
showCameraPermissionDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(
              S.of(context).permissionCamera,
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
            ),
            content: Text(
              S.of(context).permissionCameraContent,
              style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  S.of(context).deny,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text(
                  S.of(context).settings,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    openAppSettings();
                  } catch (err) {
                    print("err");
                    print(err);
                  }
                },
              ),
            ],
          ));
}

/// openAppSettingsOnCameraRequireFailed
showMicroPhonePermissionDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(
              S.of(context).permissionMicroPhone,
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
            ),
            content: Text(
              S.of(context).permissionMicroPhoneContent,
              style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  S.of(context).deny,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text(
                  S.of(context).settings,
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    openAppSettings();
                  } catch (err) {
                    print("err");
                    print(err);
                  }
                },
              ),
            ],
          ));
}

showLimitDialog(BuildContext context, {required AccountLimitType type, required String function, required String source}) {
  var userManager = AppDelegate().getManager<UserManager>();
  showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: $(27)),
              Image.asset(
                Images.ic_limit_icon,
              ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(22))),
              SizedBox(height: $(16)),
              TitleTextWidget(S.of(context).generate_reached_limit_title, Colors.white, FontWeight.w600, $(18), maxLines: 4).intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.only(left: $(10), right: $(10)),
                alignment: Alignment.center,
              ),
              SizedBox(height: $(16)),
              TitleTextWidget(
                type.getContent(context),
                ColorConstant.White,
                FontWeight.w500,
                $(13),
                maxLines: 100,
                align: TextAlign.center,
              ).intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.only(
                  bottom: $(30),
                  left: $(30),
                  right: $(30),
                ),
                alignment: Alignment.center,
              ),
              Text(
                type.getSubmitText(context),
                style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
              )
                  .intoContainer(
                width: double.maxFinite,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: ColorConstant.DiscoveryBtn),
                padding: EdgeInsets.only(top: $(10), bottom: $(10)),
                alignment: Alignment.center,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(_).pop(true);
              }),
              if (type == AccountLimitType.normal && !userManager.user!.isReferred)
                Text(
                  S.of(context).upgrade_now,
                  style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
                )
                    .intoContainer(
                  width: double.maxFinite,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: ColorConstant.DiscoveryBtn),
                  padding: EdgeInsets.only(top: $(10), bottom: $(10)),
                  margin: EdgeInsets.only(top: $(10)),
                  alignment: Alignment.center,
                )
                    .intoGestureDetector(onTap: () {
                  Navigator.of(_).pop(false);
                }),
              Text(
                S.of(context).cancel,
                style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(14)),
              )
                  .intoContainer(
                width: double.maxFinite,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: Color(0xff292929)),
                padding: EdgeInsets.only(top: $(10), bottom: $(10)),
                margin: EdgeInsets.only(top: $(16), bottom: $(24)),
                alignment: Alignment.center,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.pop(_);
              })
            ],
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))).customDialogStyle()).then((value) {
    if (value == null) {
      // do nothing
    } else if (value) {
      switch (type) {
        case AccountLimitType.guest:
          userManager.doOnLogin(context, logPreLoginAction: '${function}_generate_limit', toSignUp: true);
          break;
        case AccountLimitType.normal:
          if (userManager.user!.isReferred) {
            PaymentUtils.pay(context, source);
          } else {
            Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
            EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.MINE.id()]));
            delay(() => SubmitInvitedCodeScreen.push(Get.context!), milliseconds: 200);
            // Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
          }
          break;
        case AccountLimitType.vip:
          break;
      }
    } else {
      PaymentUtils.pay(context, source);
    }
  });
}

Future<PAICameraEntity?> showPhotoTakeDialog(
  BuildContext context,
) async {
  var type = await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Column(
      children: [
        ClipRRect(
          child: Column(
            children: [
              SizedBox(height: $(5)),
              Text(
                S.of(context).take_a_selfie,
                style: TextStyle(
                  fontSize: $(16),
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              )
                  .intoContainer(
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: $(12)),
                    color: Colors.transparent,
                  )
                  .intoGestureDetector(onTap: () => Navigator.of(_).pop(true)),
              Divider(height: 1, color: ColorConstant.LineColor),
              Text(
                S.of(context).select_from_album,
                style: TextStyle(
                  fontSize: $(16),
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              )
                  .intoContainer(
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: $(12)),
                    color: Colors.transparent,
                  )
                  .intoGestureDetector(onTap: () => Navigator.of(_).pop(false)),
              SizedBox(height: $(5)),
            ],
          ).intoContainer(
            color: ColorConstant.BackgroundColor,
          ),
          borderRadius: BorderRadius.circular($(8)),
        ),
        SizedBox(height: $(12)),
        Text(
          S.of(context).cancel,
          style: TextStyle(
            fontSize: $(16),
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        )
            .intoContainer(
                width: double.maxFinite,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: $(12)),
                decoration: BoxDecoration(
                  color: ColorConstant.BackgroundColor,
                  borderRadius: BorderRadius.circular($(8)),
                ))
            .intoGestureDetector(onTap: () => Navigator.of(_).pop()),
      ],
      mainAxisSize: MainAxisSize.min,
    )
        .intoContainer(
          padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context)),
          margin: EdgeInsets.symmetric(horizontal: $(15)),
        )
        .intoMaterial(color: Colors.transparent),
  );
  if (type == null) {
    return null;
  }
  if (type) {
    return await PAICamera.takePhoto(context);
  } else {
    var list = await PickAlbumScreen.pickImage(context, count: 1, switchAlbum: true);
    if (list == null || list.isEmpty) {
      return null;
    }
    var first = await list.first.originFile;
    if (first == null || !first.existsSync()) {
      CommonExtension().showToast('Image not exist');
      return null;
    }
    return PAICameraEntity(source: 'gallery', xFile: XFile(first.path));
  }
}
