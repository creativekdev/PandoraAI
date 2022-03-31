import 'dart:convert';
import 'package:cartoonizer/Common/importFile.dart';

import 'package:cartoonizer/Model/UserModel.dart';

const String _kUser = 'user';

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

Future<void> loginBack(BuildContext context) async {
  final box = GetStorage();
  String? login_back_page = box.read('login_back_page');
  if (login_back_page != null) {
    Navigator.popUntil(context, ModalRoute.withName(login_back_page));
    box.remove('login_back_page');
  } else {
    Navigator.popUntil(context, ModalRoute.withName('/SettingScreen'));
  }
}
