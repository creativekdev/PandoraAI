import 'dart:convert';

import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum LoadType { URL, HTML_DATA }

class AppWebView extends StatefulWidget {
  String url;
  LoadType loadType;
  String source;

  static Future<dynamic> open(
    BuildContext context, {
    required String url,
    LoadType loadType = LoadType.URL,
    Key? key,
    required String source,
  }) async {
    return Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: '/AppWebView'),
      builder: (_) => AppWebView(
        url: url,
        loadType: loadType,
        source: source,
      ),
    ));
  }

  AppWebView({
    required this.url,
    required this.source,
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
    Posthog().screenWithUser(screenName: 'app_web_view');
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
    LogUtil.d(event, tag: 'JavascriptChannel');
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
          style: TextStyle(color: Colors.white),
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
          Events.webviewLoading(source: widget.source);
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
              name: "appShowToast",
              onMessageReceived: (JavascriptMessage message) {
                _onEventFinished("showToast", message.message);
                CommonExtension().showToast(message.message);
              }),
          JavascriptChannel(
              name: 'appPop',
              onMessageReceived: (JavascriptMessage message) async {
                _onEventFinished("appPop", message.message);
                Navigator.pop(context);
              }),
          JavascriptChannel(
              name: 'appJumpFunction',
              onMessageReceived: (JavascriptMessage message) async {
                _onEventFinished("appJumpFunction", message.message);
                try {
                  var json = jsonDecode(message.message);
                  var payload = jsonConvert.convert<AppFeaturePayload>(json);
                  HomeCardTypeUtils.jump(
                    context: context,
                    source: widget.source,
                    payload: payload,
                  );
                  Navigator.pop(context);
                } on FormatException catch (e) {}
              }),
        ].toSet(),
      ),
    );
  }
}
