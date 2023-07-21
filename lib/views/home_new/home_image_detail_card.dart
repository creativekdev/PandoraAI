import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';

import '../../Common/importFile.dart';

class HomeImageDetailCard extends StatelessWidget {
  String url;
  double width;
  double height;
  bool needBlur;

  HomeImageDetailCard({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.needBlur,
  });

  @override
  Widget build(BuildContext context) {
    if (!needBlur) {
      return CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
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
          height: ScreenUtil.screenSize.height * 0.65,
          fit: BoxFit.cover,
        )
            .intoCenter()
            .intoContainer(
              width: width,
              height: height,
            )
            .blur(),
      ],
    ).intoContainer(width: width, height: height);
  }
}
