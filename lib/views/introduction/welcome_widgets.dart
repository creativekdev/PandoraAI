import 'package:cartoonizer/Common/ThemeConstant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:cartoonizer/controller/introduction_controller.dart';

class WelcomeWidgets extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subTitle;
  final int? position;
  final double? width1;
  final double? width2;
  final double? width3;
  final Color? color1;
  final Color? color2;
  final Color? color3;
  final bool? isNext;

  final IntroductionController c = Get.put(IntroductionController());

  WelcomeWidgets({Key? key, this.image, this.title, this.subTitle, this.position, this.width1, this.width2, this.width3, this.color1, this.color2, this.color3, this.isNext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      //  color: Colors.pink,
      height: (100.h - 50.w),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Container(
                height: (100.h - 50.w) / 2,
                width: 100.w,
                child: Image.asset(
                  image!,
                  height: 35.w,
                  width: 35.w,
                  fit: BoxFit.fitHeight,
                )),
          ),
          // SizedBox(height: 4.h,),
          Flexible(
            flex: 1,
            child: Container(
              height: (100.h - 50.w) / 2.2,
              width: 100.w,
              //height: 35.h,
              decoration: const BoxDecoration(color: ColorConstant.BackgroundColor, borderRadius: BorderRadius.all(Radius.circular(35.0))),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 9,
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      child: Text(title!, textAlign: TextAlign.center),
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Text(subTitle!, textAlign: TextAlign.center),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 0.7.h,
                          width: width1,
                          decoration: BoxDecoration(color: color1, borderRadius: const BorderRadius.all(Radius.circular(35.0))),
                        ),
                        const SizedBox(width: 2.0),
                        Container(
                          height: 0.7.h,
                          width: width2,
                          decoration: BoxDecoration(color: color2, borderRadius: const BorderRadius.all(Radius.circular(35.0))),
                        ),
                        const SizedBox(width: 2.0),
                        Container(
                          height: 0.7.h,
                          width: width3,
                          decoration: BoxDecoration(color: color3, borderRadius: const BorderRadius.all(Radius.circular(35.0))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
