import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';

class FeedbackDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FeedbackDialogState();
  }
}

class FeedbackDialogState extends AppState<FeedbackDialog> {
  late CartoonizerApi api;
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
  }

  submit() {
    var content = textEditingController.text.trim();
    if (content.isEmpty) {
      CommonExtension().showToast('Please input feedback');
      return;
    }
    showLoading().whenComplete(() {
      api.feedback(content).then((value) {
        hideLoading().whenComplete(() {
          if (value != null) {
            CommonExtension().showToast('Thanks for your opinions');
            Navigator.pop(context, true);
          }
        });
      });
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleTextWidget(S.of(context).give_feedback, ColorConstant.White, FontWeight.w600, $(17)).intoContainer(
          padding: EdgeInsets.only(top: $(25), bottom: $(15), left: $(15), right: $(15)),
        ),
        TextField(
          controller: textEditingController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: S.of(context).input_feedback,
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: ColorConstant.InputContent,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: $(4)),
            isDense: false,
          ),
          style: TextStyle(
            color: ColorConstant.White,
            fontSize: $(15),
            fontFamily: 'Poppins',
            height: 1,
          ),
          minLines: 5,
          maxLines: 5,
        ).intoContainer(
          padding: EdgeInsets.all($(10)),
          margin: EdgeInsets.symmetric(horizontal: $(15)),
          decoration: BoxDecoration(color: Color(0xff33363a), borderRadius: BorderRadius.circular($(6))),
        ),
        Text(
          S.of(context).submit,
          style: TextStyle(color: ColorConstant.White, fontFamily: 'Poppins', fontSize: $(17)),
        )
            .intoContainer(
                alignment: Alignment.center,
                width: double.maxFinite,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular($(6)), color: ColorConstant.BlueColor),
                padding: EdgeInsets.symmetric(vertical: $(10)),
                margin: EdgeInsets.only(
                  top: $(15),
                  bottom: $(20),
                  left: $(15),
                  right: $(15),
                ))
            .intoGestureDetector(onTap: () {
          submit();
        }),
      ],
    ).customDialogStyle();
  }
}
