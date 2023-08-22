import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';

class ClipDropApi extends RetryAbleRequester {
  ClipDropApi() : super(client: DioNode().build(logResponseEnable: false));

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    return ApiOptions(baseUrl: 'https://clipdrop-api.co', headers: {
      'x-api-key': 'e1b9d3125867dff8202a3a5f61a1349f3db48fb56582202403c72b8edc0b26d5aa8e8e5ebe29caed9d396140cbb64309',
    });
  }

  Future<String?> remove({
    required String filePath,
    required AppApi appApi,
  }) async {

  }
}
