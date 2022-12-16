import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';

class AvatarAiManager extends BaseManager {
  List<AvatarAiListEntity> dataList = [];
  late UserManager userManager;
  late CartoonizerApi api;
  AvatarConfigEntity? config;
  bool listPageAlive = false;

  @override
  Future<void> onCreate() async {
    await super.onCreate();
    api = CartoonizerApi().bindManager(this);
  }

  @override
  Future<void> onDestroy() async {
    await super.onDestroy();
    api.unbind();
  }

  @override
  Future<void> onAllManagerCreate() async {
    await super.onAllManagerCreate();
    userManager = getManager();
    if (!userManager.isNeedLogin) {
      listAllAvatarAi();
    }
    getConfig();
  }

  Future<AvatarConfigEntity?> getConfig() async {
    if (config != null) {
      // api.getAvatarAiConfig().then((value) {
      //   if (value != null) {
      //     config = value;
      //   }
      // });
      return config;
    } else {
      var avatarConfigEntity = await api.getAvatarAiConfig();
      if (avatarConfigEntity != null) {
        config = avatarConfigEntity;
      }
      return config;
    }
  }

  Future<List<AvatarAiListEntity>?> listAllAvatarAi() async {
    var list = await CartoonizerApi().listAllAvatarAi();
    if (list == null) {
      return null;
    }
    dataList = list;
    if ((userManager.user?.aiAvatarCredit ?? 0) > 0) {
      dataList.add(AvatarAiListEntity()..status = 'undefined');
    }
    return list;
  }

  Future<AvatarAiListEntity?> getAvatarAiDetail({
    required String token,
  }) async {
    return await CartoonizerApi().getAvatarAiDetail(token: token);
  }
}
