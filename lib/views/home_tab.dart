import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
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
        normalIcon: Images.ic_tab_effect_normal,
        selectedIcon: Images.ic_tab_effect,
        titleBuilder: (context) => StringConstant.tabHome,
        keyBuilder: () => GlobalKey<EffectFragmentState>(),
        fragmentBuilder: (key) => EffectFragment(
          key: key,
          tabId: AppTabId.HOME,
        ),
      ),
      //Discovery
      AppRoleTabItem(
        id: AppTabId.DISCOVERY.id(),
        normalIcon: Images.ic_tab_discovery_normal,
        selectedIcon: Images.ic_tab_discovery,
        titleBuilder: (context) => StringConstant.tabDiscovery,
        keyBuilder: () => GlobalKey<DiscoveryFragmentState>(),
        fragmentBuilder: (key) => DiscoveryFragment(
          key: key,
          tabId: AppTabId.DISCOVERY,
        ),
      ),
      //Mine
      AppRoleTabItem(
        id: AppTabId.MINE.id(),
        normalIcon: Images.ic_tab_my_normal,
        selectedIcon: Images.ic_tab_my,
        titleBuilder: (context) => StringConstant.tabMine,
        keyBuilder: () => GlobalKey<MineFragmentState>(),
        fragmentBuilder: (key) => MineFragment(
          key: key,
          tabId: AppTabId.MINE,
        ),
      ),
    ];

///appTab，关联角色权限
class AppRoleTabItem {
  String normalIcon;
  String selectedIcon;
  TitleBuilder titleBuilder;
  GlobalKey<AppTabState>? _key;
  int id;

  GlobalKey<AppTabState>? get key => _key;
  Widget? _fragment;

  Widget? get fragment => _fragment;
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
    if (_key == null) {
      _key = keyBuilder();
    }
    if (_fragment == null) {
      _fragment = fragmentBuilder(_key!);
    }
  }
}

typedef TitleBuilder = String Function(BuildContext context);

typedef KeyBuilder = GlobalKey<AppTabState> Function();

typedef FragmentBuilder = Widget Function(GlobalKey<AppTabState> key);
