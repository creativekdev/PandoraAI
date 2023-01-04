import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/input_text.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:common_utils/common_utils.dart';

class SubmitAvatarDialog {
  static Future<MapEntry<String, String>?> push(
    BuildContext context, {
    required String name,
  }) async {
    return Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(builder: (context) => _SubmitAvatarDialog()));
  }
}

class _SubmitAvatarDialog extends StatefulWidget {
  _SubmitAvatarDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<_SubmitAvatarDialog> createState() => _SubmitAvatarDialogState();
}

class _SubmitAvatarDialogState extends AppState<_SubmitAvatarDialog> {
  TextEditingController controller = TextEditingController();
  AvatarAiManager aiManager = AppDelegate().getManager();
  CacheManager cacheManager = AppDelegate().getManager();
  String? selectedStyle;

  @override
  void initState() {
    super.initState();
    var json = cacheManager.getJson(CacheManager.lastCreateAvatar);
    if (json != null) {
      controller.text = json['name'];
      selectedStyle = json['style'];
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          S.of(context).create_avatar,
          ColorConstant.White,
          FontWeight.w600,
          $(18),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: $(32)),
          Row(
            children: [
              TitleTextWidget(
                S.of(context).input_name,
                ColorConstant.White,
                FontWeight.w500,
                $(15),
                maxLines: 1,
              ),
              SizedBox(width: $(12)),
              Expanded(
                  child: InputText(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: S.of(context).please_enter_an_avatar_name,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Poppins',
                    fontSize: $(15),
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: $(15),
                ),
              )),
            ],
          ).intoContainer(color: Color(0xff242830), padding: EdgeInsets.symmetric(horizontal: $(15))),
          SizedBox(height: $(20)),
          SelectStyleCard(
              style: selectedStyle,
              onSelect: (style) {
                setState(() {
                  selectedStyle = style;
                });
              },
              roles: aiManager.config!.getRoles()),
          SizedBox(height: $(10)),
          Expanded(child: Container()),
          TitleTextWidget(
            S.of(context).create,
            ColorConstant.White,
            FontWeight.w500,
            $(17),
          )
              .intoContainer(
            padding: EdgeInsets.symmetric(vertical: $(12)),
            margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
            width: double.maxFinite,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular($(8)),
              color: ColorConstant.BlueColor,
            ),
          )
              .intoGestureDetector(onTap: () {
            var name = controller.text.trim();
            if (TextUtil.isEmpty(name)) {
              FocusScope.of(context).requestFocus(FocusNode());
              CommonExtension().showToast(S.of(context).pandora_create_input_name_hint);
              return;
            }
            if (selectedStyle == null) {
              FocusScope.of(context).requestFocus(FocusNode());
              CommonExtension().showToast(S.of(context).pandora_create_style_hint);
              return;
            }
            var json = {
              'name': controller.text,
              'style': selectedStyle,
            };
            cacheManager.setJson(CacheManager.lastCreateAvatar, json);
            Navigator.of(context).pop(MapEntry(name, selectedStyle!));
          }),
        ],
      ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))),
    );
  }
}

class SelectStyleCard extends StatefulWidget {
  String? style;
  Function(String style) onSelect;
  List<String> roles;

  SelectStyleCard({
    Key? key,
    required this.onSelect,
    required this.roles,
    this.style,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectStyleState();
  }
}

class SelectStyleState extends State<SelectStyleCard> {
  String? selectedStyle;
  late List<String> roles;

  @override
  void initState() {
    super.initState();
    selectedStyle = widget.style;
    roles = widget.roles;
  }

  @override
  Widget build(BuildContext context) {
    var title = TitleTextWidget(
      S.of(context).select_a_style,
      ColorConstant.White,
      FontWeight.w500,
      $(15),
      maxLines: 2,
    );
    var children = Wrap(
      spacing: $(12),
      runSpacing: $(12),
      alignment: WrapAlignment.start,
      children: roles.map(
        (e) {
          var checked = selectedStyle == e;
          return Text(
            AppDelegate.instance.getManager<ThirdpartManager>().getLocaleString(context, e),
            style: TextStyle(
              color: ColorConstant.White,
              fontFamily: 'Poppins',
              fontSize: $(15),
            ),
          )
              .intoContainer(
                  padding: EdgeInsets.symmetric(horizontal: $(12), vertical: $(1)),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: checked ? ColorConstant.BlueColor : ColorConstant.White,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    color: checked ? ColorConstant.BlueColor : Colors.transparent,
                  ))
              .intoGestureDetector(onTap: () {
            if (checked) {
              return;
            }
            setState(() {
              selectedStyle = e;
              widget.onSelect.call(selectedStyle!);
            });
          });
        },
      ).toList(),
    );
    Widget result;
    if (roles.length > 3) {
      result = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          SizedBox(height: $(12)),
          children,
        ],
      );
    } else {
      result = Row(
        children: [
          title,
          SizedBox(width: $(12)),
          Expanded(
            child: children,
          ),
        ],
      );
    }
    return result.intoContainer(width: double.maxFinite, color: Color(0xff242830), padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(10)));
  }
}
