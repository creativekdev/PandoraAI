import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';

class UserInfoHeaderWidget extends StatelessWidget {
  String avatar;
  String name;

  UserInfoHeaderWidget({
    Key? key,
    required this.avatar,
    required this.name,
  }) : super(key: key) {
    if (name == '') {
      name = " ";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(64)),
          child: CachedNetworkImage(
            imageUrl: avatar,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) {
              return Text(
                name[0].toUpperCase(),
                style: TextStyle(color: ColorConstant.White, fontSize: $(25)),
              ).intoContainer(
                  width: $(45),
                  height: $(45),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(32)),
                    border: Border.all(color: ColorConstant.White, width: 1),
                  ));
            },
            width: $(45),
            height: $(45),
            cacheManager: CachedImageCacheManager(),
          ),
        ).intoContainer(width: $(45), height: $(45)),
        SizedBox(width: $(10)),
        Expanded(
          child: TitleTextWidget(name, ColorConstant.White, FontWeight.normal, $(16), align: TextAlign.start),
        ),
      ],
    );
  }
}
