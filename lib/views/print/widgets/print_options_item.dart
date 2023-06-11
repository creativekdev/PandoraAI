import '../../../Common/importFile.dart';

typedef ValueCallBack = void Function(Map<String, bool> map, String value);

class PrintOptionsItem extends StatelessWidget {
  PrintOptionsItem(
      {Key? key,
      required this.showMap,
      required this.options,
      required this.onSelectTitleTap})
      : super(key: key);
  final Map<String, bool> showMap;
  final List<String> options;
  ValueCallBack onSelectTitleTap;

  // GestureTapCallback onShareTap;
  // GestureTapCallback onSharePrintTap;
  //
  // // GestureTapCallback onDownloadTap;
  // GestureTapCallback onGenerateAgainTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DividerLine(),
        Container(
          width: ScreenUtil.screenSize.width,
          height: $(64),
          padding: EdgeInsets.only(left: $(17), top: $(12), bottom: $(12)),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              return PrintTextOption(text: options[index]).intoGestureDetector(
                  onTap: () {
                onSelectTitleTap(showMap, options[index]);
              });
            },
          ),
        ),
        DividerLine(),
      ],
    );
  }
}

class PrintTextOption extends StatelessWidget {
  PrintTextOption({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return TitleTextWidget(text, ColorConstant.White, FontWeight.normal, $(14))
        .intoContainer(
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

class PrintImageOption extends StatelessWidget {
  PrintImageOption({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return TitleTextWidget(text, ColorConstant.White, FontWeight.normal, $(14))
        .intoContainer(
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
  const DividerLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: $(17),
      ),
      color: ColorConstant.InputBackground,
      height: $(0.5),
    );
  }
}
