import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_create.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_list_screen.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:cartoonizer/views/ai/avatar/pay/pay_avatar_screen.dart';

class Avatar {
  static String logoTag = 'avatar_logo';
  static String logoBackTag = 'avatar_back_logo';
  static String aiTag = 'ai_tag';

  static open(BuildContext context) {
    UserManager userManager = AppDelegate().getManager();
    userManager.doOnLogin(context, callback: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvatarAiListScreen(),
          ));
    }, autoExec: true);
  }

  static create(BuildContext context) async {
    UserManager userManager = AppDelegate().getManager();
    if (!userManager.user!.userSubscription.containsKey('avatar_ai')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AvatarAiCreateScreen()));
    } else {
      // user not pay yet. to introduce page. and get pay status to edit page.
      PayAvatarPage.push(context).then((value) {
        if (value ?? false) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AvatarAiCreateScreen()));
        }
      });
    }
  }
}

Widget shaderMask({
  required BuildContext context,
  required Widget child,
}) {
  return ShaderMask(
      shaderCallback: (Rect bounds) => LinearGradient(
            colors: [Color(0xffE31ECD), Color(0xff243CFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(Offset.zero & bounds.size),
      blendMode: BlendMode.srcATop,
      child: child);
}
