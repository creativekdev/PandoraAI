import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/utils/cacheImage/image_cache_manager.dart';

///
/// @Author: wangyu
/// @Date: 2022/6/7
/// ignore: must_be_immutable
class HomeEffectCardWidget extends StatelessWidget {
  EffectModel data;
  double parentWidth;

  HomeEffectCardWidget({
    Key? key,
    required this.parentWidth,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorConstant.CardColor,
      elevation: $(1),
      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular($(12)),
      ),
      child: Column(
        children: [
          Wrap(
            direction: Axis.horizontal,
            children: data.thumbnails.map((e) {
              var effect = data.effects[e]!;
              return ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.all(Radius.circular($(6))),
                child: _imageWidget(context,
                    url: effect.imageUrl.isEmpty
                        ? data.getShownUrl()
                        : effect.imageUrl),
              ).intoContainer(
                padding: EdgeInsets.all($(6)),
                width: (parentWidth - $(24)) / 2,
                height: (parentWidth - $(24)) / 2,
              );
            }).toList(),
          ).intoContainer(
              alignment: Alignment.centerLeft, padding: EdgeInsets.all($(6))),
          Padding(
            padding: EdgeInsets.only(
                left: $(12), right: $(12), bottom: $(24), top: $(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TitleTextWidget(data.displayName,
                      ColorConstant.BtnTextColor, FontWeight.w600, 17,
                      align: TextAlign.start),
                ),
                Image.asset(
                  ImagesConstant.ic_next,
                  height: $(32),
                  width: $(32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageWidget(BuildContext context, {required String url}) =>
      CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.fill,
        width: $(150),
        height: $(150),
        placeholder: (context, url) => loadingWidget(context),
        errorWidget: (context, url, error) => loadingWidget(context),
        cacheManager: CachedImageCacheManager(),
      );

  Widget loadingWidget(BuildContext context) => Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
}
