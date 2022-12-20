import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/input_text.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:common_utils/common_utils.dart';

class SubmitAvatarDialog {
  static Future<MapEntry<String, String>?> push(
    BuildContext context, {
    required String name,
  }) async {
    return showDialog<MapEntry<String, String>>(
        context: context,
        builder: (context) => _SubmitAvatarDialog(
              name: name,
            ));
  }
}

class _SubmitAvatarDialog extends StatefulWidget {
  String name;

  _SubmitAvatarDialog({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  State<_SubmitAvatarDialog> createState() => _SubmitAvatarDialogState();
}

class _SubmitAvatarDialogState extends State<_SubmitAvatarDialog> {
  TextEditingController controller = TextEditingController();
  AvatarAiManager aiManager = AppDelegate().getManager();
  String? selectedStyle;

  @override
  void initState() {
    super.initState();
    controller.text = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleTextWidget(
          'Give your avatars a cool \ncode-name',
          ColorConstant.White,
          FontWeight.w600,
          $(17),
          maxLines: 2,
        ),
        InputText(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'input name',
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
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))),
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
                        ),
                      )
                          .intoContainer(
                              padding: EdgeInsets.symmetric(horizontal: $(8)),
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
        ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25), vertical: $(10))),
        SizedBox(height: $(10)),
        Row(
          children: [
            Expanded(
                child: TitleTextWidget(
              'Cancel',
              ColorConstant.Red,
              FontWeight.w500,
              $(17),
            )
                    .intoContainer(
                        width: double.maxFinite,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: $(10)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular($(8)),
                          border: Border.all(color: ColorConstant.Red, width: 1),
                        ))
                    .intoGestureDetector(onTap: () {
              Navigator.of(context).pop();
            })),
            SizedBox(width: $(12)),
            Expanded(
                child: TitleTextWidget(
              'Ok',
              ColorConstant.White,
              FontWeight.w500,
              $(17),
            )
                    .intoContainer(
                        width: double.maxFinite,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: $(10)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular($(8)),
                          color: ColorConstant.BlueColor,
                        ))
                    .intoGestureDetector(onTap: () {
              var name = controller.text.trim();
              if (TextUtil.isEmpty(name)) {
                CommonExtension().showToast('Please input name');
                return;
              }
              if (selectedStyle == null) {
                CommonExtension().showToast('Please select style');
                return;
              }
              Navigator.of(context).pop(MapEntry(name, selectedStyle!));
            })),
          ],
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
      ],
    )
        .intoContainer(
          decoration: BoxDecoration(
            color: ColorConstant.BackgroundColor,
            borderRadius: BorderRadius.circular($(8)),
          ),
          padding: EdgeInsets.symmetric(vertical: $(12)),
          margin: EdgeInsets.symmetric(horizontal: $(35)),
        )
        .intoCenter()
        .intoMaterial(color: Colors.transparent)
        .blankAreaIntercept();
  }
}
