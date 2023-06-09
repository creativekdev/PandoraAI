import 'package:webview_flutter/webview_flutter.dart';

import '../../Common/importFile.dart';
import '../../images-res.dart';

class PrintPaymentScreen extends StatefulWidget {
  const PrintPaymentScreen({Key? key, required this.payUrl}) : super(key: key);
  final String payUrl;

  @override
  State<PrintPaymentScreen> createState() => _PrintPaymentScreenState();
}

class _PrintPaymentScreenState extends State<PrintPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      backgroundColor: ColorConstant.BackgroundColor,
      body: Container(
        height: ScreenUtil.screenSize.height,
        width: ScreenUtil.screenSize.width,
        child: WebView(
          backgroundColor: ColorConstant.BackgroundColor,
          initialUrl: widget.payUrl,
        ),
      ),
    );
  }
}
