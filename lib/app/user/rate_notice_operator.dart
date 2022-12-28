import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/rate_config_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';

import 'widget/feedback_dialog.dart';

const int second = 1000;
const int minute = second * 60;
const int hour = minute * 60;
const int day = hour * 24;

// in production
const int maxSwitchCount = 10;
const int maxDuration = 2 * day;
const int nextActivatePositive = 2160; // 90 * 24; hour
const int nextActivateNegative = 720; // 30 * 24; hour

// in development
// const int maxSwitchCount = 3;
// const int maxDuration = 10 * minute;
// const int nextActivatePositive = 2;
// const int nextActivateNegative = 1;

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
    if (configEntity!.switchCount >= maxSwitchCount) {
      return true;
    }
    return false;
  }

  void onSwitch(BuildContext context) {
    if (configEntity == null) return;
    if (configEntity!.nextActivateDate != 0) {
      return;
    }
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
    saveConfig(configEntity!);
    judgeAndShowNotice(context);
  }

  judgeAndShowNotice(BuildContext context) {
    LogUtil.v('${configEntity?.print()}', tag: 'rateConfig');
    if (shouldRate()) {
      logEvent(Events.rate_dialog_loading);
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _noticeDialogWidget(context),
      ).then((value) {
        if (value ?? false) {
          // 3 month later
          configEntity!.nextActivateDate = DateTime.now().add(Duration(hours: nextActivatePositive)).millisecondsSinceEpoch;
          configEntity!.calculateInNextActivate = true;
        } else {
          // 1 month later
          configEntity!.nextActivateDate = DateTime.now().add(Duration(hours: nextActivateNegative)).millisecondsSinceEpoch;
          configEntity!.switchCount = 0;
          configEntity!.calculateInNextActivate = false;
        }
        saveConfig(configEntity!);
      });
    }
  }

  Widget _noticeDialogWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleTextWidget('Rate Pandora Avatar', ColorConstant.White, FontWeight.w600, $(17)).intoContainer(
          padding: EdgeInsets.only(top: $(20), bottom: $(15), left: $(15), right: $(15)),
        ),
        TitleTextWidget(
          'If you enjoy using Pandora Avatar, would you mind taking a moment to rate it?',
          ColorConstant.White,
          FontWeight.normal,
          $(14),
          maxLines: 10,
        ).intoContainer(
          padding: EdgeInsets.only(bottom: $(15), left: $(15), right: $(15)),
        ),
        Container(height: 1, color: ColorConstant.LineColor),
        Text(
          'Looove it! rate now',
          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(16)),
        )
            .intoContainer(
          width: double.maxFinite,
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: $(10)),
          alignment: Alignment.center,
        )
            .intoGestureDetector(onTap: () {
          logEvent(Events.rate_us);
          rateApp();
          // var url = Config.getStoreLink(toRate: true);
          // launchURL(url);
          Navigator.pop(context, true);
        }),
        Container(height: 1, color: ColorConstant.LineColor),
        Text(
          'Give feedback',
          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(16)),
        )
            .intoContainer(
          width: double.maxFinite,
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: $(10)),
          alignment: Alignment.center,
        )
            .intoGestureDetector(onTap: () {
          showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (context) => FeedbackDialog(),
          ).then((value) {
            if (value ?? false) {
              Navigator.pop(context, true);
            }
          });
        }),
        Container(height: 1, color: ColorConstant.LineColor),
        Text(
          'No, thanks',
          style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(16)),
        )
            .intoContainer(
          width: double.maxFinite,
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: $(10)),
          alignment: Alignment.center,
        )
            .intoGestureDetector(onTap: () {
          logEvent(Events.rate_no_thanks);
          Navigator.pop(context, false);
        }),
      ],
    ).intoContainer(width: double.maxFinite).customDialogStyle();
  }
}
