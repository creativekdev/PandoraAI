import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WelcomeWidgets extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subTitle;
  final Color? color;

  WelcomeWidgets({Key? key, this.image, this.title, this.subTitle, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                child: Image.asset(
                  image!,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 100.h,
                width: 100.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 70.h),
                      child: Text(
                        title!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        subTitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.normal, fontFamily: "Poppins"),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
