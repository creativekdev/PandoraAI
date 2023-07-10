import '../../../Common/importFile.dart';
import '../../../images-res.dart';

class PopmenuUtil {
  static Future showPopMenu(BuildContext context, LongPressStartDetails details, List<LongPressItem> items) {
    final List<PopupMenuItem> popupMenuItems = [];
    for (LongPressItem item in items) {
      PopupMenuItem popupMenuItem = PopupMenuItem(
        // PopupMenuItem 的坑，默认为8，点击到边矩的地方会无反应
        padding: const EdgeInsets.all(0),
        // 不使用 PopupMenuItem 的 onTap 事件
        // onTap: item.onTap,
        child: Builder(builder: (context0) {
          // 这里需要使用 新的 context ，不然点击会无反应。
          // 区分现有的 context
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (item.onTap != null) {
                item.onTap!();
              }
            },
            child: Row(children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.ic_report,
                      width: $(16),
                    ),
                    SizedBox(
                      width: $(5),
                    ),
                    TitleTextWidget(item.text, Colors.black, FontWeight.normal, $(14)),
                  ],
                ),
              ),
            ]),
          );
        }),
      );

      popupMenuItems.add(popupMenuItem);
    }

    RenderBox? renderBox = Overlay.of(context)?.context.findRenderObject() as RenderBox;

    // 表示位置（在画面边缘会自动调整位置）
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx + 55, // 菜单显示位置X轴坐标
        details.globalPosition.dy - 40, // 菜单显示位置Y轴坐标
      ),
      Offset.zero & renderBox.size,
    );

    return showMenu(context: context, position: position, items: popupMenuItems, useRootNavigator: true);
  }
}

class LongPressItem {
  final String text;
  final GestureTapCallback? onTap;

  const LongPressItem({this.text = '', this.onTap});
}
