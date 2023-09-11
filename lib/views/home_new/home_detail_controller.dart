import 'package:cartoonizer/Common/importFile.dart';

import '../../api/app_api.dart';
import '../../app/cache/cache_manager.dart';
import '../../models/discovery_list_entity.dart';
import '../../models/home_post_entity.dart';

class HomeDetailController extends GetxController {
  HomeDetailController({required int index, required List<DiscoveryListEntity>? posts, required String? categoryVaule, required int records}) {
    _index = index;
    _posts = posts;
    currentPost = _posts![_index!];
    category = categoryVaule;
    _records = records;
    pageController = PageController(initialPage: index);
    manager = CacheManager().getManager();
    isShowedGuide = manager.getBool(CacheManager.showedGuideOfHomeDetail);
  }

  late DiscoveryListEntity _currentPost;

  set currentPost(DiscoveryListEntity value) {
    _currentPost = value;
    update();
  }

  DiscoveryListEntity get currentPost => _currentPost;

  late CacheManager manager;

  late AppApi appApi;

  late bool isShowedGuide;

  late PageController pageController;
  int? _records;

  set records(int? value) {
    _records = value;
    update();
  }

  int? get records => _records;

  Offset? _offset;

  Offset? get offset => _offset;

  set offset(Offset? value) {
    _offset = value;
    update();
  }

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

  getNewIndex(int newIndex) {
    index = newIndex;
    currentPost = _posts![_index!];
    update();
  }

  getNewIndexByPost() {
    for (int i = 0; i < _posts!.length; i++) {
      DiscoveryListEntity post = _posts![i];
      if (post.id == _currentPost.id) {
        index = i;
        break;
      }
    }
    pageController.jumpToPage(index!);
    update();
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
    appApi = AppApi().bindController(this);
  }

  onLoadMore() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    HomePostEntity? homePostEntity = await loadData(posts?.length ?? 0, 10);
    if (records != homePostEntity?.data.records) {
      homePostEntity = await loadData(0, homePostEntity?.data.records ?? 0);
      records = homePostEntity?.data.records ?? 0;
      _posts = homePostEntity?.data.rows ?? [];
      _isLoading = false;
      getNewIndexByPost();
      update();
    } else {
      _posts?.addAll(homePostEntity?.data.rows ?? []);
      _isLoading = false;
      update();
    }
  }

  Future<HomePostEntity?> loadData(int from, int size) async {
    return await appApi.socialHomePost(from: from, size: size, category: category ?? '');
  }

  @override
  void dispose() {
    super.dispose();
    appApi.unbind();
    pageController.dispose();
  }
}
