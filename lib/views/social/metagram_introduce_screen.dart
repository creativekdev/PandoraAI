import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/Widgets/connector/platform_connector_page.dart';
import 'package:cartoonizer/common/importFile.dart';

class MetagramIntroduceScreen extends StatefulWidget {
  const MetagramIntroduceScreen({Key? key}) : super(key: key);

  @override
  State<MetagramIntroduceScreen> createState() => _MetagramIntroduceScreenState();
}

class _MetagramIntroduceScreenState extends State<MetagramIntroduceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
          Positioned(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleTextWidget('Metagram', Color(0xFFFFE674), FontWeight.normal, $(12)),
                SizedBox(height: $(4)),
                TitleTextWidget('Turn all your instagram into anime!', Colors.white, FontWeight.normal, $(20), maxLines: 3)
                    .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(60))),
                Container(
                  height: $(60),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x00000000),
                        Color(0xff000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                TitleTextWidget('Add Business Account', Colors.black, FontWeight.normal, $(16))
                    .intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular($(32))),
                )
                    .intoGestureDetector(onTap: () {
                  PlatformConnectorPage.push(context, platform: ConnectorPlatform.instagramBusiness).then((value) {
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    }
                  });
                }).intoContainer(color: Colors.black, width: ScreenUtil.screenSize.width, padding: EdgeInsets.only(left: $(26), right: $(26), top: $(15))),
                TitleTextWidget('Add Basic Account', Colors.white, FontWeight.normal, $(14))
                    .intoContainer(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: $(12)),
                )
                    .intoGestureDetector(onTap: () {
                  PlatformConnectorPage.push(context, platform: ConnectorPlatform.instagram).then((value) {
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    }
                  });
                }).intoContainer(color: Colors.black, width: ScreenUtil.screenSize.width, padding: EdgeInsets.symmetric(horizontal: $(26))),
                Container(
                  color: Colors.black,
                  width: ScreenUtil.screenSize.width,
                  height: ScreenUtil.getBottomPadding(context),
                ),
              ],
            ),
            bottom: 0,
            left: 0,
            right: 0,
          )
        ],
      ),
    );
  }
}
