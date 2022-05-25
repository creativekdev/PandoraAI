import 'dart:io';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/views/HomeScreen.dart';

import 'package:cartoonizer/api.dart';

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

showToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: ColorConstant.BtnTextColor,
    textColor: ColorConstant.White,
    fontSize: 16.0,
  );
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
