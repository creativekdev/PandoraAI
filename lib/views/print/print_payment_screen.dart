import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:webview_flutter/webview_flutter.dart';

import '../../Common/importFile.dart';
import '../../config.dart';
import '../../models/print_order_entity.dart';

typedef CancelPayCallBack = void Function(String sessionId, String payUrl);
typedef PayCompleteCallBack = void Function(String sessionId, String payUrl);

class PrintPaymentScreen extends StatefulWidget {
  const PrintPaymentScreen({Key? key, required this.sessionId, required this.payUrl, required this.cancelPayCallBack, required this.payCompleteCallBack, required this.orderEntity})
      : super(key: key);
  final String sessionId;
  final String payUrl;
  final CancelPayCallBack cancelPayCallBack;
  final PayCompleteCallBack payCompleteCallBack;
  final PrintOrderEntity orderEntity;

  @override
  State<PrintPaymentScreen> createState() => _PrintPaymentScreenState();
}

class _PrintPaymentScreenState extends State<PrintPaymentScreen> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    final wsUrl = Uri(
      host: Config.instance.metagramSocket,
      scheme: Config.instance.metagramSocketSchema,
      port: Config.instance.metagramSocketPort,
      path: '/profile',
    );
    socket = IO.io(
        wsUrl.toString(),
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableReconnection() // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .setExtraHeaders({'origin': Config.instance.host}) // optional
            .enableForceNewConnection()
            .setQuery({
              'influencer_id': '${widget.sessionId}',
            })
            .build());
    socket?.onConnect((_) {
      print('127.0.0.1 connect');
    });
    socket?.onReconnect((_) {
      print('127.0.0.1 reconnect');
    });
    socket?.on('pay_complete', (data) {
      print('127.0.0.1 ==== Received event: $data');
      // 跳转成功界面
      widget.payCompleteCallBack(widget.sessionId, widget.payUrl);
    });
    socket?.onDisconnect((data) {
      print("127.0.0.1 ==== Disconnected $data");
    });
    socket?.connect();
  }

  @override
  Widget build(BuildContext context) {
    print("127.0.0.1 ==== ${widget.payUrl}");
    print("127.0.0.1 ==== ${widget.sessionId}");
    return WillPopScope(
      onWillPop: () async {
        // 跳转取消界面
        widget.cancelPayCallBack(widget.sessionId, widget.payUrl);
        return false;
      },
      child: Scaffold(
        appBar: AppNavigationBar(
          brightness: Brightness.light,
          visible: false,
        ),
        backgroundColor: ColorConstant.BackgroundColor,
        body: SingleChildScrollView(
          child: Container(
            height: ScreenUtil.screenSize.height,
            width: ScreenUtil.screenSize.width,
            child: WebView(
              navigationDelegate: (NavigationRequest request) async {
                // 处理取消逻辑
                if (request.url.contains("https://socialbook.io/pay_success_screen")) {
                  widget.payCompleteCallBack(widget.sessionId, widget.payUrl);
                  return NavigationDecision.prevent;
                }
                if (request.url.contains("https://socialbook.io/pay_cancel_screen")) {
                  widget.cancelPayCallBack(widget.sessionId, widget.payUrl);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              // backgroundColor: ColorConstant.BackgroundColor,
              initialUrl: widget.payUrl,
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }
}
