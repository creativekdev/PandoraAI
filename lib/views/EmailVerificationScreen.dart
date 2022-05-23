import 'dart:convert';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/common/utils.dart';
import 'package:cartoonizer/api.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cartoonizer/views/HomeScreen.dart';

import '../common/Extension.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? email;

  EmailVerificationScreen(this.email);

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  bool isLoading = false;
  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  Timer _timer = Timer(Duration(milliseconds: 1), () {});
  int _start = 60;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _start = 60;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  clickLogout() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
      ModalRoute.withName('/HomeScreen'),
    );
  }

  clickResend() async {
    if (_start != 60) {
      return;
    }

    setState(() {
      isLoading = true;
    });
    startTimer();
    var user = await getUser();

    Map<String, String> body = {
      "email": widget.email ?? "",
    };

    try {
      final response = await API.post("/user/${user.id}/activation/send", body: body);
      if (response.statusCode == 200) {
        CommonExtension().showToast("Resend successfully!");
      } else {
        var body = jsonDecode(response.body);
        CommonExtension().showToast(body['message'] ?? "Resend failure.");
      }
    } catch (e) {
      CommonExtension().showToast("Resend failure.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  callActivate() async {
    setState(() {
      isLoading = true;
    });

    var body = {
      "code": currentText,
    };

    try {
      final response = await API.post("/api/user/activate", body: body);

      if (response.statusCode == 200) {
        CommonExtension().showToast("Activate successfully!");
        loginBack(context);
      } else {
        var body = jsonDecode(response.body);
        textEditingController.clear();
        CommonExtension().showToast(body['message'] ?? "Activate failure.");
      }
    } catch (e) {
      CommonExtension().showToast("Activate failure.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            backgroundColor: ColorConstant.BackgroundColor,
            body: SafeArea(
                child: LoadingOverlay(
                    isLoading: isLoading,
                    child: SingleChildScrollView(
                      child: Container(
                        // height:80.h,
                        width: 100.w,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: MediaQuery.of(context).size.height / 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                StringConstant.enter_email_code,
                                style: TextStyle(color: ColorConstant.BtnTextColor, fontWeight: FontWeight.bold, fontSize: 28),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Form(
                              key: formKey,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                  child: PinCodeTextField(
                                    appContext: context,
                                    length: 6,
                                    animationType: AnimationType.fade,
                                    pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.box,
                                        borderRadius: BorderRadius.circular(5),
                                        fieldHeight: 50,
                                        fieldWidth: 45,
                                        inactiveColor: ColorConstant.BtnBorderColor,
                                        selectedColor: ColorConstant.BtnBorderColor,
                                        selectedFillColor: Colors.white,
                                        activeColor: ColorConstant.PrimaryColor,
                                        activeFillColor: Colors.white,
                                        inactiveFillColor: Colors.white),
                                    cursorColor: Colors.black,
                                    animationDuration: Duration(milliseconds: 300),
                                    enableActiveFill: true,
                                    errorAnimationController: errorController,
                                    controller: textEditingController,
                                    keyboardType: TextInputType.number,
                                    boxShadows: [
                                      BoxShadow(
                                        offset: Offset(0, 1),
                                        color: Colors.black12,
                                        blurRadius: 10,
                                      )
                                    ],
                                    onCompleted: (v) {
                                      callActivate();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        currentText = value;
                                      });
                                    },
                                    beforeTextPaste: (text) {
                                      return true;
                                    },
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                              child: RichText(
                                text: TextSpan(
                                    text: StringConstant.code_send_to_email,
                                    children: [
                                      TextSpan(text: "${widget.email}", style: TextStyle(color: ColorConstant.BtnTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
                                    ],
                                    style: TextStyle(color: ColorConstant.HintColor, fontSize: 16)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                child: Column(
                                  children: [
                                    Text(
                                      StringConstant.resend_tips,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: ColorConstant.HintColor, fontSize: 16),
                                    ),
                                    TextButton(
                                        onPressed: _start == 60 ? () => clickResend() : null,
                                        child: Text(
                                          '${StringConstant.resend}${_start == 60 ? "" : " ${_start}"}',
                                          style:
                                              TextStyle(color: _start == 60 ? ColorConstant.PrimaryColor : ColorConstant.BtnTextColor, fontWeight: FontWeight.bold, fontSize: 16),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => clickLogout(),
                                          child: Text(
                                            "Click logout",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: ColorConstant.PrimaryColor, fontWeight: FontWeight.w500, fontFamily: 'Poppins', decoration: TextDecoration.underline),
                                          ),
                                        ),
                                        Text(
                                          StringConstant.resend_logout,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: ColorConstant.HintColor, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    )))));
  }
}
