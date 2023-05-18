import 'dart:convert';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:skeletons/skeletons.dart';

import 'blink_image.dart';

class MetagramCard extends StatelessWidget {
  MetagramPageEntity? entity;

  Map<String, dynamic>? payload;

  List<String>? userAvatars;

  Function(MetagramItemEntity entity, int index) onItemClick;

  MetagramCard({
    super.key,
    this.entity,
    required this.onItemClick,
  }) {
    if (entity != null && entity!.socialPostPage != null) {
      userAvatars = entity!.socialPostPage!.coverImage?.split(',');
      try {
        payload = jsonDecode(entity!.socialPostPage!.payload ?? '');
      } catch (e) {
        payload = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(context),
        buildPosts(context),
      ],
    );
  }

  Widget buildHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            buildAvatar(context),
            SizedBox(width: $(15)),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: buildUserAttr(context, key: 'posts', title: 'Posts'),
                  ),
                  SizedBox(width: $(12)),
                  Expanded(
                    child: buildUserAttr(context, key: 'followers', title: 'Followers'),
                  ),
                  SizedBox(width: $(12)),
                  Expanded(
                    child: buildUserAttr(context, key: 'followings', title: 'Following'),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: $(12)),
        buildBio(context),
        SizedBox(height: $(12)),
        Divider(
          height: 1,
          color: Color(0xff464646),
        ),
        SizedBox(height: $(12)),
      ],
    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)));
  }

  Widget buildAvatar(BuildContext context) {
    if (userAvatars == null) {
      return SkeletonAvatar(
        style: SkeletonAvatarStyle(shape: BoxShape.circle, width: $(92), height: $(92)),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular($(64)),
        child: BlinkImage(
          width: $(92),
          height: $(92),
          images: userAvatars!,
          loopDelay: 1500,
        ),
      );
    }
  }

  Widget buildUserName(BuildContext context) {
    if (entity?.socialPostPage == null) {
      return SkeletonLine(
        style: SkeletonLineStyle(height: $(17)),
      );
    } else {
      return TitleTextWidget(entity!.socialPostPage!.name ?? '', Colors.white, FontWeight.w500, $(17), maxLines: 2).intoContainer(alignment: Alignment.centerLeft);
    }
  }

  Widget buildUserAttr(BuildContext context, {required String key, required String title}) {
    if (payload == null) {
      return SkeletonLine(
        style: SkeletonLineStyle(height: $(12)),
      );
    } else {
      return Column(
        children: [
          TitleTextWidget(title, ColorConstant.White, FontWeight.w400, $(12)),
          TitleTextWidget(((payload![key] ?? 0) as int).socialize, ColorConstant.White, FontWeight.w500, $(14)),
        ],
      );
    }
  }

  Widget buildBio(BuildContext context) {
    if (payload == null) {
      return SkeletonLine(
        style: SkeletonLineStyle(height: $(12)),
      );
    } else {
      return TitleTextWidget(payload!['bio'] ?? '', Colors.white, FontWeight.w500, $(14), maxLines: 10).intoContainer(alignment: Alignment.centerLeft);
    }
  }

  buildPosts(BuildContext context) {
    var height = ScreenUtil.screenSize.height - $(150) - 44 - ScreenUtil.getStatusBarHeight();
    var imageWidth = (ScreenUtil.screenSize.width - $(34)) / 3;
    if (entity == null) {
      return SkeletonListView(
        itemCount: 6,
        item: Row(
          children: [
            SkeletonAvatar(
              style: SkeletonAvatarStyle(width: imageWidth, height: imageWidth),
            ),
            SizedBox(
              width: $(1),
            ),
            SkeletonAvatar(
              style: SkeletonAvatarStyle(width: imageWidth, height: imageWidth),
            ),
            SizedBox(
              width: $(1),
            ),
            SkeletonAvatar(
              style: SkeletonAvatarStyle(width: imageWidth, height: imageWidth),
            ),
          ],
        ).intoContainer(margin: EdgeInsets.only(top: $(1))),
      ).intoContainer(height: height);
    } else {
      return Wrap(
        alignment: WrapAlignment.start,
        spacing: $(1),
        runSpacing: $(1),
        children: entity!.rows.transfer(
          (e, index) => BlinkImage(
            images: e.resourceList().filter((t) => t.type == 'image').map((e) => e.url!).toList(),
            width: imageWidth,
            height: imageWidth,
            loopDelay: (index % 2) * 1000 + 1000,
          ).intoGestureDetector(onTap: () {
            onItemClick.call(e, index);
          }),
        ),
      ).intoContainer(width: double.maxFinite, padding: EdgeInsets.symmetric(horizontal: $(15)));
    }
  }
}
