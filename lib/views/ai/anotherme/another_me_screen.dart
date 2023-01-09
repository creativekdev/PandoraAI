import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';

class AnotherMeScreen extends StatefulWidget {
  const AnotherMeScreen({Key? key}) : super(key: key);

  @override
  State<AnotherMeScreen> createState() => _AnotherMeScreenState();
}

class _AnotherMeScreenState extends AppState<AnotherMeScreen> {
  late double imageSize;
  AnotherMeController controller = AnotherMeController();

  @override
  void initState() {
    super.initState();
    imageSize = ScreenUtil.screenSize.width - $(50);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
      ),
      body: GetBuilder<AnotherMeController>(
        init: controller,
        builder: (controller) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: buildImageContainer(context, controller),
              ),
              buildOptContainer(context, controller),
            ],
          );
        },
      ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))),
    );
  }

  Widget buildImageContainer(BuildContext context, AnotherMeController controller) {
    return controller.sourcePhoto == null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Images.ic_choose_photo_initial_header,
                width: imageSize,
                height: imageSize,
              ),
              SizedBox(height: $(80)),
              TitleTextWidget(
                S.of(context).another_me_tips,
                ColorConstant.White,
                FontWeight.bold,
                $(20),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Images.ic_choose_photo_initial_header,
                width: imageSize,
                height: imageSize,
              ),
            ],
          );
  }

  Widget buildOptContainer(BuildContext context, AnotherMeController controller) {
    return controller.transList.isEmpty
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Images.ic_camera, width: $(24)),
              SizedBox(width: $(8)),
              Text(
                S.of(context).choose_photo,
                style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(16), fontWeight: FontWeight.w600),
              ),
            ],
          )
            .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                margin: EdgeInsets.only(bottom: $(50), top: $(80)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorConstant.DiscoveryBtn,
                  borderRadius: BorderRadius.circular($(8)),
                ))
            .intoGestureDetector(onTap: () {
            //todo 选择图片
          })
        : Column(children: [
            Text(
              S.of(context).generate_again,
              style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(16), fontWeight: FontWeight.w600),
            )
                .intoContainer(
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: $(10)),
                    margin: EdgeInsets.only(
                      bottom: $(20),
                      top: $(80),
                      left: $(25),
                      right: $(25),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorConstant.DiscoveryBtn,
                      borderRadius: BorderRadius.circular($(8)),
                    ))
                .intoGestureDetector(onTap: () {
              // 重新生成
            }),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Images.ic_download, height: $(24), width: $(24))
                    .intoGestureDetector(
                      onTap: () {},
                    )
                    .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
                Image.asset(Images.ic_share_discovery, height: $(24), width: $(24))
                    .intoGestureDetector(
                      onTap: () {},
                    )
                    .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
                Image.asset(Images.ic_share, height: $(24), width: $(24))
                    .intoGestureDetector(
                      // onTap: () => showPickPhotoDialog(context),
                      onTap: () {},
                    )
                    .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
              ],
            ),
          ]).intoContainer(margin: EdgeInsets.only(bottom: $(100)));
  }
}
