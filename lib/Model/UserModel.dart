class UserModel {
  String email = "";
  String name = "";
  String avatar = "";
  int credit = 0;
  Map<String, dynamic> subscription = {};

  UserModel({required this.email, required this.name, required this.avatar});

  factory UserModel.fromGetLogin(Map json) {
    var data = json['data'] ?? {};
    var member = data['member'] ?? {};

    UserModel user = UserModel(
      email: member['email'] ?? "",
      name: member['name'] ?? "",
      avatar: member['avatar'] ?? "",
    );

    user.credit = data['cartoonize_credit'] ?? 0;

    var user_subscription = data['user_subscription'] ?? [];

    for (int i = 0; i < user_subscription.length; i++) {
      Map<String, dynamic> item = user_subscription[i];

      if (item['plan_category'] == 'creator' && item['status'] == 'success') {
        user.subscription = item;
      }
    }

    return user;
  }

  factory UserModel.fromJson(Map json) {
    UserModel user = UserModel(
      email: (json['email'] == null) ? "" : json['email'],
      name: (json['name'] == null) ? "" : json['name'],
      avatar: (json['avatar'] == null) ? "" : json['avatar'],
    );

    user.subscription = json['subscription'];
    user.credit = json['credit'];
    return user;
  }

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'avatar': avatar, "credit": credit, "subscription": subscription};
}
