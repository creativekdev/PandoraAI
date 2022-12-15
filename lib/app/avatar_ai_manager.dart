import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';

class AvatarAiManager extends BaseManager {
  List<AvatarAiListEntity> dataList = [];
  late UserManager userManager;

  @override
  Future<void> onAllManagerCreate() async {
    await super.onAllManagerCreate();
    userManager = getManager();
    if (!userManager.isNeedLogin) {
      listAllAvatarAi();
    }
  }

  Future<List<AvatarAiListEntity>?> listAllAvatarAi() async {
    var list = await CartoonizerApi().listAllAvatarAi();
    if (list == null) {
      return null;
    }
    dataList = list;
    return list;
  }
}
