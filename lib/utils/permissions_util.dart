import 'dart:io';

import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionsUtil {
  static Future<bool> checkPermissions() async {
    var list = [Permission.camera, Permission.storage, Permission.microphone];
    var deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt > 32) {
        list.remove(Permission.storage);
        list.add(Permission.photos);
        // list.add(Permission.videos);
        // list.add(Permission.audio);
      }
    } else if (Platform.isIOS) {
      list.add(Permission.photos);
    }
    List<Permission> reqList = <Permission>[];
    for (var value in list) {
      var permissionStatus = await value.status;
      if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
        reqList.add(value);
      }
    }
    if (reqList.isEmpty) {
      return true;
    }
    var values = await reqList.request();
    for (var result in values.values) {
      if (result.isDenied || result.isPermanentlyDenied) {
        return false;
      }
    }
    return true;
  }

  static Future<void> permissionDenied(BuildContext context) async {
    var cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
      showCameraPermissionDialog(context);
      return;
    }
    var microStatus = await Permission.microphone.status;
    if (microStatus.isDenied || microStatus.isPermanentlyDenied) {
      showMicroPhonePermissionDialog(context);
      return;
    }
    var galleryStatus = await Permission.photos.status;
    if (galleryStatus.isDenied || galleryStatus.isPermanentlyDenied) {
      showPhotoLibraryPermissionDialog(context);
      return;
    }
  }
}
