import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_create.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';

class Avatar {
  static String logoTag = 'avatar_logo';
  static String logoBackTag = 'avatar_back_logo';
  static String aiTag = 'ai_tag';

  static open(BuildContext context) {
    Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => AvatarIntroduceScreen())).then((value) {
      if (value ?? false) {
        UserManager userManager = AppDelegate().getManager();
        userManager.doOnLogin(context, callback: () {
          if (userManager.user!.userSubscription.containsKey('avatar_ai')) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AvatarAiCreateScreen()));
          } else {
            // user not pay yet. to introduce page. and get pay status to edit page.
            Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => AvatarIntroduceScreen())).then((value) {
              if (value ?? false) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AvatarAiCreateScreen()));
              }
            });
          }
        }, autoExec: true);
      }
    });
  }
}
