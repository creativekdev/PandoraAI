import 'package:cartoonizer/views/print/print_shipping_controller.dart';
import 'package:cartoonizer/views/print/widgets/print_delivery_item.dart';
import 'package:cartoonizer/views/print/widgets/print_input_item.dart';
import 'package:cartoonizer/views/print/widgets/print_submit_area.dart';
import 'package:google_maps_webservice/places.dart';

import '../../Common/importFile.dart';
import '../../Widgets/blank_area_intercept.dart';
import '../../Widgets/state/app_state.dart';
import '../../images-res.dart';

class PrintShippingScreen extends StatefulWidget {
  const PrintShippingScreen({Key? key}) : super(key: key);

  @override
  State<PrintShippingScreen> createState() => _PrintShippingScreenState();
}

class _PrintShippingScreenState extends AppState<PrintShippingScreen> {
  PrintShippingController controller = PrintShippingController();

  @override
  void initState() {
    super.initState();
    controller.searchAddressController.addListener(() {
      controller.searchLocation(controller.places!, controller.searchAddressController.text).then((value) {
        if (controller.searchAddressController.text.isNotEmpty && controller.isResult == false) {
          hideSearchResults();
          showSearchResults();
        } else {
          hideSearchResults();
        }
        controller.isResult = false;
      });
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          S.of(context).shipping_details,
          style: TextStyle(
            color: Colors.white,
            fontSize: $(18),
          ),
        ),
        leading: Image.asset(
          Images.ic_back,
          width: $(24),
        )
            .intoContainer(
          margin: EdgeInsets.all($(14)),
        )
            .intoGestureDetector(onTap: () {
          hideSearchResults();
          Navigator.pop(context);
        }),
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: GetBuilder<PrintShippingController>(
        init: controller,
        builder: (controller) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: $(15)),
                child: BlankAreaIntercept(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: TitleTextWidget(S.of(context).address, ColorConstant.White, FontWeight.w500, $(16), align: TextAlign.left)),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          title: S.of(context).search_address,
                          controller: controller.searchAddressController,
                          completeCallback: () {
                            hideSearchResults();
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          title: S.of(context).apartment_suite_other,
                          controller: controller.apartmentController,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          title: S.of(context).first_name,
                          controller: controller.firstNameController,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          title: S.of(context).last_name,
                          controller: controller.secondNameController,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputContactItem(
                          title: S.of(context).contact_number,
                          controller: controller.contactNumberController,
                          regionCodeEntity: controller.regionEntity,
                          onTap: () {
                            controller.onTapRegion(context);
                          },
                        ),
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
                  bool isSuccess = await controller.onSubmit();
                  if (isSuccess) {
                    await controller.gotoPaymentPage(context);
                  }
                  hideLoading();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // 显示地理位置搜索结果
  void showSearchResults() {
    OverlayState? overlayState = Overlay.of(context);
    if (controller.overlayEntry == null && overlayState != null) {
      controller.overlayEntry = OverlayEntry(builder: (context) {
        return Positioned(
          top: $(131) + ScreenUtil.getNavigationBarHeight() + ScreenUtil.getStatusBarHeight() + $(48), // 输入框下方的偏移量，根据你的界面布局进行调整
          left: $(15),
          right: $(15),
          child: Material(
            child: Container(
              height:
                  ScreenUtil.screenSize.height - ($(131) + ScreenUtil.getNavigationBarHeight() + ScreenUtil.getStatusBarHeight() + $(48)) - ScreenUtil.getKeyboardHeight(context),
              // 悬浮面板的高度，根据你的需求进行调整
              color: ColorConstant.BackgroundColor,
              child: GetBuilder<PrintShippingController>(
                init: controller,
                builder: (controller) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: $(10)),
                    itemCount: controller.predictions.length, // 根据搜索结果的数量进行调整
                    itemBuilder: (context, index) {
                      Prediction prediction = controller.predictions[index];
                      return TitleTextWidget(
                        prediction.description ?? '',
                        ColorConstant.White,
                        FontWeight.normal,
                        $(12),
                        align: TextAlign.left,
                      )
                          .intoContainer(
                        height: $(40),
                      )
                          .intoGestureDetector(onTap: () {
                        controller.isResult = true;
                        controller.searchAddressController.text = prediction.description!;

                        FocusScope.of(context).unfocus();
                        // 处理选择的搜索结果
                        hideSearchResults();
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );
      });
      overlayState.insert(controller.overlayEntry!);
    }
  }

  // 隐藏地理位置搜索结果
  void hideSearchResults() {
    controller.overlayEntry?.remove();
    controller.overlayEntry = null;
  }

  @override
  void dispose() {
    Get.delete<PrintShippingController>();
    super.dispose();
  }
}
