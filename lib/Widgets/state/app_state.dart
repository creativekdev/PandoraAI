import 'package:cartoonizer/Common/importFile.dart';

///app state
///features:
/// hide keyboard on touch outside
/// add loading state
abstract class AppState<T extends StatefulWidget> extends State<T> {
  bool loading = false;
  bool canCancelOnLoading = true;

  AppState({this.canCancelOnLoading = true});

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
    return WillPopScope(
        child: Stack(
          children: [
            buildWidget(context).blankAreaIntercept(),
            loading
                ? Center(
              child: CircularProgressIndicator(),
            ).intoContainer(color: Color(0x55000000))
                : Container(),
          ],
          fit: StackFit.expand,
        ).ignore(ignoring: loading),
        onWillPop: () async {
          if (canCancelOnLoading) {
            return true;
          }
          return !loading;
        });
  }

  Future<void> showLoading() async {
    setState(() {
      loading = true;
    });
  }

  Future<void> hideLoading() async {
    setState(() {
      loading = false;
    });
  }

  @protected
  Widget buildWidget(BuildContext context);
}

///
abstract class KeyboardState<T extends StatefulWidget> extends State<T> {}

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
