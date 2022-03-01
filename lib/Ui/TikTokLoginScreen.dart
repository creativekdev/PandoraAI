import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TikTokLoginScreen extends StatefulWidget {

  final url;

  const TikTokLoginScreen({Key? key, required this.url}) : super(key: key);

  @override
  _TikTokLoginScreenState createState() => _TikTokLoginScreenState();
}

class _TikTokLoginScreenState extends State<TikTokLoginScreen> {

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleTextWidget(
            StringConstant.tiktok_login,
            ColorConstant.White,
            FontWeight.w600,
            14.sp),
      ),
      body: SafeArea(child: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        gestureNavigationEnabled: true,
        navigationDelegate: (NavigationRequest request) async {
          if(request.url.startsWith("https://open-api.tiktok.com/oauth/authorize/callback")) {
            Navigator.pop(context, {'code' : '${Uri.parse(request.url).queryParameters['code']}'});
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      )),
    );
  }
}
