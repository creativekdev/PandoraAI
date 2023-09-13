import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/rate_config_entity.dart';
import 'package:common_utils/common_utils.dart';

import 'widget/rate_notice_dialog_content.dart';

const int second = 1000;
const int minute = second * 60;
const int hour = minute * 60;
const int day = hour * 24;

class RateNoticeOperator {
  CacheManager cacheManager;

  RateConfigEntity? configEntity;

  RateNoticeOperator({required this.cacheManager});

  init() {
    var json = cacheManager.getJson(cacheManager.rateConfigKey());
    if (json == null) {
      configEntity = RateConfigEntity();
      configEntity!.isShowed = false;
      saveConfig(configEntity!);
    } else {
      configEntity = jsonConvert.convert(json);
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
    // 如果已经弹过则不弹
    if (configEntity?.isShowed == true) {
      return false;
    }
    // 如果是转换，转换次数如果小于2，则不弹
    if ((configEntity?.switchCount ?? 0) < 2 && addCount) {
      return false;
    }
    return true;
  }

  void onSwitch(BuildContext context, bool addCount) {
    if (configEntity == null) return;
    if (addCount) {
      configEntity!.switchCount++;
      saveConfig(configEntity!);
    }
    judgeAndShowNotice(context, addCount);
  }

  void onBuy(BuildContext context) {
    return;
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
              configEntity?.isShowed = true;
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
