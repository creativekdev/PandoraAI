import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/views/HomeScreen.dart';

import 'package:cartoonizer/api.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Model/UserModel.dart';
import 'package:cartoonizer/Ui/home/HomeScreen.dart';

const String _kUser = 'user';

String get APP_TYPE {
  String platform = Platform.isIOS ? 'ios' : 'android';
  String type = 'app_cartoonizer_${platform}';
  return type;
}

Future<UserModel> getUser() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  var localUser = sharedPreferences.getString(_kUser) ?? "";
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

bool isShowAds(UserModel? user) {
  if (user == null) return false;

  bool showAds = true;
  if (user.email != "" && (user.subscription.containsKey('id') || user.credit > 0)) {
    showAds = false;
  }
  return showAds;
}

Future<File> imageCompressAndGetFile(File file) async {
  UserModel user = await getUser();

  if (file.lengthSync() < 200 * 1024) {
    return file;
  }

  var quality = 100;
  if (file.lengthSync() > 4 * 1024 * 1024) {
    quality = 50;
  } else if (file.lengthSync() > 2 * 1024 * 1024) {
    quality = 60;
  } else if (file.lengthSync() > 1 * 1024 * 1024) {
    quality = 70;
  } else if (file.lengthSync() > 0.5 * 1024 * 1024) {
    quality = 80;
  }

  var dir = await getTemporaryDirectory();
  var targetPath = dir.absolute.path + "/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";

  var minSize = user.credit > 0 ? 1024 : 512;

  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    minWidth: minSize,
    minHeight: minSize,
    quality: quality,
  );

  return result!;
}
