import 'dart:ui' show ImageFilter;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double _appTabBarHeight = 55.0;

double get AppTabBarHeight => _appTabBarHeight;

const Color _kDefaultTabBarBorderColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x4C000000),
  darkColor: Color(0x29000000),
);
const Color _kDefaultTabBarInactiveColor = CupertinoColors.inactiveGray;

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({
    Key? key,
    required this.items,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.currentIndex = 0,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor = _kDefaultTabBarInactiveColor,
    this.iconSize = 30.0,
    this.elevation = 4,
    this.border = const Border(
      top: BorderSide(
        color: Colors.transparent,
        width: 0.0, // One physical pixel.
        style: BorderStyle.solid,
      ),
    ),
  })  : assert(
          items.length >= 2,
          "Tabs need at least 2 items to conform to Apple's HIG",
        ),
        assert(0 <= currentIndex && currentIndex < items.length),
        super(key: key);

  /// Must not be null.
  final List<BottomNavigationBarItem> items;

  /// The callback that is called when a item is tapped.
  ///
  /// The widget creating the bottom navigation bar needs to keep track of the
  /// current index and call `setState` to rebuild it with the newly provided
  /// index.
  final ValueChanged<int>? onTap;

  final ValueChanged<int>? onDoubleTap;
  final ValueChanged<int>? onLongPress;

  final int currentIndex;
  final double elevation;

  final Color? backgroundColor;

  final Color? activeColor;

  final Color inactiveColor;

  final double iconSize;

  final Border border;

  @override
  Size get preferredSize => const Size.fromHeight(_appTabBarHeight);

  bool opaque(BuildContext context) {
    final Color backgroundColor = this.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor;
    return CupertinoDynamicColor.resolve(backgroundColor, context).alpha == 0xFF;
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final Color backgroundColor = CupertinoDynamicColor.resolve(
      this.backgroundColor ?? CupertinoTheme.of(context).barBackgroundColor,
      context,
    );

    BorderSide resolveBorderSide(BorderSide side) {
      return side == BorderSide.none ? side : side.copyWith(color: CupertinoDynamicColor.resolve(side.color, context));
    }

    // Return the border as is when it's a subclass.
    final Border resolvedBorder = border.runtimeType != Border
        ? border
        : Border(
            top: resolveBorderSide(border.top),
            left: resolveBorderSide(border.left),
            bottom: resolveBorderSide(border.bottom),
            right: resolveBorderSide(border.right),
          );

    final Color inactive = CupertinoDynamicColor.resolve(inactiveColor, context);
    Widget result = Material(
      color: backgroundColor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: resolvedBorder,
        ),
        child: SizedBox(
          height: _appTabBarHeight + bottomPadding,
          child: IconTheme.merge(
            // Default with the inactive state.
            data: IconThemeData(color: inactive, size: iconSize),
            child: DefaultTextStyle(
              // Default with the inactive state.
              style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(color: inactive),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Semantics(
                  explicitChildNodes: true,
                  child: Row(
                    // Align bottom since we want the labels to be aligned.
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _buildTabItems(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      elevation: elevation,
    );

    if (!opaque(context)) {
      // For non-opaque backgrounds, apply a blur effect.
      result = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: result,
        ),
      );
    }

    return result;
  }

  List<Widget> _buildTabItems(BuildContext context) {
    final List<Widget> result = <Widget>[];
    final CupertinoLocalizations localizations = CupertinoLocalizations.of(context);

    for (int index = 0; index < items.length; index += 1) {
      final bool active = index == currentIndex;
      result.add(
        _wrapActiveItem(
          context,
          Expanded(
            child: Semantics(
              selected: active,
              hint: localizations.tabSemanticsLabel(
                tabIndex: index + 1,
                tabCount: items.length,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: index == currentIndex && onDoubleTap != null
                    ? () {
                        onDoubleTap!(index);
                      }
                    : null,
                onTap: onTap == null
                    ? null
                    : () {
                        onTap!(index);
                      },
                onLongPress: index == currentIndex && onLongPress != null
                    ? () {
                        onLongPress!(index);
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, top: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _buildSingleTabItem(items[index], active),
                  ),
                ),
              ),
            ),
          ),
          active: active,
        ),
      );
    }
    return result;
  }

  List<Widget> _buildSingleTabItem(BottomNavigationBarItem item, bool active) {
    return <Widget>[
      Stack(
        children: [
          item.activeIcon.offstage(offstage: !active),
          item.icon.offstage(offstage: active),
        ],
      ).intoContainer(width: iconSize, height: iconSize),
      // Expanded(
      //   child: Center(child: active ? item.activeIcon : item.icon),
      // ),
      if (item.label != null) Text(item.label!),
    ];
  }

  /// Change the active tab item's icon and title colors to active.
  Widget _wrapActiveItem(BuildContext context, Widget item, {required bool active}) {
    if (!active) return item;

    final Color activeColor = CupertinoDynamicColor.resolve(
      this.activeColor ?? CupertinoTheme.of(context).primaryColor,
      context,
    );
    return IconTheme.merge(
      data: IconThemeData(color: activeColor),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: activeColor),
        child: item,
      ),
    );
  }

  /// Create a clone of the current [CupertinoTabBar] but with provided
  /// parameters overridden.
  AppTabBar copyWith({
    Key? key,
    List<BottomNavigationBarItem>? items,
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    double? iconSize,
    Border? border,
    int? currentIndex,
    ValueChanged<int>? onTap,
  }) {
    return AppTabBar(
      key: key ?? this.key,
      items: items ?? this.items,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      iconSize: iconSize ?? this.iconSize,
      border: border ?? this.border,
      currentIndex: currentIndex ?? this.currentIndex,
      onTap: onTap ?? this.onTap,
    );
  }
}
