import 'dart:ui';

import 'package:cartoonizer/Widgets/blank_area_intercept.dart';
import 'package:cartoonizer/Widgets/size_changed.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

extension WidgetExtension on Widget {
  Center intoCenter({
    Key? key,
    double? widthFactor,
    double? heightFactor,
  }) =>
      Center(
        key: key,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: this,
      );

  Padding intoPadding({
    Key? key,
    required EdgeInsets padding,
  }) =>
      Padding(
        key: key,
        padding: padding,
        child: this,
      );

  Container intoContainer({
    Key? key,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Clip clipBehavior = Clip.none,
    Matrix4? transform,
  }) =>
      Container(
        key: key,
        alignment: alignment,
        padding: padding,
        color: color,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        constraints: constraints,
        width: width,
        height: height,
        margin: margin,
        clipBehavior: clipBehavior,
        transform: transform,
        child: this,
      );

  Material intoMaterial({
    Key? key,
    MaterialType type = MaterialType.canvas,
    double elevation = 0.0,
    Color? color,
    Color? shadowColor,
    TextStyle? textStyle,
    ShapeBorder? shape,
    BorderRadiusGeometry? borderRadius,
    bool borderOnForeground = true,
    Clip clipBehavior = Clip.none,
    Duration animationDuration = kThemeChangeDuration,
  }) =>
      Material(
        key: key,
        type: type,
        elevation: elevation,
        color: color,
        shadowColor: shadowColor,
        textStyle: textStyle,
        shape: shape,
        borderRadius: borderRadius,
        borderOnForeground: borderOnForeground,
        clipBehavior: clipBehavior,
        animationDuration: animationDuration,
        child: this,
      );

  Ink intoInkWell({
    Key? key,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureTapDownCallback? onTapDown,
    GestureTapCancelCallback? onTapCancel,
    ValueChanged<bool>? onHighlightChanged,
    ValueChanged<bool>? onHover,
    MouseCursor? mouseCursor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    MaterialStateProperty<Color>? overlayColor,
    Color? splashColor,
    InteractiveInkFeatureFactory? splashFactory,
    double? radius,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    bool enableFeedback = true,
    bool excludeFromSemantics = false,
    FocusNode? focusNode,
    bool canRequestFocus = true,
    ValueChanged<bool>? onFocusChange,
    bool autofocus = false,
  }) =>
      Ink(
        key: key,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          onTapDown: onTapDown,
          onTapCancel: onTapCancel,
          onHighlightChanged: onHighlightChanged,
          onHover: onHover,
          mouseCursor: mouseCursor,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          overlayColor: overlayColor,
          splashColor: splashColor,
          splashFactory: splashFactory,
          radius: radius,
          borderRadius: borderRadius,
          customBorder: customBorder,
          enableFeedback: enableFeedback,
          excludeFromSemantics: excludeFromSemantics,
          focusNode: focusNode,
          canRequestFocus: canRequestFocus,
          onFocusChange: onFocusChange,
          autofocus: autofocus,
          child: this,
        ),
      );

  GestureDetector intoGestureDetector({
    Key? key,
    GestureTapCallback? onTap,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCancelCallback? onTapCancel,
  }) =>
      GestureDetector(
        onTap: onTap,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        child: this,
      );

  AbsorbPointer absorb({
    Key? key,
    bool absorbing = true,
    bool? ignoringSemantics,
  }) =>
      AbsorbPointer(
        child: this,
        key: key,
        absorbing: absorbing,
        ignoringSemantics: ignoringSemantics,
      );

  IgnorePointer ignore({
    Key? key,
    bool ignoring = true,
    bool? ignoringSemantics,
  }) =>
      IgnorePointer(
        key: key,
        ignoring: ignoring,
        ignoringSemantics: ignoringSemantics,
        child: this,
      );

  Offstage offstage({
    Key? key,
    bool offstage = true,
  }) =>
      Offstage(
        key: key,
        offstage: offstage,
        child: this,
      );

  Visibility visibility({
    Key? key,
    bool visible = true,
    bool maintainState = false,
    bool maintainAnimation = false,
    bool maintainSize = false,
    bool maintainSemantics = false,
    bool maintainInteractivity = false,
    Widget replacement = const SizedBox.shrink(),
  }) =>
      Visibility(
        key: key,
        visible: visible,
        child: this,
        maintainSize: maintainSize,
        maintainAnimation: maintainAnimation,
        maintainState: maintainState,
        maintainSemantics: maintainSemantics,
        maintainInteractivity: maintainInteractivity,
        replacement: replacement,
      );

  SizeChanged listenSizeChanged({
    Key? key,
    Function(Size size)? onSizeChanged,
  }) =>
      SizeChanged(
        key: key,
        onSizeChanged: onSizeChanged,
        child: this,
      );

  BlankAreaIntercept blankAreaIntercept({
    Key? key,
    KeyboardInterceptType interceptType = KeyboardInterceptType.hideKeyboard,
    Function? onBlankTap,
  }) =>
      BlankAreaIntercept(
        key: key,
        interceptType: interceptType,
        child: this,
        onBlankTap: onBlankTap,
      );

  ClipRect blur({Key? key, double x = 12, double y = 12, BlendMode blendMode = BlendMode.srcOver}) => ClipRect(
        key: key,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: x, sigmaY: y),
          child: this,
          blendMode: blendMode,
        ),
      );

  Hero hero({Key? key, required Object tag}) => Hero(tag: tag, child: this.intoMaterial(color: Colors.transparent));

  SkeletonTheme skeletonTheme() => SkeletonTheme(
        themeMode: ThemeMode.dark,
        shimmerGradient: LinearGradient(
          colors: [
            Color(0xFFD8E3E7),
            Color(0xFFC8D5DA),
            Color(0xFFD8E3E7),
          ],
          stops: [0.1, 0.5, 0.9],
        ),
        darkShimmerGradient: LinearGradient(
          colors: [
            Color(0xFF222222),
            Color(0xFF242424),
            Color(0xFF2B2B2B),
            Color(0xFF242424),
            Color(0xFF222222),
          ],
          stops: [0.0, 0.2, 0.5, 0.8, 1],
          begin: Alignment(-2.4, -0.2),
          end: Alignment(2.4, 0.2),
          tileMode: TileMode.clamp,
        ),
        child: this,
      );
}

typedef DelayCallback<T> = T Function();

Future<T> delay<T>(
  DelayCallback<T> callback, {
  int milliseconds = 16,
}) async {
  await Future.delayed(Duration(milliseconds: milliseconds), () => () {});
  return callback.call();
}

extension StateEx on State {
  pop<T extends Object>([T? data]) {
    Navigator.of(context).pop(data);
  }
}
