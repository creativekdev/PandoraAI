import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/rate_config_entity.dart';
import 'package:common_utils/common_utils.dart';

import 'widget/rate_notice_dialog_content.dart';

const int second = 1000;
const int minute = second * 60;
const int hour = minute * 60;
const int day = hour * 24;

// in production
// const int maxDuration = 15 * day;
// const int nextActivate = 360; // 90 * 24; hour

// in development
const int maxDuration = 10 * minute;
const int nextActivate = 2;

class RateNoticeOperator {
  CacheManager cacheManager;

  RateConfigEntity? configEntity;

  RateNoticeOperator({required this.cacheManager});

  init() {
    var json = cacheManager.getJson(cacheManager.rateConfigKey());
    if (json == null) {
      configEntity = RateConfigEntity();
      configEntity!.firstLoginDate = DateTime.now().millisecondsSinceEpoch;
      saveConfig(configEntity!);
    } else {
      configEntity = jsonConvert.convert(json);
      if (configEntity!.nextActivateDate != 0 && configEntity!.nextActivateDate < DateTime.now().millisecondsSinceEpoch) {
        configEntity!.nextActivateDate = 0;
        saveConfig(configEntity!);
      } else if (DateUtils.isSameDay(DateTime.fromMillisecondsSinceEpoch(configEntity!.nextActivateDate), DateTime.now())) {
        configEntity!.nextActivateDate = 0;
        saveConfig(configEntity!);
      }
    }
  }

  dispose() async {
    if (configEntity != null) {
      await saveConfig(configEntity!);
      configEntity = null;
    }
  }

  Future<bool> saveConfig(RateConfigEntity configEntity) async {
    var rateConfigKey = cacheManager.rateConfigKey();
    return cacheManager.setJson(rateConfigKey, configEntity.toJson());
  }

  bool shouldRate(bool addCount) {
    if (configEntity == null) {
      return false;
    }
    // 如果是转换，转换次数如果小于2，则不弹
    if ((configEntity?.switchCount ?? 0) < 2 && addCount) {
      return false;
    }
    // 判断时间是否大于15天
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
    return false;
  }

  void onSwitch(BuildContext context, bool addCount) {
    if (configEntity == null) return;
    if (configEntity!.nextActivateDate != 0) {
      return;
    }
    if (addCount) {
      configEntity!.switchCount++;
      saveConfig(configEntity!);
    }
    judgeAndShowNotice(context, addCount);
  }

  void onBuy(BuildContext context) {
    return;
    if (configEntity == null) return;
    if (configEntity!.nextActivateDate != 0) {
      return;
    }
    configEntity!.nextActivateDate = DateTime.now().millisecondsSinceEpoch - day;
    configEntity!.calculateInNextActivate = false;
    saveConfig(configEntity!);
    judgeAndShowNotice(context, false);
  }

  bool _dialogShown = false;

  Future<bool> judgeAndShowNotice(BuildContext context, bool addCount) async {
    if (_dialogShown) {
      return false;
    }
    LogUtil.v('${configEntity?.print()}', tag: 'rateConfig');
    if (shouldRate(addCount)) {
      _dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => RateNoticeDialogContent(
          onResult: (value) {
            delay(() {
              _dialogShown = false;
              // 15天后再次激活
              configEntity!.nextActivateDate = DateTime.now().add(Duration(hours: nextActivate)).millisecondsSinceEpoch;
              configEntity!.switchCount = 0;
              configEntity!.calculateInNextActivate = true;
              saveConfig(configEntity!);
            }, milliseconds: 100);
          },
        ),
      );
      return true;
    }
    return false;
  }
}
