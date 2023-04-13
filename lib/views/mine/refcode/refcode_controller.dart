import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:common_utils/common_utils.dart';

class RefCodeController extends GetxController {
  UserManager userManager = AppDelegate().getManager();
  AvatarAiManager aiManager = AppDelegate().getManager();
  TextEditingController textEditingController = TextEditingController();
  late CartoonizerApi api;

  List<RefTab> tabList = [
    RefTab.enterCode,
    RefTab.myCode,
  ];
  late TabController tabController;
  bool inputEnable = false;

  refreshInputEnable() {
    if (textEditingController.text.length != 0) {
      if (!inputEnable) {
        inputEnable = true;
        update();
      }
    } else {
      if (inputEnable) {
        inputEnable = false;
        update();
      }
    }
  }

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    if (_currentIndex == index) {
      return;
    }
    this._currentIndex = index;
    update();
  }

  String get inputText => textEditingController.text;

  set inputText(String text) {
    textEditingController.text = text;
    refreshInputEnable();
  }

  bool get referred {
    return userManager.user?.isReferred ?? false;
  }

  @override
  void onInit() {
    super.onInit();
    api = CartoonizerApi().bindController(this);
  }

  @override
  void dispose() {
    api.unbind();
    super.dispose();
  }

  Future<bool> submit(BuildContext context) async {
    var text = textEditingController.text;
    if (TextUtil.isEmpty(text)) {
      CommonExtension().showToast(S.of(context).please_input_invited_code);
      return false;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    var value = await api.submitInvitedCode(text);
    if (value != null) {
      return true;
    } else {
      return false;
    }
  }
}

enum RefTab {
  enterCode,
  myCode,
}

extension RefTabEx on RefTab {
  String title(BuildContext context) {
    switch (this) {
      case RefTab.enterCode:
        return S.of(context).enter_code;
      case RefTab.myCode:
        return S.of(context).my_code;
    }
  }
}
