import 'package:cartoonizer/views/print/print_shipping_controller.dart';
import 'package:cartoonizer/views/print/widgets/print_delivery_item.dart';
import 'package:cartoonizer/views/print/widgets/print_input_item.dart';
import 'package:cartoonizer/views/print/widgets/print_submit_area.dart';
import 'package:google_maps_webservice/places.dart';

import '../../Common/importFile.dart';
import '../../Widgets/blank_area_intercept.dart';
import '../../images-res.dart';

class PrintShippingScreen extends StatefulWidget {
  const PrintShippingScreen({Key? key}) : super(key: key);

  @override
  State<PrintShippingScreen> createState() => _PrintShippingScreenState();
}

class _PrintShippingScreenState extends State<PrintShippingScreen> {
  final String googleMapApiKey = 'AIzaSyAb_K04sbhK0h7hDPeHlOcNPtlX059TxHk'; // 替换为你的 Google Maps API 密钥

  PrintShippingController controller = PrintShippingController();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    controller.searchAddressController.addListener(() {
      if (controller.searchAddressController.text.isNotEmpty) {
        showSearchResults();
      } else {
        hideSearchResults();
      }
    });
  }

  void searchLocation(GoogleMapsPlaces places, String text) async {
    // 进行地点搜索操作
    PlacesAutocompleteResponse response = await places.autocomplete(
      text, // 搜索关键字
      types: ['geocode'], // 限制搜索结果类型为地理编码（地址）
      language: 'en', // 搜索结果的语言
      components: [Component(Component.country, 'us')], // 限制搜索结果的条件
    );

    // 处理搜索结果
    if (response.isOkay) {
      for (Prediction prediction in response.predictions) {
        print(prediction.description);
      }
    } else {
      print(response.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleMapApiKey);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Shipping details".tr,
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
          Navigator.pop(context);
        }),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: $(15)),
            child: GetBuilder<PrintShippingController>(
              init: controller,
              builder: (controller) {
                return BlankAreaIntercept(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: TitleTextWidget("Address".tr, ColorConstant.White, FontWeight.w500, $(16), align: TextAlign.left)),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          title: 'Search address'.tr,
                          controller: controller.searchAddressController,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          title: 'Apartment/Suite/Othe'.tr,
                          controller: controller.apartmentController,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          title: 'First name'.tr,
                          controller: controller.firstNameController,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputItem(
                          title: 'Last name'.tr,
                          controller: controller.secondNameController,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: PrintInputContactItem(
                          title: 'Contact number'.tr,
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
                );
              },
            ),
          ),
          PrintSubmitArea(
            total: 56.75,
            onTap: () {
              // if (controller.onSubmit()) {
              //   Navigator.of(context).push<void>(Right2LeftRouter(child: PrintShippingScreen()));
              // }
            },
          ),
        ],
      ),
    );
  }

  void showSearchResults() {
    OverlayState? overlayState = Overlay.of(context);
    if (_overlayEntry == null && overlayState != null) {
      _overlayEntry = OverlayEntry(builder: (context) {
        return Positioned(
          top: $(131) + ScreenUtil.getNavigationBarHeight() + ScreenUtil.getStatusBarHeight() + $(48), // 输入框下方的偏移量，根据你的界面布局进行调整
          left: $(15),
          right: $(15),
          child: Material(
            // elevation: 4.0,
            child: Container(
              height:
                  ScreenUtil.screenSize.height - ($(131) + ScreenUtil.getNavigationBarHeight() + ScreenUtil.getStatusBarHeight() + $(48)) - ScreenUtil.getKeyboardHeight(context),
              // 悬浮面板的高度，根据你的需求进行调整
              color: Colors.black,
              child: ListView.builder(
                itemCount: 10, // 根据搜索结果的数量进行调整
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      'Search Result $index',
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // 处理选择的搜索结果
                      hideSearchResults();
                    },
                  );
                },
              ),
            ),
          ),
        );
      });

      overlayState.insert(_overlayEntry!);
    }
  }

  void hideSearchResults() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    Get.delete<PrintShippingController>();
    super.dispose();
  }
}
