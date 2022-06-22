import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/discovery/discovery_fragment.dart';
import 'package:cartoonizer/views/effect/effect_fragment.dart';
import 'package:cartoonizer/views/mine/mine_fragment.dart';

///
/// appTab配置
List<AppRoleTabItem> buildTabItem() => [
      //Home
      AppRoleTabItem(
        id: AppTabId.HOME.id(),
        normalIcon: Icon(
          Icons.home_rounded,
          size: $(28),
        ),
        selectedIcon: Icon(
          Icons.home_rounded,
          size: $(28),
          color: ColorConstant.BlueColor,
        ),
        titleBuilder: (context) => 'HOME',
        keyBuilder: () => GlobalKey<EffectFragmentState>(),
        fragmentBuilder: (key) => EffectFragment(
          key: key,
          tabId: AppTabId.HOME,
        ),
      ),
      //Discovery
      AppRoleTabItem(
        id: AppTabId.DISCOVERY.id(),
        normalIcon: Icon(
          Icons.list_alt,
          size: $(28),
        ),
        selectedIcon: Icon(
          Icons.list_alt,
          size: $(28),
          color: ColorConstant.BlueColor,
        ),
        titleBuilder: (context) => 'Discovery',
        keyBuilder: () => GlobalKey<DiscoveryFragmentState>(),
        fragmentBuilder: (key) => DiscoveryFragment(
          key: key,
          tabId: AppTabId.DISCOVERY,
        ),
      ),
      //Mine
      AppRoleTabItem(
        id: AppTabId.MINE.id(),
        normalIcon: Icon(
          Icons.person,
          size: $(28),
        ),
        selectedIcon: Icon(
          Icons.person,
          size: $(28),
          color: ColorConstant.BlueColor,
        ),
        titleBuilder: (context) => 'Mine',
        keyBuilder: () => GlobalKey<MineFragmentState>(),
        fragmentBuilder: (key) => MineFragment(
          key: key,
          tabId: AppTabId.MINE,
        ),
      ),
    ];

///appTab，关联角色权限
class AppRoleTabItem {
  Widget normalIcon;
  Widget selectedIcon;
  TitleBuilder titleBuilder;
  late GlobalKey<AppTabState> _key;
  int id;

  GlobalKey<AppTabState> get key => _key;
  late Widget _fragment;

  Widget get fragment => _fragment;
  KeyBuilder keyBuilder;
  FragmentBuilder fragmentBuilder;

  AppRoleTabItem({
    required this.id,
    required this.normalIcon,
    required this.selectedIcon,
    required this.titleBuilder,
    required this.keyBuilder,
    required this.fragmentBuilder,
  });

  createFragment() {
    _key = keyBuilder();
    _fragment = fragmentBuilder(_key);
  }
}

typedef TitleBuilder = String Function(BuildContext context);

typedef KeyBuilder = GlobalKey<AppTabState> Function();

typedef FragmentBuilder = Widget Function(GlobalKey<AppTabState> key);
