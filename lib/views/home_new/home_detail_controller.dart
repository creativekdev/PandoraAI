import 'package:cartoonizer/Common/importFile.dart';

import '../../api/cartoonizer_api.dart';
import '../../app/cache/cache_manager.dart';
import '../../models/discovery_list_entity.dart';

class HomeDetailController extends GetxController {
  HomeDetailController({required int index, required List<DiscoveryListEntity>? posts, required String? categoryVaule}) {
    _index = index;
    _posts = posts;
    category = categoryVaule;
    pageController = PageController(initialPage: index);
    manager = CacheManager().getManager();
    isShowedGuide = manager.getBool(CacheManager.showedGuideOfHomeDetail);
  }

  late CacheManager manager;

  late CartoonizerApi cartoonizerApi;

  late bool isShowedGuide;

  late PageController pageController;

  bool _isLoading = false;

  String? category;

  int? _index;

  set index(int? value) {
    _index = value;
    if (_index! >= (_posts!.length - 2)) {
      onLoadMore();
      update();
    }
    if (isShowedGuide == false) {
      manager.setBool(CacheManager.showedGuideOfHomeDetail, true);
      isShowedGuide = true;
      update();
    }
  }

  int? get index => _index;

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
    cartoonizerApi.unbind();
    pageController.dispose();
  }
}
