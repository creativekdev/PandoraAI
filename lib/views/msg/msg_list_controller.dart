import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';
import 'package:cartoonizer/models/msg_entity.dart';

class MsgListController extends GetxController {
  MsgManager msgManager = AppDelegate().getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();

  List<MsgTab> tabList = [MsgTab.like, MsgTab.comment, MsgTab.system];

  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  set tabIndex(int index) {
    if (index == _tabIndex) {
      return;
    }
    _tabIndex = index;
    update();
  }

  late AppApi api;

  @override
  void onInit() {
    super.onInit();
    api = AppApi().bindController(this);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    api.unbind();
    super.dispose();
  }

  readMsg(MsgEntity entity) {
    msgManager.readMsg(entity).then((value) {
      if (value != null) {
        entity.read = true;
        update();
      }
    });
  }

  readAll(MsgTab? tab) async {
    delay(() {}, milliseconds: 500);
    if (tab == null) {
      var baseEntity = await msgManager.readAll([]);
      if (baseEntity != null) {
        update();
      }
    } else {
      var needReadLike = tab == MsgTab.like && msgManager.likeCount.value != 0;
      var needReadComment = tab == MsgTab.comment && msgManager.commentCount.value != 0;
      var needReadSystem = tab == MsgTab.system && msgManager.systemCount.value != 0;
      if (needReadLike || needReadComment || needReadSystem) {
        var baseEntity = await msgManager.readAll(tab.types);
        if (baseEntity != null) {
          update();
        }
      }
    }
  }
}

enum MsgTab {
  like,
  comment,
  system,
}

extension MsgTabEx on MsgTab {
  String get title {
    switch (this) {
      case MsgTab.like:
        return S.of(Get.context!).like;
      case MsgTab.comment:
        return S.of(Get.context!).comments;
      case MsgTab.system:
        return S.of(Get.context!).system;
    }
  }

  Color get selectedColor {
    switch (this) {
      case MsgTab.like:
        return Color(0xFFFF375F);
      case MsgTab.comment:
        return Color(0xFF35B87F);
      case MsgTab.system:
        return Color(0xFF558DD9);
    }
  }

  String get iconRes {
    switch (this) {
      case MsgTab.like:
        return Images.ic_msg_like;
      case MsgTab.comment:
        return Images.ic_msg_comment;
      case MsgTab.system:
        return Images.ic_msg_icon;
    }
  }

  List<MsgType> get types {
    switch (this) {
      case MsgTab.like:
        return [
          MsgType.like_social_post_comment,
          MsgType.like_social_post,
        ];
      case MsgTab.comment:
        return [
          MsgType.comment_social_post,
          MsgType.comment_social_post_comment,
        ];
      case MsgTab.system:
        return [
          MsgType.ai_avatar_completed,
          MsgType.UNDEFINED,
        ];
    }
  }
}
