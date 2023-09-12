import 'package:cartoonizer/widgets/cacheImage/cached_network_image_utils.dart';

import '../../common/importFile.dart';

class HomeImageDetailCard extends StatelessWidget {
  String url;
  double width;
  double height;
  String category;

  HomeImageDetailCard({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // if (category == "facetoon") {
    return Stack(
      children: [
        CachedNetworkImageUtils.custom(
          context: context,
          imageUrl: url,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
        CachedNetworkImageUtils.custom(
          context: context,
          imageUrl: url,
          width: width,
          height: category == "facetoon" ? ScreenUtil.screenSize.height * 0.65 : height,
          fit: category == "facetoon" ? BoxFit.cover : BoxFit.contain,
        )
            .intoContainer(
              alignment: Alignment.center,
              width: width,
              height: height,
            )
            .blur(),
      ],
    ).intoContainer(width: width, height: height);
    // }
    // return CachedNetworkImageUtils.custom(
    //   context: context,
    //   imageUrl: url,
    //   width: width,
    //   height: height,
    //   fit: BoxFit.cover,
    // );
  }
}
