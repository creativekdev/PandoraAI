import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/models/UserModel.dart';

class HomeTabUserHolder {
  UserModel? user;

  Future<void> initStoreInfo(BuildContext context) async {
    user = await API.getLogin(needLoad: true, context: context);
  }
}
