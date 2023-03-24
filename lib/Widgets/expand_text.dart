import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';

class ExpandableText extends StatefulWidget {
  String text;
  TextStyle style;
  int minLines;
  double width;
  StrutStyle? strutStyle;
  TextAlign? textAlign;
  TextDirection? textDirection;
  Locale? locale;
  bool? softWrap;
  TextOverflow? overflow;
  double? textScaleFactor;
  int? maxLines;
  String? semanticsLabel;
  TextWidthBasis? textWidthBasis;
  ui.TextHeightBehavior? textHeightBehavior;
  Color? selectionColor;
  Duration duration;

  ExpandableText({
    required this.text,
    required this.style,
    required this.width,
    this.duration = const Duration(milliseconds: 250),
    this.minLines = 1,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines = 9999,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> with SingleTickerProviderStateMixin {
  late String text;
  late TextStyle style;
  late int minLines;
  late AnimationController animationController;
  late CurvedAnimation anim;
  late double width;
  double minHeight = 0;
  double maxHeight = 0;
  String? collapseText;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: widget.duration);
    anim = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    initFromWidget();
  }

  @override
  void didUpdateWidget(covariant ExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    animationController.duration = widget.duration;
    anim = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    initFromWidget();
  }

  void initFromWidget() {
    text = widget.text;
    style = widget.style;
    minLines = widget.minLines;
    width = widget.width;

    // 绘制标题文本
    minHeight = (TextPainter(
      text: TextSpan(text: text, style: style),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: minLines,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
      textHeightBehavior: widget.textHeightBehavior,
      textScaleFactor: widget.textScaleFactor ?? 1.0,
    )..layout(maxWidth: width))
        .height;
    maxHeight = (TextPainter(
      text: TextSpan(text: text, style: style),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: widget.maxLines,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
      textHeightBehavior: widget.textHeightBehavior,
      textScaleFactor: widget.textScaleFactor ?? 1.0,
    )..layout(maxWidth: width))
        .height;
    var oneLineWidth = (TextPainter(
      text: TextSpan(text: text, style: style),
      ellipsis: '...',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
      textWidthBasis: TextWidthBasis.longestLine,
      maxLines: widget.maxLines,
      locale: widget.locale,
      strutStyle: widget.strutStyle,
      textHeightBehavior: widget.textHeightBehavior,
      textScaleFactor: widget.textScaleFactor ?? 1.0,
    )..layout(maxWidth: double.infinity))
        .width;
    if (oneLineWidth > width) {
      var d = width * 1.8 / oneLineWidth;
      var e = (text.length * d).toInt();
      collapseText = text.substring(0, e);
    } else {
      collapseText = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (minHeight == maxHeight) {
      return Text(
        text,
        style: style,
        overflow: widget.overflow,
        maxLines: widget.maxLines,
        textAlign: widget.textAlign,
        textScaleFactor: widget.textScaleFactor,
        textHeightBehavior: widget.textHeightBehavior,
        strutStyle: widget.strutStyle,
        locale: widget.locale,
        selectionColor: widget.selectionColor,
        semanticsLabel: widget.semanticsLabel,
        softWrap: widget.softWrap,
        textDirection: widget.textDirection,
        textWidthBasis: widget.textWidthBasis,
      );
    }
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        return Stack(
          children: [
            Text(
              animationController.isDismissed ? '${collapseText}...' : text,
              style: style,
              overflow: widget.overflow,
              maxLines: animationController.isDismissed ? minLines : widget.maxLines,
              textAlign: widget.textAlign,
              textScaleFactor: widget.textScaleFactor,
              textHeightBehavior: widget.textHeightBehavior,
              strutStyle: widget.strutStyle,
              locale: widget.locale,
              selectionColor: widget.selectionColor,
              semanticsLabel: widget.semanticsLabel,
              softWrap: widget.softWrap,
              textDirection: widget.textDirection,
              textWidthBasis: widget.textWidthBasis,
            ),
            Positioned(
              child: Text(
                animationController.isDismissed ? S.of(context).expand : S.of(context).collapse,
                style: TextStyle(color: Color(0xff888888)),
              ).intoContainer(padding: EdgeInsets.only(left: $(10), top: $(5), bottom: $(2))).intoGestureDetector(onTap: () {
                if (animationController.isDismissed) {
                  animationController.forward();
                } else if (animationController.isCompleted) {
                  animationController.reverse();
                }
              }),
              bottom: 0,
              right: 0,
            )
          ],
        ).intoContainer(height: minHeight + (maxHeight - minHeight) * animationController.value);
      },
    );
  }
}
