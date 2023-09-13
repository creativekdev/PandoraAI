import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class PaymentAttrsList extends StatelessWidget {
  final List<String> list = [
    Images.ic_pro_attr_facetoon,
    Images.ic_pro_attr_effects,
    Images.ic_pro_attr_bg_remover,
    Images.ic_pro_attr_scribble,
    Images.ic_pro_attr_ai_coloring,
    Images.ic_pro_attr_txt2img,
    Images.ic_pro_attr_metaverse,
    Images.ic_pro_attr_edition_tool,
  ];

  @override
  Widget build(BuildContext context) {
    var itemSize = ScreenUtil.getCurrentWidgetSize(context).width / 4.25;
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(colors: [
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x00000000),
          Color(0x99000000),
          Color(0xcc000000),
        ], begin: Alignment.centerLeft, end: Alignment.centerRight)
            .createShader(rect);
      },
      blendMode: BlendMode.srcATop,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: $(15)),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => Image.asset(
          list[index],
          width: itemSize,
          height: itemSize,
        ).intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : $(11))),
        itemCount: list.length,
      ).intoContainer(height: itemSize),
    );
  }
}
