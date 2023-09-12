import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/models/print_option_entity.dart';
import 'package:cartoonizer/views/print/print_controller.dart';
import 'package:cartoonizer/views/print/print_shipping_screen.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_quatity_item.dart';
import 'package:cartoonizer/views/print/widgets/print_select_item.dart';
import 'package:cartoonizer/views/print/widgets/print_submit_area.dart';
import 'package:cartoonizer/views/print/widgets/print_web_item.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../widgets/app_navigation_bar.dart';
import '../../widgets/cacheImage/cached_network_image_utils.dart';
import '../../widgets/router/routers.dart';
import '../../app/app.dart';
import '../../app/user/user_manager.dart';

class PrintScreen extends StatefulWidget {
  String source;
  final PrintOptionData optionData;
  final String file;

  PrintScreen({
    Key? key,
    required this.optionData,
    required this.file,
    required this.source,
  }) : super(key: key);

  @override
  State<PrintScreen> createState() => PrintScreenState();
}

class PrintScreenState extends AppState<PrintScreen> {
  late PrintOptionData optionData;
  late String file;
  late PrintController controller;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'print_screen');
    optionData = widget.optionData;
    file = widget.file;
    controller = Get.put(PrintController(optionData: optionData, file: file, screenState: this));
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: GetBuilder<PrintController>(
        init: controller,
        builder: (controller) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(top: $(8), left: $(16), right: $(16), bottom: $(8)),
                      child: TitleTextWidget(
                        controller?.optionData.title ?? "",
                        ColorConstant.White,
                        FontWeight.bold,
                        $(24),
                        maxLines: 10,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: RepaintBoundary(
                      key: controller.repaintKey,
                      child: Stack(
                        children: [
                          CachedNetworkImageUtils.custom(
                            context: context,
                            useOld: false,
                            imageUrl: controller.imgUrl,
                            width: ScreenUtil.screenSize.width,
                            fit: BoxFit.fitWidth,
                          ).intoContainer(
                            width: ScreenUtil.screenSize.width,
                            height: controller.imgSize.height,
                          ),
                          Image.file(
                            File(controller.file!),
                            width: controller.size.width,
                            height: controller.size.height,
                            fit: BoxFit.contain,
                          ).intoContainer(
                              margin: EdgeInsets.only(
                            top: controller.origin.dy,
                            left: controller.origin.dx,
                          ))
                        ],
                      ).blankAreaIntercept(),
                    ),
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
                                  content: controller.selectOptions[value.keys.first] ?? '',
                                  imgUrl: controller.imgUrl,
                                  showImage: value.keys.first.toLowerCase() == "color" && controller.selectOptions[value.keys.first] != null,
                                ).intoGestureDetector(onTap: () {
                                  controller.onTapOptions(value, key);
                                }),
                                DividerLine(),
                                if (value.values.first)
                                  PrintOptionsItem(
                                    showMap: value,
                                    content: controller.selectOptions[value.keys.first] ?? '',
                                    options: controller.options[value.keys.first],
                                    onSelectTitleTap: (map, value) {
                                      controller.onTapOption(map, value);
                                    },
                                  )
                              ]),
                            ),
                          ))
                      .values
                      .toList(),
                  SliverToBoxAdapter(
                    child: PrintQuatityItem(
                      quantity: "${controller.quantity}",
                      onAddTap: () {
                        controller.onAddTap();
                      },
                      onSubTap: () {
                        controller.onSubTap();
                      },
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: $(16))),
                  if (controller.product != null)
                    SliverToBoxAdapter(
                        child: PrintWebItem(
                      htmlString: controller.product?.data.rows.first.descriptionHtml ?? "<div></div>",
                    )),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: $(144),
                    ),
                  ),
                ],
              ),
              PrintSubmitArea(
                total: controller.total,
                onTap: () async {
                  showLoading();
                  bool isSuccess = await controller.onSubmit(context);
                  if (isSuccess) {
                    UserManager userManager = AppDelegate().getManager();
                    userManager.doOnLogin(
                      context,
                      logPreLoginAction: 'print_shipping_screen',
                      callback: () {
                        hideLoading();
                        Events.printCreateOrder(source: widget.source);
                        Navigator.of(context).push<void>(Right2LeftRouter(
                            settings: RouteSettings(name: '/PrintShippingScreen'),
                            child: PrintShippingScreen(
                              source: widget.source,
                            )));
                      },
                      autoExec: true,
                      onCancel: () {
                        hideLoading();
                      },
                    );
                  } else {}
                  hideLoading();
                },
              ),
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
