import 'package:cartoonizer/Common/importFile.dart';

import '../../api/cartoonizer_api.dart';
import '../../models/discovery_list_entity.dart';

class HomeDetailsController extends GetxController {
  HomeDetailsController();

  late CartoonizerApi cartoonizerApi;

  late ScrollController scrollController;

  bool _isLoading = false;

  String? category;
  List<DiscoveryListEntity>? _posts;

  set posts(List<DiscoveryListEntity>? value) {
    _posts = value;
    update();
  }

  List<DiscoveryListEntity>? get posts => _posts;

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
    scrollController = ScrollController()
      ..addListener(() {
        if (scrollController.position.pixels + $(80) >= scrollController.position.maxScrollExtent) {
          onLoadMore();
        }
      });
  }

  onLoadMore() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    cartoonizerApi.socialHomePost(from: _posts?.length ?? 0, size: 10, category: category ?? '').then((value) {
      _posts?.addAll(value?.data.rows ?? []);
      _isLoading = false;
      update();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }
}
