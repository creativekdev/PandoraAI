import 'package:cartoonizer/api/allshare_api.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/home_screen.dart';
import 'package:cartoonizer/views/introduction/welcome_widgets.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IntroductionScreenState();
  }
}

class IntroductionScreenState extends State<IntroductionScreen> {
  int position = 0;
  List pages = [];

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'introduction_screen');
    AllShareApi().onFirstEntry();
    pageController = PageController(initialPage: 0);
    delay(() {
      setState(() {
        pages = [
          {
            'image': Images.introduction_bg1,
            'title': S.of(context).welcome_content1,
            'subTitle': S.of(context).welcome_title1,
          },
          {
            'image': Images.introduction_bg2,
            'title': S.of(context).welcome_content2,
            'subTitle': S.of(context).welcome_title2,
          },
          {
            'image': Images.introduction_bg3,
            'title': S.of(context).welcome_content3,
            'subTitle': S.of(context).welcome_title3,
          }
        ];
      });
    });
  }

  _onContinueClick(BuildContext context) {
    AppDelegate.instance.getManager<CacheManager>().setBool(CacheManager.keyHasIntroductionPageShowed, true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomeScreen(),
        settings: RouteSettings(name: "/HomeScreen"),
      ),
      ModalRoute.withName('/HomeScreen'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    position = index;
                  });
                },
                children: pages
                    .map((e) => WelcomeWidgets(
                          image: e['image'],
                          title: e['title'],
                          subTitle: e['subTitle'],
                          color: Colors.white,
                        ))
                    .toList()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: buildPoint(), mainAxisSize: MainAxisSize.min),
                SizedBox(height: $(20)),
                GestureDetector(
                  onTap: () {
                    _onContinueClick(context);
                  },
                  child: Container(
                    width: 100.w,
                    height: 54,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [Color.fromRGBO(227, 30, 205, 1), Color.fromRGBO(36, 60, 255, 1)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            S.of(context).txtContinue,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: "Poppins"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ).visibility(visible: position == pages.length - 1),
                GestureDetector(
                  onTap: () {
                    pageController.animateToPage(position + 1, duration: Duration(milliseconds: 200), curve: Curves.linear);
                  },
                  child: Image.asset(Images.ic_introduction_next, width: $(44)).intoContainer(margin: EdgeInsets.symmetric(vertical: $(4))),
                ).visibility(visible: position != pages.length - 1),
              ],
            ).intoContainer(
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + $(10)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildPoint() {
    List<Widget> result = [];
    for (int i = 0; i < pages.length; i++) {
      result.add(
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: position == i ? Colors.white : Color.fromRGBO(255, 255, 255, 0.5),
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
        ).intoContainer(padding: EdgeInsets.all($(7.5)), color: Colors.transparent).intoGestureDetector(onTap: () {
          if (position != i) {
            pageController.animateToPage(i, duration: Duration(milliseconds: 200), curve: Curves.linear);
          }
        }),
      );
    }
    return result;
  }
}
