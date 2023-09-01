import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:common_utils/common_utils.dart';

class MsgDiscoveryCard extends StatelessWidget {
  MsgDiscoveryEntity data;
  GestureTapCallback? onTap;
  DateTime? dateTime;
  DiscoveryListEntity? discovery;
  MsgTab tab;
  late String userName;

  MsgDiscoveryCard({
    Key? key,
    required this.data,
    this.onTap,
    required this.tab,
  }) : super(key: key) {
    dateTime = data.created.timezoneCur;
    var json = AppDelegate.instance.getManager<CacheManager>().getJson(CacheManager.cacheDiscoveryListEntity + '${data.getPostId()}');
    if (json != null) {
      discovery = jsonConvert.convert(json);
    }
    userName = data.name;
    if (TextUtil.isEmpty(userName)) {
      userName = S.of(Get.context!).accountCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    var details = getDetails(data, context);
    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: TextUtil.isEmpty(data.avatar)
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
                      imageUrl: data.avatar.avatar(),
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
                          userName,
                          style: TextStyle(
                            color: Color(0xfff3f3f3),
                            fontFamily: 'Poppins',
                            fontSize: $(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Container(
                      //   width: 8,
                      //   height: 8,
                      //   decoration: BoxDecoration(color: data.read ? Colors.transparent : Colors.red, borderRadius: BorderRadius.circular(8)),
                      // ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    data.created.isEmpty ? '2022-01-01' : DateUtil.formatDate(dateTime, format: 'MM-dd HH:mm'),
                    style: TextStyle(color: Color(0xfff3f3f3), fontFamily: 'Poppins', fontSize: $(12), fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: $(8)),
        RichText(
          text: TextSpan(text: '', children: [
            ...details
                .map(
                  (e) => TextSpan(
                    text: e,
                    style: TextStyle(
                      color: e == '@${userName}' ? Color(0xFF7593BB) : ColorConstant.White,
                    ),
                  ),
                )
                .toList(),
            tab == MsgTab.like
                ? WidgetSpan(
                    child: Image.asset(
                      Images.ic_discovery_liked,
                      width: $(16),
                    ).intoContainer(margin: EdgeInsets.only(left: $(4))),
                  )
                : WidgetSpan(child: SizedBox.shrink()),
          ]),
          textAlign: TextAlign.start,
        ).intoContainer(width: double.maxFinite),
        SizedBox(height: $(8)),
        buildDiscoveryCard(context),
      ],
    )
        .intoContainer(
          color: Color(0xff232528),
          padding: EdgeInsets.all($(15)),
          margin: EdgeInsets.only(top: $(8)),
        )
        .intoGestureDetector(onTap: onTap);
  }

  Widget buildDiscoveryCard(BuildContext context) {
    return discovery != null
        ? buildDiscoveryContent(context, discovery!)
        : FutureBuilder<DiscoveryListEntity?>(
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done || snapshot.data == null) {
                return SizedBox.shrink();
              }
              return buildDiscoveryContent(context, snapshot.data!);
            },
            future: AppApi().getDiscoveryDetail(
              data.getPostId(),
              useCache: true,
              toast: false,
              needRetry: false,
            ),
          );
  }

  Widget buildDiscoveryContent(BuildContext context, DiscoveryListEntity entity) {
    return Row(
      children: [
        CachedNetworkImageUtils.custom(context: context, imageUrl: entity.resourceList().first.url!, width: $(54), height: $(54)),
        SizedBox(width: $(8)),
        Expanded(
          child: TitleTextWidget(entity.text, Color(0xff8f8f8f), FontWeight.w500, $(13), align: TextAlign.start, maxLines: 2),
        )
      ],
    ).intoContainer(color: ColorConstant.BackgroundColor, padding: EdgeInsets.symmetric(vertical: $(8), horizontal: $(8)));
  }

  List<String> getDetails(MsgDiscoveryEntity data, BuildContext context) {
    if (tab == MsgTab.like) {
      return ['@${userName}', ' liked your ${data.commentSocialPostId == 0 ? 'post' : 'comment'}'];
    } else {
      return [data.status == "deleted" ? S.of(context).deleted_comment : data.text];
    }
  }
}
