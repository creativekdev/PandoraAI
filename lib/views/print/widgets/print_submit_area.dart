import '../../../Common/importFile.dart';

class PrintSubmitArea extends StatefulWidget {
  const PrintSubmitArea({Key? key, required this.total, required this.onTap}) : super(key: key);
  final double total;
  final GestureTapCallback onTap;

  @override
  State<PrintSubmitArea> createState() => _PrintSubmitAreaState();
}

class _PrintSubmitAreaState extends State<PrintSubmitArea> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      // top: ScreenUtil.screenSize.height -
      //     $(144) -
      //     ScreenUtil.getNavigationBarHeight() -
      //     ScreenUtil.getStatusBarHeight() -
      //     ScreenUtil.getBottomPadding(context) -
      //     ScreenUtil.getBottomBarHeight(),
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
          height: $(144),
          color: Color.fromRGBO(00, 00, 00, 0.69),
          child: Column(
            children: [
              Row(
                children: [
                  TitleTextWidget(S.of(context).Subtotal, ColorConstant.White, FontWeight.w500, $(14)),
                  Spacer(),
                  PriceWidget(integerVale: getInt(widget.total), fractionValue: getDouble(widget.total)),
                ],
              ).intoContainer(
                padding: EdgeInsets.only(left: $(17), right: $(17), top: $(17)),
              ),
              SizedBox(
                height: $(20),
              ),
              TitleTextWidget(
                S.of(context).checkout,
                ColorConstant.White,
                FontWeight.w500,
                $(17),
              )
                  .intoContainer(
                alignment: Alignment.center,
                height: $(48),
                margin: EdgeInsets.only(left: $(17), right: $(17)),
                decoration: BoxDecoration(
                  color: ColorConstant.BlueColor,
                  borderRadius: BorderRadius.circular($(10)),
                ),
              )
                  .intoGestureDetector(onTap: () {
                widget.onTap();
              })
            ],
          )).blur(),
    );
  }
}

class PriceWidget extends StatelessWidget {
  PriceWidget({Key? key, required this.integerVale, required this.fractionValue}) : super(key: key);
  final String integerVale;
  final String fractionValue;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '\$', // 小数点后的数字
            style: TextStyle(fontSize: $(14), fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: integerVale, // 小数点前的数字
            style: TextStyle(fontSize: $(20), fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: '.$fractionValue', // 小数点后的数字
            style: TextStyle(fontSize: $(14), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// 获取一个double类型的整数部分
String getInt(double value) {
  return value.toInt().toString();
}

// 获取一个double类型的小数部分
String getDouble(double value) {
  String valueStr = value.toStringAsFixed(2).toString();
  return valueStr.split(".")[1].substring(0, 2);
}
