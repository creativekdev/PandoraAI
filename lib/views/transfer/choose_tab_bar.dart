import 'package:cartoonizer/Common/importFile.dart';

typedef ItemBuilder = Widget Function(BuildContext context, int index, String value, bool checked);

class ChooseTabBar extends StatelessWidget {
  List<String> tabList;
  bool scrollable;
  int currentIndex;
  double height;
  Function(int index) onTabClick;
  late ItemBuilder itemBuilder;

  ChooseTabBar({
    Key? key,
    required this.tabList,
    required this.onTabClick,
    this.scrollable = false,
    this.currentIndex = 0,
    required this.height,
    ItemBuilder? itemBuilder,
  }) : super(key: key) {
    this.itemBuilder = itemBuilder ??= (context, index, value, checked) {
      if (checked) {
        return ShaderMask(
          shaderCallback: (Rect bounds) => LinearGradient(
            colors: [Color(0xffE31ECD), Color(0xff243CFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(Offset.zero & bounds.size),
          blendMode: BlendMode.srcATop,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: ColorConstant.White,
              fontSize: $(14),
            ),
          ),
        );
      } else {
        return Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: ColorConstant.HintColor,
            fontSize: $(14),
          ),
        ).intoContainer(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.transparent,
          alignment: Alignment.center,
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items(context)
              .map((e) => e.intoContainer(
                    height: height,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ))
              .toList(),
        ),
      );
    } else {
      return Row(
        children: items(context)
            .map((e) => Expanded(
                    child: e.intoContainer(
                  alignment: Alignment.center,
                  height: height,
                )))
            .toList(),
      );
    }
  }

  List<Widget> items(BuildContext context) {
    return tabList.transfer((data, index) => itemBuilder
            .call(
          context,
          index,
          data,
          index == currentIndex,
        )
            .intoGestureDetector(onTap: () {
          if (currentIndex != index) {
            onTabClick.call(index);
          }
        }));
  }
}
