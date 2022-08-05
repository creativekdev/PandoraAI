import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/msg_entity.dart';

class MsgCard extends StatelessWidget {
  MsgEntity data;
  GestureTapCallback? onTap;

  MsgCard({
    Key? key,
    required this.data,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          data.title,
          style: textStyle(),
        ),
      ],
    )
        .intoContainer(
          padding: EdgeInsets.all($(10)),
        )
        .intoMaterial(
          color: ColorConstant.CardColor,
          elevation: 4,
          borderRadius: BorderRadius.circular($(6)),
        )
        .intoGestureDetector(onTap: onTap)
        .intoContainer(
          margin: EdgeInsets.only(left: $(15), right: $(15), top: $(15)),
        );
  }

  TextStyle textStyle() {
    if (data.read) {
      return TextStyle(color: Color(0xfff3f3f3), fontFamily: 'Poppins', fontSize: $(15), fontWeight: FontWeight.w400);
    } else {
      return TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(15), fontWeight: FontWeight.w800);
    }
  }
}
