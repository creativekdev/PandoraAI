import 'dart:convert';

class SocialUserInfo {
  int id = 0;
  String email = "";
  String name = "";
  String avatar = "";
  String status = "registered";
  String appleId = "";
  int cartoonizeCredit = 0;
  int aiAvatarCredit = 0;
  MemberInfo? member;

  Map<String, dynamic> userSubscription = {};
  List<dynamic> creditcards = [];

  String getShownEmail() {
    return member?.email ?? email;
  }

  String getShownName() {
    return member?.name ?? name;
  }

  String getShownAvatar() {
    return member?.avatar ?? avatar;
  }

  SocialUserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    email = json['email'] ?? '';
    name = json['name'] ?? '';
    avatar = json['avatar'] ?? '';
    status = json['status'] ?? "registered";
    appleId = json['apple_id'] ?? '';
    cartoonizeCredit = json['cartoonize_credit'] ?? 0;
    creditcards = json['creditcards'] ?? [];
    aiAvatarCredit = json['ai_avatar_credit'] ?? 0;
    var subscription = json['user_subscription'] ?? [];

    for (int i = 0; i < subscription.length; i++) {
      Map<String, dynamic> item = subscription[i];
      if (item['plan_category'] == 'creator' && (item['status'] == 'success' || item['status'] == 'pending')) {
        userSubscription = item;
      }
    }
    var memberJson = json['member'];
    if (memberJson != null && memberJson is Map<String, dynamic>) {
      member = MemberInfo.fromJson(memberJson);
    }
  }

  Map<String, dynamic> toJson() {
    var map = {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'status': status,
      'apple_id': appleId,
      'cartoonize_credit': cartoonizeCredit,
      'creditcards': creditcards,
      'ai_avatar_credit': aiAvatarCredit,
    };
    if (userSubscription.keys.isEmpty) {
      map['user_subscription'] = [];
    } else {
      map['user_subscription'] = [userSubscription];
    }
    if (member != null) {
      map['member'] = member!.toJson();
    }
    return map;
  }

  bool equals(SocialUserInfo? userInfo) {
    return userInfo == null ? false : jsonEncode(toJson()) == jsonEncode(userInfo.toJson());
  }

  SocialUserInfo copy() {
    return SocialUserInfo.fromJson(toJson());
  }
}

class MemberInfo {
  int id = 0;
  String email = '';
  String name = '';
  String avatar = '';

  MemberInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    email = json['email'] ?? '';
    name = json['name'] ?? '';
    avatar = json['avatar'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
    };
  }

  bool equals(MemberInfo? member) {
    return member == null ? false : jsonEncode(toJson()) == jsonEncode(member.toJson());
  }

  MemberInfo copy() {
    return MemberInfo.fromJson(toJson());
  }
}
