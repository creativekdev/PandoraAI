import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';

class DiscoveryListController extends GetxController {
  late CartoonizerApi api;

  List<TagData> tags = [
    TagData(title: '# Me-taverse', tag: 'another_me'),
    TagData(title: '# AITextToImage', tag: 'txt2img'),
    TagData(title: '# AIScribble', tag: 'scribble'),
    TagData(title: '# Facetoon', tag: 'cartoonize'),
    TagData(title: '# PandoraAvatar', tag: 'ai_avatar')
  ];
  TagData? _currentTag;

  TagData? get currentTag => _currentTag;

  set currentTag(TagData? data) {
    _currentTag = data;
    update();
  }

  int page = 0;
  int pageSize = 10;
  List<ListData> dataList = [];
  bool listLoading = false;

  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onAppStateListener;
  late StreamSubscription onCreateCommentListener;
  late StreamSubscription onDeleteListener;
  late StreamSubscription onNewPostEventListener;
  late TabController tabController;

  late ScrollController scrollController;
  Rx<bool> likeLocalAddAlready = false.obs;

  @override
  void onInit() {
    super.onInit();
    api = CartoonizerApi().bindController(this);
    scrollController = ScrollController();
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      // Check if the event data is null or true and the list is not loading.
      if (event.data ?? true && !listLoading) {
        // Call the EasyRefresh controller's callRefresh() method to retrieve the latest data from the server.
        onLoadFirstPage();
      } else {
        // Set the likeId property to null for each data item in the data list.
        for (var value in dataList) {
          value.data!.likeId = null;
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
  }

  @override
  void onReady() {
    super.onReady();
    onLoadFirstPage();
  }

  @override
  void dispose() {
    api.unbind();
    onLoginEventListener.cancel();
    onLikeEventListener.cancel();
    onUnlikeEventListener.cancel();
    onAppStateListener.cancel();
    onCreateCommentListener.cancel();
    onDeleteListener.cancel();
    onNewPostEventListener.cancel();
    super.dispose();
  }

  /// This function adds data to the data list.
  Future<void> addToDataList(int page, List<DiscoveryListEntity> list) async {
    /// Loop through the [list] parameter.
    for (int i = 0; i < list.length; i++) {
      /// Get the current item in the list and create a new ListData object with a page number
      /// and a reference to the data item.
      var data = list[i];
      dataList.add(ListData(
        page: page,
        data: data,

        /// Set the visible property to true if no other data item in the data list has an ID matching the current item's ID.
        visible: dataList.pick((t) => t.data?.id == data.id) == null,
      ));
    }
  }

  /// This function loads the first page of data.
  /// return noMore
  Future<bool> onLoadFirstPage() async {
    listLoading = true;
    update();
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
}

class ListData {
  int page;
  DiscoveryListEntity? data;
  bool visible;

  ListData({
    this.data,
    required this.page,
    this.visible = true,
  });
}

class TagData {
  String tag;
  String title;

  TagData({
    required this.title,
    required this.tag,
  });
}
