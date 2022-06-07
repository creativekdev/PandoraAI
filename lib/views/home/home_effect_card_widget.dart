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

  HomeEffectCardWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorConstant.CardColor,
      elevation: $(1),
      shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all($(6)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all($(6)),
                        child: ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(2.w)),
                          child: _imageWidget(context,
                              url: data.getShownUrl(pos: 1)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all($(6)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(2.w)),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: _imageWidget(context,
                              url: data.getShownUrl(pos: 2)),
                        ),
                      ),
                    ),
                  ],
                ),
                // if (data.key != "transform")
                //   Row(
                //     children: [
                //       Expanded(
                //         child: Padding(
                //           padding: EdgeInsets.all($(6)),
                //           child: ClipRRect(
                //             borderRadius:
                //                 BorderRadius.all(Radius.circular(2.w)),
                //             clipBehavior: Clip.antiAliasWithSaveLayer,
                //             child: _imageWidget(context,
                //                 url: data.getShownUrl(pos: 2)),
                //           ),
                //         ),
                //       ),
                //       if (data.effects.length >= 3)
                //         Expanded(
                //           child: Padding(
                //             padding: EdgeInsets.all($(6)),
                //             child: ClipRRect(
                //               borderRadius:
                //                   BorderRadius.all(Radius.circular(2.w)),
                //               clipBehavior: Clip.antiAliasWithSaveLayer,
                //               child: _imageWidget(context,
                //                   url: data.getShownUrl(pos: 3)),
                //             ),
                //           ),
                //         ),
                //     ],
                //   )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 3.w, right: 3.w, bottom: 3.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TitleTextWidget(
                      (data.display_name.toString() == "null")
                          ? data.key
                          : data.display_name,
                      ColorConstant.BtnTextColor,
                      FontWeight.w600,
                      17,
                      align: TextAlign.start),
                ),
                Image.asset(
                  ImagesConstant.ic_next,
                  height: 50,
                  width: 50,
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
