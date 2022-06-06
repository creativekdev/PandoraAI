import 'package:flutter/material.dart';

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
  }) =>
      GestureDetector(
        onTap: onTap,
        child: this,
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
}

typedef DelayCallback<T> = T Function();

Future<T> delay<T>(
    DelayCallback<T> callback, {
      int milliseconds = 16,
    }) =>
    Future<T>.delayed(
      Duration(milliseconds: milliseconds),
          () => callback.call(),
    );