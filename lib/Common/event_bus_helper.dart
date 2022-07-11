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

class OnAppStateChangeEvent extends BaseEvent {}
