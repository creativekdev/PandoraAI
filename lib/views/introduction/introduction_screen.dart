import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/home/HomeScreen.dart';
import 'package:cartoonizer/views/introduction/welcome_widgets.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  _onContinueClick(BuildContext context) {
    AppDelegate.instance.getManager<CacheManager>().setBool(CacheManager.keyHasIntroductionPageShowed, true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
      ModalRoute.withName('/HomeScreen'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              child: PageView(
                children: <Widget>[
                  WelcomeWidgets(
                    image: ImagesConstant.ic_introduction_bg1,
                    title: StringConstant.app_name,
                    subTitle: StringConstant.welcome_title1,
                    position: 1,
                    color: Colors.white,
                  ),
                  WelcomeWidgets(
                    image: ImagesConstant.ic_introduction_bg2,
                    title: StringConstant.app_name,
                    subTitle: StringConstant.welcome_title2,
                    position: 2,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 3.h,
              child: GestureDetector(
                onTap: () => _onContinueClick(context),
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
                          colors: [Color.fromRGBO(36, 60, 255, 1), Color.fromRGBO(227, 30, 205, 1)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          StringConstant.txtContinue,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: "Poppins"),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
