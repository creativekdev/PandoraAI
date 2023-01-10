import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:flutter/cupertino.dart';

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
        Text(
          S.of(context).see_it_now,
          style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
        )
            .intoContainer(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(color: ColorConstant.LineColor, width: 1),
                )))
            .intoGestureDetector(onTap: () {
          EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.DISCOVERY.id()]));
          Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
        }),
        Text(
          S.of(context).ok,
          style: TextStyle(fontSize: $(15), fontFamily: 'Poppins', color: Colors.white),
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
