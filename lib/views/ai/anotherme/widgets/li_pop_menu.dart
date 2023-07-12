import 'package:cartoonizer/utils/screen_util.dart';
import 'package:flutter/material.dart';

const Color _bgColor = Color(0xFF191717);

typedef _ClickCallBack = void Function(int selectIndex, String selectText);

class LiPopMenu {
  static BuildContext? menuContext;

  /// 显示带线带背景 pop
  static void showLinePop(BuildContext context, {bool isShowBg = true, _ClickCallBack? clickCallback, required List<ListPopItem> listData, Color? color}) {
    menuContext = context;
    Widget _buildMenuLineCell(dataArr) {
      return ListView.separated(
        itemCount: dataArr.length,
        padding: const EdgeInsets.all(0.0),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return Material(
              color: _bgColor,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (clickCallback != null) {
                      clickCallback(index, listData[index].text);
                    }
                  },
                  child: Container(
                    height: $(57),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: $(14)),
                        Image.asset(
                          dataArr[index].icon,
                          width: $(24),
                          height: $(24),
                          color: color,
                        ),
                        SizedBox(width: $(12)),
                        Text(listData[index].text, style: TextStyle(color: Color(0xFFFFFFFF), fontSize: $(14)))
                      ],
                    ),
                  )));
        },
        separatorBuilder: (context, index) {
          return Divider(
            height: $(1),
            indent: $(48),
            endIndent: 0,
            color: Color(0xFF333333),
          );
        },
      );
    }

    Widget _menusView(dataArr) {
      var cellH = dataArr.length * $(57);
      double navH = ScreenUtil.getStatusBarHeight() + 44.0;
      if (isShowBg = true) {
        navH = navH - ScreenUtil.getStatusBarHeight();
      } else {
        navH = navH - 10;
      }
      return Positioned(
        right: $(8),
        top: navH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            ClipRRect(borderRadius: BorderRadius.circular(5), child: Container(color: _bgColor, width: $(150), height: cellH, child: _buildMenuLineCell(dataArr)))
          ],
        ),
      );
    }

    if (isShowBg == true) {
      // 带背景
      showDialog(
          context: context,
          barrierDismissible: false,
          useSafeArea: true,
          useRootNavigator: false,
          builder: (context) {
            return _BasePopMenus(child: _menusView(listData));
          });
    } else {
      Navigator.of(context).push(DialogRouter(_BasePopMenus(child: _menusView(listData))));
    }
  }

  /// 隐藏
  static void dissmiss() {
    if (Navigator.of(menuContext!).canPop()) {
      Navigator.of(menuContext!).pop();
    }
  }
}

class _BasePopMenus extends Dialog {
  _BasePopMenus({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(onTap: () => Navigator.pop(context)),
          // 内容
          child
        ],
      ),
    );
  }
}

class DialogRouter extends PageRouteBuilder {
  final Widget page;

  DialogRouter(this.page)
      : super(
          opaque: false,
          // 自定义遮罩颜色
          barrierColor: Colors.white10.withAlpha(1),
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
        );
}

class CustomDialog extends Dialog {
  CustomDialog({
    Key? key,
    required this.child,
    this.clickBgHidden: false, // 点击背景隐藏，默认不隐藏
  }) : super(key: key);

  final Widget child;
  final bool clickBgHidden;

  @override
  Widget build(BuildContext context) {
    return Material(
        // 透明层
        type: MaterialType.transparency,
        child: Stack(
          children: <Widget>[
            InkWell(
              onTap: () {
                if (clickBgHidden == true) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            // 内容
            Center(child: child)
          ],
        ));
  }
}

class ListPopItem {
  ListPopItem({required this.text, required this.icon});

  final String text;
  final String icon;
}
