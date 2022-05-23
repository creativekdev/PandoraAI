import 'package:page_indicator/page_indicator.dart';
import 'package:cartoonizer/common/importFile.dart';

import 'package:cartoonizer/Controller/introduction_controller.dart';
import 'package:cartoonizer/views/introduction/welcome_widgets.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GetBuilder<IntroductionController>(
      init: IntroductionController(),
      builder: (_) {
        return Scaffold(
          appBar: null,
          body: SafeArea(
            child: Container(
              child: Stack(
                children: [
                  Container(
                    //color: Colors.blue,
                    height: 100.h,
                    margin: EdgeInsets.only(top: 10.w, bottom: 35.w),
                    child: PageIndicatorContainer(
                      child: PageView(
                        children: <Widget>[
                          WelcomeWidgets(
                            image: ImagesConstant.ic_man,
                            title: "AAAAAAAAAAAAAAAA",
                            subTitle: "AAAAAAAAAAAAAAAAAAAAA",
                            position: 1,
                            width1: 5.w,
                            width2: 2.5.w,
                            width3: 2.5.w,
                            color1: Colors.white,
                            color2: Colors.white,
                            color3: Colors.white,
                            isNext: false,
                          ),
                          WelcomeWidgets(
                              image: ImagesConstant.ic_man,
                              title: "AAAAAAAAAAAAAAAAAAA",
                              subTitle: "AAAAAAAAAAAAAAAAAAAAA",
                              position: 2,
                              width1: 2.5.w,
                              width2: 5.w,
                              width3: 2.5.w,
                              color1: Colors.white,
                              color2: Colors.white,
                              color3: Colors.white,
                              isNext: false),
                          WelcomeWidgets(
                              image: ImagesConstant.ic_man,
                              title: "AAAAAAAAAAAAAAAAAAA",
                              subTitle: "AAAAAAAAAAAAAAAAAAAAA",
                              position: 3,
                              width1: 2.5.w,
                              width2: 2.5.w,
                              width3: 5.w,
                              color1: Colors.white,
                              color2: Colors.white,
                              color3: Colors.white,
                              isNext: true),
                        ],
                        controller: _.controller,
                      ),
                      align: IndicatorAlign.bottom,
                      length: 3,
                      indicatorSpace: 20.0,
                      padding: const EdgeInsets.all(10),
                      indicatorColor: Colors.white,
                      indicatorSelectorColor: Colors.white,
                      shape: IndicatorShape.circle(size: 0),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 10.w,
                        padding: EdgeInsets.only(top: 1.w, right: 2.h),
                        child: GestureDetector(
                          onTap: () => print("Clicked"),
                          child: Container(alignment: Alignment.topRight, child: Text("AAAAAAAAAAAAAAAAAAAAA")),
                        ),
                      ),
                      //  SizedBox(width: 5.w),

                      //SizedBox(height: 1.h),
                      Column(
                        children: [
                          Container(
                              height: 18.w,
                              width: 100.w,
                              margin: EdgeInsets.only(bottom: 2.w),
                              //alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    ImagesConstant.ic_back,
                                    width: 18.w,
                                    height: 18.w,
                                    fit: BoxFit.fitHeight,
                                    color: Colors.transparent,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        //  c.jumpToNextPage(isNext);
                                      },
                                      child: Image.asset(
                                        ImagesConstant.ic_back,
                                        width: 18.w,
                                        height: 18.w,
                                        fit: BoxFit.fitHeight,
                                      )),
                                  Image.asset(
                                    ImagesConstant.ic_back,
                                    width: 18.w,
                                    height: 18.w,
                                    fit: BoxFit.fitHeight,
                                    color: Colors.transparent,
                                  ),
                                ],
                              )),
                          Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Card(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.white, width: 0.00001),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 10,
                                shadowColor: Colors.white,
                                child: Text("AAAAAAAAAAAAAAAAAAAAA")),
                          ),
                          SizedBox(height: 2.w),
                          SizedBox(height: 2.w),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
