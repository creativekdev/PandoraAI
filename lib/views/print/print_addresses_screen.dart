import 'package:cartoonizer/views/print/print_addresses_screen_controller.dart';
import 'package:cartoonizer/views/print/print_edit_address.dart';

import '../../Common/importFile.dart';
import '../../Widgets/app_navigation_bar.dart';
import '../../Widgets/router/routers.dart';
import '../../Widgets/state/app_state.dart';
import '../../images-res.dart';
import '../../models/address_entity.dart';

class PrintAddressScreen extends StatefulWidget {
  const PrintAddressScreen({Key? key, required this.source, required this.addresses}) : super(key: key);
  final String source;
  final List<AddressDataCustomerAddress> addresses;

  @override
  State<PrintAddressScreen> createState() => _PrintAddressScreenState();
}

class _PrintAddressScreenState extends AppState<PrintAddressScreen> {
  PrintAddressesScreenController controller = PrintAddressesScreenController();

  @override
  void initState() {
    super.initState();
    controller.addresses = widget.addresses;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
        appBar: AppNavigationBar(
          backgroundColor: Colors.transparent,
          middle: Text(
            S.of(context).addresses,
            style: TextStyle(
              color: Colors.white,
              fontSize: $(18),
            ),
          ),
        ),
        backgroundColor: ColorConstant.BackgroundColor,
        body: GetBuilder<PrintAddressesScreenController>(
            init: controller,
            builder: (controller) {
              return CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (content, index) {
                        AddressDataCustomerAddress address = controller.addresses[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (address.xDefault)
                                  Image.asset(
                                    Images.ic_recent_checked,
                                    width: $(20),
                                  ).intoPadding(
                                    padding: EdgeInsets.only(
                                      top: $(16),
                                      left: $(8),
                                    ),
                                  ),
                                TitleTextWidget(
                                  address.name,
                                  ColorConstant.White,
                                  FontWeight.w500,
                                  $(14),
                                ).intoPadding(
                                  padding: EdgeInsets.only(
                                    top: $(16),
                                    left: $(8),
                                  ),
                                ),
                                TitleTextWidget(
                                  address.phone,
                                  ColorConstant.White,
                                  FontWeight.w500,
                                  $(14),
                                ).intoPadding(
                                  padding: EdgeInsets.only(
                                    top: $(16),
                                    left: $(8),
                                  ),
                                ),
                                Spacer(),
                                Image.asset(
                                  Images.ic_edit,
                                  width: $(20),
                                  color: ColorConstant.White,
                                )
                                    .intoPadding(
                                  padding: EdgeInsets.only(
                                    top: $(16),
                                    right: $(8),
                                  ),
                                )
                                    .intoGestureDetector(onTap: () {
                                  Navigator.of(context)
                                      .push<AddressDataCustomerAddress>(Right2LeftRouter(
                                          settings: RouteSettings(name: '/PrintEditAddressScreen'),
                                          child: PrintEditAddressScreen(
                                            source: widget.source,
                                            address: address,
                                            index: index,
                                          )))
                                      .then((value) {});
                                }),
                              ],
                            ),
                            TitleTextWidget(
                              address.address1,
                              ColorConstant.White,
                              FontWeight.w500,
                              $(14),
                              align: TextAlign.left,
                              maxLines: 2,
                            ).intoPadding(
                              padding: EdgeInsets.only(
                                top: $(8),
                                left: $(36),
                                right: $(36),
                              ),
                            ),
                          ],
                        )
                            .intoContainer(
                          margin: EdgeInsets.only(top: $(8), left: $(16), right: $(16)),
                          height: $(96),
                          decoration: BoxDecoration(color: Color(0xFF1B1C1D), borderRadius: BorderRadius.circular($(8))),
                        )
                            .intoGestureDetector(onTap: () {
                          Navigator.of(context).pop(index);
                        });
                      },
                      childCount: controller.addresses.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: ColorConstant.White,
                        ),
                        SizedBox(
                          width: $(5),
                        ),
                        TitleTextWidget(
                          "Add New Address",
                          ColorConstant.White,
                          FontWeight.w500,
                          $(14),
                        )
                      ],
                    )
                        .intoContainer(
                            height: $(48),
                            decoration: BoxDecoration(
                              color: ColorConstant.BlueColor,
                              borderRadius: BorderRadius.circular($(8)),
                            ),
                            margin: EdgeInsets.only(
                              left: $(16),
                              right: $(16),
                              top: $(30),
                              bottom: $(50),
                            ))
                        .intoGestureDetector(onTap: () {
                      Navigator.of(context).push<void>(Right2LeftRouter(
                          settings: RouteSettings(name: '/PrintEditAddressScreen'),
                          child: PrintEditAddressScreen(
                            source: widget.source,
                          )));
                    }),
                  )
                ],
              );
            }));
  }
}
