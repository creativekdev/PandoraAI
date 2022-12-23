import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/input_text.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
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
  String? selectedStyle;

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          'Create Avatar',
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
                'Input name',
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
                  hintText: 'Please enter an avatar name',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              )),
            ],
          ).intoContainer(color: Color(0xff242830), padding: EdgeInsets.symmetric(horizontal: $(25))),
          SizedBox(height: $(20)),
          Row(
            children: [
              TitleTextWidget(
                'Select a style',
                ColorConstant.White,
                FontWeight.w500,
                $(15),
                maxLines: 2,
              ),
              SizedBox(width: $(12)),
              Expanded(
                child: Wrap(
                  spacing: $(12),
                  runSpacing: $(12),
                  alignment: WrapAlignment.start,
                  children: aiManager.config!
                      .getRoles()
                      .map(
                        (e) => Text(
                          e,
                          style: TextStyle(
                            color: ColorConstant.White,
                            fontFamily: 'Poppins',
                            fontSize: $(15),
                          ),
                        )
                            .intoContainer(
                                padding: EdgeInsets.symmetric(horizontal: $(10), vertical: $(4)),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: ColorConstant.BlueColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                  color: selectedStyle == e ? ColorConstant.BlueColor : Colors.transparent,
                                ))
                            .intoGestureDetector(onTap: () {
                          setState(() {
                            selectedStyle = e;
                          });
                        }),
                      )
                      .toList(),
                ),
              ),
            ],
          ).intoContainer(color: Color(0xff242830), padding: EdgeInsets.symmetric(horizontal: $(25), vertical: $(10))),
          SizedBox(height: $(10)),
          Expanded(child: Container()),
          TitleTextWidget(
            'Create',
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
              CommonExtension().showToast('Please input name');
              return;
            }
            if (selectedStyle == null) {
              FocusScope.of(context).requestFocus(FocusNode());
              CommonExtension().showToast('Please select style');
              return;
            }
            Navigator.of(context).pop(MapEntry(name, selectedStyle!));
          }),
        ],
      ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context))),
    );
  }
}
