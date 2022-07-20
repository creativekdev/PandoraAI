import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/views/home_screen.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String _kUser = 'user';

String get APP_TYPE {
  String platform = Platform.isIOS ? 'ios' : 'android';
  String type = 'app_cartoonizer_${platform}';
  return type;
}

Future<UserModel> getUser() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var localUser = sharedPreferences.getString(_kUser) ?? "{}";
  return UserModel.fromJson(jsonDecode(localUser));
}

Future<void> saveUser(Map data) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  UserModel user = await getUser();

  if (data.containsKey('name')) {
    user.name = data['name'];
  }
  if (data.containsKey('email')) {
    user.email = data['email'];
  }
  if (data.containsKey('avatar')) {
    user.avatar = data['avatar'];
  }

  sharedPreferences.setString(_kUser, jsonEncode(user));
}

Future<void> loginBack(BuildContext context, {bool isLogout: false}) async {
  if (!isLogout) {
    var user = await API.getLogin(needLoad: true, context: context) as UserModel;
    if (user.status != 'activated') return;
  }

  final box = GetStorage();
  String? login_back_page = box.read('login_back_page');
  if (login_back_page != null) {
    Navigator.popUntil(context, ModalRoute.withName(login_back_page));
    box.remove('login_back_page');
  } else {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/HomeScreen"),
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

bool isShowAdsNew() {
  var manager = AppDelegate.instance.getManager<UserManager>();
  if (manager.isNeedLogin) {
    return true;
  }
  var user = manager.user!;
  if (user.userSubscription.containsKey('id') || user.cartoonizeCredit > 0) {
    return false;
  }
  return true;
}

@Deprecated("instead by isShowAdsNew")
bool isShowAds(UserModel? user) {
  if (user == null) return false;

  bool showAds = true;
  if (user.email != "" && (user.subscription.containsKey('id') || user.credit > 0)) {
    showAds = false;
  }
  return showAds;
}

String getFileName(String url) {
  return url.substring(url.lastIndexOf('/') + 1);
}

String getFileType(String fileName) {
  return fileName.substring(fileName.lastIndexOf(".") + 1);
}

Future<bool> mkdirByPath(String path) async {
  return mkdir(Directory(path));
}

Future<bool> mkdir(Directory file) async {
  var bool = await file.exists();
  if (!bool) {
    await file.create();
    return true;
  }
  return true;
}

Future<File> imageCompressAndGetFile(File file) async {
  var user = AppDelegate.instance.getManager<UserManager>().user;
  var length = await file.length();
  if (length < 200 * 1024) {
    return file;
  }

  var quality = 100;
  if (length > 4 * 1024 * 1024) {
    quality = 50;
  } else if (length > 2 * 1024 * 1024) {
    quality = 60;
  } else if (length > 1 * 1024 * 1024) {
    quality = 70;
  } else if (length > 0.5 * 1024 * 1024) {
    quality = 80;
  }

  var dir = await getTemporaryDirectory();
  var targetPath = dir.absolute.path + "/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

  var minSize = (user?.cartoonizeCredit ?? 0) > 0 ? 1024 : 512;

  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    minWidth: minSize,
    minHeight: minSize,
    quality: quality,
  );

  return result!;
}

Future<Uint8List> imageCompressWithList(Uint8List image) async {
  var length = image.length;
  if (length < 200 * 1024) {
    return image;
  }

  var quality = 100;
  if (length > 4 * 1024 * 1024) {
    quality = 50;
  } else if (length > 2 * 1024 * 1024) {
    quality = 60;
  } else if (length > 1 * 1024 * 1024) {
    quality = 70;
  } else if (length > 0.5 * 1024 * 1024) {
    quality = 80;
  }
  var uint8list = await FlutterImageCompress.compressWithList(
    image,
    quality: quality,
  );
  return Uint8List.fromList(uint8list.toList());
}
