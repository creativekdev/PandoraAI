import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';

class AvatarDetailScreen extends StatefulWidget {
  String token;

  AvatarDetailScreen({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<AvatarDetailScreen> createState() => _AvatarDetailScreenState();
}

class _AvatarDetailScreenState extends AppState<AvatarDetailScreen> {
  late CartoonizerApi api;
  dynamic entity;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    delay(() => showLoading().whenComplete(() {
          api.getAvatarAiDetail(token: widget.token).then((value) {
            hideLoading().whenComplete(() {
              if (value != null) {
                setState(() {
                  entity = value;
                });
              } else {
                // Navigator.of(context).pop();
              }
            });
          });
        }));
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
      ),
      body: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: $(15),vertical: $(15)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          mainAxisSpacing: $(12),
          crossAxisSpacing: $(12),
        ),
        itemBuilder: (context, index) {
          return CachedNetworkImageUtils.custom(context: context, imageUrl: imgUrl);
        },
        itemCount: 10,
      ),
    );
  }
}
