import 'package:cartoonizer/Common/importFile.dart';

class OkToast extends StatelessWidget {
  Widget icon;
  String text;
  Color color;

  OkToast({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: icon,
          margin: EdgeInsets.only(top: $(10), bottom: $(15)),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: $(14), fontFamily: 'Poppins', decoration: TextDecoration.none, fontWeight: FontWeight.w400),
          maxLines: 1,
        ).intoContainer(width: double.maxFinite),
      ],
    ).intoContainer(
        decoration: BoxDecoration(
          color: Color.fromARGB(220, 35, 35, 35),
          borderRadius: BorderRadius.circular($(6)),
        ),
        width: $(150),
        height: $(130));
  }
}
