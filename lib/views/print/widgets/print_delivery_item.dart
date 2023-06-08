import 'package:cartoonizer/views/print/widgets/print_options_item.dart';

import '../../../Common/importFile.dart';
import '../../../images-res.dart';
import '../../../models/shipping_method_entity.dart';

class PrintDeliveryitem extends StatelessWidget {
  PrintDeliveryitem({Key? key, required this.shippingMethodEntity, this.isSelected = false}) : super(key: key);
  ShippingMethodEntity shippingMethodEntity;
  bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: $(8)),
        Container(
          height: $(64),
          decoration: BoxDecoration(
            color: ColorConstant.EffectCardColor,
            borderRadius: BorderRadius.circular($(8)),
          ),
          child: Row(
            children: [
              SizedBox(width: $(16)),
              isSelected
                  ? Image.asset(Images.ic_recent_checked, width: $(16)).blur()
                  : Container(
                      width: $(16),
                      height: $(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ).blur(),
              SizedBox(width: $(16)),
              Image.asset(
                Images.ic_delivery,
                width: $(24),
                height: $(24),
              ).intoContainer(
                  width: $(40),
                  height: $(40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFB956),
                    borderRadius: BorderRadius.circular($(4)),
                  )),
              SizedBox(width: $(8)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TitleTextWidget(
                        shippingMethodEntity.shippingRateData.displayName.tr,
                        ColorConstant.White,
                        FontWeight.bold,
                        $(14),
                        align: TextAlign.left,
                      ),
                      TitleTextWidget(
                        "\$${shippingMethodEntity.shippingRateData.fixedAmount.amount / 100.0}".tr,
                        ColorConstant.White,
                        FontWeight.bold,
                        $(14),
                        align: TextAlign.right,
                      ),
                    ],
                  ).intoContainer(
                    width: $(245),
                    padding: EdgeInsets.only(right: $(12)),
                  ),
                  TitleTextWidget(
                    shippingMethodEntity.shippingRateData.type.tr,
                    ColorConstant.White,
                    FontWeight.normal,
                    $(12),
                    align: TextAlign.left,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PrintDeliveryTitle extends StatelessWidget {
  const PrintDeliveryTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: $(24)),
        DividerLine(
          left: 0,
        ),
        SizedBox(height: $(16)),
        TitleTextWidget(
          "Shipping & Delivery".tr,
          ColorConstant.White,
          FontWeight.normal,
          $(16),
          align: TextAlign.left,
        ),
        TitleTextWidget(
          "Last name".tr,
          ColorConstant.White,
          FontWeight.normal,
          $(14),
          align: TextAlign.left,
        ),
      ],
    );
  }
}
