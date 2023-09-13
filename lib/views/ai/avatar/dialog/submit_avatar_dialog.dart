import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/widgets/input_text.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:common_utils/common_utils.dart';

class SubmitAvatarDialog {
  static Future<MapEntry<String, String>?> push(BuildContext context) async {
    return Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(
      builder: (context) => _SubmitAvatarDialog(),
      settings: RouteSettings(name: '/_SubmitAvatarDialog'),
    ));
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
      controller.text = json['name']?.toString() ?? '';
      selectedStyle = json['style'] ?? aiManager.config?.getRoles()[0];
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
          aiManager.config != null
              ? SelectStyleCard(
                  style: selectedStyle,
                  onSelect: (style) {
                    setState(() {
                      selectedStyle = style;
                    });
                  },
                  config: aiManager.config!,
                )
              : SizedBox.shrink(),
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
              .intoGestureDetector(onTap: () async {
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
            var json = cacheManager.getJson(CacheManager.lastCreateAvatar);
            if (json == null) {
              json = {};
            }
            json['name'] = controller.text;
            json['style'] = selectedStyle;
            await cacheManager.setJson(CacheManager.lastCreateAvatar, json);
            showConfirmDialog(context).then((value) {
              var lastAvatarConfig = cacheManager.getJson(CacheManager.lastCreateAvatar);
              if (value ?? false) {
                cacheManager.setJson(CacheManager.lastCreateAvatar, lastAvatarConfig).then((value) {
                  Navigator.of(context).pop(MapEntry(name, selectedStyle!));
                });
              } else {
                lastAvatarConfig['style'] = null;
                lastAvatarConfig['isChangeTemplate'] = true;
                cacheManager.setJson(CacheManager.lastCreateAvatar, lastAvatarConfig).then((value) {
                  Navigator.of(context).pop();
                });
              }
            });
          }),
        ],
      ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))),
    );
  }

  Future<bool?> showConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
        context: context,
        builder: (_) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleTextWidget(S.of(context).remind, ColorConstant.White, FontWeight.w600, $(17)).intoContainer(
                padding: EdgeInsets.only(top: $(20), bottom: $(15), left: $(15), right: $(15)),
              ),
              TitleTextWidget(
                S.of(context).avatar_create_ensure_hint.replaceAll('%s', aiManager.config!.getName(selectedStyle ?? '')),
                ColorConstant.White,
                FontWeight.normal,
                $(14),
                maxLines: 10,
              ).intoContainer(
                padding: EdgeInsets.only(bottom: $(15), left: $(15), right: $(15)),
              ),
              Container(height: 1, color: ColorConstant.LineColor),
              Text(
                S.of(context).yes,
                style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(16)),
              )
                  .intoContainer(
                width: double.maxFinite,
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                alignment: Alignment.center,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.pop(context, true);
              }),
              Container(height: 1, color: ColorConstant.LineColor),
              Text(
                S.of(context).choose_another,
                style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.DiscoveryBtn, fontSize: $(16)),
              )
                  .intoContainer(
                width: double.maxFinite,
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                alignment: Alignment.center,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.pop(context, false);
              }),
            ],
          ).intoContainer(width: double.maxFinite).customDialogStyle();
        });
  }
}

class SelectStyleCard extends StatefulWidget {
  String? style;
  Function(String style) onSelect;
  late List<String> roles;
  AvatarConfigEntity config;

  SelectStyleCard({
    Key? key,
    required this.onSelect,
    this.style,
    required this.config,
  }) : super(key: key) {
    this.roles = config.getRoles();
  }

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
  void didUpdateWidget(covariant SelectStyleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    selectedStyle = widget.style;
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
            widget.config.getName(e),
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
