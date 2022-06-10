import 'dart:convert';
import 'dart:io';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/views/EmailVerificationScreen.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'Common/importFile.dart';
import 'Common/sToken.dart';

class API {
  // Stitching parameters
  static String joinParams(Map<String, dynamic>? params, String url) {
    if (params != null && params.isNotEmpty) {
      StringBuffer stringBuffer = StringBuffer("?");
      params.forEach((key, value) {
        stringBuffer.write("$key" + "=" + "$value" + "&");
      });
      String paramStr = stringBuffer.toString();
      paramStr = paramStr.substring(0, paramStr.length - 1);
      url = url + paramStr;
    }
    return url;
  }

  // get request
  static Future<http.Response> get(String url, {Map<String, String>? headers, Map<String, dynamic>? params}) async {
    print("API------> GET: $url");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var cookie = "sb.connect.sid=${sharedPreferences.getString("login_cookie")}";

    // add custom headers
    if (headers == null || headers.isEmpty) {
      headers = {"Content-type": "application/x-www-form-urlencoded", "cookie": cookie};
    } else {
      if (headers["cookie"] == null) {
        headers["cookie"] = cookie;
      }
    }

    // add custom params
    if (params == null || params.isEmpty) {
      params = {
        "app_platform": Platform.operatingSystem,
        "app_version": packageInfo.version,
        "app_build": packageInfo.buildNumber,
        'from_app': "1",
      };
    } else {
      params["app_platform"] = Platform.operatingSystem;
      params["app_version"] = packageInfo.version;
      params["app_build"] = packageInfo.buildNumber;
      params['from_app'] = "1";
    }

    // add ts and signature
    params["ts"] = DateTime.now().millisecondsSinceEpoch.toString();
    params["s"] = sToken(params);

    if (url.startsWith("http") == false) {
      url = "${Config.instance.host}" + url;
    }
    url = joinParams(params, url);
    return await http.get(Uri.parse(url), headers: headers);
  }

  // post request
  static Future<http.Response> post(String url, {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    print("API------> POST: $url");
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var cookie = "sb.connect.sid=${sharedPreferences.getString("login_cookie")}";

    // add custom headers
    if (headers == null || headers.isEmpty) {
      headers = {"Content-type": "application/json", "cookie": cookie};
    } else {
      if (headers["cookie"] == null) {
        headers["cookie"] = cookie;
      }
      if (headers["Content-type"] == null) {
        headers["Content-type"] = "application/json";
      }
    }

    // add custom params
    if (body == null || body.isEmpty) {
      body = {
        "app_platform": Platform.operatingSystem,
        "app_version": packageInfo.version,
        "app_build": packageInfo.buildNumber,
        'from_app': "1",
      };
    } else {
      body["app_platform"] = Platform.operatingSystem;
      body["app_version"] = packageInfo.version;
      body["app_build"] = packageInfo.buildNumber;
      body['from_app'] = "1";
    }

    // add ts and signature
    body["ts"] = DateTime.now().millisecondsSinceEpoch.toString();
    body["s"] = sToken(body);

    if (url.startsWith("http") == false) {
      url = "${Config.instance.host}" + url;
    }
    return await http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
  }

  // get login
  static Future<dynamic> getLogin({bool needLoad = false, BuildContext? context}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isLogin = sharedPreferences.getBool('isLogin') ?? false;
    var localUser = sharedPreferences.getString('user') ?? "";

    if (needLoad || localUser == '') {
      var response = await get('/api/user/get_login');
      Map data = jsonDecode(response.body.toString());

      if (response.statusCode == 200 && data['login'] == true) {
        UserModel user = UserModel.fromGetLogin(data);
        sharedPreferences.setString("user", jsonEncode(user));

        if (context != null && user.status != 'activated') {
          // remove all route and push email verification screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => EmailVerificationScreen(user.email)),
            ModalRoute.withName('/EmailVerificationScreen'),
          );
        }
        return user;
      } else {
        UserModel user = UserModel.fromUnlogin(data);
        sharedPreferences.setString("user", jsonEncode(user));
        return user;
      }
    }
    return UserModel.fromJson(jsonDecode(localUser));
  }

  // buy plan with stripe
  static Future<bool> buyPlan(body) async {
    var response = await post("/api/plan/buy", body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      var body = jsonDecode(response.body);
      CommonExtension().showToast(body["message"] ?? body["code"]);
      return false;
    }
  }

  // check latest version
  static Future<Map> checkLatestVersion() async {
    var data = {};
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    try {
      var response = await get("/api/check_app_version");
      var body = jsonDecode(response.body);
      data = body["data"] ?? {};
      int availableBuild = data['available_build'] ?? 0;

      if (availableBuild > int.parse(packageInfo.buildNumber)) {
        data["need_update"] = true;
      }

      return data;
    } catch (e) {
      return {"need_update": false};
    }
  }

  static Future<EffectMap?> getHomeConfig() async {
    var response = await API.get("/api/tool/cartoonize_config/v3");
    if (response.statusCode == 200) {
      final Map<String, dynamic> parsed = json.decode(response.body.toString());
      return EffectMap.fromJson(parsed);
    }
    return null;
  }
}
