import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:common_utils/common_utils.dart';
import 'package:like_button/like_button.dart';

class MetagramListCard extends StatelessWidget {
  MetagramItemEntity data;
  late List<DiscoveryResource> resourceList;
  Function onEditTap;

  MetagramListCard({
    super.key,
    required this.data,
    required this.onEditTap,
  }) {
    resourceList = data.resourceList();
  }

  @override
  Widget build(BuildContext context) {
    if (resourceList.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            CachedNetworkImageUtils.custom(
              context: context,
              imageUrl: resourceList.last.url!,
              fit: BoxFit.cover,
            ),
            Positioned(
              child: ClipRRect(
                      child: CachedNetworkImageUtils.custom(
                        context: context,
                        imageUrl: resourceList.first.url!,
                        fit: BoxFit.cover,
                        width: $(70),
                      ),
                      borderRadius: BorderRadius.circular($(6)))
                  .intoContainer(padding: EdgeInsets.all($(2)))
                  .intoMaterial(borderRadius: BorderRadius.circular($(8)), color: Colors.white, elevation: 4),
              top: $(15),
              left: $(15),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  buildComments(context).intoGestureDetector(onTap: () {
                    //todo
                  }),
                  SizedBox(width: $(12)),
                  LikeButton(
                    size: $(26),
                    countPostion: CountPostion.bottom,
                    circleColor: CircleColor(
                      start: Color(0xfffc2a2a),
                      end: Color(0xffc30000),
                    ),
                    bubblesColor: BubblesColor(
                      dotPrimaryColor: Color(0xfffc2a2a),
                      dotSecondaryColor: Color(0xffc30000),
                    ),
                    // isLiked: controller.liked.value,
                    likeBuilder: (bool isLiked) {
                      return Image.asset(
                        isLiked ? Images.ic_discovery_liked : Images.ic_discovery_like,
                        width: $(26),
                        color: isLiked ? Colors.red : Colors.white,
                      );
                    },
                    likeCount: data.likes,
                    // onTap: (liked) async => await onLikeTap.call(liked),
                    countBuilder: (int? count, bool isLiked, String text) {
                      count ??= 0;
                      return Text(
                        count.socialize,
                        style: TextStyle(color: Colors.white, fontSize: $(12)),
                      );
                    },
                  ),
                  SizedBox(width: $(12)),
                  Image.asset(Images.ic_metagram_shareout, width: $(26)).intoGestureDetector(onTap: () {
                    //todo
                  }),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            Container(
              width: 80,
              height: 22,
              color: Colors.red,
            ),
            Expanded(
                child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(width: $(12)),
                Image.asset(Images.ic_share_discovery, width: $(26)).intoGestureDetector(onTap: () {
                  //todo
                }),
                SizedBox(width: $(12)),
                Image.asset(Images.ic_metagram_download, width: $(26)).intoGestureDetector(onTap: () {
                  //todo
                }),
              ],
            )),
          ],
        ).intoContainer(padding: EdgeInsets.only(top: $(12), left: $(12), right: $(12), bottom: $(6))),
        TitleTextWidget(data.text ?? '', Colors.white, FontWeight.normal, $(15))
            .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12)))
            .offstage(offstage: TextUtil.isEmpty(data.text)),
        OutlineWidget(
          radius: $(8),
          strokeWidth: $(1.5),
          gradient: LinearGradient(
            colors: [
              Color(0xFFEC5DD8),
              Color(0xFF7F97F3),
              Color(0xFF04F1F9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Text(
            S.of(context).generate_again,
            style: TextStyle(
              color: ColorConstant.White,
              fontSize: $(13),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ).intoContainer(
            height: $(30),
            width: $(120),
            alignment: Alignment.center,
          ),
        ).intoMaterial(color: Color(0xff222222), borderRadius: BorderRadius.circular($(8))).intoGestureDetector(onTap: () {
          onEditTap.call();
        }).intoContainer(
          margin: EdgeInsets.symmetric(horizontal: $(12), vertical: $(12)),
        ),
      ],
    );
  }

  Widget buildComments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          Images.ic_metagram_comment,
          width: $(26),
        ),
        TitleTextWidget(data.comments.socialize, Colors.white, FontWeight.w400, $(12)),
      ],
    );
  }
}
