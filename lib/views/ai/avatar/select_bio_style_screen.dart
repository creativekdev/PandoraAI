import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';

class SelectStyleScreen {
  static Future<String?> push(BuildContext context, {String? gender}) {
    return Navigator.of(context).push<String>(MaterialPageRoute(
      builder: (context) => _SelectGenderScreen(bioStyle: gender),
    ));
  }
}

class _SelectGenderScreen extends StatefulWidget {
  String? bioStyle;

  _SelectGenderScreen({
    Key? key,
    this.bioStyle,
  }) : super(key: key);

  @override
  State<_SelectGenderScreen> createState() => _SelectGenderScreenState();
}

class _SelectGenderScreenState extends State<_SelectGenderScreen> {
  String? bioStyle;
  AvatarAiManager aiManager = AppDelegate().getManager();

  @override
  void initState() {
    super.initState();
    bioStyle = widget.bioStyle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.BackgroundColor,
        appBar: AppNavigationBar(
          backgroundColor: ColorConstant.BackgroundColor,
          middle: TitleTextWidget(S.of(context).select_style, ColorConstant.White, FontWeight.w600, $(17)),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: aiManager.config!.getRoles().map((e) {
                  bool checked = e == bioStyle;
                  return Row(
                    children: [
                      checked
                          ? Container(
                              width: $(22),
                              height: $(22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular($(16)),
                                border: Border.all(
                                  width: 1,
                                  color: checked ? ColorConstant.BlueColor : ColorConstant.White,
                                ),
                                color: ColorConstant.BlueColor,
                              ),
                              child: Icon(
                                Icons.check,
                                size: $(16),
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.only(left: 2, right: 4, top: 2, bottom: 4),
                            )
                          : Container(
                              width: $(22),
                              height: $(22),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular($(16)),
                                border: Border.all(
                                  width: 1,
                                  color: ColorConstant.White,
                                ),
                              ),
                            ),
                      SizedBox(width: $(12)),
                      Text(
                        e,
                        style: TextStyle(
                          color: ColorConstant.White,
                          fontSize: $(19),
                        ),
                      )
                    ],
                  )
                      .intoContainer(
                        padding: EdgeInsets.symmetric(horizontal: $(25), vertical: $(25)),
                      )
                      .intoMaterial(
                        elevation: 4,
                        color: ColorConstant.CardColor,
                        borderRadius: BorderRadius.circular($(8)),
                      )
                      .intoGestureDetector(onTap: () {
                    setState(() {
                      bioStyle = e;
                    });
                  }).intoContainer(
                          margin: EdgeInsets.symmetric(
                    vertical: $(10),
                    horizontal: $(30),
                  ));
                }).toList(),
              ),
            ),
            Text(
              'Ok',
              style: TextStyle(color: Colors.white),
            )
                .intoContainer(
              padding: EdgeInsets.symmetric(vertical: $(12)),
              margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
              width: double.maxFinite,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(8)),
                color: ColorConstant.BlueColor,
              ),
            )
                .intoGestureDetector(onTap: () {
              if (bioStyle == null) {
                CommonExtension().showToast('Please select style');
              } else {
                Navigator.of(context).pop(bioStyle);
              }
            })
          ],
        ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))));
  }
}
