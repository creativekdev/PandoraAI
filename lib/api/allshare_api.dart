import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:device_uuid/device_uuid.dart';

class AllShareApi extends RetryAbleRequester {
  CacheManager cacheManager = AppDelegate().getManager();

  AllShareApi() : super(client: DioNode().build(logResponseEnable: true), needLogError: false);

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: 'https://allsha.re', headers: {});
  }

  Future<BaseEntity?> onFirstEntry() async {
    return await post('/track/app/install/${APP_HASH_VALUE}', params: {
      'device_id': await DeviceUuid().getUUID(),
    });
  }

  Future<BaseEntity?> onSignUp({required String email}) async {
    return await post('/track/app/signup/${APP_HASH_VALUE}', params: {
      'device_id': await DeviceUuid().getUUID(),
      'email': email,
    });
  }

  Future<BaseEntity?> identify({required String accountId}) async {
    return await post('/track/app/identify/${APP_HASH_VALUE}', params: {
      'device_id': await DeviceUuid().getUUID(),
      'account_id': accountId,
    });
  }

  Future<BaseEntity?> conversion({required String accountId, required double conversion}) async {
    return await post('/track/app/conversion/${APP_HASH_VALUE}', params: {
      'device_id': await DeviceUuid().getUUID(),
      'account_id': accountId,
      'conversion': conversion,
    });
  }
}
