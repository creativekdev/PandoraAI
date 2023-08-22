import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';

typedef LimitBuilder = MapEntry<int, int> Function();

class ReferredCard extends StatelessWidget {
  UserManager userManager = AppDelegate().getManager();

  List<ReferredItem> items = [];

  ReferredCard({Key? key}) : super(key: key) {
    items = [
      ReferredItem(
        type: HomeCardType.anotherme,
        primary: Color(0x5532C5FF),
        colors: [
          Color(0xFF2778FF),
          Color(0xFF32C5FF),
        ],
      ),
      ReferredItem(
        type: HomeCardType.txt2img,
        primary: Color(0x99fecd09),
        colors: [
          Color(0xFFfa9500),
          Color(0xfffecd09),
        ],
      ),
      ReferredItem(
        type: HomeCardType.scribble,
        primary: Color(0x993fdb87),
        colors: [
          Color(0xff02be65),
          Color(0xFF3fdb87),
        ],
      ),
      ReferredItem(
        type: HomeCardType.stylemorph,
        primary: Color(0x99FF4949),
        colors: [
          Color(0xFFFF0000),
          Color(0xFFFF4949),
        ],
      ),
      ReferredItem(
        type: HomeCardType.cartoonize,
        primary: Color(0x99FEA940),
        colors: [
          Color(0xFFF4872D),
          Color(0xFFFEA940),
        ],
      ),
      ReferredItem(
        type: HomeCardType.removeBg,
        primary: Color(0xFF02F8D6),
        colors: [
          Color(0xFF02CE95),
          Color(0xFF02CE95),
        ],
      ),
    ];
  }

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
        SizedBox(height: $(4)),
        Wrap(
          runSpacing: $(8),
          spacing: $(8),
          children: items
              .map(
                (e) => ClipRRect(
                  borderRadius: BorderRadius.circular($(6)),
                  child: buildItem(context, title: e.type.title(), value: userManager.getLimitRule(e.type)).intoContainer(
                    width: double.maxFinite,
                    padding: EdgeInsets.all($(12)),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: e.colors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )),
                  ),
                ).intoContainer(width: (ScreenUtil.screenSize.width - $(42)) / 2),
              )
              .toList(),
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
          style: TextStyle(color: Color(0xb2ffffff), fontSize: $(16), fontWeight: FontWeight.normal),
        ),
        SizedBox(height: $(8)),
        Text(
          count,
          style: TextStyle(color: ColorConstant.White, fontSize: $(18)),
        ),
      ],
    );
  }
}

class ReferredItem {
  Color primary;
  List<Color> colors;
  HomeCardType type;

  ReferredItem({
    required this.type,
    required this.primary,
    required this.colors,
  });
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
