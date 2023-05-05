import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';

class ReferredCard extends StatelessWidget {
  UserManager userManager = AppDelegate().getManager();

  ReferredCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (userManager.isNeedLogin) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: $(10)),
        TitleTextWidget(S.of(context).remaining_credits, Colors.white, FontWeight.w500, $(16), align: TextAlign.start),
        SizedBox(height: $(12)),
        ClipRRect(
          borderRadius: BorderRadius.circular($(6)),
          child: CustomPaint(
            foregroundPainter: ForegroundPainter(
              color: Color(0x5532C5FF),
              degree: 12,
              offset: -60,
              width: 40,
              space: 20,
            ),
            child: buildItem(context, title: 'Metaverse', value: userManager.getAnotherMeLimit()).intoContainer(
              width: double.maxFinite,
              padding: EdgeInsets.all($(16)),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color(0xFF2778FF),
                  Color(0xFF32C5FF),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )),
            ),
          ),
        ),
        SizedBox(height: $(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular($(6)),
          child: CustomPaint(
            foregroundPainter: ForegroundPainter(
              color: Color(0x99fecd09),
              degree: 12,
              offset: -60,
              width: 40,
              space: 20,
            ),
            child: buildItem(context, title: 'AI Artist: Text to Image', value: userManager.getTxt2ImgLimit()).intoContainer(
              width: double.maxFinite,
              padding: EdgeInsets.all($(16)),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color(0xFFfa9500),
                  Color(0xfffecd09),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )),
            ),
          ),
        ),
        SizedBox(height: $(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular($(6)),
          child: CustomPaint(
            foregroundPainter: ForegroundPainter(
              color: Color(0xff3fdb87),
              degree: 12,
              offset: -60,
              width: 40,
              space: 20,
            ),
            child: buildItem(context, title: 'AI Scribble', value: userManager.getAiDrawLimit()).intoContainer(
              width: double.maxFinite,
              padding: EdgeInsets.all($(16)),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color(0xff02be65),
                  Color(0xFF3fdb87),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )),
            ),
          ),
        ),
      ],
    ).intoContainer(
      margin: EdgeInsets.all($(16)),
    );
  }

  Widget buildItem(
    BuildContext context, {
    required String title,
    required MapEntry value,
  }) {
    String count = '${value.key + value.value} ${S.of(context).per_day}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Color(0xb2ffffff), fontSize: $(14)),
        ),
        SizedBox(height: $(8)),
        Text(
          count,
          style: TextStyle(color: ColorConstant.White, fontSize: $(20)),
        ),
        SizedBox(height: $(16)),
      ],
    );
  }
}

class ForegroundPainter extends CustomPainter {
  Color color;
  int degree;
  int width;
  int offset;
  int space;

  ForegroundPainter({
    required this.color,
    required this.degree,
    required this.space,
    required this.offset,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width - degree + offset, 0)
        ..lineTo(size.width + offset, 0)
        ..lineTo(size.width / 1.25 + offset, size.height)
        ..lineTo(size.width / 1.25 - degree + offset, size.height)
        ..close(),
      Paint()..color = color,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width + offset + space, 0)
        ..lineTo(size.width + width + offset + space, 0)
        ..lineTo(size.width / 1.25 + width + offset + space, size.height)
        ..lineTo(size.width / 1.25 + offset + space, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
