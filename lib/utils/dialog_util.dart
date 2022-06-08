import 'package:cartoonizer/Common/importFile.dart';
import 'package:flutter/cupertino.dart';

/// openAppSettingsOnGalleryRequireFailed
showPhotoLibraryPermissionDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text(
              'PhotoLibrary Permission',
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
            ),
            content: Text(
              'This app needs photo library access to choose pictures for upload user profile photo',
              style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  'Deny',
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text(
                  'Settings',
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
              'Camera Permission',
              style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
            ),
            content: Text(
              'This app needs camera access to take pictures for upload user profile photo',
              style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  'Deny',
                  style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text(
                  'Settings',
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
