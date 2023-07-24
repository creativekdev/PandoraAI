import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/api/socialmedia_connector_api.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/views/discovery/widget/show_report_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Common/Extension.dart';
import '../../app/app.dart';

class DiscoveryListController extends GetxController {
  late AppApi api;
  late SocialMediaConnectorApi socialMediaConnectorApi;

  List<TagData> tags = [
    TagData(title: '# StyleMorph', tag: 'stylemorph'),
    TagData(title: '# AIColoring', tag: 'lineart'),
    TagData(title: '# Me-taverse', tag: 'another_me'),
    TagData(title: '# AITextToImage', tag: 'txt2img'),
    TagData(title: '# AIScribble', tag: 'scribble'),
    TagData(title: '# Facetoon', tag: 'cartoonize'),
    TagData(title: '# PandoraAvatar', tag: 'ai_avatar'),
  ];
  TagData? _currentTag;

  TagData? get currentTag => _currentTag;

  set currentTag(TagData? data) {
    _currentTag = data;
    update();
  }

  bool _isMetagram = false;

  set isMetagram(bool value) {
    _isMetagram = value;
    update();
  }

  bool get isMetagram => _isMetagram;
  int page = 0;
  int pageSize = 10;
  List<ListData> dataList = [];
  bool listLoading = false;

  Function(bool scrollDown)? onScrollChange;
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onAppStateListener;
  late StreamSubscription onCreateCommentListener;
  late StreamSubscription onDeleteListener;
  late StreamSubscription onNewPostEventListener;
  late StreamSubscription networkListener;
  late TabController tabController;

  late ScrollController scrollController;
  Rx<bool> likeLocalAddAlready = false.obs;

  double lastScrollPos = 0;
  bool lastScrollDown = false;

