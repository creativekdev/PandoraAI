import 'dart:convert';
import 'dart:math';

import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:skeletons/skeletons.dart';

const List<List<Color>> _cList = [
  [Color(0xff4e54c8), Color(0xff8f94fb)],
  [Color(0xffbc4e9c), Color(0xfff80759)],
  [Color(0xffFF8C00), Color(0xffFF0080)],
  [Color(0xff11998e), Color(0xff38ef7d)],
  [Color(0xffFC5C7D), Color(0xff6A82FB)],
  [Color(0xff800080), Color(0xffffc0cb)],
  [Color(0xff00F260), Color(0xff0575E6)]
];

class DiscoveryMgListCard extends StatelessWidget {
  SocialPostPageEntity data;
  Function() onTap;
  List<Color> colors = [];
  Map<String, dynamic>? payload;
  List<String>? userAvatars;
  late List<String> previewImages;
  double width;
  late double imageSize;

  DiscoveryMgListCard({
    Key? key,
    required this.data,
    required this.onTap,
    required this.width,
  }) : super(key: key) {
    colors = _cList[Random().nextInt(_cList.length)];
    userAvatars = data.coverImage?.split(',');
    previewImages = data.previewImages?.split(',') ?? [];
    if (previewImages.length > 4) {
      previewImages = previewImages.sublist(0, 4);
    }
    try {
      payload = jsonDecode(data.payload ?? '');
    } catch (e) {
      payload = null;
    }
    imageSize = (width - $(22)) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: $(10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular($(128)),
                child: CachedNetworkImageUtils.custom(
                    context: context,
                    imageUrl: userAvatars != null ? userAvatars!.first : '',
                    width: $(55),
                    height: $(55),
                    placeholder: (context, url) {
                      return SkeletonAvatar(
                        style: SkeletonAvatarStyle(width: $(55), height: $(55)),
                      );
                    }),
              )
                  .intoContainer(
                    padding: EdgeInsets.all($(2.5)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(32)),
                      color: Colors.grey,
                    ),
                  )
                  .intoCenter(),
              flex: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildUserAttr(context, key: 'posts', title: 'Posts'),
                  buildUserAttr(context, key: 'followers', title: 'Followers'),
                  buildUserAttr(context, key: 'followings', title: 'Following'),
                ],
              ),
              flex: 6,
            ),
          ],
        ),
        Wrap(
          spacing: $(5),
          runSpacing: $(5),
          children: previewImages
              .map((e) => CachedNetworkImageUtils.custom(
                    useOld: false,
                    context: context,
                    imageUrl: e,
                    width: imageSize,
                    height: imageSize,
                  ))
              .toList(),
        ).intoContainer(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(8)),
        ),
      ],
    )
        .intoContainer(
            decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors, begin: Alignment.bottomLeft, end: Alignment.topRight),
      borderRadius: BorderRadius.circular($(12)),
    ))
        .intoGestureDetector(onTap: () {
      onTap.call();
    });
  }

  Widget buildUserAttr(BuildContext context, {required String key, required String title}) {
    if (payload == null) {
      return SkeletonLine(
        style: SkeletonLineStyle(height: $(12)),
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TitleTextWidget(title, ColorConstant.White, FontWeight.w400, $(9)),
          SizedBox(width: $(6)),
          TitleTextWidget(((payload![key] ?? 0) as int).socialize, ColorConstant.White, FontWeight.w500, $(11)),
        ],
      );
    }
  }
}
