import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/online_model.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/network/base_requester.dart';

class CartoonizerApi extends BaseRequester {
  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    Map<String, String> headers = {};
    if (!userManager.isNeedLogin) {
      headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    }
    return ApiOptions(baseUrl: Config.instance.apiHost, headers: headers);
  }

  Future<BaseEntity?> login(Map<String, dynamic> params) => post('/user/login', params: params);

  Future<OnlineModel> getCurrentUser() async {
    var baseEntity = await get('/user/get_login');
    if (baseEntity != null) {
      if (baseEntity.data != null) {
        Map<String, dynamic> data = baseEntity.data;
        bool login = data['login'] ?? false;
        SocialUserInfo? user;
        if (login) {
          user = SocialUserInfo.fromJson(data['data']);
        }
        return OnlineModel(user: user, loginSuccess: login, aiServers: data['ai_servers']);
      }
    }
    return OnlineModel(user: null, loginSuccess: false, aiServers: {});
  }
}
