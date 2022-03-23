import 'dart:io';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Common/instagram_constant.dart';
import '../Model/InstagramModel.dart';

class InstaLoginScreen extends StatefulWidget {
  const InstaLoginScreen({Key? key}) : super(key: key);

  @override
  _InstaLoginScreenState createState() => _InstaLoginScreenState();
}

class _InstaLoginScreenState extends State<InstaLoginScreen> {
  final InstagramModel instagram = InstagramModel();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleTextWidget(StringConstant.insta_login, ColorConstant.White, FontWeight.w600, 14.sp),
      ),
      body: SafeArea(
          child: WebView(
        initialUrl: InstagramConstant.instance.url,
        javascriptMode: JavascriptMode.unrestricted,
        gestureNavigationEnabled: true,
        navigationDelegate: (NavigationRequest request) async {
          if (request.url.startsWith(InstagramConstant.redirectUri)) {
            instagram.getAuthorizationCode(request.url);
            await instagram.getTokenAndUserID().then((isDone) {
              if (isDone) {
                instagram.getUserProfile().then((isDone) async {
                  print('${instagram.username} logged in!');
                  Navigator.pop(context, {
                    'token': instagram.authorizationCode.toString(),
                    'name': instagram.username.toString(),
                    'accessToken': instagram.accessToken.toString()
                  });
                });
              }
            });
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      )),
    );
  }
}
