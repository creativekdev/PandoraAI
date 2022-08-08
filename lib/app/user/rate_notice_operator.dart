import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/rate_config_entity.dart';

const int second = 1000;
const int minute = second * 60;
const int hour = minute * 60;
const int day = hour * 24;

const int maxSwitchCount = 10;
const int maxDuration = 2 * day;

class RateNoticeOperator {
  CacheManager cacheManager;

  RateConfigEntity? configEntity;

  RateNoticeOperator({required this.cacheManager});

  init() {
    if (cacheManager.rateConfigKey() == null) {
      configEntity = null;
    } else {
      var json = cacheManager.getJson(cacheManager.rateConfigKey()!);
      if (json == null) {
        configEntity = RateConfigEntity();
        configEntity!.firstLoginDate = DateTime.now().millisecondsSinceEpoch;
        saveConfig(configEntity!);
      } else {
        configEntity = jsonConvert.convert(json);
      }
    }
  }

  dispose() {
    if (configEntity != null) {
      saveConfig(configEntity!);
      configEntity = null;
    }
  }

  Future<bool> saveConfig(RateConfigEntity configEntity) => cacheManager.setJson(cacheManager.rateConfigKey()!, configEntity.toJson());

  bool shouldRate() {
    if (configEntity == null) {
      return false;
    }
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (configEntity!.nextActivateDate != 0) {
      if (configEntity!.nextActivateDate < currentTime) {
        if (!configEntity!.calculateInNextActivate) {
          return true;
        }
      }
    }
    if (currentTime - configEntity!.firstLoginDate > maxDuration) {
      if (configEntity!.nextActivateDate == 0) {
        return true;
      }
    }
    if (configEntity!.switchCount > maxSwitchCount) {
      return true;
    }
    return false;
  }

  void onSwitch(BuildContext context) {
    if (configEntity == null) return;
    configEntity!.switchCount++;
    saveConfig(configEntity!);
    judgeAndShowNotice(context);
  }

  void onBuy(BuildContext context) {
    if (configEntity == null) return;
    if (configEntity!.nextActivateDate != 0) {
      return;
    }
    configEntity!.nextActivateDate = DateTime.now().millisecondsSinceEpoch - day;
    configEntity!.calculateInNextActivate = false;
    judgeAndShowNotice(context);
  }

  judgeAndShowNotice(BuildContext context) {
    print('-----------------------------rateConfig: ${configEntity?.toJson()}');
    if (shouldRate()) {
      showDialog(
        context: context,
        builder: (_) => Column(
          children: [
            Text('rate dialog'),
          ],
        ),
      );
    }
  }
}
