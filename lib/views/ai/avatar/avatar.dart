import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_create.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_list_screen.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:cartoonizer/views/ai/avatar/pay/pay_avatar_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Avatar {
  static String logoTag = 'avatar_logo';
  static String logoBackTag = 'avatar_back_logo';
  static String aiTag = 'ai_tag';

  static intro(BuildContext context) {
    UserManager userManager = AppDelegate().getManager();
    AvatarAiManager aiManager = AppDelegate().getManager();
    if (!userManager.isNeedLogin && (userManager.user!.aiAvatarCredit > 0 || aiManager.dataList.isNotEmpty)) {
      Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: "/AvatarAiListScreen"),
            builder: (context) => AvatarAiListScreen(),
          ));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: "/AvatarIntroduceScreen"),
            builder: (context) => AvatarIntroduceScreen(),
          ));
    }
  }

  static open(BuildContext context) {
    UserManager userManager = AppDelegate().getManager();
    userManager.doOnLogin(context, callback: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(name: "/AvatarAiListScreen"),
            builder: (context) => AvatarAiListScreen(),
          ));
    }, autoExec: true);
  }

  static create(BuildContext context) async {
    UserManager userManager = AppDelegate().getManager();
    userManager.doOnLogin(context, callback: () {
      if (userManager.user!.aiAvatarCredit > 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: "/AvatarAiCreateScreen"),
              builder: (context) => AvatarAiCreateScreen(),
            )).then((value) {
          Navigator.of(context).popUntil(ModalRoute.withName('/AvatarAiListScreen'));
          if (value ?? false) {
            EventBusHelper().eventBus.fire(OnCreateAvatarAiEvent());
            open(context);
          }
        });
      } else {
        // user not pay yet. to introduce page. and get pay status to edit page.
        PayAvatarPage.push(context).then((payStatus) {
          if (payStatus ?? false) {
            userManager.refreshUser().then((onlineInfo) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: "/AvatarAiCreateScreen"),
                    builder: (context) => AvatarAiCreateScreen(),
                  )).then((value) {
                Navigator.of(context).popUntil(ModalRoute.withName('/AvatarAiListScreen'));
                if (value ?? false) {
                  EventBusHelper().eventBus.fire(OnCreateAvatarAiEvent());
                  open(context);
                }
              });
            });
          }
        });
      }
    }, autoExec: true);
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
