import 'package:cartoonizer/Common/importFile.dart';

class ChooseTabBar extends StatelessWidget {
  List<String> tabList;
  bool scrollable;
  int currentIndex;
  double height;
  Function(int index) onTabClick;

  ChooseTabBar({
    Key? key,
    required this.tabList,
    required this.onTabClick,
    this.scrollable = false,
    this.currentIndex = 0,
    required this.height,
  }) : super(key: key);

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
    return tabList.transfer((data, index) {
      if (index == currentIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular(8)),
            ),
            SizedBox(width: 4),
            Text(
              data,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: ColorConstant.White,
                fontSize: $(16),
              ),
            ),
          ],
        );
      } else {
        return Text(
          data,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: ColorConstant.HintColor,
            fontSize: $(15),
          ),
        ).intoGestureDetector(onTap: () {
          onTabClick.call(index);
        });
      }
    });
  }
}
