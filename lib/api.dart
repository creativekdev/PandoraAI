import 'dart:convert';
import 'package:http/http.dart';
import 'package:cartoonizer/Common/importFile.dart';

import 'package:cartoonizer/config.dart';

import 'Model/UserModel.dart';

class API {
  static Future<UserModel> getLogin(bool needLoad) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var localUser = sharedPreferences.getString('user') ?? "";

    if (needLoad) {
      final headers = {"cookie": "sb.connect.sid=${sharedPreferences.getString("login_cookie")}"};
      var response = await get(Uri.parse('${Config.instance.apiHost}/user/get_login'), headers: headers);
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body.toString());
        UserModel user = UserModel.fromGetLogin(data);
        sharedPreferences.setString("user", jsonEncode(user));
        return user;
      }
      return UserModel.fromJSON(jsonDecode(localUser));
    } else {
      return UserModel.fromJSON(jsonDecode(localUser));
    }
  }
}