import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/network/base_requester.dart';

import '../app/user/user_manager.dart';

class Text2ImageApi extends BaseRequester {
  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: userManager.aiServers['sdserver'] ?? 'https://ai.pandoraai.app:7003', headers: headers);
  }

  Future<String?> randomPrompt() async {
    var baseEntity = await get('/sdapi/v1/random_prompt');
    return baseEntity?.data['data'];
  }

  Future<String?> text2image({
    required String prompt,
    int width = 640,
    int height = 480,
    int seed = -1,
    int steps = 20,
  }) async {}
}
