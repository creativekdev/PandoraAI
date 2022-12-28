import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:cartoonizer/views/ai/avatar/dialog/submit_avatar_dialog.dart';
import 'package:cartoonizer/views/transfer/choose_tab_bar.dart';

import 'avatar.dart';

class AvatarIntroduceScreen extends StatefulWidget {
  AvatarIntroduceScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AvatarIntroduceScreenState();
}

class AvatarIntroduceScreenState extends AppState<AvatarIntroduceScreen> {
  List<String> dataList = [];
  Size? size;
  int selectedStyleIndex = 0;
  late StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    logEvent(Events.avatar_introduce_loading);
    streamSubscription = EventBusHelper().eventBus.on<OnCreateAvatarAiEvent>().listen((event) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(backgroundColor: ColorConstant.BackgroundColor),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: $(10)),
            shaderMask(
                context: context,
                child: Text(
                  S.of(context).what_to_expect,
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(26),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                )),
            SizedBox(height: $(15)),
            TitleTextWidget(
                    S.of(context).expect_details,
                    ColorConstant.White,
                    FontWeight.w400,
                    $(13),
                    maxLines: 10)
                .intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(25)),
            ),
            Image.asset(
              Images.ic_avatar_ai_planet,
              height: $(60),
            ).intoContainer(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(
                  horizontal: $(15),
                ),
                margin: EdgeInsets.only(bottom: $(6))),
            TitleTextWidget(
                    S.of(context).guidelines,
                    Colors.white,
                    FontWeight.bold,
                    $(17),
                    maxLines: 3)
                .intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(35)),
            ),
            SizedBox(height: $(35)),
            shaderMask(
                context: context,
                child: Text(
                  S.of(context).examples,
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(18),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                )),
            FutureBuilder(
              builder: (context, snapShot) {
                if (snapShot.data == null) {
                  return Container();
                }
                var config = snapShot.data! as AvatarConfig;
                var roles = config.getRoles();
                var style = roles[selectedStyleIndex];
                var examples = config.examples(style);
                return Column(
                  children: [
                    ChooseTabBar(
                        tabList: roles,
                        currentIndex: selectedStyleIndex,
                        onTabClick: (index) {
                          setState(() {
                            selectedStyleIndex = index;
                          });
                        },
                        height: $(36)),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: $(12), right: $(12), bottom: $(12)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: $(6),
                        crossAxisSpacing: $(6),
                      ),
                      itemBuilder: (context, index) {
                        return buildItem(context, index, examples);
                      },
                      itemCount: examples.length,
                    ),
                  ],
                );
              },
              future: AppDelegate().getManager<AvatarAiManager>().getConfig(),
            )
          ],
        ),
      ),
      bottomNavigationBar: TitleTextWidget(S.of(context).txtContinue, ColorConstant.White, FontWeight.normal, $(17))
          .intoContainer(
            margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
            decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(8))),
            alignment: Alignment.center,
          )
          .intoContainer(
            width: ScreenUtil.screenSize.width,
            alignment: Alignment.center,
            height: $(72),
          )
          .intoGestureDetector(onTap: () {
        SubmitAvatarDialog.push(context, name: '').then((nameStyle) {
          if (nameStyle != null) {
            Avatar.create(context, name: nameStyle.key, style: nameStyle.value, state: this);
          }
        });
      }).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))),
    );
  }

  Widget buildItem(BuildContext context, int index, List<String> examples) {
    return ClipRRect(
      child: CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: examples[index],
        width: (ScreenUtil.screenSize.width - $(36)) / 2,
        height: (ScreenUtil.screenSize.width - $(36)) / 2,
      ),
      borderRadius: BorderRadius.circular($(8)),
    );
  }
}
