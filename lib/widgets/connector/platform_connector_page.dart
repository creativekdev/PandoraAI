import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/auth/auth.dart';
import 'package:cartoonizer/widgets/auth/auth_api.dart';
import 'package:cartoonizer/widgets/auth/connector_platform.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/instagram_constant.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/InstagramModel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlatformConnectorPage {
  static Future<bool?> push(
    BuildContext context, {
    required ConnectorPlatform platform,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        settings: RouteSettings(name: '/_PlatformConnectorPage'),
        builder: (context) => _PlatformConnectorPage(platform: platform),
      ),
    );
  }
}

class _PlatformConnectorPage extends StatefulWidget {
  ConnectorPlatform platform;

  _PlatformConnectorPage({
    Key? key,
    required this.platform,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PlatformConnectorState();
  }
}

class PlatformConnectorState extends AppState<_PlatformConnectorPage> {
  WebViewController? controller;
  late ConnectorPlatform platform;
  bool _isWebAuth = false;
  Auth auth = Auth();
  late AuthApi authApi;

  InstagramModel? instagram;

  @override
  void initState() {
    super.initState();
    authApi = AuthApi().bindState(this);
    platform = widget.platform;
    _isWebAuth = platform == ConnectorPlatform.instagram;
    delay(() {
      switch (platform) {
        case ConnectorPlatform.youtube:
          showLoading().whenComplete(() {
            auth.signInWithYoutube().then((value) {
              if (value.credential == null) {
                hideLoading();
                Navigator.of(context).pop(false);
              } else {
                authApi.connectWithYoutube(value.token!).then((value) {
                  hideLoading().whenComplete(() {
                    if (value != null) {
                      Navigator.of(context).pop(true);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  });
                });
              }
            });
          });
          break;
        case ConnectorPlatform.facebook:
          showLoading().whenComplete(() {
            auth.signInWithFacebook().then((value) {
              if (value.token == null) {
                hideLoading();
                Navigator.of(context).pop(false);
              } else {
                authApi.connectWithFacebook(value.token!).then((value) {
                  hideLoading().whenComplete(() {
                    if (value != null) {
                      Navigator.of(context).pop(true);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  });
                });
              }
            });
          });
          break;
        case ConnectorPlatform.instagramBusiness:
          showLoading().whenComplete(() {
            auth.signInWithFacebook().then((value) {
              if (value.token == null) {
                hideLoading();
                Navigator.of(context).pop(false);
              } else {
                authApi.connectWithInstagramBusiness(value.token!).then((value) {
                  hideLoading().whenComplete(() {
                    if (value != null) {
                      Navigator.of(context).pop(true);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  });
                });
              }
            });
          });
          break;
        case ConnectorPlatform.tiktok:
          showLoading().whenComplete(() {
            auth.signInWithTiktok().then((value) {
              if (value == null) {
                hideLoading();
                Navigator.of(context).pop(false);
              } else {
                authApi.connectWithTiktok(value.accessToken, value.openId, value.tempData).then((value) {
                  hideLoading().whenComplete(() {
                    if (value != null) {
                      Navigator.of(context).pop(true);
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  });
                });
              }
            });
          });
          break;
        case ConnectorPlatform.instagram:
          break;
        case ConnectorPlatform.UNDEFINED:
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    authApi.unbind();
  }

  connectToPlatformWithWebview() {
    if (platform == ConnectorPlatform.instagram) {
      instagram = InstagramModel();
      controller!.loadUrl(
        InstagramConstant.instance.url,
      );
    } else if (platform == ConnectorPlatform.tiktok) {}
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.White,
      appBar: AppNavigationBar(
        brightness: Brightness.light,
        backIcon: Image.asset(
          Images.ic_back,
          height: $(24),
          width: $(24),
          color: Colors.black,
        ),
        middle: TitleTextWidget(S.of(context).platform_connecting, ColorConstant.White, FontWeight.w600, $(18)),
      ),
      body: (_isWebAuth)
          ? WebView(
              backgroundColor: Colors.white,
              onWebViewCreated: (controller) {
                this.controller = controller;
                controller.clearCache().whenComplete(() {
                  connectToPlatformWithWebview();
                });
              },
              javascriptMode: JavascriptMode.unrestricted,
              gestureNavigationEnabled: true,
              navigationDelegate: (NavigationRequest request) async {
                return await onNaviRequest(request);
              },
            )
          : Container(
              width: double.maxFinite,
              height: double.maxFinite,
            ),
    );
  }

  Future<NavigationDecision> onNaviRequest(NavigationRequest request) async {
    if (platform == ConnectorPlatform.instagram) {
      if (request.url.startsWith(InstagramConstant.redirectUri)) {
        instagram!.getAuthorizationCode(request.url);
        await showLoading();
        var isDone = await instagram!.getTokenAndUserID();
        if (isDone) {
          await instagram!.getUserProfile();
          var baseEntity = await authApi.connectWithInstagram(instagram!.accessToken ?? '');
          await AppDelegate().getManager<UserManager>().refreshConnections();
          await hideLoading();
          Navigator.of(context).pop(baseEntity != null);
        } else {
          CommonExtension().showToast('Authed failed');
          await hideLoading();
          Navigator.pop(context, false);
        }
        return NavigationDecision.prevent;
      }
    } else if (platform == ConnectorPlatform.tiktok) {}
    return NavigationDecision.navigate;
  }
}
