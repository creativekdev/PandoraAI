import 'dart:math';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_svg/svg.dart';

/// 经典Header
class AppClassicalHeader extends Header {
  /// Key
  final Key? key;

  /// 方位
  final AlignmentGeometry? alignment;

  /// 背景颜色
  final Color bgColor;

  /// 更多信息文字颜色
  final Color infoColor;

  AppClassicalHeader({
    double extent = 60.0,
    double triggerDistance = 70.0,
    bool float = false,
    Duration? completeDuration = const Duration(seconds: 1),
    bool enableInfiniteRefresh = false,
    bool enableHapticFeedback = true,
    bool overScroll = true,
    this.key,
    this.alignment,
    this.bgColor = Colors.transparent,
    this.infoColor = Colors.teal,
  }) : super(
          extent: extent,
          triggerDistance: triggerDistance,
          float: float,
          completeDuration: float
              ? completeDuration == null
                  ? Duration(
                      milliseconds: 400,
                    )
                  : completeDuration +
                      Duration(
                        milliseconds: 400,
                      )
              : completeDuration,
          enableInfiniteRefresh: enableInfiniteRefresh,
          enableHapticFeedback: enableHapticFeedback,
          overScroll: overScroll,
        );

  @override
  Widget contentBuilder(BuildContext context, RefreshMode refreshState, double pulledExtent, double refreshTriggerPullDistance, double refreshIndicatorExtent,
      AxisDirection axisDirection, bool float, Duration? completeDuration, bool enableInfiniteRefresh, bool success, bool noMore) {
    return AppClassicalHeaderWidget(
      key: key,
      classicalHeader: this,
      refreshState: refreshState,
      pulledExtent: pulledExtent,
      refreshTriggerPullDistance: refreshTriggerPullDistance,
      refreshIndicatorExtent: refreshIndicatorExtent,
      axisDirection: axisDirection,
      float: float,
      completeDuration: completeDuration,
      enableInfiniteRefresh: enableInfiniteRefresh,
      success: success,
      noMore: noMore,
    );
  }
}

/// 经典Header组件
class AppClassicalHeaderWidget extends StatefulWidget {
  final AppClassicalHeader classicalHeader;
  final RefreshMode refreshState;
  final double pulledExtent;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;
  final AxisDirection axisDirection;
  final bool float;
  final Duration? completeDuration;
  final bool enableInfiniteRefresh;
  final bool success;
  final bool noMore;

  AppClassicalHeaderWidget({
    Key? key,
    required this.refreshState,
    required this.classicalHeader,
    required this.pulledExtent,
    required this.refreshTriggerPullDistance,
    required this.refreshIndicatorExtent,
    required this.axisDirection,
    required this.float,
    required this.completeDuration,
    required this.enableInfiniteRefresh,
    required this.success,
    required this.noMore,
  }) : super(key: key);

  @override
  AppClassicalHeaderWidgetState createState() => AppClassicalHeaderWidgetState();
}

class AppClassicalHeaderWidgetState extends State<AppClassicalHeaderWidget> with TickerProviderStateMixin<AppClassicalHeaderWidget> {
  // 是否到达触发刷新距离
  bool _overTriggerDistance = false;

  bool get overTriggerDistance => _overTriggerDistance;

  set overTriggerDistance(bool over) {
    if (_overTriggerDistance != over) {
      _overTriggerDistance ? _readyController.forward() : _restoreController.forward();
      _overTriggerDistance = over;
    }
  }

  // 是否刷新完成
  bool _refreshFinish = false;

  set refreshFinish(bool finish) {
    if (_refreshFinish != finish) {
      if (finish && widget.float) {
        Future.delayed(widget.completeDuration! - Duration(milliseconds: 400), () {
          if (mounted) {
            _floatBackController.forward();
          }
        });
        Future.delayed(widget.completeDuration!, () {
          _floatBackDistance = null;
          _refreshFinish = false;
        });
      }
      _refreshFinish = finish;
    }
  }

  // 动画
  late AnimationController _readyController;
  late Animation<double> _readyAnimation;
  late AnimationController _restoreController;
  late Animation<double> _restoreAnimation;
  late AnimationController _floatBackController;
  late Animation<double> _floatBackAnimation;

  // Icon旋转度
  double _iconRotationValue = 1.0;

  // 浮动时,收起距离
  double? _floatBackDistance;

  // 刷新结束图标
  IconData get _finishedIcon {
    if (!widget.success) return Icons.error_outline;
    if (widget.noMore) return Icons.hourglass_empty;
    return Icons.done;
  }

