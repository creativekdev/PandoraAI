import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
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
    String? name = extras['user_name'];
    if (TextUtil.isEmpty(name)) {
      userName = StringConstant.accountCancelled;
    } else {
      userName = name!;
    }
    avatar = extras['user_avatar']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            msgType == MsgType.UNDEFINED
                ? Image.asset(Images.ic_msg_list).intoContainer(
                    width: $(50),
                    height: $(50),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ColorConstant.SysMsgIconColor, borderRadius: BorderRadius.circular(32)),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: TextUtil.isEmpty(avatar)
                        ? Text(
                            userName[0].toUpperCase(),
                            style: TextStyle(color: ColorConstant.White, fontSize: $(25)),
                          ).intoContainer(
                            width: $(50),
                            height: $(50),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular($(32)),
                              border: Border.all(color: ColorConstant.White, width: 1),
                            ))
                        : CachedNetworkImageUtils.custom(
                            context: context,
                            useOld: true,
                            imageUrl: avatar.avatar(),
                            width: $(50),
                            height: $(50),
                            errorWidget: (context, url, error) {
                              return Text(
                                userName[0].toUpperCase(),
                                style: TextStyle(color: ColorConstant.White, fontSize: $(25)),
                              ).intoContainer(
                                  width: $(50),
                                  height: $(50),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular($(32)),
                                    border: Border.all(color: ColorConstant.White, width: 1),
                                  ));
                            }),
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
                          msgType == MsgType.UNDEFINED ? 'System Information' : extras['user_name'] ?? StringConstant.accountCancelled,
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
        ).intoContainer(padding: EdgeInsets.all($(15))),
        Container(
          height: 1,
          width: double.maxFinite,
          color: ColorConstant.LineColor,
          margin: EdgeInsets.only(left: $(78)),
        ),
      ],
    )
        .intoMaterial(
          color: ColorConstant.CardColor,
        )
        .intoGestureDetector(onTap: onTap);
  }
}
