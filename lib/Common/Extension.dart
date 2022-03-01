import 'package:cartoonizer/Common/ColorConstant.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommonExtension{

  bool isValidEmail(String email){
    return RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(email);
  }

  void showToast(String text){
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: ColorConstant.BtnTextColor,
        textColor: ColorConstant.White,
        fontSize: 16.0
    );
  }
}
