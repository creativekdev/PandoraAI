import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';

class SocialMediaConnectorApi extends RetryAbleRequester {
  UserManager userManager = AppDelegate().getManager();

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: Config.instance.apiHost, headers: {});
  }

  Future<String?> getSlugByIgName({required String igName}) async {
    var baseEntity = await get('/core_user/search',
        params: {
          'channel': ConnectorPlatform.instagram.value(),
          'username': igName,
        },
        needRetry: false,
        canClickRetry: false,
        preHandleRequest: false, onFailed: (response) {
      response;
    });
    return baseEntity?.data['data']['slug'];
  }

  Future<String?> getSlugByCoreId({required int coreId}) async {
    var baseEntity = await get('/core_user/slug/$coreId');
    return baseEntity?.data['slug'];
  }

  Future<MetagramPageEntity?> getMetagramData({
    required int from,
    required int size,
    required String slug,
  }) async {
    Map<String, dynamic> params = {
      'from': from,
      'size': size,
      'slug': slug,
    };
    var baseEntity = await get('/social_post_page/get', params: params);
    return jsonConvert.convert<MetagramPageEntity>(baseEntity?.data['data']);
  }

  Future<BaseEntity?> startBuildMetagram({required int coreUserId}) async {
    return await get('/social_post_page/run/$coreUserId');
  }
}
