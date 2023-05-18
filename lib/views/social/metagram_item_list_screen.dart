import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/social/metagram_controller.dart';

import 'widget/metagram_list_card.dart';

class MetagramItemListScreen extends StatefulWidget {
  const MetagramItemListScreen({Key? key}) : super(key: key);

  @override
  State<MetagramItemListScreen> createState() => _MetagramItemListScreenState();
}

class _MetagramItemListScreenState extends State<MetagramItemListScreen> {
  MetagramController controller = Get.find<MetagramController>();

  @override
  void initState() {
    super.initState();
    delay(() {
      controller.itemScrollController.jumpTo(
        index: controller.scrollPosition,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(backgroundColor: ColorConstant.BackgroundColor),
      body: GetBuilder<MetagramController>(
        builder: (controller) {
          return ScrollablePositionedList.builder(
              itemPositionsListener: controller.itemPositionsListener,
              itemScrollController: controller.itemScrollController,
              itemCount: controller.data!.rows.length,
              itemBuilder: (context, index) {
                return MetagramListCard(
                  data: controller.data!.rows[index],
                ).intoContainer(margin: EdgeInsets.only(bottom: index == controller.data!.rows.length - 1 ? $(400) : $(15)));
              });
        },
        init: Get.find<MetagramController>(),
      ),
    );
  }
}
