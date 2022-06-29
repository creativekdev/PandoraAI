import 'package:cartoonizer/Widgets/blank_area_intercept.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/common/importFile.dart';

typedef BottomSheetBuilder = Widget Function(BuildContext context);

class AppBottomSheet extends StatefulWidget {
  static showDialog(
    BuildContext context, {
    required BottomSheetBuilder builder,
    Color backgroundColor = Colors.transparent,
    int animationDuration = 500,
  }) {
    Navigator.push(
        context,
        FadeRouter(
          child: AppBottomSheet(
            backgroundColor: backgroundColor,
            builder: builder,
          ),
          duration: animationDuration,
          opaque: false,
        ));
  }

  final Color backgroundColor;
  final BottomSheetBuilder builder;

  AppBottomSheet({
    Key? key,
    required this.backgroundColor,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AppBottomSheetState();
  }
}

class AppBottomSheetState extends State<AppBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Column(
        children: [
          Expanded(
              child: Container(
            width: double.maxFinite,
            color: Colors.transparent,
          )),
          widget.builder(context).intoGestureDetector(onTap: () {}),
        ],
      ).blankAreaIntercept(interceptType: KeyboardInterceptType.pop),
    );
  }
}
