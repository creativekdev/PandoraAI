import 'package:cartoonizer/Common/importFile.dart';

class NsfwCard extends StatelessWidget {
  final double width;
  final double height;
  final GestureTapCallback onTap;

  NsfwCard({
    Key? key,
    required this.width,
    required this.height,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.black45,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).scary_content_alert,
            style: TextStyle(color: ColorConstant.White, fontFamily: 'Poppins', fontSize: $(12)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: $(16)),
          Text(
            S.of(context).show_it + S.of(context).q1,
            style: TextStyle(
              color: ColorConstant.BlueColor,
              fontFamily: 'Poppins',
              fontSize: $(12),
            ),
          )
              .intoContainer(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular($(6)),
                  border: Border.all(color: ColorConstant.BlueColor, width: 1),
                ),
                padding: EdgeInsets.only(left: $(15), right: $(15), bottom: $(2), top: $(4)),
              )
              .intoGestureDetector(onTap: onTap),
        ],
      ),
    ).intoGestureDetector(onTap: () {});
  }
}
