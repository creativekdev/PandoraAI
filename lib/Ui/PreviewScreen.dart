import 'dart:convert';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/sToken.dart';
import 'package:cartoonizer/Model/JsonValueModel.dart';
import 'package:http/http.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'LoginScreen.dart';
import 'PurchaseScreen.dart';
import 'ShareScreen.dart';

class PreviewScreen extends StatefulWidget {
  final String image, url, algoName;

  const PreviewScreen(
      {Key? key,
      required this.image,
      required this.url,
      required this.algoName})
      : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with WidgetsBindingObserver {
  late SharedPreferences sharedPrefs;
  bool isLoading = false;
  bool isShowLoading = false;
  bool isVisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: LoadingOverlay(
            isLoading: isShowLoading,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => {Navigator.pop(context)},
                        child: Image.asset(
                          ImagesConstant.ic_back_dark,
                          height: 10.w,
                          width: 10.w,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await ImageGallerySaver.saveImage(
                              base64Decode(widget.image),
                              quality: 100,
                              name:
                                  "Cartoonizer_${DateTime.now().millisecondsSinceEpoch}");
                          CommonExtension().showToast("Image Saved!");
                        },
                        child: Image.asset(
                          ImagesConstant.ic_download,
                          height: 10.w,
                          width: 10.w,
                        ),
                      ),
                      SizedBox(
                        width: 2.w,
                      ),
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(name: "/ShareScreen"),
                                builder: (context) => ShareScreen(
                                  image: widget.image,
                                  isVideo: false,
                                ),
                              ))
                        },
                        child: Image.asset(
                          ImagesConstant.ic_share,
                          height: 10.w,
                          width: 10.w,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.w),
                          child: Image.memory(
                            base64Decode(widget.image),
                            width: 90.w,
                            height: 90.w,
                          ),
                        ),
                        Visibility(
                          visible: isVisible,
                          child: TitleTextWidget(
                              StringConstant.rate_result,
                              ColorConstant.BtnTextColor,
                              FontWeight.w500,
                              12.sp),
                        ),
                        Visibility(visible: isVisible, child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isShowLoading = true;
                                  });
                                  var sharedPrefs =
                                  await SharedPreferences.getInstance();
                                  final headers = {
                                    "Content-type": "application/json",
                                    "cookie":
                                    "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"
                                  };
                                  final headers1 = {
                                    "Content-type": "application/json",
                                  };
                                  List<JsonValueModel> params = [];
                                  params.add(
                                      JsonValueModel("type", "cartoonize"));
                                  params.add(JsonValueModel("like", "1"));
                                  params.add(JsonValueModel("url", widget.url));
                                  params.add(
                                      JsonValueModel("algo", widget.algoName));
                                  params.sort();
                                  var databody = jsonEncode(<String, dynamic>{
                                    'type': "cartoonize",
                                    'like': 1,
                                    'url': widget.url,
                                    'algo': widget.algoName,
                                    's': sToken(params),
                                  });
                                  final rateResponse = await post(
                                      Uri.parse(
                                          'https://socialbook.io/api/tool/matting/evaluate'),
                                      body: databody,
                                      headers:
                                      (sharedPrefs.getBool("isLogin") ??
                                          false)
                                          ? headers
                                          : headers1)
                                      .whenComplete(() => setState(() {
                                    isShowLoading = false;
                                    isVisible = false;
                                  }));
                                },
                                child: SimpleShadow(
                                  child: Image.asset(
                                    ImagesConstant.ic_emoji1,
                                    height: 10.w,
                                    width: 10.w,
                                  ),
                                  sigma: 5,
                                ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isShowLoading = true;
                                  });
                                  var sharedPrefs =
                                  await SharedPreferences.getInstance();
                                  final headers = {
                                    "Content-type": "application/json",
                                    "cookie":
                                    "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"
                                  };
                                  final headers1 = {
                                    "Content-type": "application/json",
                                  };
                                  List<JsonValueModel> params = [];
                                  params.add(
                                      JsonValueModel("type", "cartoonize"));
                                  params.add(JsonValueModel("like", "1"));
                                  params
                                      .add(JsonValueModel("url", widget.url));
                                  params.add(JsonValueModel(
                                      "algo", widget.algoName));
                                  params.sort();
                                  var databody = jsonEncode(<String, dynamic>{
                                    'type': "cartoonize",
                                    'like': -1,
                                    'url': widget.url,
                                    'algo': widget.algoName,
                                    's': sToken(params),
                                  });
                                  final rateResponse = await post(
                                      Uri.parse(
                                          'https://socialbook.io/api/tool/matting/evaluate'),
                                      body: databody,
                                      headers: (sharedPrefs
                                          .getBool("isLogin") ??
                                          false)
                                          ? headers
                                          : headers1)
                                      .whenComplete(() => setState(() {
                                    isShowLoading = false;
                                    isVisible = false;
                                  }));
                                },
                                child: SimpleShadow(
                                  child: Image.asset(
                                    ImagesConstant.ic_emoji2,
                                    height: 10.w,
                                    width: 10.w,
                                  ),
                                  sigma: 5,
                                ),
                              ),
                            ],
                          ),
                        ),),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        FutureBuilder(
                          future: _getPrefs(),
                          builder: (context, snapshot) {
                            return Visibility(
                              visible: (!(snapshot.data != null
                                      ? snapshot.data as bool
                                      : true) ||
                                  isLoading),
                              child: GestureDetector(
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings:
                                          RouteSettings(name: "/LoginScreen"),
                                      builder: (context) => LoginScreen(),
                                    ),
                                  ).then((value) => setState(() {
                                        isLoading = (value != null)
                                            ? value as bool
                                            : true;
                                      }))
                                },
                                child: RoundedBorderBtnWidget(
                                    StringConstant.signup_text),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        TitleTextWidget(StringConstant.no_watermark,
                            ColorConstant.HintColor, FontWeight.w400, 12.sp),
                        SizedBox(
                          height: 1.5.h,
                        ),
                        GestureDetector(
                          onTap: () => {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings:
                                      RouteSettings(name: "/PurchaseScreen"),
                                  builder: (context) => PurchaseScreen(),
                                ))
                          },
                          child:
                              RoundedBorderBtnWidget(StringConstant.go_premium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Future<bool> _getPrefs() async {
    sharedPrefs = await SharedPreferences.getInstance();
    return sharedPrefs.getBool("isLogin") ?? false;
  }
}