  @override
  void onInit() {
    super.onInit();
    api = AppApi().bindController(this);
    socialMediaConnectorApi = SocialMediaConnectorApi().bindController(this);
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.positions.isEmpty) {
        return;
      }
      if (scrollController.positions.length != 1) {
        return;
      }
      var newPos = scrollController.position.pixels;
      if (newPos < 0) {
        return;
      }
      if (newPos - lastScrollPos > 0) {
        if (!lastScrollDown) {
          lastScrollDown = true;
          onScrollChange?.call(lastScrollDown);
        }
      } else {
        if (lastScrollDown) {
          lastScrollDown = false;
          onScrollChange?.call(lastScrollDown);
        }
      }
      lastScrollPos = newPos;
    });

    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      // Check if the event data is null or true and the list is not loading.
      if (event.data ?? true && !listLoading) {
        // Call the EasyRefresh controller's callRefresh() method to retrieve the latest data from the server.
        onLoadFirstPage();
      } else {
        // Set the likeId property to null for each data item in the data list.
        for (var value in dataList) {
          if (value.data is DiscoveryListEntity) {
            value.data!.likeId = null;
          }
        }
        // Update the view.
        update();
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      // Get the ID and like ID from the event data.
      var id = event.data!.key;
      var likeId = event.data!.value;
      // For each data item in the data list, check if the ID matches the event ID.
      // If so, update the likeId and likes properties, and update the view.
      for (var data in dataList) {
        if (data.data!.id == id) {
          data.data!.likeId = likeId;
          data.liked.value = true;
          if (likeLocalAddAlready.value) {
            likeLocalAddAlready.value = false;
          } else {
            data.data!.likes++;
          }
          update();
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      // For each data item in the data list, check if the ID matches the event ID.
      // If so, set the likeId property to null, decrement the likes property, and update the view.
      for (var data in dataList) {
        if (data.data!.id == event.data) {
          data.data!.likeId = null;
          data.liked.value = false;
          if (likeLocalAddAlready.value) {
            likeLocalAddAlready.value = false;
          } else {
            data.data!.likes--;
          }
          update();
        }
      }
    });

    // When the app state changes, update the view.
    onAppStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      update();
    });

    // If there is 1 comment, loop through the data list and increment the comments property for the data item with the matching ID.
    // Update the view.
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (event.data?.length == 1) {
        for (var value in dataList) {
          if (value.data!.id == event.data![0]) {
            value.data!.comments++;
            break;
          }
        }
        update();
      }
    });

    // Loop through the data list and mark the data item with the matching ID as removed.
    // Update the view.
    onDeleteListener = EventBusHelper().eventBus.on<OnDeleteDiscoveryEvent>().listen((event) {
      for (var value in dataList) {
        if (value.data!.id == event.data) {
          value.data!.removed = true;
          break;
        }
      }
      update();
    });

    // Create an event listener that listens for new post events and calls the onLoadFirstPage() method.
    onNewPostEventListener = EventBusHelper().eventBus.on<OnNewPostEvent>().listen((event) {
      onLoadFirstPage();
    });
    networkListener = EventBusHelper().eventBus.on<OnNetworkStateChangeEvent>().listen((event) {
      if (dataList.isEmpty) {
        if (event.data != ConnectivityResult.none) {
          onLoadFirstPage();
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    onLoadFirstPage();
  }

  @override
  void dispose() {
    api.unbind();
    socialMediaConnectorApi.unbind();
    onLoginEventListener.cancel();
    onLikeEventListener.cancel();
    onUnlikeEventListener.cancel();
    onAppStateListener.cancel();
    onCreateCommentListener.cancel();
    onDeleteListener.cancel();
    onNewPostEventListener.cancel();
    networkListener.cancel();
    super.dispose();
  }

  /// This function adds data to the data list.
  Future<void> addToDataList(int page, List<dynamic> list) async {
    for (int i = 0; i < list.length; i++) {
      /// Get the current item in the list and create a new ListData object with a page number
      /// and a reference to the data item.
      var data = list[i];
      if (data is SocialPostPageEntity) {
        dataList.add(ListData(page: page, data: data, liked: false, visible: true));
      } else if (data is DiscoveryListEntity) {
        dataList.add(ListData(
          page: page,
          data: data,
          liked: data.likeId != null,
          visible: dataList.pick((t) => t.data?.id == data.id) == null,
        ));
      }
    }
  }

  /// This function loads the first page of data.
  /// return noMore
  Future<bool> onLoadFirstPage() async {
    listLoading = true;
    update();
    if (isMetagram) {
      return await _loadFirstMetagram();
    } else {
      return await _loadFirstDiscovery();
    }
  }

  Future<bool> _loadFirstMetagram() async {
    var value = await socialMediaConnectorApi.listAllMetagrams(from: 0, size: pageSize);
    delay(() {
      listLoading = false;
      update();
    }, milliseconds: 1500);
    if (value != null) {
      Events.discoveryLoading();
      page = 0;
      dataList.clear();
      var list = value.getDataList<SocialPostPageEntity>();
      addToDataList(page, list).whenComplete(() {
        update();
      });
      return false;
    } else {
      return false;
    }
  }

  Future<bool> _loadFirstDiscovery() async {
    var value = await api.listDiscovery(
      from: 0,
      pageSize: pageSize,
      sort: DiscoverySort.newest,
      category: currentTag?.tag,
    );
    delay(() {
      listLoading = false;
      update();
    }, milliseconds: 1500);
    if (value != null) {
      Events.discoveryLoading();
      page = 0;
      dataList.clear();
      var list = value.getDataList<DiscoveryListEntity>();
      addToDataList(page, list).whenComplete(() {
        update();
      });
      return list.length != pageSize;
    } else {
      return false;
    }
  }

  Future<bool> onLoadMorePage() async {
    listLoading = true;
    update();
    if (isMetagram) {
      return await _loadMoreMetagram();
    } else {
      return await _loadMoreDiscovery();
    }
  }

  Future<bool> _loadMoreMetagram() async {
    var value = await socialMediaConnectorApi.listAllMetagrams(from: (page + 1) * pageSize, size: pageSize);
    delay(() {
      listLoading = false;
      update();
    }, milliseconds: 1500);
    if (value == null) {
      return false;
    } else {
      page++;
      var list = value.getDataList<SocialPostPageEntity>();
      addToDataList(page, list).whenComplete(() {
        update();
      });
      return list.length != pageSize;
    }
  }

  Future<bool> _loadMoreDiscovery() async {
    var value = await api.listDiscovery(
      from: (page + 1) * pageSize,
      pageSize: pageSize,
      sort: DiscoverySort.newest,
      category: currentTag?.tag,
    );
    delay(() {
      listLoading = false;
      update();
    }, milliseconds: 1500);
    if (value == null) {
      return false;
    } else {
      page++;
      var list = value.getDataList<DiscoveryListEntity>();
      addToDataList(page, list).whenComplete(() {
        update();
      });
      return list.length != pageSize;
    }
  }

  void onLongPressAction(DiscoveryListEntity data, BuildContext context) {
    UserManager userManager = AppDelegate.instance.getManager();
    userManager.doOnLogin(context, logPreLoginAction: 'loginNormal', currentPageRoute: '/DiscoveryListScreen', callback: () {
      reportAction(data, context);
    });
  }

  reportAction(DiscoveryListEntity data, BuildContext context) {
    CacheManager manager = CacheManager().getManager();
    UserManager userManager = AppDelegate.instance.getManager();
    final String posts = manager.getString("${CacheManager.reportOfPosts}_${userManager.user?.id}");
    if (posts.contains("${data.id.toString()},")) {
      CommonExtension().showToast(S.of(context).HaveReport, gravity: ToastGravity.CENTER);
      return;
    }
    api.postReport(data.id).then((value) {
      if (posts.isEmpty) {
        manager.setString("${CacheManager.reportOfPosts}_${userManager.user?.id}", "${data.id.toString()},");
      } else {
        manager.setString("${CacheManager.reportOfPosts}_${userManager.user?.id}", "$posts${data.id.toString()},");
      }
      showReportDialog(context);
    });
  }
}

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

class TagData {
  String tag;
  String title;

  TagData({
    required this.title,
    required this.tag,
  });
}
