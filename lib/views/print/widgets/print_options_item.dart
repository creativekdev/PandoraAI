import '../../../Common/importFile.dart';

typedef ValueCallBack = void Function(Map<String, bool> map, String value);

class PrintOptionsItem extends StatelessWidget {
  PrintOptionsItem({Key? key, required this.showMap, required this.options, required this.onSelectTitleTap, this.content = ""}) : super(key: key);
  final Map<String, bool> showMap;
  final String content;
  final List<String> options;
  ValueCallBack onSelectTitleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DividerLine(),
        SizedBox(
          height: $(12),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: $(15)),
          child: Wrap(
            direction: Axis.horizontal,
            runSpacing: $(12),
            spacing: $(12),
            children: [
              ...options.map((e) {
                return PrintTextOption(
                  text: e,
                  isSelect: e == content,
                ).intoGestureDetector(onTap: () {
                  onSelectTitleTap(showMap, e);
                });
              })
            ],
          ),
        ),
        SizedBox(
          height: $(12),
        ),
        DividerLine(),
      ],
    );
  }
}

class PrintTextOption extends StatelessWidget {
  PrintTextOption({Key? key, required this.text, required this.isSelect}) : super(key: key);
  final String text;
  final bool isSelect;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: TitleTextWidget(text, ColorConstant.White, FontWeight.normal, $(14)).intoContainer(
        alignment: Alignment.center,
        // width: $(59),
        height: $(40),
        padding: EdgeInsets.symmetric(horizontal: $(8)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelect ? ColorConstant.BlueColor : ColorConstant.loginTitleColor,
            width: $(1),
          ),
        ),
      ),
    );
  }
}

class PrintImageOption extends StatelessWidget {
  PrintImageOption({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return TitleTextWidget(text, ColorConstant.White, FontWeight.normal, $(14)).intoContainer(
      alignment: Alignment.center,
      width: $(59),
      height: $(40),
      margin: EdgeInsets.only(right: $(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorConstant.loginTitleColor,
          width: $(1),
        ),
      ),
    );
  }
}

class DividerLine extends StatelessWidget {
  DividerLine({Key? key, this.left, this.right}) : super(key: key);
  double? left;
  double? right;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: left ?? $(17),
        right: right ?? $(0),
      ),
      color: ColorConstant.InputBackground,
      height: $(0.5),
    );
  }
}
