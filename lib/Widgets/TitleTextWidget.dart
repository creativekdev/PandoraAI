import 'package:cartoonizer/Common/importFile.dart';

Widget TitleTextWidget(String text, Color color, FontWeight fontWeight, double size, {TextAlign align = TextAlign.center}) => Text(
      text,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontFamily: 'Poppins',
        fontSize: size,
      ),
      overflow: TextOverflow.fade,
      maxLines: 1,
      softWrap: false,
    );
