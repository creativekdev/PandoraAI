import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';

// unused yet
class TabAIFragment extends StatefulWidget {
  AppTabId tabId;

  TabAIFragment({Key? key, required this.tabId}) : super(key: key);

  @override
  State<TabAIFragment> createState() => TabAIFragmentState();
}

class TabAIFragmentState extends AppState<TabAIFragment> with AutomaticKeepAliveClientMixin, AppTabState {
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
  void onDetached() {
    super.onDetached();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildWidget(context);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          AppNavigationBar(
            backgroundColor: ColorConstant.BackgroundColor,
            showBackItem: false,
            middle: TitleTextWidget(
              S.of(context).tabAI,
              ColorConstant.White,
              FontWeight.w500,
              $(18),
            ),
          ).intoContainer(height: kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight()),

        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
