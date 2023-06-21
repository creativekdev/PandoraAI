import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:webview_flutter/webview_flutter.dart';

import '../../Common/importFile.dart';
import '../../config.dart';
import '../../models/print_order_entity.dart';

class PrintPaymentScreen extends StatefulWidget {
  String source;
  final String sessionId;
  final String payUrl;
  final PrintOrderEntity orderEntity;

  PrintPaymentScreen({
    Key? key,
    required this.sessionId,
    required this.payUrl,
    required this.orderEntity,
    required this.source,
  }) : super(key: key);

  @override
  State<PrintPaymentScreen> createState() => _PrintPaymentScreenState();
}

class _PrintPaymentScreenState extends State<PrintPaymentScreen> {
  late IO.Socket socket;
  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'print_payment_screen');
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
    socket?.onConnect((_) {});
    socket?.onReconnect((_) {});
    socket?.on('pay_complete', (data) {
      // 跳转成功界面
      Navigator.of(context).pop(true);
    });

    socket?.onDisconnect((data) {});
    socket?.connect();
    socket?.onError((data) {
      // 跳转失败界面
      Navigator.of(context).pop(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 跳转取消界面
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
          return false;
        }
        Navigator.of(context).pop(false);
        return false;
      },
      child: Scaffold(
        appBar: AppNavigationBar(
          brightness: Brightness.light,
          visible: false,
        ),
        backgroundColor: ColorConstant.BackgroundColor,
        body: Container(
          height: double.infinity,
          width: ScreenUtil.screenSize.width,
          child: WebView(
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            navigationDelegate: (NavigationRequest request) async {
              if (request.url.startsWith(ALIPAY_SCHEML_ANDROID) || request.url.startsWith(ALIPAY_SCHEML_IOS)) {
                launchURL(request.url, force: true);
                return NavigationDecision.prevent;
              }
              // 处理取消逻辑
              if (request.url.contains(Config.instance.successUrl)) {
                return NavigationDecision.prevent;
              }
              if (request.url.contains(Config.instance.cancelUrl)) {
                Navigator.of(context).pop(false);
              }
              return NavigationDecision.navigate;
            },
            initialUrl: widget.payUrl,
            javascriptMode: JavascriptMode.unrestricted,
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
