import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/blank_area_intercept.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache_manager.dart';

/// true to clear last input
/// false to keep last input
typedef InputCallback = Future<bool> Function(String text);

const int _maxInputLength = 280;

class InputScreen extends StatefulWidget {
  String? oldString;
  String uniqueId;
  String? hint;

  InputCallback callback;

  InputScreen({
    Key? key,
    this.oldString,
    required this.callback,
    this.uniqueId = '',
    this.hint,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => InputScreenState();
}

class InputScreenState extends State<InputScreen> {
  CacheManager cacheManager = AppDelegate.instance.getManager();
  TextEditingController textEditingController = TextEditingController();
  String? hint;
  late String uniqueId;
  late InputCallback callback;
  bool ignore = false;

  @override
  void initState() {
    super.initState();
    uniqueId = widget.uniqueId;
    callback = widget.callback;
    hint = widget.hint;
    if (widget.oldString != null) {
      textEditingController.text = widget.oldString!;
    } else {
      textEditingController.text = cacheManager.getString(_getKey());
    }
  }

  String _getKey() {
    return '${CacheManager.keyCacheInput}_$uniqueId';
  }

  submit() async {
    var string = textEditingController.text.trim();
    if (string.isEmpty) {
      return;
    }
    setState(() => ignore = true);
    var bool = await callback.call(string);
    setState(() => ignore = false);
    if (bool) {
      cacheManager.setString(_getKey(), '');
      Navigator.pop(context);
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      controller: textEditingController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(_maxInputLength),
                      ],
                      textInputAction: TextInputAction.done,
                      style: TextStyle(height: 1, color: ColorConstant.White),
                      maxLines: 3,
                      minLines: 1,
                      onChanged: (text) {
                        cacheManager.setString(_getKey(), text);
                      },
                      onEditingComplete: () {
                        submit();
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
                    ).intoContainer(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: ColorConstant.InputContent,
                        borderRadius: BorderRadius.circular($(6)),
                      ),
                    ),
                  ),
                  SizedBox(width: $(8)),
                  Text(
                    StringConstant.send,
                    style: TextStyle(color: ColorConstant.White, fontFamily: 'Poppins'),
                  )
                      .intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(9)),
                    decoration: BoxDecoration(
                      color: ColorConstant.BlueColor,
                      borderRadius: BorderRadius.circular($(6)),
                    ),
                  )
                      .intoGestureDetector(onTap: () {
                    submit();
                  }),
                ],
              ).intoContainer(
                  color: ColorConstant.InputBackground,
                  padding: EdgeInsets.symmetric(
                    horizontal: $(15),
                    vertical: $(8),
                  )),
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    ).ignore(ignoring: ignore);
  }
}
