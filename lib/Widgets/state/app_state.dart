import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/blank_area_intercept.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';

///app state
///features:
/// hide keyboard on touch outside
/// add loading state
abstract class AppState<T extends StatefulWidget> extends State<T> {
  bool loading = false;
  bool canCancelOnLoading = true;
  KeyboardInterceptType interceptType = KeyboardInterceptType.hideKeyboard;
  Widget? progressWidget;

  AppState({
    this.canCancelOnLoading = true,
    this.interceptType = KeyboardInterceptType.hideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return build2(context);
  }

  /// call this when state extends more than one super class like extends AppState with AutomaticKeepAliveClientMixin
  /// and developer need to override build. like this
  /// @override
  /// Widget build(BuildContext context) {
  ///   super.build(context);
  ///   return build2(context);
  /// }
  Widget build2(BuildContext context) {
    if (canCancelOnLoading || !loading) {
      return _pageWidget(context);
    }
    return WillPopScope(
        child: _pageWidget(context),
        onWillPop: () async {
          return !loading;
        });
  }

  Widget _pageWidget(BuildContext context) => Stack(
        children: [
          buildWidget(context).blankAreaIntercept(interceptType: interceptType),
          loading
              ? Center(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    progressWidget == null
                        ? Container()
                        : progressWidget!
                            .intoContainer(
                              margin: EdgeInsets.only(top: 6),
                            )
                            .intoMaterial(color: Colors.transparent),
                  ],
                )).intoContainer(color: Color(0x55000000))
              : Container(),
        ],
        fit: StackFit.expand,
      ).ignore(ignoring: loading);

  Future<void> showLoading({Widget? progressWidget}) async {
    if (!mounted) {
      return;
    }
    setState(() {
      this.progressWidget = progressWidget;
      loading = true;
    });
  }

  Future<void> hideLoading() async {
    if (!mounted) {
      return;
    }
    setState(() {
      progressWidget = null;
      loading = false;
    });
  }

  @protected
  Widget buildWidget(BuildContext context);
}

mixin AppTabState<T extends StatefulWidget> on State<T> {
  bool _attached = true;

  bool get attached => _attached;

  void onAttached() {
    _attached = true;
  }

  void onDetached() {
    _attached = false;
  }
}

///页面状态 显示\隐藏
enum VisibilityState { hide, show }

mixin WidgetVisibilityStateMixin<T extends StatefulWidget> on State<T> implements WidgetsBindingObserver {
  late FocusNode _ownFocusNode, _oldFocusNode, _newFocusNode;
  VisibilityState visibilityState = VisibilityState.hide;

  ///忽略的焦点列表
  List<FocusNode> _ignoreFocusList = [];

  List<FocusNode> get ignoreFocusList => _ignoreFocusList;

  set ignoreFocusList(List<FocusNode> list) => _ignoreFocusList = list;

  ///显示
  void onShow() {
    visibilityState = VisibilityState.show;
  }

  ///不显示
  void onHide() {
    visibilityState = VisibilityState.hide;
  }

  _addFocusNodeChangeCb() {
    _ownFocusNode = _oldFocusNode = _newFocusNode = FocusManager.instance.primaryFocus!;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPersistentFrameCallback(focusNodeChangeCb);
    onShow();
  }

  ///焦点判断
  void focusNodeChangeCb(_) {
    _newFocusNode = FocusManager.instance.primaryFocus!;
    if (_newFocusNode == _oldFocusNode) return;
    _oldFocusNode = _newFocusNode;

    if (_judgeNeedIgnore(_newFocusNode)) return;
    if (_newFocusNode == _ownFocusNode) {
      if (visibilityState != VisibilityState.show) {
        onShow();
      }
    } else {
      if (visibilityState != VisibilityState.hide) {
        onHide();
      }
    }
  }

  ///忽略焦点值
  bool _judgeNeedIgnore(focusNode) {
    return _ignoreFocusList.contains(focusNode);
  }

  @override
  void initState() {
    super.initState();
    Future(_addFocusNodeChangeCb);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
