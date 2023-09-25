import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/home_page_entity.dart';
import 'package:cartoonizer/widgets/outline_widget.dart';
import 'package:cartoonizer/widgets/visibility_holder.dart';

import 'pai_content_view.dart';

class PaiContentFacetoonView extends StatefulWidget {
  final double height;
  final double width;
  final String title;
  final HomeItemEntity data;
  final OnClickAll onAllTap;
  final OnClickItem onTapItem;

  const PaiContentFacetoonView({
    super.key,
    required this.height,
    required this.width,
    required this.title,
    required this.data,
    required this.onAllTap,
    required this.onTapItem,
  });

  @override
  State<PaiContentFacetoonView> createState() => _PaiContentFacetoonViewState();
}

class _PaiContentFacetoonViewState extends State<PaiContentFacetoonView> {
  late HomeItemEntity data;
  late List<DiscoveryListEntity> socialPost;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    socialPost = data.getDataList<DiscoveryListEntity>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 15.dp),
            TitleTextWidget(
              widget.title,
              ColorConstant.White,
              FontWeight.w500,
              $(16),
              maxLines: 1,
            ).intoContainer(
              alignment: Alignment.center,
            ),
            Spacer(),
            TitleTextWidget(
              "${S.of(context).all} >",
              ColorConstant.DividerColor,
              FontWeight.w400,
              $(12),
            )
                .intoContainer(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.dp),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: ColorConstant.White.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular($(10)),
              ),
            )
                .intoGestureDetector(
              onTap: () {
                widget.onAllTap(data.key ?? '', socialPost, widget.title);
              },
            ),
            SizedBox(width: 15.dp),
          ],
        ).intoContainer(padding: EdgeInsets.symmetric(vertical: 8.dp)),
        Stack(
          children: [
            VisibilityImageHolder(
              url: socialPost[currentIndex].resourceList().first.url!,
              height: widget.height,
              width: widget.width,
            ),
            Positioned(
              child: Container(
                width: widget.width,
                height: widget.width / 2,
                decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                  Color(0x00000000),
                  Color(0xee000000),
                ])),
              ),
              bottom: 0,
            ),
            Align(
              child: Text(
                S.of(context).try_it_now,
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 12.sp),
              )
                  .intoContainer(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [
                    ColorConstant.ColorLinearStart,
                    ColorConstant.ColorLinearEnd,
                  ]),
                  borderRadius: BorderRadius.circular($(32)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 4.dp),
                margin: EdgeInsets.only(bottom: 25.dp),
              )
                  .intoGestureDetector(onTap: () {
                widget.onTapItem(currentIndex, data.key ?? '', socialPost, widget.title);
              }),
              alignment: Alignment.bottomCenter,
            ),
          ],
        ).intoContainer(height: widget.height),
        ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (c, index) {
            return OutlineWidget(
                    strokeWidth: 3.dp,
                    radius: 8.dp,
                    gradient: LinearGradient(
                      colors: currentIndex == index ? [ColorConstant.ColorLinearStart, ColorConstant.ColorLinearEnd] : [Colors.transparent, Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: ClipRRect(
                      child: VisibilityImageHolder(
                        url: socialPost[index].resourceList().first.url!,
                        height: 55.dp,
                        width: 55.dp,
                      ),
                      borderRadius: BorderRadius.circular(5.dp),
                    ).intoContainer(margin: EdgeInsets.all(3.dp)))
                .intoGestureDetector(onTap: () {
              setState(() {
                currentIndex = index;
              });
            }).intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : 8.dp));
          },
          itemCount: socialPost.length,
        ).intoContainer(height: 60.dp),
      ],
    );
  }
}
