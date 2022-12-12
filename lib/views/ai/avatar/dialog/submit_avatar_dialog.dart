import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/input_text.dart';
import 'package:common_utils/common_utils.dart';

class SubmitAvatarDialog {
  static Future<String?> push(
    BuildContext context, {
    required String name,
  }) async {
    return showDialog<String>(
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
          'Give your avatars a cool\ncode-name',
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
        SizedBox(height: $(10)),
        TitleTextWidget(
          'Submit',
          ColorConstant.White,
          FontWeight.w500,
          $(17),
        )
            .intoContainer(
                width: double.maxFinite,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                margin: EdgeInsets.symmetric(horizontal: $(15)),
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
          Navigator.of(context).pop(name);
        }),
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
        .intoMaterial(color: Colors.transparent);
  }
}
