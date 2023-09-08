import 'package:cartoonizer/Common/importFile.dart';

import '../../api/app_api.dart';
import '../../models/discovery_list_entity.dart';
import '../../models/home_post_entity.dart';

class HomeDetailsController extends GetxController {
  HomeDetailsController();

  late AppApi appApi;

  late ScrollController scrollController;

  bool _isLoading = false;

  String? category;
  List<DiscoveryListEntity>? _posts;

  set posts(List<DiscoveryListEntity>? value) {
    _posts = value;
    update();
  }

  List<DiscoveryListEntity>? get posts => _posts;
  int? records;

  @override
  void onInit() {
    super.onInit();
    appApi = AppApi().bindController(this);
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

    // appApi.socialHomePost(from: _posts?.length ?? 0, size: 10, category: category ?? '').then((value) {
    //   _posts?.addAll(value?.data.rows ?? []);
    //   _isLoading = false;
    //   update();
    // });
    HomePostEntity? homePostEntity = await loadData(posts?.length ?? 0, 10);
    if (records != homePostEntity?.data.records) {
      homePostEntity = await loadData(0, homePostEntity?.data.records ?? 0);
      records = homePostEntity?.data.records ?? 0;
      _posts = homePostEntity?.data.rows ?? [];
      _isLoading = false;
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
    scrollController.dispose();
  }
}
