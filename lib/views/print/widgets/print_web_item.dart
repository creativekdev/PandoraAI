import 'package:webview_flutter/webview_flutter.dart';

import '../../../Common/importFile.dart';

class PrintWebItem extends StatefulWidget {
  PrintWebItem({Key? key, required this.htmlString}) : super(key: key);
  final String htmlString;

  @override
  State<PrintWebItem> createState() => _PrintWebItemState();
}

class _PrintWebItemState extends State<PrintWebItem> {
  double webViewHeight = 300.0;
  WebViewController? _controller;

  var css = '<style>html, body p {font-size: 40px; color: white;}</style>';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: webViewHeight,
      color: ColorConstant.BackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: $(17)),
      child: WebView(
        backgroundColor: ColorConstant.BackgroundColor,
        initialUrl: 'about:blank',
        onWebViewCreated: (WebViewController controller) {
          _controller = controller;
          controller.loadUrl(Uri.dataFromString(
            "<html><head>$css</head><body>${widget.htmlString}</body></html>",
            mimeType: 'text/html',
          ).toString());
        },
        onPageFinished: (String url) async {
          _controller
              ?.evaluateJavascript(
            'document.documentElement.scrollHeight.toString()',
          )
              .then((result) {
            double newHeight = double.tryParse(result) ?? 0.0;
            setState(() {
              webViewHeight = newHeight;
            });
          });
        },
      ),
    );
  }
}
