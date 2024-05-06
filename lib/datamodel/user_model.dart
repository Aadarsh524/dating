class UserModel {
  final String uid;
  String name;
  String email;
  String gender;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
    };
  }
}
