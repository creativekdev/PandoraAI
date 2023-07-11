import 'dart:convert';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum LoadType { URL, HTML_DATA }

class AppWebView extends StatefulWidget {
  String url;
  LoadType loadType;

  static Future<dynamic> open(
    BuildContext context, {
    required String url,
    LoadType loadType = LoadType.URL,
    Key? key,
  }) async {
    return Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: '/AppWebView'),
      builder: (_) => AppWebView(url: url, loadType: loadType),
    ));
  }

  AppWebView({
    required this.url,
    this.loadType = LoadType.URL,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AppWebViewState();
  }
}

class AppWebViewState extends AppState<AppWebView> {
  late WebViewController _controller;
  late String loadUri;
  String? _title;
  double progress = 0;

  @override
  initState() {
    super.initState();
    if (widget.loadType == LoadType.URL) {
      loadUri = widget.url;
    } else {
      loadUri = Uri.dataFromString(widget.url, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString();
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  ///事件通知，js端调用flutter方法执行的结果，通过此方法回调
  _onEventFinished(String key, String value) {
    var event = {"method": "$key", "data": "$value"};
    var string = json.encode(event).toString();
    // _controller.evaluateJavascript("window.postMessage($string, '*')");
  }

  Future<bool> _onBackPressured() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    } else {
      return true;
    }
  }

  _setTitle(String? title) {
    if (title == null) {
      title = '';
    }
    if (title.startsWith("\"")) {
      title = title.substring(1, title.length);
    }
    if (title.endsWith("\"")) {
      title = title.substring(0, title.length - 1);
    }
    setState(() {
      _title = title!;
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        backAction: () async {
          if (await _onBackPressured()) {
            Navigator.pop(context);
          }
        },
        middle: Text(
          _title ?? '',
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.close_rounded,
          color: Colors.white,
          size: $(24),
        )
            .intoContainer(
          padding: EdgeInsets.only(top: $(8), bottom: $(8), left: $(8)),
          color: Colors.transparent,
        )
            .intoGestureDetector(onTap: () {
          Navigator.pop(context);
        }),
        child: PreferredSize(
          child: LinearProgressIndicator(
            backgroundColor: Colors.white70.withOpacity(0),
            value: progress == 1.0 ? 0 : progress,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          preferredSize: Size.fromHeight(3.0),
        ),
        childHeight: 4.0,
      ),
      body: WebView(
        initialUrl: loadUri,
        backgroundColor: Colors.transparent,
        //允许JS执行
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (c) {
          c.clearCache();
          _controller = c;
        },
        onProgress: (int pro) {
          if (mounted) {
            setState(() {
              progress = (pro / 100.0);
            });
          }
        },
        //页面加载完成，这里更新title
        onPageFinished: (url) {
          if (widget.loadType == LoadType.URL) {
            _controller.getTitle().then((value) => _setTitle(value));
          }
        },
        //向js开放方法
        javascriptChannels: <JavascriptChannel>[
          JavascriptChannel(
              name: "showToast",
              onMessageReceived: (JavascriptMessage message) {
                print("参数： ${message.message}");
                CommonExtension().showToast(message.message);
                _onEventFinished("showToast", "执行结束");
              }),
          JavascriptChannel(
              name: 'popRoute',
              onMessageReceived: (JavascriptMessage message) async {
                debugPrint("参数： ${message.message}");
                Navigator.pop(context);
              }),
        ].toSet(),
      ),
    );
  }
}
