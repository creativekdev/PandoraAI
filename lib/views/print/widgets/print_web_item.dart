import 'dart:convert';

import 'package:cartoonizer/Widgets/webview/js_list.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: webViewHeight,
      color: ColorConstant.BackgroundColor,
      child: WebView(
        backgroundColor: ColorConstant.BackgroundColor,
        initialUrl: Uri.dataFromString(widget.htmlString.html(), mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString(),
        javascriptMode: JavascriptMode.unrestricted,
        //inject method into dom
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: 'onSizeChanged',
              onMessageReceived: (JavascriptMessage message) {
                debugPrint("参数： ${message.message}");
                var map = jsonDecode(message.message);
                setState(() {
                  webViewHeight = double.parse(map['height'].toString());
                });
              }),
        ].toSet(),
        onWebViewCreated: (WebViewController controller) {
          _controller = controller;
        },
        onPageFinished: (String url) async {
          _controller?.runJavascript(JsList.getSizeChangedJavascript());
        },
      ),
    );
  }
}

extension _HtmlStringEx on String {
  String html() {
    return '<html><head>'
        '<meta charset=\'utf-8\'>'
        '<meta name=\'viewport\' id=\'viewport\' '
        'content=\'width=device-width,height=device-height,'
        'target-densitydpi=high-dpi,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no\'>'
        '</head>'
        '<style type=\'text/css\'>'
        'html, body p {color: white;}'
        '*{margin: 0;padding: 0;outline: none;cursor: pointer;}'
        '.main{width: 90%;margin:0 auto;}'
        'img{width: 100%;margin: 0;padding: 0;border: 0;}'
        'p:empty{line-height:0;}'
        'p{margin:10px 0;}'
        '</style>'
        '<body><div style="margin: 12px;">'
        '$this</div></body>'
        '</html>';
  }
}