  // 更新时间
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    // 初始化时间
    _dateTime = DateTime.now();
    // 准备动画
    _readyController = new AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _readyAnimation = new Tween(begin: 0.5, end: 1.0).animate(_readyController)
      ..addListener(() {
        setState(() {
          if (_readyAnimation.status != AnimationStatus.dismissed) {
            _iconRotationValue = _readyAnimation.value;
          }
        });
      });
    _readyAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _readyController.reset();
      }
    });
    // 恢复动画
    _restoreController = new AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _restoreAnimation = new Tween(begin: 1.0, end: 0.5).animate(_restoreController)
      ..addListener(() {
        setState(() {
          if (_restoreAnimation.status != AnimationStatus.dismissed) {
            _iconRotationValue = _restoreAnimation.value;
          }
        });
      });
    _restoreAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _restoreController.reset();
      }
    });
    // float收起动画
    _floatBackController = new AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _floatBackAnimation = new Tween(begin: widget.refreshIndicatorExtent, end: 0.0).animate(_floatBackController)
      ..addListener(() {
        setState(() {
          if (_floatBackAnimation.status != AnimationStatus.dismissed) {
            _floatBackDistance = _floatBackAnimation.value;
          }
        });
      });
    _floatBackAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _floatBackController.reset();
      }
    });
  }

  @override
  void dispose() {
    _readyController.dispose();
    _restoreController.dispose();
    _floatBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 是否为垂直方向
    bool isVertical = widget.axisDirection == AxisDirection.down || widget.axisDirection == AxisDirection.up;
    // 是否反向
    bool isReverse = widget.axisDirection == AxisDirection.up || widget.axisDirection == AxisDirection.left;
    // 是否到达触发刷新距离
    overTriggerDistance = widget.refreshState != RefreshMode.inactive && widget.pulledExtent >= widget.refreshTriggerPullDistance;
    if (widget.refreshState == RefreshMode.refreshed) {
      refreshFinish = true;
    }
    return Stack(
      children: <Widget>[
        Positioned(
          top: !isVertical
              ? 0.0
              : isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance!)
                  : null,
          bottom: !isVertical
              ? 0.0
              : !isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance!)
                  : null,
          left: isVertical
              ? 0.0
              : isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance!)
                  : null,
          right: isVertical
              ? 0.0
              : !isReverse
                  ? _floatBackDistance == null
                      ? 0.0
                      : (widget.refreshIndicatorExtent - _floatBackDistance!)
                  : null,
          child: Container(
            alignment: widget.classicalHeader.alignment ??
                (isVertical
                    ? isReverse
                        ? Alignment.topCenter
                        : Alignment.bottomCenter
                    : !isReverse
                        ? Alignment.centerRight
                        : Alignment.centerLeft),
            width: isVertical
                ? double.infinity
                : _floatBackDistance == null
                    ? (widget.refreshIndicatorExtent > widget.pulledExtent ? widget.refreshIndicatorExtent : widget.pulledExtent)
                    : widget.refreshIndicatorExtent,
            height: isVertical
                ? _floatBackDistance == null
                    ? (widget.refreshIndicatorExtent > widget.pulledExtent ? widget.refreshIndicatorExtent : widget.pulledExtent)
                    : widget.refreshIndicatorExtent
                : double.infinity,
            color: widget.classicalHeader.bgColor,
            child: SizedBox(
              height: isVertical ? widget.refreshIndicatorExtent : double.infinity,
              width: !isVertical ? widget.refreshIndicatorExtent : double.infinity,
              child: isVertical
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildContent(isVertical, isReverse),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildContent(isVertical, isReverse),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建显示内容
  List<Widget> _buildContent(bool isVertical, bool isReverse) {
    return isVertical
        ? <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                child: (widget.refreshState == RefreshMode.refresh || widget.refreshState == RefreshMode.armed) && !widget.noMore
                    ? Container(
                        width: 20.0,
                        height: 20.0,
                        child: FrameAnimatedSvg(
                          child: SvgPicture.asset(Images.ic_refresh_header),
                        ),
                      )
                    : widget.refreshState == RefreshMode.refreshed ||
                            widget.refreshState == RefreshMode.done ||
                            (widget.enableInfiniteRefresh && widget.refreshState != RefreshMode.refreshed) ||
                            widget.noMore
                        ? Icon(
                            _finishedIcon,
                            color: widget.classicalHeader.infoColor,
                          )
                        : Transform.rotate(
                            child: Icon(
                              isReverse ? Icons.arrow_upward : Icons.arrow_downward,
                              color: widget.classicalHeader.infoColor,
                            ),
                            angle: 2 * pi * _iconRotationValue,
                          ),
              ),
            ),
          ]
        : <Widget>[
            Container(
              child: widget.refreshState == RefreshMode.refresh || widget.refreshState == RefreshMode.armed
                  ? Container(
                      width: 20.0,
                      height: 20.0,
                      child: FrameAnimatedSvg(
                        child: SvgPicture.asset(Images.ic_refresh_header),
                      ),
                    )
                  : widget.refreshState == RefreshMode.refreshed ||
                          widget.refreshState == RefreshMode.done ||
                          (widget.enableInfiniteRefresh && widget.refreshState != RefreshMode.refreshed) ||
                          widget.noMore
                      ? Icon(
                          _finishedIcon,
                          color: widget.classicalHeader.infoColor,
                        )
                      : Transform.rotate(
                          child: Icon(
                            isReverse ? Icons.arrow_back : Icons.arrow_forward,
                            color: widget.classicalHeader.infoColor,
                          ),
                          angle: 2 * pi * _iconRotationValue,
                        ),
            )
          ];
  }
}

class FrameAnimatedSvg extends StatefulWidget {
  SvgPicture child;

  int framePerLoop = 12;

  FrameAnimatedSvg({Key? key, required this.child, this.framePerLoop = 12}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FrameAnimatedSvgState();
}

class FrameAnimatedSvgState extends State<FrameAnimatedSvg> {
  double angle = 0;

  @override
  initState() {
    super.initState();
    startLoop();
  }

  startLoop() {
    if (!mounted) {
      return;
    }
    var aLoop = 2 * pi;
    double d = aLoop / widget.framePerLoop;
    angle += d;
    if (angle > aLoop) {
      angle -= aLoop;
    }
    delay(() {
      if (!mounted) {
        return;
      }
      setState(() {});
      startLoop();
    }, milliseconds: 128);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: widget.child,
    );
  }
}
