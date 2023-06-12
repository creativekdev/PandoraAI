import 'package:cartoonizer/views/print/widgets/print_options_item.dart';

import '../../../Common/importFile.dart';
import '../../../images-res.dart';

class PrintOrderItem extends StatelessWidget {
  const PrintOrderItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              "Order ID: 1234567",
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
              Image.asset(
                Images.ic_ai_draw_camera,
                width: $(80),
                height: $(80),
              ).intoContainer(
                  decoration: BoxDecoration(
                color: Color(0xFFFB8888),
                borderRadius: BorderRadius.circular(8),
              )),
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
                          "T-shirt T-shirtT-shiT-shirt T-shirtT-shiT-shirt T-shirtT-shiT-shirt T-shirtT-shiT-shirt T-shirtT-shiT-shirt T-shirtT-shi",
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
                            TitleTextWidget("\$2.75", ColorConstant.White, FontWeight.normal, $(14), align: TextAlign.right),
                            TitleTextWidget("1 piece", ColorConstant.loginTitleColor, FontWeight.normal, $(14), align: TextAlign.right),
                          ],
                        ).intoContainer(
                          width: $(60),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TitleTextWidget("Paied", Color(0xFF30D158), FontWeight.normal, $(14), align: TextAlign.left),
                        TitleTextWidget("2023-02-22", ColorConstant.loginTitleColor, FontWeight.normal, $(14), align: TextAlign.right),
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
