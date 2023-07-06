import 'package:cartoonizer/common/importFile.dart';

class BackgroundPickerHolder extends StatefulWidget {
  const BackgroundPickerHolder({super.key});

  @override
  State<BackgroundPickerHolder> createState() => _BackgroundPickerHolderState();
}

class _BackgroundPickerHolderState extends State<BackgroundPickerHolder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late double contentHeight;
  late double tipsWidth;

  dynamic resultData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    tipsWidth = ScreenUtil.screenSize.width / 3 + $(8);
    contentHeight = ScreenUtil.screenSize.height / 3;
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          Navigator.of(context).pop(resultData);
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          break;
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                  child: Container(
                color: Colors.transparent,
              ).intoGestureDetector(onTap: () {
                dismiss();
              })),
              AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _controller.value) * contentHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: ScreenUtil.screenSize.width / 3 + $(8),
                            height: $(5),
                            margin: EdgeInsets.symmetric(vertical: $(8)),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular($(12))),
                          ),
                          Expanded(child: Container()),
                        ],
                      ).intoContainer(
                          height: contentHeight,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular($(12)), topRight: Radius.circular($(12))),
                          )),
                    );
                  }),
            ],
          )
              .intoContainer(
                color: Color.fromRGBO(0, 0, 0, _controller.value * 0.3),
              )
              .ignore(ignoring: _controller.isAnimating);
        });
  }

  dismiss({dynamic data}) {
    resultData = data;
    _controller.reverse();
  }
}
