import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';

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
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular($(64)),
          child: CachedNetworkImage(
            imageUrl: avatar,
            fit: BoxFit.cover,
          ),
        ).intoContainer(width: $(45), height: $(45)),
        SizedBox(width: $(10)),
        Expanded(
            child: Text(
          name,
          style: TextStyle(color: ColorConstant.White, fontSize: $(16)),
        )),
      ],
    );
  }
}
