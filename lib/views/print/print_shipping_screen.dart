import 'package:cartoonizer/views/print/print_addresses_screen.dart';
import 'package:cartoonizer/views/print/print_shipping_controller.dart';
import 'package:cartoonizer/views/print/widgets/print_delivery_item.dart';
import 'package:cartoonizer/views/print/widgets/print_submit_area.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:skeletons/skeletons.dart';

import '../../Common/importFile.dart';
import '../../Widgets/app_navigation_bar.dart';
import '../../Widgets/blank_area_intercept.dart';
import '../../Widgets/router/routers.dart';
import '../../Widgets/state/app_state.dart';

class PrintShippingScreen extends StatefulWidget {
  String source;

  PrintShippingScreen({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  State<PrintShippingScreen> createState() => _PrintShippingScreenState();
}

class _PrintShippingScreenState extends AppState<PrintShippingScreen> {
  PrintShippingController controller = PrintShippingController();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'print_shipping_screen');
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        middle: Text(
          S.of(context).shipping_details,
          style: TextStyle(
            color: Colors.white,
            fontSize: $(18),
          ),
        ),
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: GetBuilder<PrintShippingController>(
          init: controller,
          builder: (controller) {
            if (controller.viewInit == false) {
              return SkeletonListView(
                itemCount: 6,
                padding: EdgeInsets.zero,
                spacing: $(4),
                item: Column(
                  children: [
                    Row(
                      children: [
                        UnconstrainedBox(
                          child: SkeletonAvatar(
                              style: SkeletonAvatarStyle(
                            width: ScreenUtil.screenSize.width - $(15),
                            height: $(100),
                          )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: $(8),
                    )
                  ],
                ),
              );
            }
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: $(15)),
                  child: BlankAreaIntercept(
                    child: CustomScrollView(
                      controller: controller.scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: $(16),
                                color: ColorConstant.White,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleTextWidget(
                                    controller.seletedAddress != null ? "${controller.seletedAddress?.address1}${controller.seletedAddress?.address2}" : S.of(context).add_address,
                                    ColorConstant.White,
                                    FontWeight.bold,
                                    $(14),
                                    align: TextAlign.left,
                                    maxLines: 3,
                                  ).intoContainer(width: ScreenUtil.screenSize.width - $(96), padding: EdgeInsets.only(bottom: controller.seletedAddress != null ? $(10) : 0)),
                                  if (controller.seletedAddress != null)
                                    Row(
                                      children: [
                                        TitleTextWidget(
                                          "${controller.seletedAddress?.name}",
                                          ColorConstant.White,
                                          FontWeight.bold,
                                          $(14),
                                          align: TextAlign.left,
                                        ).intoContainer(padding: EdgeInsets.only(right: $(5))),
                                        TitleTextWidget(
                                          "${controller.seletedAddress?.phone}",
                                          ColorConstant.White,
                                          FontWeight.bold,
                                          $(14),
                                          align: TextAlign.left,
                                        )
                                      ],
                                    )
                                ],
                              ).intoContainer(
                                  padding: EdgeInsets.only(
                                right: $(5),
                                left: $(5),
                              )),
                              Spacer(),
                              Icon(
                                Icons.navigate_next,
                                size: $(24),
                                color: ColorConstant.White,
                              ),
                            ],
                          )
                              .intoContainer(
                                  padding: EdgeInsets.only(
                                    top: $(16),
                                    bottom: $(16),
                                    left: $(8),
                                    right: $(8),
                                  ),
                                  margin: EdgeInsets.only(
                                    top: $(16),
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1B1C1D),
                                    borderRadius: BorderRadius.circular($(8)),
                                  ))
                              .intoGestureDetector(onTap: () {
                            Navigator.of(context)
                                .push<int>(Right2LeftRouter(
                                    settings: RouteSettings(name: '/PrintAddressScreen'),
                                    child: PrintAddressScreen(
                                      source: widget.source,
                                      addresses: controller.addresses ?? [],
                                    )))
                                .then((value) {
                              controller.onUpdateAddress(value!);
                            });
                          }),
                        ),
                        SliverToBoxAdapter(
                          child: PrintDeliveryTitle(),
                        ),
                        ...controller.effectdatacontroller.data!.shippingMethods
                            .asMap()
                            .map(
                              (index, value) => MapEntry(
                                index,
                                SliverToBoxAdapter(
                                  child: PrintDeliveryitem(
                                    shippingMethodEntity: value,
                                    isSelected: index == controller.deliveryIndex,
                                  ).intoGestureDetector(
                                    onTap: () {
                                      controller.onTapDeliveryType(index);
                                    },
                                  ),
                                ),
                              ),
                            )
                            .values
                            .toList(),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: $(144),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PrintSubmitArea(
                  total: controller.total,
                  onTap: () async {
                    showLoading();
                    bool isSuccess = await controller.onSubmit(context);
                    if (isSuccess) {
                      await controller.gotoPaymentPage(context, widget.source);
                    }
                    hideLoading();
                  },
                ),
              ],
            );
          }),
    );
  }

  @override
  void dispose() {
    Get.delete<PrintShippingController>();
    super.dispose();
  }
}
