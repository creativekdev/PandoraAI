import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:flutter/cupertino.dart';

const double _kNavBarPersistentHeight = 44.0;

const _HeroTag _defaultHeroTag = _HeroTag(null);

class _HeroTag {
  const _HeroTag(this.navigator);

  final NavigatorState? navigator;

  // Let the Hero tag be described in tree dumps.
  @override
  String toString() => 'Default Hero tag for Cupertino navigation bars with navigator $navigator';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _HeroTag && other.navigator == navigator;
  }

  @override
  int get hashCode {
    return identityHashCode(navigator);
  }
}

// ignore: must_be_immutable
class AppNavigationBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  Key? key;
  Brightness brightness;
  Color backgroundColor;
  Widget? leading;
  bool automaticallyImplyLeading;
  bool automaticallyImplyMiddle;
  String? previousPageTitle;
  Widget? middle;
  bool showBackItem;
  Widget? trailing;
  EdgeInsetsDirectional? padding;
  bool transitionBetweenRoutes;
  Function? backAction;
  Object heroTag;
  double elevation;
  Widget? child;
  double childHeight;
  bool visible;
  Widget? backIcon;
  Widget? statusBar;
  Decoration? decoration;
  bool blurAble;

  AppNavigationBar({
    this.key,
    this.backgroundColor = Colors.white,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.automaticallyImplyMiddle = true,
    this.previousPageTitle,
    this.middle,
    this.showBackItem = true,
    this.trailing,
    this.padding,
    this.transitionBetweenRoutes = false,
    this.backAction,
    this.heroTag = _defaultHeroTag,
    this.elevation = 0,
    this.child,
    this.visible = true,
    this.childHeight = 0,
    this.brightness = Brightness.dark,
    this.backIcon,
    this.statusBar,
    this.decoration,
    this.blurAble = false,
  }) {
    this.backIcon ??= Image.asset(
      Images.ic_back,
      height: $(24),
      width: $(24),
    );
    this.statusBar ??= Container(
      color: Colors.transparent,
      height: ScreenUtil.getStatusBarHeight(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Offstage(
            child: CupertinoNavigationBar(
                brightness: brightness,
                heroTag: heroTag,
                key: key,
                backgroundColor: blurAble ? Colors.transparent : backgroundColor,
                leading: showBackItem
                    ? GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          // width: backText == null ? $(32) : $(20),
                          alignment: Alignment.centerLeft,
                          child: backIcon,
                        ),
                        onTap: () {
                          backAction == null ? Navigator.pop(context) : backAction!();
                        },
                      )
                    : (leading == null ? Container() : leading),
                automaticallyImplyLeading: automaticallyImplyLeading,
                automaticallyImplyMiddle: automaticallyImplyMiddle,
                previousPageTitle: previousPageTitle,
                middle: middle,
                trailing: trailing,
                padding: padding,
                transitionBetweenRoutes: transitionBetweenRoutes,
                border: null),
            offstage: !visible,
          ),
          Offstage(
            offstage: visible,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
              child: statusBar!,
            ),
          ),
          Offstage(offstage: child == null, child: child),
        ],
      ).intoContainer(decoration: decoration),
      elevation: elevation,
      color: backgroundColor,
    );
  }

  bool get fullObstruction => backgroundColor.alpha == 0xFF;

  @override
  Size get preferredSize {
    return Size.fromHeight((visible ? _kNavBarPersistentHeight : 0) + childHeight);
  }

  @override
  bool shouldFullyObstruct(BuildContext context) {
    return true;
  }
}