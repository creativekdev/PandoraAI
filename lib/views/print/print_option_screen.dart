import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/print/print_option_controller.dart';
import 'package:cartoonizer/views/print/print_screen.dart';
import 'package:cartoonizer/views/print/widgets/print_option_item.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../Widgets/router/routers.dart';

class PrintOptionScreen extends StatefulWidget {
  PrintOptionScreen({Key? key, required this.file}) : super(key: key);
  File file;

  @override
  State<PrintOptionScreen> createState() => _PrintOptionScreenState();
}

class _PrintOptionScreenState extends State<PrintOptionScreen> {
  PrintOptionController controller = Get.put(PrintOptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Image.asset(
          Images.ic_back,
          width: $(24),
        )
            .intoContainer(
          margin: EdgeInsets.all($(14)),
        )
            .intoGestureDetector(onTap: () {
          Navigator.pop(context);
        }),
      ),
      backgroundColor: Colors.black,
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
                return PrintOptionItem(
                  data: controller.printOptionEntity.data[index],
                ).intoGestureDetector(onTap: () {
                  print(index);
                  Navigator.of(context).push<void>(Right2LeftRouter(
                      child: PrintScreen(
                    optionData: controller.printOptionEntity.data[index],
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
