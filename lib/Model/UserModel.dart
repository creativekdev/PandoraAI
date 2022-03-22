class UserModel {
  String email = "";
  String name = "";
  String avatar = "";
  Map<String, dynamic> subscription = {};

  UserModel({required this.email, required this.name, required this.avatar});

  factory UserModel.fromGetLogin(Map json) {
    var data = json['data'];
    UserModel user = UserModel(
      email: (data['member']['email'] == null) ? "" : data['member']['email'],
      name: (data['member']['name'] == null) ? "" : data['member']['name'],
      avatar: (data['member']['avatar'] == null) ? "" : data['member']['avatar'],
    );

    var user_subscription = data['user_subscription'];

    for (int i = 0; i < user_subscription.length; i++) {
      Map<String, dynamic> item = user_subscription[i];

      if (item['plan_category'] == 'creator' && item['status'] == 'success') {
        user.subscription = item;
      }
    }

    return user;
  }

  factory UserModel.fromJSON(Map json) {
    UserModel user = UserModel(
      email: (json['email'] == null) ? "" : json['email'],
      name: (json['name'] == null) ? "" : json['name'],
      avatar: (json['avatar'] == null) ? "" : json['avatar'],
    );

    user.subscription = json['subscription'];
    return user;
  }

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'avatar': avatar, "subscription": subscription};
}
