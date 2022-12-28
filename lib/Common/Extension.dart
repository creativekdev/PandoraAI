import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/toast/ok_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommonExtension {
  bool isValidEmail(String email) {
    return RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(email);
  }

  void showToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: ColorConstant.CardColor,
        textColor: ColorConstant.White,
        fontSize: 16.0);
  }

  void showImageSavedOkToast(BuildContext context) {
    showCustomToast(
        context,
        OkToast(
            text: S.of(context).toastImageSaved,
            color: Color.fromARGB(255, 206, 206, 206),
            icon: Image.asset(
              ImagesConstant.ic_image_saved,
              width: $(36),
            )));
  }

  void showVideoSavedOkToast(BuildContext context) {
    showCustomToast(
        context,
        OkToast(
            text: S.of(context).toastVideoSaved,
            color: Color.fromARGB(255, 206, 206, 206),
            icon: Image.asset(
              ImagesConstant.ic_image_saved,
              width: $(36),
            )));
  }

  void showFailedToast(BuildContext context) {
    showCustomToast(
      context,
      OkToast(
          text: S.of(context).commonFailedToast,
          color: Color.fromARGB(255, 206, 206, 206),
          icon: Image.asset(
            ImagesConstant.ic_image_failed,
            width: $(36),
          )),
    );
  }

  void showCustomToast(BuildContext context, Widget widget) {
    var entry = OverlayEntry(
      builder: (_) => Center(child: widget),
    );

    Overlay.of(context)?.insert(entry);
    Timer(const Duration(seconds: 2), () {
      entry.remove();
    });
  }
}
