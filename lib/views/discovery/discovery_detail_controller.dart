import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/views/discovery/widget/show_report_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../app/user/user_manager.dart';

class DiscoveryDetailController extends GetxController {
  DiscoveryListEntity discoveryEntity;
  late CartoonizerApi api;

  int pageSize = 20;
  List<DiscoveryCommentListEntity> dataList = [];
  late StreamSubscription onLoginEventListener;
  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  late StreamSubscription onDiscoveryLikeEventListener;
  late StreamSubscription onDiscoveryUnlikeEventListener;
  late StreamSubscription onCreateCommentListener;
  List<DiscoveryResource> resources = [];

  ScrollController scrollController = ScrollController();
  CacheManager cacheManager = AppDelegate().getManager();
  Rx<bool> likeLocalAddAlready = false.obs;
  Rx<bool> liked = false.obs;

  DiscoveryDetailController({required this.discoveryEntity});

  bool _isRequesting = false;
  Rx<int> loadingCommentId = 0.obs;

  void onReportAction(DiscoveryCommentListEntity data, BuildContext context) {
    UserManager userManager = AppDelegate.instance.getManager();
    userManager.doOnLogin(context, logPreLoginAction: 'loginNormal', currentPageRoute: '/DiscoveryDetailScreen', callback: () {
      reportCommentAction(data, context);
    });
  }

