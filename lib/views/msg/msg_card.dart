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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.detail,
                style: textStyle(),
              ),
              SizedBox(height: 4),
              Text(
                data.created.isEmpty ? '2022-01-01' : data.created,
                style: timeStyle(),
              ),
            ],
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: data.read ? Colors.transparent : Colors.red, borderRadius: BorderRadius.circular(8)),
        ),
      ],
    )
        .intoContainer(
          padding: EdgeInsets.all($(15)),
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
      return TextStyle(color: Color(0xfff3f3f3), fontFamily: 'Poppins', fontSize: $(16), fontWeight: FontWeight.w400);
    } else {
      return TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(16), fontWeight: FontWeight.w800);
    }
  }

  TextStyle timeStyle() {
    if (data.read) {
      return TextStyle(color: Color(0xfff3f3f3), fontFamily: 'Poppins', fontSize: $(12), fontWeight: FontWeight.normal);
    } else {
      return TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(12), fontWeight: FontWeight.w700);
    }
  }
}
