import 'dart:convert';
import 'package:http/http.dart';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Ui/EmailVerificationScreen.dart';
import 'package:cartoonizer/config.dart';

import 'Model/UserModel.dart';

class API {
  static Future<dynamic> getLogin({bool needLoad = false, BuildContext? context}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isLogin = sharedPreferences.getBool('isLogin') ?? false;
    var localUser = sharedPreferences.getString('user') ?? "";

    if (!isLogin) {
      return UserModel.fromJson({});
    }

    if (needLoad || localUser == '') {
      final headers = {"cookie": "sb.connect.sid=${sharedPreferences.getString("login_cookie")}"};
      var response = await get(Uri.parse('${Config.instance.apiHost}/user/get_login'), headers: headers);
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body.toString());
        UserModel user = UserModel.fromGetLogin(data);
        sharedPreferences.setString("user", jsonEncode(user));

        if (context != null && user.status != 'activated') {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: "/EmailVerificationScreen"),
                builder: (context) => EmailVerificationScreen(user.email),
              ));
        }

        return user;
      }
      return UserModel.fromJson(jsonDecode(localUser));
    }

    return UserModel.fromJson(jsonDecode(localUser));
  }
}