  reportCommentAction(DiscoveryCommentListEntity data, BuildContext context) {
    CacheManager manager = CacheManager().getManager();
    UserManager userManager = AppDelegate.instance.getManager();
    final String posts = manager.getString("${CacheManager.reportOfCommentPosts}_${userManager.user?.id}");
    if (posts.contains("${data.id.toString()},")) {
      CommonExtension().showToast(S.of(context).HaveReport, gravity: ToastGravity.CENTER);
      return;
    }
    api.postCommentReport(data.id).then((value) {
      final String posts = manager.getString("${CacheManager.reportOfCommentPosts}_${userManager.user?.id}");
      if (posts.isEmpty) {
        manager.setString("${CacheManager.reportOfCommentPosts}_${userManager.user?.id}", "${data.id.toString()},");
      } else {
        manager.setString("${CacheManager.reportOfCommentPosts}_${userManager.user?.id}", "$posts${data.id.toString()},");
      }
      showReportDialog(context);
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

  @override
  void onInit() {
    super.onInit();
    resources = discoveryEntity.resourceList();
    liked.value = discoveryEntity.likeId != null;
    api = CartoonizerApi().bindController(this);
    onLoginEventListener = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? true) {
        loadFirstPage();
      } else {
        for (var value in dataList) {
          value.likeId = null;
        }
        update();
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnCommentLikeEvent>().listen((event) {
      var id = event.data!.key;
      var likeId = event.data!.value;
      for (var data in dataList) {
        if (data.id == id) {
          data.likeId = likeId;
          if (likeLocalAddAlready.value) {
            likeLocalAddAlready.value = false;
          } else {
            data.likes++;
          }
          update();
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnCommentUnlikeEvent>().listen((event) {
      for (var data in dataList) {
        if (data.id == event.data) {
          data.likeId = null;
          if (likeLocalAddAlready.value) {
            likeLocalAddAlready.value = false;
          } else {
            data.likes--;
          }
          update();
        }
      }
    });
    onDiscoveryLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      if (discoveryEntity.id == event.data!.key) {
        if (likeLocalAddAlready.value) {
          likeLocalAddAlready.value = false;
        } else {
          discoveryEntity.likes++;
        }
        discoveryEntity.likeId = event.data!.value;
        update();
      }
    });
    onDiscoveryUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      if (discoveryEntity.id == event.data) {
        if (likeLocalAddAlready.value) {
          likeLocalAddAlready.value = false;
        } else {
          discoveryEntity.likes--;
        }
        discoveryEntity.likeId = null;
        update();
      }
    });
    onCreateCommentListener = EventBusHelper().eventBus.on<OnCreateCommentEvent>().listen((event) {
      if (event.data![0] == discoveryEntity.id) {
        discoveryEntity.comments++;
        update();
      } else if ((event.data?.length ?? 0) > 1) {
        for (var value in dataList) {
          if (value.id == event.data![1]) {
            value.comments++;
            break;
          }
        }
        update();
      }
    });
    scrollController.addListener(() {
      if (_isRequesting) {
        return;
      }
      if (dataList.length < pageSize) {
        return;
      }
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent - 20) {
        print("-------------------scroll-----${scrollController.offset}");
        loadMorePage();
      }
    });
    var json = cacheManager.getJson('${CacheManager.commentList}:${discoveryEntity.id}') ?? [];
    dataList = jsonConvert.convertListNotNull<DiscoveryCommentListEntity>(json) ?? [];
  }

  _saveData() {
    cacheManager.setJson('${CacheManager.commentList}:${discoveryEntity.id}', dataList.map((e) => e.toJson()).toList());
  }

  @override
  void onReady() {
    super.onReady();
    loadFirstPage();
  }

  @override
  void dispose() {
    api.unbind();
    onUnlikeEventListener.cancel();
    onLikeEventListener.cancel();
    onLoginEventListener.cancel();
    onDiscoveryLikeEventListener.cancel();
    onDiscoveryUnlikeEventListener.cancel();
    onCreateCommentListener.cancel();
    super.dispose();
  }

  loadFirstPage() {
    if (_isRequesting) {
      return;
    }
    _isRequesting = true;
    api
        .listDiscoveryComments(
      from: 0,
      pageSize: pageSize,
      socialPostId: discoveryEntity.id,
    )
        .then((value) {
      _isRequesting = false;
      if (value != null) {
        var list = value.getDataList<DiscoveryCommentListEntity>();
        dataList = list;
        cacheManager.setJson('${CacheManager.commentList}:${discoveryEntity.id}', list.map((e) => e.toJson()).toList());
        update();
        loadChildrenComments(list);
      }
    });
  }

  loadMorePage() {
    if (_isRequesting) {
      return;
    }
    _isRequesting = true;
    api
        .listDiscoveryComments(
      from: dataList.length,
      pageSize: pageSize,
      socialPostId: discoveryEntity.id,
    )
        .then((value) {
      _isRequesting = false;
      if (value != null) {
        var list = value.getDataList<DiscoveryCommentListEntity>();
        dataList.addAll(list);
        update();
        loadChildrenComments(list);
      }
    });
  }

  Future<BaseEntity?> deleteDiscovery() async {
    return api.deleteDiscovery(discoveryEntity.id);
  }

  commentUnLike(DiscoveryCommentListEntity entity) {
    entity.likes--;
    likeLocalAddAlready.value = true;
    update();
    api.commentUnLike(entity.id, entity.likeId!).then((value) {
      if (value == null) {
        entity.likes++;
        likeLocalAddAlready.value = false;
      } else {
        _saveData();
      }
    });
  }

  commentLike(DiscoveryCommentListEntity entity) {
    entity.likes++;
    likeLocalAddAlready.value = true;
    update();
    api.commentLike(entity.id).then((value) {
      if (value == null) {
        entity.likes--;
        likeLocalAddAlready.value = false;
      } else {
        _saveData();
      }
    });
  }

  discoveryUnLike() {
    discoveryEntity.likes--;
    liked.value = false;
    likeLocalAddAlready.value = true;
    api.discoveryUnLike(discoveryEntity.id, discoveryEntity.likeId!).then((value) {
      if (value == null) {
        discoveryEntity.likes++;
        likeLocalAddAlready.value = false;
        liked.value = true;
      } else {
        _saveData();
      }
    });
  }

  discoveryLike(String dataType, String style) {
    discoveryEntity.likes++;
    liked.value = true;
    likeLocalAddAlready.value = true;
    api
        .discoveryLike(
      discoveryEntity.id,
      source: dataType,
      style: style,
    )
        .then((value) {
      if (value == null) {
        discoveryEntity.likes--;
        likeLocalAddAlready.value = false;
        liked.value = false;
      } else {
        _saveData();
      }
    });
  }

  Future<bool> createDiscoveryComment(
    String comment,
    String dataType,
    String style, {
    int? replySocialPostCommentId,
    int? parentSocialPostCommentId,
    required Function() onUserExpired,
  }) async {
    var baseEntity = await api.createDiscoveryComment(
      comment: comment,
      source: dataType,
      style: style,
      socialPostId: discoveryEntity.id,
      replySocialPostCommentId: replySocialPostCommentId,
      parentSocialPostCommentId: parentSocialPostCommentId,
      onUserExpired: onUserExpired,
    );
    if (baseEntity != null) {
      if (parentSocialPostCommentId == null) {
        dataList.insert(0, baseEntity);
      } else {
        var pick = dataList.pick((t) => t.id == parentSocialPostCommentId);
        pick?.children.insert(0, baseEntity);
      }
      update();
      CommonExtension().showToast('Comment posted');
      _saveData();
      // delay(() => loadFirstPage(), milliseconds: 64);
    }
    return baseEntity != null;
  }

  loadChildrenComments(List<DiscoveryCommentListEntity> list) {
    Future.wait(list
            .map((e) => api.listDiscoveryComments(
                  from: 0,
                  pageSize: 2,
                  socialPostId: e.socialPostId,
                  parentSocialPostCommentId: e.id,
                ))
            .toList())
        .then((value) {
      value.forEach((element) {
        if (element != null) {
          var dataList = element.getDataList<DiscoveryCommentListEntity>();
          if (dataList.isNotEmpty) {
            var pick = list.pick((t) => t.id == dataList.first.parentSocialPostCommentId);
            pick?.children = dataList;
          }
        }
      });
      update();
    });
  }

  void getSecondaryComments(DiscoveryCommentListEntity data) {
    if (loadingCommentId.value != 0) {
      return;
    }
    int size = 2;
    if (data.children.length >= 2) {
      size = 9;
    }
    loadingCommentId.value = data.id;
    api
        .listDiscoveryComments(
      from: data.children.length,
      pageSize: size,
      socialPostId: data.socialPostId,
      parentSocialPostCommentId: data.id,
    )
        .then((value) {
      loadingCommentId.value = 0;
      if (value != null) {
        var children = value.getDataList<DiscoveryCommentListEntity>();
        if (children.isNotEmpty) {
          data.children.addAll(children);
        }
      }
      update();
    });
  }
}
