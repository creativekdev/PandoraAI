import 'package:cartoonizer/common/importFile.dart';

Widget TitleTextWidget(String text, Color color, FontWeight fontWeight, double size, {TextAlign align = TextAlign.center, int maxLines = 1}) => Text(
      text,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontFamily: 'Poppins',
        fontSize: size,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      softWrap: true,
    );
