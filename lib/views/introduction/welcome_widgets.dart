import 'package:cartoonizer/common/importFile.dart';

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
                child: Image.asset(image!, fit: BoxFit.contain),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                  ),
                  SizedBox(height: $(20)),
                  Text(
                    subTitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.normal, fontFamily: "Poppins"),
                  ),
                ],
              ).intoContainer(alignment: Alignment.bottomCenter, width: 100.w, height: 100.h, padding: EdgeInsets.only(bottom: $(160))),
            ],
          ),
        ],
      ),
    );
  }
}
