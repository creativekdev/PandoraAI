import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/print_option_entity.dart';
import 'package:cartoonizer/views/print/print_controller.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_select_item.dart';
import 'package:cartoonizer/views/print/widgets/print_web_item.dart';

import '../../Widgets/cacheImage/cached_network_image_utils.dart';

class PrintScreen extends StatefulWidget {
  PrintScreen({Key? key, required this.optionData}) : super(key: key);
  final PrintOptionData optionData;

  @override
  State<PrintScreen> createState() => _PrintScreenState(optionData: optionData);
}

class _PrintScreenState extends State<PrintScreen> {
  _PrintScreenState({required this.optionData}) {
    print(optionData);
    controller = Get.put(PrintController(optionData: optionData));
  }

  PrintOptionData optionData;
  late PrintController controller;

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
      body: GetBuilder<PrintController>(
        init: controller,
        builder: (controller) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                      top: $(8), left: $(16), right: $(16), bottom: $(8)),
                  child: TitleTextWidget(controller?.optionData.title ?? "",
                      ColorConstant.White, FontWeight.bold, $(12)),
                ),
              ),
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    CachedNetworkImageUtils.custom(
                      context: context,
                      imageUrl: controller?.optionData.thumbnail ?? "",
                      width: ScreenUtil.screenSize.width,
                      fit: BoxFit.fitWidth,
                    )
                  ],
                ).blankAreaIntercept(),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: $(8)),
              ),
              ...controller.showesed
                  .asMap()
                  .map((key, value) => MapEntry(
                        key,
                        SliverToBoxAdapter(
                          child: Column(children: [
                            PrintSelectItem(
                              title: value.keys.first,
                              content: controller.options[value.keys.first],
                              imgUrl: "Grey",
                            ).intoGestureDetector(onTap: () {
                              controller.onTapOptions(value);
                            }),
                            DividerLine(),
                            if (value.values.first)
                              PrintOptionsItem(
                                showMap: value,
                                options: controller.options[value.keys.first],
                                onSelectTitleTap: (map, value) {
                                  controller.onTapOption(map, value);
                                },
                              )
                          ]).intoContainer(
                            color: ColorConstant.EffectFunctionGrey,
                          ),
                          // child: value.values.first
                          //     ? PrintOptionsItem(
                          //         showMap: value,
                          //         options: controller.options[value.keys.first],
                          //         onSelectTitleTap: () {
                          //           controller.onTapOptions(value);
                          //         },
                          //       )
                          //     : PrintSelectItem(title: value.keys.first)
                          //         .intoGestureDetector(onTap: () {
                          //         controller.onTapOptions(value);
                          //       }),
                        ),
                      ))
                  .values
                  .toList(),
              SliverToBoxAdapter(child: SizedBox(height: $(16))),
              if (controller.product != null)
                SliverToBoxAdapter(
                    child: PrintWebItem(
                  htmlString:
                      controller.product?.data.rows.first.descriptionHtml ??
                          "<div></div>",
                )),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PrintController>();
    super.dispose();
  }
}
