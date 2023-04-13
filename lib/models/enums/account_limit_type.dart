import 'package:cartoonizer/Common/importFile.dart';

enum AccountLimitType {
  guest,
  normal,
  vip,
}

extension AccountLimitTypeEx on AccountLimitType {
  String getTitle(BuildContext context, String function) {
    return S.of(context).generate_reached_limit_title.replaceAll('%s', function);
  }

  String getContent(BuildContext context, String function) {
    return S.of(context).reached_limit_content;
    switch (this) {
      case AccountLimitType.guest:
        return S.of(context).generate_reached_limit_guest.replaceAll('%s', function);
      case AccountLimitType.normal:
        return S.of(context).generate_reached_limit.replaceAll('%s', function);
      case AccountLimitType.vip:
        return S.of(context).generate_reached_limit_vip.replaceAll('%s', function);
    }
  }

  String getSubmitText(BuildContext context) {
    return S.of(context).submit_now;
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
