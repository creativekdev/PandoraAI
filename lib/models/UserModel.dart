@Deprecated('use UserManager and SocialUserInfo')
class UserModel {
  int id = 0;
  String email = "";
  String name = "";
  String avatar = "";
  String status = "registered";
  String apple_id = "";
  int credit = 0;
  Map<String, dynamic> ai_servers = {};
  Map<String, dynamic> subscription = {};
  List<dynamic> creditcards = [];

  UserModel({this.email = "", this.name = "", this.avatar = ""});

  factory UserModel.fromGetLogin(Map json) {
    var data = json['data'] ?? {};
    var member = data['member'] ?? {};

    UserModel user = UserModel(
      email: member['email'] ?? "",
      name: member['name'] ?? "",
      avatar: member['avatar'] ?? "",
    );

    user.id = data['id'] ?? 0;
    user.apple_id = data['apple_id'] ?? "";
    user.status = data['status'] ?? "registered";
    user.credit = data['cartoonize_credit'] ?? 0;
    user.creditcards = data['creditcards'] ?? [];
    user.ai_servers = json['ai_servers'] ?? {};

    var user_subscription = data['user_subscription'] ?? [];

    for (int i = 0; i < user_subscription.length; i++) {
      Map<String, dynamic> item = user_subscription[i];

      if (item['plan_category'] == 'creator' && (item['status'] == 'success' || item['status'] == 'pending')) {
        user.subscription = item;
      }
    }

    return user;
  }

  factory UserModel.fromUnlogin(Map json) {
    UserModel user = UserModel();
    user.ai_servers = json['ai_servers'] ?? {};
    return user;
  }

  factory UserModel.fromJson(Map json) {
    UserModel user = UserModel(
      email: (json['email'] == null) ? "" : json['email'],
      name: (json['name'] == null) ? "" : json['name'],
      avatar: (json['avatar'] == null) ? "" : json['avatar'],
    );

    user.id = json['id'] ?? 0;
    user.apple_id = json['apple_id'] ?? "";
    user.subscription = json['subscription'] ?? {};
    user.status = json['status'] ?? "registered";
    user.credit = json['credit'] ?? 0;
    user.creditcards = json['creditcards'] ?? [];
    user.ai_servers = json['ai_servers'] ?? {};

    return user;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        'name': name,
        'email': email,
        'avatar': avatar,
        "apple_id": apple_id,
        "credit": credit,
        "creditcards": creditcards,
        "status": status,
        "subscription": subscription,
        "ai_servers": ai_servers
      };
}
