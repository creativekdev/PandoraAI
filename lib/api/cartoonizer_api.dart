import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/network/base_requester.dart';

class CartoonizerApi extends BaseRequester {
  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    Map<String, String> headers = {};
    if (userManager.isLogin) {
      headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    }
    return ApiOptions(baseUrl: Config.instance.apiHost, headers: headers);
  }


}
