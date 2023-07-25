import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';

enum AccountLimitType {
  guest,
  normal,
  vip,
}

extension AccountLimitTypeEx on AccountLimitType {
  String getTitle(BuildContext context, String function) {
    return S.of(context).generate_reached_limit_title.replaceAll('%s', function);
  }

  String getContent(BuildContext context) {
    switch (this) {
      case AccountLimitType.guest:
        return S.of(context).reached_limit_content_guest;
      case AccountLimitType.normal:
        return S.of(context).reached_limit_content;
      case AccountLimitType.vip:
        return S.of(context).reached_limit_content_vip;
    }
  }

  String getSubmitText(BuildContext context) {
    switch (this) {
      case AccountLimitType.guest:
        return S.of(context).sign_up_now;
      case AccountLimitType.normal:
        var manager = AppDelegate.instance.getManager<UserManager>();
        if (manager.user!.isReferred) {
          return S.of(context).upgrade_now;
        } else {
          return S.of(context).enter_now;
        }
      case AccountLimitType.vip:
        return S.of(context).okay;
    }
  }

  // String getNegativeText(BuildContext context) {
  //   return S.of(context).explore_more;
  // }

  String? getPositiveText(BuildContext context) {
    switch (this) {
      case AccountLimitType.guest:
        return S.of(context).sign_up_now;
      case AccountLimitType.normal:
        return S.of(context).upgrade_now;
      case AccountLimitType.vip:
        return null;
    }
  }
}
