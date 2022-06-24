
import 'package:cartoonizer/Common/importFile.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

/// 质感设计Header
class CartoonizerMaterialHeader extends Header {
  final Key? key;
  final double displacement;

  /// 颜色
  final Animation<Color?>? valueColor;

  /// 背景颜色
  final Color? backgroundColor;

  final LinkHeaderNotifier linkNotifier = LinkHeaderNotifier();

  CartoonizerMaterialHeader({
    this.key,
    this.displacement = 40.0,
    this.valueColor,
    this.backgroundColor,
    completeDuration = const Duration(seconds: 1),
    bool enableHapticFeedback = false,
  }) : super(
    float: true,
    extent: 125.0,
    triggerDistance: 125.0,
    completeDuration: completeDuration == null
        ? Duration(
      milliseconds: 300,
    )
        : completeDuration +
        Duration(
          milliseconds: 300,
        ),
    enableInfiniteRefresh: false,
    enableHapticFeedback: enableHapticFeedback,
  );

  @override
  Widget contentBuilder(
      BuildContext context,
      RefreshMode refreshState,
      double pulledExtent,
      double refreshTriggerPullDistance,
      double refreshIndicatorExtent,
      AxisDirection axisDirection,
      bool float,
      Duration? completeDuration,
      bool enableInfiniteRefresh,
      bool success,
      bool noMore) {
    linkNotifier.contentBuilder(
        context,
        refreshState,
        pulledExtent,
        refreshTriggerPullDistance,
        refreshIndicatorExtent,
        axisDirection,
        float,
        completeDuration,
        enableInfiniteRefresh,
        success,
        noMore);
    return MaterialHeaderWidget(
      key: key,
      displacement: displacement,
      valueColor: valueColor,
      backgroundColor: backgroundColor,
      linkNotifier: linkNotifier,
    );
  }
}
