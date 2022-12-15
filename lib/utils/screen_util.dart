import 'dart:ui';

import 'package:flutter/material.dart';

///
/// @Author: wangyu
/// @Date: 2022/5/30
///
/// screen util
/// scaling design size to physics size depends on real screen density
class ScreenUtil {
  static MediaQueryData? mediaQuery = MediaQueryData.fromWindow(window);

  static double _pixelRatio() => mediaQuery?.devicePixelRatio ?? 1;
  static dynamic _ratio;

  static double _designWidth = 375; //mobile mode design width
  static double _designHeight = 680;
  static double _designPadWidth = 580; //pad mode design width
  static double padWidth = 720; //gt 720 to switch to pad mode

  static _init() {
    Size size;
    // use default size(375*680) on failed to get real screen size
    if (mediaQuery == null || mediaQuery!.size.width == 0) {
      size = Size(_designWidth, _designHeight);
    } else {
      size = mediaQuery!.size;
    }
    double uiwidth = size.width >= padWidth ? _designPadWidth : _designWidth;
    var w = size.width;
    if (size.width > size.height) {
      w = size.height;
    }
    _ratio = w / uiwidth;
  }

  static _check() {
    if (mediaQuery == null || mediaQuery!.size.width == 0) {
      mediaQuery = MediaQueryData.fromWindow(window);
      _init();
    }
  }

  static dp(number) {
    _check();
    if (!(_ratio is double || _ratio is int)) {
      _init();
    }
    return number * _ratio;
  }

  static Size get screenSize {
    return mediaQuery?.size ?? Size(_designWidth, _designHeight);
  }

  static Size getCurrentWidgetSize(BuildContext context) {
    var box = context.findRenderObject() as RenderBox?;
    return box?.size ?? screenSize;
  }

  static double getScreenPixelDensity() {
    return _pixelRatio();
  }

  static double getStatusBarHeight() {
    return mediaQuery?.padding.top ?? 0;
  }

  static double getBottomBarHeight() {
    return mediaQuery?.padding.bottom ?? 0;
  }

  static double getNavigationBarHeight() {
    return mediaQuery?.padding.top ?? 0 + kToolbarHeight;
  }

  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  static double getBottomPadding(BuildContext context) {
    if (MediaQuery.of(context).padding.bottom == 0) {
      return $(15);
    } else {
      return MediaQuery.of(context).padding.bottom;
    }
  }
}

double $(double value) => ScreenUtil.dp(value);
