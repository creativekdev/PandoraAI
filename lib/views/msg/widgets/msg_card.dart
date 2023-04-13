import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:common_utils/common_utils.dart';

class MsgCard extends StatelessWidget {
  MsgEntity data;
  GestureTapCallback? onTap;
  late Map<String, dynamic> extras;
  late MsgType msgType;
  DateTime? dateTime;
  late String userName;
  late String avatar;

  MsgCard({
    Key? key,
    required this.data,
    this.onTap,
  }) : super(key: key) {
    extras = data.extras;
    msgType = data.msgType;
    var date = DateUtil.getDateTime(data.created, isUtc: true);
    if (date != null) {
      var timeZoneOffset = DateTime.now().timeZoneOffset;
      dateTime = date.add(timeZoneOffset);
    }
    avatar = extras['user_avatar']?.toString() ?? '';
    String? name = extras['user_name'];
    if (TextUtil.isEmpty(name)) {
      userName = S.of(Get.context!).accountCancelled;
    } else {
      userName = name!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(32)),
          child: Image.asset(Images.ic_app).intoContainer(
            width: $(50),
            height: $(50),
            alignment: Alignment.center,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).system_msg,
                      style: TextStyle(
                        color: Color(0xfff3f3f3),
                        fontFamily: 'Poppins',
                        fontSize: $(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    data.created.isEmpty ? '2022-01-01' : DateUtil.formatDate(dateTime, format: 'MM-dd HH:mm'),
                    style: TextStyle(color: Color(0xfff3f3f3), fontFamily: 'Poppins', fontSize: $(12), fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.detail,
                      style: TextStyle(color: ColorConstant.DiscoveryCommentGrey, fontFamily: 'Poppins', fontSize: $(12), fontWeight: FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: data.read ? Colors.transparent : Colors.red, borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    )
        .intoContainer(padding: EdgeInsets.all($(15)))
        .intoContainer(
          color: Color(0xff232528),
          margin: EdgeInsets.only(top: $(8)),
        )
        .intoGestureDetector(onTap: onTap);
  }
}
