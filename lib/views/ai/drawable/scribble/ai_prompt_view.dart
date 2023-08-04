import '../../../../Common/importFile.dart';
import '../../../../images-res.dart';

class AiPromptView extends StatefulWidget {
  const AiPromptView({Key? key}) : super(key: key);

  @override
  State<AiPromptView> createState() => _AiPromptViewState();
}

class _AiPromptViewState extends State<AiPromptView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    final Tween<double> scaleTween = Tween<double>(begin: 0.95, end: 1.05);

    _animation = scaleTween.animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextSpan textSpan = TextSpan(text: S.of(context).create_with_prompt, style: TextStyle(color: Colors.white));
    final TextPainter textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    return ScaleTransition(
      scale: _animation,
      child: Stack(
        children: [
          GradientStar(
            width: textPainter.width + $(30) + $(20),
            height: $(36),
          ),
          Container(
            padding: EdgeInsets.only(left: $(15), right: $(15), top: $(8)),
            child: Row(
              children: [
                Text(
                  S.of(context).create_with_prompt,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: $(14),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: $(5)),
                  child: Image.asset(
                    'assets/images/ic_prompt.webp',
                    width: $(20),
                    height: $(20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GradientStar extends StatelessWidget {
  GradientStar({Key? key, required this.width, required this.height}) : super(key: key);
  double width;
  double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: TipPainter(),
        size: Size(width, height), // Adjust the size as needed
      ),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFF969696).withOpacity(0.57), // 阴影的颜色
          offset: Offset(0, $(4)), // 阴影的偏移量
          blurRadius: $(14), // 阴影的模糊半径
          spreadRadius: $(3), // 阴影的扩散半径
        )
      ]),
    );
  }
}

class TipPainter extends CustomPainter {
  double angleHeight = $(7);
  double radius = $(8);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height + angleHeight);

    final path = Path()
      ..moveTo(0, radius) // 左上角圆角
      ..arcToPoint(Offset(radius, 0), radius: Radius.circular(radius))
      ..lineTo(size.width - radius, 0) // 右上角圆角
      ..arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius))
      ..lineTo(size.width, size.height - radius) // 右下角圆角
      ..arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius))
      ..lineTo(radius, size.height)
      ..lineTo(radius * 3 + $(5), size.height)
      ..lineTo(radius * 3, size.height + angleHeight)
      ..lineTo(radius * 3 - $(5), size.height)
      ..lineTo(radius, size.height)
      ..arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius))
      ..close();

    // 渐变、画笔
    final shader = LinearGradient(
      colors: [
        Color(0xFFF7B500),
        Color(0xFFB620E0),
        Color(0xFF32C5FF),
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(rect);

    final Paint paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
    // canvas.drawShadow(path, Color(0xFF969696).withOpacity(0.57), $(4), true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
