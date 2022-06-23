import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/SettingScreen.dart';
import 'package:flutter/material.dart';

class MineFragment extends StatefulWidget {
  AppTabId tabId;

  MineFragment({Key? key, required this.tabId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MineFragmentState();
}

class MineFragmentState extends AppState<MineFragment> with AutomaticKeepAliveClientMixin, AppTabState {
  UserManager userManager = AppDelegate.instance.getManager();

  @override
  bool get wantKeepAlive => true;

  void onAttached() {
    super.onAttached();
    userManager.refreshUser();
  }

  void onDetached() {
    super.onDetached();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: buildWidget(context),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return SettingScreen();
  }
}
