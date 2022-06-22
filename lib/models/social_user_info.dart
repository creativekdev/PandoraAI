import 'dart:convert';

class SocialUserInfo {
  String id = '';
  String email = "";
  String name = "";
  String avatar = "";
  String status = "registered";
  String appleId = "";
  int cartoonizeCredit = 0;

  Map<String, dynamic> userSubscription = {};
  List<dynamic> creditcards = [];

  SocialUserInfo.fromJson(Map<String, dynamic> json) {
    id = (json['id'] ?? '').toString();
    email = json['email'] ?? '';
    name = json['name'] ?? '';
    avatar = json['avatar'] ?? '';
    status = json['status'] ?? "registered";
    appleId = json['apple_id'] ?? '';
    cartoonizeCredit = json['cartoonize_credit'] ?? 0;
    creditcards = json['creditcards'] ?? [];
    var subscription = json['user_subscription'] ?? [];

    for (int i = 0; i < subscription.length; i++) {
      Map<String, dynamic> item = subscription[i];
      if (item['plan_category'] == 'creator' && (item['status'] == 'success' || item['status'] == 'pending')) {
        userSubscription = item;
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'status': status,
      'apple_id': appleId,
      'cartoonize_credit': cartoonizeCredit,
      'creditcards': creditcards,
      'user_subscription': userSubscription,
    };
  }

  bool equals(SocialUserInfo? userInfo) {
    return userInfo == null ? false : jsonEncode(toJson()) == jsonEncode(userInfo.toJson());
  }
}
