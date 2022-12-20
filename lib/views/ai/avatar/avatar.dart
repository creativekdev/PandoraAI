import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_create.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_list_screen.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:cartoonizer/views/ai/avatar/pay/pay_avatar_screen.dart';

class Avatar {
  static String logoTag = 'avatar_logo';
  static String logoBackTag = 'avatar_back_logo';
  static String aiTag = 'ai_tag';

  static openFromHome(BuildContext context) {
    UserManager userManager = AppDelegate.instance.getManager();
    if (userManager.isNeedLogin) {
      intro(context);
    } else {
      AvatarAiManager aiManager = AppDelegate.instance.getManager();
      if (aiManager.dataList.isNotEmpty) {
        open(context);
      } else {
        intro(context);
      }
    }
  }

  static intro(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/AvatarIntroduceScreen"),
          builder: (context) => AvatarIntroduceScreen(),
        ));
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

  static create(BuildContext context, {required String name, required String style}) async {
    UserManager userManager = AppDelegate().getManager();
    userManager.doOnLogin(context, callback: () {
      var forward = () {
        Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: "/AvatarAiCreateScreen"),
              builder: (context) => AvatarAiCreateScreen(
                name: name,
                style: style,
              ),
            )).then((value) {
          if (value ?? false) {
            EventBusHelper().eventBus.fire(OnCreateAvatarAiEvent());
            AvatarAiManager aiManager = AppDelegate().getManager();
            if (!aiManager.listPageAlive) {
              open(context);
            }
          }
        });
      };
      if (userManager.user!.aiAvatarCredit > 0) {
        forward.call();
      } else {
        // user not pay yet. to introduce page. and get pay status to edit page.
        PayAvatarPage.push(context).then((payStatus) {
          if (payStatus ?? false) {
            forward.call();
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
