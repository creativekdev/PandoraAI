import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:event_bus/event_bus.dart';

/// EventBusHelper
/// usage:
///   1. create event extends baseEvent
///       class NewEvent extends BaseEvent<bool> {
///         NewEvent({bool? data}) : super(data: data);
///       }
///   2. subscribe
///       StreamSubscription callback = EventBusHelper().eventBus.on<NewEvent>().listen((event) {
///           // event.data is nullable bool type;
///       });
///   3. unsubscribe
///       callback.cancel();
///   3. send event:
///       EventBusHelper().eventBus.fire(event);
class EventBusHelper {
  final eventBus = EventBus();

  factory EventBusHelper() => _sharedInstance();

  static EventBusHelper? _instance;

  EventBusHelper._internal();

  static EventBusHelper _sharedInstance() {
    if (_instance == null) {
      _instance = EventBusHelper._internal();
    }
    return _instance!;
  }
}

///
/// BaseEventInfo
class BaseEvent<T> {
  T? data;

  BaseEvent({this.data});
}

class LoginStateEvent extends BaseEvent<bool> {
  LoginStateEvent({required bool data}) : super(data: data);
}

class UserInfoChangeEvent extends BaseEvent<SocialUserInfo> {
  UserInfoChangeEvent({required SocialUserInfo data}) : super(data: data);
}

///tab切换事件
///data为数组，第一个元素表示首页tab的id，具体见[AppRoleTabItem]的[buildTabItem()]配置
///第二个元素则表示二级页面的tab位置，比如切换到id为2的第3个tab，则传递data: [2,2]
class OnTabSwitchEvent extends BaseEvent<List<int>> {
  OnTabSwitchEvent({required List<int> data}) : super(data: data);
}

class OnTabDoubleClickEvent extends BaseEvent<int> {
  OnTabDoubleClickEvent({data}) : super(data: data);
}

class OnTabLongPressEvent extends BaseEvent<int> {
  OnTabLongPressEvent({data}) : super(data: data);
}

/// like success event
/// @data <id, likeId>
class OnDiscoveryLikeEvent extends BaseEvent<MapEntry<int, int>> {
  OnDiscoveryLikeEvent({required MapEntry<int, int> data}) : super(data: data);
}

class OnDiscoveryUnlikeEvent extends BaseEvent<int> {
  OnDiscoveryUnlikeEvent({required int data}) : super(data: data);
}

/// like success event
/// @data <id, likeId>
class OnCommentLikeEvent extends BaseEvent<MapEntry<int, int>> {
  OnCommentLikeEvent({required MapEntry<int, int> data}) : super(data: data);
}

class OnCommentUnlikeEvent extends BaseEvent<int> {
  OnCommentUnlikeEvent({required int data}) : super(data: data);
}

/// create comment event
/// @data <socialPostId, replyCommentId>
class OnCreateCommentEvent extends BaseEvent<List<int>> {
  OnCreateCommentEvent({required List<int> data}) : super(data: data);
}

class OnAppStateChangeEvent extends BaseEvent {}

/// cartoonizer process event
class OnCartoonizerFinishedEvent extends BaseEvent<bool> {
  OnCartoonizerFinishedEvent({required bool data}) : super(data: data);
}

class OnPaySuccessEvent extends BaseEvent {}

/// new notify send to app
class OnNewMsgReceivedEvent extends BaseEvent<String> {
  OnNewMsgReceivedEvent({required String id}) : super(data: id);
}

/// on delete discovery event
class OnDeleteDiscoveryEvent extends BaseEvent<int> {
  OnDeleteDiscoveryEvent({required int id}) : super(data: id);
}

class OnSplashAdLoadingChangeEvent extends BaseEvent {}

/// switch home_screen tab
class OnEffectPushClickEvent extends BaseEvent<PushExtraEntity> {
  OnEffectPushClickEvent({required PushExtraEntity data}) : super(data: data);
}

class OnEffectNsfwChangeEvent extends BaseEvent {}

class OnHomeConfigGetEvent extends BaseEvent {}

class OnNewPostEvent extends BaseEvent {}

class OnHashTagChangeEvent extends BaseEvent<String> {
  OnHashTagChangeEvent({String? data}) : super(data: data);
}

class OnClearCacheEvent extends BaseEvent {}
