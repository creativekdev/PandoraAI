import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:common_utils/common_utils.dart';

class UserInfoHeaderWidget extends StatelessWidget {
  String avatar;
  String name;

  UserInfoHeaderWidget({
    Key? key,
    required this.avatar,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (TextUtil.isEmpty(name)) {
      name = S.of(context).accountCancelled;
    }
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(64)),
          child: CachedNetworkImageUtils.custom(
            context: context,
            imageUrl: avatar.avatar(),
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
        SizedBox(width: $(12)),
        Expanded(
          child: TitleTextWidget(name, ColorConstant.White, FontWeight.normal, $(16), align: TextAlign.start),
        ),
      ],
    );
  }
}
