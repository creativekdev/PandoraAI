import 'package:cartoonizer/common/importFile.dart';

class ListData {
  int page;
  dynamic data;
  bool visible;
  Rx<bool> liked = false.obs;

  ListData({
    this.data,
    required this.page,
    this.visible = true,
    required bool liked,
  }) {
    this.liked.value = liked;
  }
}
