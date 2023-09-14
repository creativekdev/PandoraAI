import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class PaymentAttrsList extends StatefulWidget {
  const PaymentAttrsList({super.key});

  @override
  State<PaymentAttrsList> createState() => _PaymentAttrLoopBarState();
}

class _PaymentAttrLoopBarState extends State<PaymentAttrsList> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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

  double totalWidth = 0;
  double itemSize = 0;
  var scrollController = ScrollController();
  double baseWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 6000));
    delay(() {
      int totalSize = list.length * 2;
      itemSize = ScreenUtil.getCurrentWidgetSize(context).width / 4.25;
      totalWidth = itemSize * totalSize + $(30) + $(11) * (totalSize - 1);
      baseWidth = itemSize * list.length + $(15) + $(11) * (list.length - 1) - $(4);
      setState(() {});
      _controller.addListener(() {
        scrollController.jumpTo(_controller.value * baseWidth);
      });
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        controller: scrollController,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: $(15)),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => Image.asset(
          list[index % list.length],
          width: itemSize,
          height: itemSize,
        ).intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : $(11))),
        itemCount: list.length * 2,
      ).intoContainer(height: itemSize),
    );
  }
}
