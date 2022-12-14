import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/badge.dart';
import 'package:cartoonizer/Widgets/indicator/line_tab_indicator.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/PurchaseScreen.dart';
import 'package:cartoonizer/views/StripeSubscriptionScreen.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:cartoonizer/views/effect/effect_face_fragment.dart';
import 'package:cartoonizer/views/effect/effect_full_body_fragment.dart';
import 'package:cartoonizer/views/effect/effect_random_fragment.dart';
import 'package:cartoonizer/views/effect/effect_tab_state.dart';

class TabAiFragment extends StatefulWidget {
  AppTabId tabId;

  TabAiFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<TabAiFragment> createState() => TabAiFragmentState();
}

class TabAiFragmentState extends State<TabAiFragment> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin, AppTabState, EffectTabState {
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late AppTabId tabId;

  @override
  void initState() {
    super.initState();
    tabId = widget.tabId;
  }

  @override
  void onAttached() {
    super.onAttached();
    var lastTime = cacheManager.getInt('${CacheManager.keyLastTabAttached}_${tabId.id()}');
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - lastTime > 5000) {
      logEvent(Events.tab_ai_loading);
    }
    cacheManager.setInt('${CacheManager.keyLastTabAttached}_${tabId.id()}', currentTime);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AvatarIntroduceScreen(fromTab: true,).intoContainer(padding: EdgeInsets.only(bottom: $(50)));
  }

  @override
  bool get wantKeepAlive => true;
}
