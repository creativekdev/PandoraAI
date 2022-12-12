import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';

import 'pay_avatar_android.dart';
import 'pay_avatar_ios.dart';

class PayAvatarPage {
  static Future<bool?> push(
    BuildContext context,
  ) =>
      Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (context) => _PayAvatarPage(),
      ));
}

class _PayAvatarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PayAvatarPageState();
  }
}

class PayAvatarPageState extends AppState<_PayAvatarPage> {
  late CartoonizerApi api;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    api.listAllBuyPlan().then((value) {
      setState(() {

      });
    });
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
      body: Column(
        children: [
          Platform.isIOS ? PayAvatarIOS() : PayAvatarAndroid(),
        ],
      ),
    );
  }
}
