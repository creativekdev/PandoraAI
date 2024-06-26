import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/views/EditProfileScreen.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return UserProfileState();
  }
}

class UserProfileState extends State<UserProfileScreen> {
  UserManager userManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'user_profile_screen');
    // logEvent(Events.profile_page_loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.MineBackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        blurAble: false,
        middle: TitleTextWidget('User Profile', ColorConstant.White, FontWeight.w600, $(17)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: $(12)),
            ImageTextBarWidget(S.of(context).edit_profile, ImagesConstant.ic_edit_profile, true)
                .intoGestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(name: "/EditProfileScreen"),
                        builder: (context) => EditProfileScreen(),
                      )),
                )
                .intoContainer(margin: EdgeInsets.only(top: 1)),
            Container(
              width: double.maxFinite,
              height: 1,
              color: Color(0xff323232),
            ).intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(15)),
              color: ColorConstant.BackgroundColor,
            ),
          ],
        ),
      ),
    );
  }
}
