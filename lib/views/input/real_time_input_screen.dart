import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/blank_area_intercept.dart';

/// true to clear last input
/// false to keep last input

const int _maxInputLength = 280;

typedef OnChange = Function(String content);

/// input screen
/// content submit on changed any time
class RealTimeInputScreen extends StatefulWidget {
  String? oldString;
  String? hint;
  OnChange onChange;

  RealTimeInputScreen({
    Key? key,
    this.oldString,
    required this.onChange,
    this.hint,
  }) : super(key: key);

  @override
  RealTimeInputScreenState createState() => RealTimeInputScreenState();
}

class RealTimeInputScreenState extends State<RealTimeInputScreen> {
  TextEditingController textEditingController = TextEditingController();
  String? hint;
  late OnChange onChange;

  @override
  void initState() {
    super.initState();
    onChange = widget.onChange;
    hint = widget.hint;
    if (widget.oldString != null) {
      textEditingController.text = widget.oldString!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlankAreaIntercept(
      interceptType: KeyboardInterceptType.pop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              child: TextField(
                autofocus: true,
                controller: textEditingController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxInputLength),
                ],
                textInputAction: TextInputAction.done,
                style: TextStyle(height: 1, color: Colors.black),
                maxLines: 3,
                minLines: 1,
                onChanged: (text) {
                  onChange.call(text);
                },
                onEditingComplete: () {
                  Navigator.of(context).pop();
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: ColorConstant.DiscoveryCommentGrey,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(12)),
                  isDense: true,
                ),
              )
                  .intoContainer(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: ColorConstant.aiDrawGrey,
                      borderRadius: BorderRadius.circular($(6)),
                    ),
                  )
                  .intoContainer(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: $(15),
                        vertical: $(8),
                      )),
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }
}
