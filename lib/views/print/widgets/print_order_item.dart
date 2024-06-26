import 'dart:convert';

import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:common_utils/common_utils.dart';

import '../../../common/importFile.dart';
import '../../../widgets/cacheImage/cached_network_image_utils.dart';
import '../../../models/print_orders_entity.dart';

class PrintOrderItem extends StatelessWidget {
  PrintOrderItem({Key? key, required this.rows}) : super(key: key);
  PrintOrdersDataRows rows;

  @override
  Widget build(BuildContext context) {
    PrintOrdersDataRowsPayloadOrder order = PrintOrdersDataRowsPayloadOrder.fromJson(jsonDecode(rows.payload)["order"]);
    return Column(
      children: [
        SizedBox(
          height: $(16),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: $(16)),
          alignment: Alignment.centerLeft,
          height: $(164),
          color: Color(0xFF1B1C1D),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: $(12),
            ),
            TitleTextWidget(
              S.of(context).order_ID + " ${rows.shopifyOrderId}",
              ColorConstant.White,
              FontWeight.w500,
              $(17),
              align: TextAlign.left,
            ),
            SizedBox(
              height: $(12),
            ),
            DividerLine(
              left: 0,
              right: 0,
            ),
            SizedBox(
              height: $(16),
            ),
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular($(8)),
                child: CachedNetworkImageUtils.custom(
                  context: context,
                  imageUrl: rows.psPreviewImage,
                  width: $(80),
                  height: $(80),
                  fit: BoxFit.cover,
                ).intoContainer(
                    decoration: BoxDecoration(
                  color: Color(0xFFFB8888),
                  borderRadius: BorderRadius.circular($(8)),
                )),
              ),
              SizedBox(
                width: $(16),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TitleTextWidget(
                          "${rows.name}",
                          ColorConstant.White,
                          FontWeight.normal,
                          $(14),
                          maxLines: 2,
                          align: TextAlign.left,
                        ).intoContainer(
                          width: $(168),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TitleTextWidget("\$${rows.totalPrice}", ColorConstant.White, FontWeight.normal, $(14), align: TextAlign.right),
                            TitleTextWidget("${order.lineItems.first.quantity} piece", ColorConstant.loginTitleColor, FontWeight.normal, $(14), align: TextAlign.right),
                          ],
                        ).intoContainer(
                          width: $(60),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TitleTextWidget("${rows.financialStatus}", Color(0xFF30D158), FontWeight.normal, $(14), align: TextAlign.left),
                        TitleTextWidget("${DateUtil.formatDate(rows.created.timezoneCur, format: 'yyyy-MM-dd HH:mm')}", ColorConstant.loginTitleColor, FontWeight.normal, $(14),
                            align: TextAlign.right),
                      ],
                    )
                  ],
                ),
              )
            ])
          ]),
        ),
      ],
    );
  }
}
