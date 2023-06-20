import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/views/print/print_option_controller.dart';
import 'package:cartoonizer/views/print/print_screen.dart';
import 'package:cartoonizer/views/print/widgets/print_option_item.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../Widgets/router/routers.dart';

class PrintOptionScreen extends StatefulWidget {
  String source;
  File file;

  PrintOptionScreen({
    Key? key,
    required this.file,
    required this.source,
  }) : super(key: key);

  @override
  State<PrintOptionScreen> createState() => _PrintOptionScreenState();
}

class _PrintOptionScreenState extends State<PrintOptionScreen> {
  PrintOptionController controller = Get.put(PrintOptionController());

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'print_option_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: $(8)),
        child: GetBuilder<PrintOptionController>(
          init: controller,
          builder: (controller) {
            if (controller.viewInit == false) {
              return SizedBox();
            }
            return MasonryGridView.count(
              itemCount: controller.printOptionEntity.data.length,
              crossAxisCount: 2,
              mainAxisSpacing: $(4),
              crossAxisSpacing: $(4),
              itemBuilder: (context, index) {
                var data = controller.printOptionEntity.data[index];
                return PrintOptionItem(
                  data: data,
                ).intoGestureDetector(onTap: () {
                  Events.printGoodsSelectClick(source: widget.source, goodsId: data.id.toString());
                  Navigator.of(context).push<void>(Right2LeftRouter(
                      settings: RouteSettings(name: '/PrintScreen'),
                      child: PrintScreen(
                        optionData: data,
                        file: widget.file.path,
                        source: widget.source,
                      )));
                });
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PrintOptionController>();
    super.dispose();
  }
}
