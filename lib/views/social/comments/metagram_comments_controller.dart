import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/api/socialmedia_connector_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';

class MetagramCommentsController extends GetxController {
  late SocialMediaConnectorApi api;
  late CartoonizerApi cartoonizerApi;
  MetagramItemEntity data;

  List<DiscoveryCommentListEntity> dataList = [];
  int pageSize = 20;
  CacheManager cacheManager = AppDelegate().getManager();
  ScrollController scrollController = ScrollController();
  bool _isRequesting = false;
  Rx<int> loadingCommentId = 0.obs;
  Rx<bool> likeLocalAddAlready = false.obs;

  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;

  MetagramCommentsController({required this.data});

  @override
  void onInit() {
    super.onInit();
    api = SocialMediaConnectorApi().bindController(this);
    cartoonizerApi = CartoonizerApi().bindController(this);
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
        } else {
          data.children.forEach((element) {
            if (element.id == id) {
              element.likeId = likeId;
              if (likeLocalAddAlready.value) {
                likeLocalAddAlready.value = false;
              } else {
                element.likes++;
              }
              update();
            }
          });
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
        } else {
          data.children.forEach((element) {
            if (element.id == event.data) {
              element.likeId = null;
              if (likeLocalAddAlready.value) {
                likeLocalAddAlready.value = false;
              } else {
                element.likes--;
              }
              update();
            }
          });
        }
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
    var json = cacheManager.getJson('${CacheManager.commentList}:metagram:${data.id}') ?? [];
    dataList = jsonConvert.convertListNotNull<DiscoveryCommentListEntity>(json) ?? [];
  }

  _saveData() {
    cacheManager.setJson('${CacheManager.commentList}:metagram:${data.id}', dataList.map((e) => e.toJson()).toList());
  }

  @override
  void onReady() {
    super.onReady();
    loadFirstPage();
  }

  @override
  void dispose() {
    api.unbind();
    cartoonizerApi.unbind();
    super.dispose();
  }

  loadFirstPage() {
    if (_isRequesting) {
      return;
    }
    _isRequesting = true;
    cartoonizerApi
        .listDiscoveryComments(
      from: 0,
      pageSize: pageSize,
      socialPostId: data.id!,
    )
        .then((value) {
      _isRequesting = false;
      if (value != null) {
        var list = value.getDataList<DiscoveryCommentListEntity>();
        dataList = list;
        cacheManager.setJson('${CacheManager.commentList}:metagram:${data.id}', list.map((e) => e.toJson()).toList());
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
    cartoonizerApi
        .listDiscoveryComments(
      from: dataList.length,
      pageSize: pageSize,
      socialPostId: data.id!,
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

  commentUnLike(DiscoveryCommentListEntity entity) {
    entity.likes--;
    likeLocalAddAlready.value = true;
    update();
    cartoonizerApi.commentUnLike(entity.id, entity.likeId!).then((value) {
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
    cartoonizerApi.commentLike(entity.id).then((value) {
      if (value == null) {
        entity.likes--;
        likeLocalAddAlready.value = false;
      } else {
        _saveData();
      }
    });
  }

  loadChildrenComments(List<DiscoveryCommentListEntity> list) {
    Future.wait(list
            .map((e) => cartoonizerApi.listDiscoveryComments(
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
    cartoonizerApi
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

  Future<bool> createDiscoveryComment(
    String comment,
    String dataType,
    String style, {
    int? replySocialPostCommentId,
    int? parentSocialPostCommentId,
    required Function() onUserExpired,
  }) async {
    var baseEntity = await cartoonizerApi.createDiscoveryComment(
      comment: comment,
      source: dataType,
      style: style,
      socialPostId: data.id!,
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
}
