import 'package:cartoonizer/views/print/print_edit_address_controller.dart';
import 'package:cartoonizer/views/print/widgets/print_input_item.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:skeletons/skeletons.dart';

import '../../common/importFile.dart';
import '../../widgets/app_navigation_bar.dart';
import '../../widgets/blank_area_intercept.dart';
import '../../widgets/state/app_state.dart';
import '../../models/address_entity.dart';
import '../common/region/select_region_page.dart';

class PrintEditAddressScreen extends StatefulWidget {
  String source;
  AddressDataCustomerAddress? address;
  int? index;

  PrintEditAddressScreen({Key? key, required this.source, this.address, this.index}) : super(key: key);

  @override
  State<PrintEditAddressScreen> createState() => _PrintEditAddressScreenState(address);
}

class _PrintEditAddressScreenState extends AppState<PrintEditAddressScreen> {
  _PrintEditAddressScreenState(this.address);

  AddressDataCustomerAddress? address;
  late PrintEditAddressController controller;

  @override
  void initState() {
    super.initState();
    controller = PrintEditAddressController(address: address);
    Posthog().screenWithUser(screenName: 'print_edit_address_screen');
    controller.searchAddressController.addListener(() {
      controller.searchLocation(controller.places, controller.searchAddressController.text).then((value) {
        if (controller.searchAddressController.text.isNotEmpty && controller.isResult == false) {
          hideSearchResults();
          if (controller.searchAddressFocusNode.hasFocus) {
            showSearchResults();
          }
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
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        middle: Text(
          S.of(context).edit_address,
          style: TextStyle(
            color: Colors.white,
            fontSize: $(18),
          ),
        ),
        backAction: () {
          Navigator.pop(context);
          controller.searchAddressFocusNode.unfocus();
          hideSearchResults();
        },
        trailing: widget.address == null
            ? SizedBox()
            : TitleTextWidget(S.of(context).delete, ColorConstant.Red, FontWeight.w400, $(14)).intoGestureDetector(
                onTap: () async {
                  showLoading();
                  bool isSuccess = await controller.onDeleteAddress(context);
                  if (isSuccess) {
                    Navigator.of(context).pop();
                  }
                  hideLoading();
                },
              ),
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: GetBuilder<PrintEditAddressController>(
        init: controller,
        builder: (controller) {
          if (controller.viewInit == false) {
            return SkeletonListView(
              itemCount: 30,
              padding: EdgeInsets.symmetric(horizontal: $(15)),
              spacing: $(4),
              item: Column(
                children: [
                  Row(
                    children: [
                      UnconstrainedBox(
                        child: SkeletonAvatar(
                            style: SkeletonAvatarStyle(
                          width: ScreenUtil.screenSize.width - $(30),
                          height: $(50),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: $(15),
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
                      controller.isShowSate
                          ? SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  PrintInputItem(
                                    width: (ScreenUtil.screenSize.width - $(45)) / 2,
                                    title: S.of(context).country_region,
                                    controller: controller.countryController,
                                    canEdit: false,
                                    onTap: () {
                                      controller.onTapRegion(context, SelectRegionType.country);
                                      hideSearchResults();
                                    },
                                  ),
                                  SizedBox(
                                    width: $(15),
                                  ),
                                  PrintInputItem(
                                    width: (ScreenUtil.screenSize.width - $(45)) / 2,
                                    title: S.of(context).STATE,
                                    controller: controller.stateController,
                                    canEdit: false,
                                    onTap: () {
                                      controller.onTapState(context);
                                      hideSearchResults();
                                    },
                                  ),
                                ],
                              ),
                            )
                          : SliverToBoxAdapter(
                              child: PrintInputItem(
                                width: ScreenUtil.screenSize.width - $(30),
                                title: S.of(context).country_region,
                                controller: controller.countryController,
                                canEdit: false,
                                onTap: () {
                                  controller.onTapRegion(context, SelectRegionType.country);
                                  hideSearchResults();
                                },
                              ),
                            ),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          width: ScreenUtil.screenSize.width - $(30),
                          title: S.of(context).search_address,
                          controller: controller.searchAddressController,
                          focusNode: controller.searchAddressFocusNode,
                          completeCallback: () {
                            hideSearchResults();
                          },
                          onTap: () {
                            controller.scrollController.animateTo(
                              $(110),
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear,
                            );
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          width: ScreenUtil.screenSize.width - $(30),
                          title: S.of(context).apartment_suite_other,
                          controller: controller.apartmentController,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Row(
                          children: [
                            PrintInputItem(
                              width: (ScreenUtil.screenSize.width - $(45)) / 2,
                              title: S.of(context).first_name,
                              controller: controller.firstNameController,
                            ),
                            SizedBox(
                              width: $(15),
                            ),
                            PrintInputItem(
                              width: (ScreenUtil.screenSize.width - $(45)) / 2,
                              title: S.of(context).last_name,
                              controller: controller.secondNameController,
                            )
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Row(
                          children: [
                            PrintInputItem(
                              width: (ScreenUtil.screenSize.width - $(45)) / 2,
                              title: S.of(context).city,
                              controller: controller.cityController,
                            ),
                            SizedBox(
                              width: $(15),
                            ),
                            PrintInputItem(
                              width: (ScreenUtil.screenSize.width - $(45)) / 2,
                              title: S.of(context).zip_code,
                              controller: controller.zipCodeController,
                            )
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputContactItem(
                          title: S.of(context).contact_number,
                          controller: controller.contactNumberController,
                          regionCodeEntity: controller.regionEntity,
                          onTap: () {
                            controller.onTapRegion(context, SelectRegionType.callingCode);
                          },
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(top: $(119), bottom: $(60)),
                        sliver: SliverToBoxAdapter(
                          child: TitleTextWidget(S.of(context).save, ColorConstant.White, FontWeight.w500, $(17))
                              .intoContainer(
                            alignment: Alignment.center,
                            height: $(48),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular($(10)), color: ColorConstant.BlueColor),
                          )
                              .intoGestureDetector(onTap: () async {
                            showLoading();

                            await controller.onSubmit(context);
                            hideLoading();
                          }),
                        ),
                      )
                    ],
                  ),
                ),
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
          top: $(120) + ScreenUtil.getNavigationBarHeight() + ScreenUtil.getStatusBarHeight(), // 输入框下方的偏移量，根据你的界面布局进行调整
          left: $(15),
          right: $(15),
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: ScreenUtil.screenSize.height - ($(120) + ScreenUtil.getNavigationBarHeight() + ScreenUtil.getStatusBarHeight()) - ScreenUtil.getKeyboardHeight(context),
              // 悬浮面板的高度，根据你的需求进行调整
              child: GetBuilder<PrintEditAddressController>(
                init: controller,
                builder: (controller) {
                  return ListView.builder(
                    // padding: EdgeInsets.symmetric(horizontal: $(10)),
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
                        color: ColorConstant.BackgroundColor,
                        padding: EdgeInsets.symmetric(horizontal: $(10)),
                        height: $(40),
                      )
                          .intoGestureDetector(onTap: () async {
                        PlacesDetailsResponse detail = await controller.places.getDetailsByPlaceId(prediction.placeId!);
                        controller.zipCodeController.text = controller.getZipCode(detail.result.addressComponents);
                        controller.cityController.text = controller.getCityName(detail.result.addressComponents);
                        controller.setStateEntity(detail.result.addressComponents);
                        controller.isResult = true;
                        controller.searchAddressController.text = prediction.description!;
                        controller.formattedAddress = detail.result.formattedAddress!;
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
    Get.delete<PrintEditAddressController>();
    super.dispose();
  }
}
