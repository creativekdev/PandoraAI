import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/webview/js_list.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/transfer/pick_photo_screen.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum LoadType { URL, HTML_DATA }

class AppWebView extends StatefulWidget {
  String url;
  LoadType loadType;

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
  ChoosePhotoScreenController controller = Get.put(ChoosePhotoScreenController());

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
    Get.delete<ChoosePhotoScreenController>();
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
        backIcon: Icon(
          Icons.arrow_back_ios,
          size: $(24),
          color: Colors.white,
        ),
        middle: Text(
          _title ?? '',
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: WebView(
        initialUrl: loadUri,
        //允许JS执行
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (c) {
          c.clearCache();
          _controller = c;
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
              name: "saveToAlbum",
              onMessageReceived: (JavascriptMessage message) {
                print("参数： ${message.message}");
                showLoading().whenComplete(() {
                  SyncNetworkImage(url: message.message).getImage().then((value) async {
                    var byteData = await value.image.toByteData(format: ImageByteFormat.png);
                    var int8list = byteData!.buffer.asUint8List();
                    await ImageGallerySaver.saveImage(
                      int8list,
                      quality: 100,
                      name: "Cartoonizer_${DateTime.now().millisecondsSinceEpoch}",
                    );
                    hideLoading();
                    CommonExtension().showImageSavedOkToast(context);
                    _controller.runJavascript(JsList.postToWebView("saveToAlbum", {'result': '1'}));
                  }).onError((error, stackTrace) {
                    hideLoading();
                    CommonExtension().showToast(error.toString());
                    _controller.runJavascript(JsList.postToWebView("saveToAlbum", {'result': '0'}));
                  });
                });
              }),
          JavascriptChannel(
              name: 'choosePhoto',
              onMessageReceived: (JavascriptMessage message) {
                debugPrint("参数： ${message.message}");
                PickPhotoScreen.push(context, controller: controller, onPickFromSystem: (takePhoto) async {
                  if (takePhoto) {
                    pickImage(context, from: "result", source: ImageSource.camera);
                  } else {
                    pickImage(context, from: "result", source: ImageSource.gallery);
                  }
                  return true;
                }, onPickFromRecent: (entity) async {
                  return await pickImage(context, from: "result", source: ImageSource.gallery, entity: entity);
                }, onPickFromAiSource: (file) async {
                  return await pickImage(context, from: "result", source: ImageSource.gallery, file: file);
                }, floatWidget: Container());
              }),
          JavascriptChannel(
              name: 'getPayStatus',
              onMessageReceived: (JavascriptMessage message) {
                debugPrint("参数： ${message.message}");
                UserManager userManager = AppDelegate().getManager();
                bool payStatus;
                if (userManager.isNeedLogin) {
                  payStatus = false;
                } else {
                  if (userManager.user!.userSubscription.isEmpty) {
                    payStatus = false;
                  } else {
                    payStatus = true;
                  }
                }
                _controller.runJavascript(JsList.postToWebView("getPayStatus", {'result': '${payStatus ? '1' : '0'}'}));
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

  Future<bool> pickImage(BuildContext context, {String from = "center", required ImageSource source, File? file, UploadRecordEntity? entity}) async {
    logEvent(Events.upload_photo, eventValues: {"method": "camera", "from": from});
    await showLoading();
    File? compressedImage;
    if (file != null) {
      compressedImage = await imageCompressAndGetFile(file);
      if (controller.image.value != null) {
        File oldFile = controller.image.value as File;
        if ((await md5File(oldFile)) == (await md5File(compressedImage))) {
          CommonExtension().showToast("You've chosen this photo already");
          await hideLoading();
          return false;
        }
      }
    } else if (entity == null) {
      XFile? image = await ImagePicker().pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
      if (image == null) {
        CommonExtension().showToast("cancelled");
        await hideLoading();
        return false;
      }
      compressedImage = await imageCompressAndGetFile(File(image.path));
    } else {
      controller.updateImageFile(File(entity.fileName));
    }
    if (compressedImage != null) {
      controller.updateImageFile(compressedImage);
    }
    controller.updateImageUrl("");
    var bool = await controller.uploadCompressedImage();
    await hideLoading();
    if (bool) {
      _controller.runJavascript(JsList.postToWebView("choosePhoto", {'result': controller.imageUrl.value}));
      return true;
    }
    return false;
  }
}

var testHtml = '<html>'
    '<head>'
    '<script>'
    'function showAppToast(msg){'
    'window.showToast.postMessage(msg);'
    '}'
    ''
    'function saveImage(){'
    'window.saveToAlbum.postMessage(\'https://fast-socialbook.s3.us-west-2.amazonaws.com/image_picker_89BBDCB3-7E91-4569-B59E-474B51EBD396-3211-0000013E819E445F.jpg\');'
    '}'
    ''
    'function chooseAppPhoto(){'
    'window.choosePhoto.postMessage(\'\');'
    '}'
    ''
    'function getAppPayStatus(){'
    'window.getPayStatus.postMessage(\'\');'
    '}'
    ''
    'function popAppRoute(){'
    'window.popRoute.postMessage(\'\');'
    '}'
    ''
    '</script>'
    '</head>'
    '<body style="background: black;">'
    '<div style="padding: 50px;">'
    '<h1 style="color: white;" onclick=showAppToast(\'test\')>showToast</h1>'
    '<h1 style="color: white;" onclick=saveImage()>saveToAlbum</h1>'
    '<h1 style="color: white;" onclick="chooseAppPhoto()">choosePhoto</h1>'
    '<h1 style="color: white;" onclick="getAppPayStatus()">getPayStatus</h1>'
    '<h1 style="color: white;" onclick="popAppRoute()">popRoute</h1>'
    '</div>'
    '</body>'
    '</html>';
