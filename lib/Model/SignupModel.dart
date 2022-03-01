class SignupModel {
  String email = "";
  String name = "";
  String avatar = "";

  SignupModel({required this.email, required this.name, required this.avatar});

  factory SignupModel.fromJson(Map json){
    return SignupModel(
      email: json['data']['member']['email'],
      name: json['data']['member']['name'],
      avatar: (json['data']['member']['avatar'] == null)? "" : json['data']['member']['avatar'],
    );
  }
}