class UserProfileModel {
  final String uid;
  String image;
  String name;
  String address;
  String age;
  String gender;
  String bio;
  String interests;
  Map<String, String> seeking;
  List<Upload> uploads;

  UserProfileModel({
    required this.uid,
    required this.image,
    required this.name,
    required this.address,
    required this.age,
    required this.gender,
    required this.bio,
    required this.interests,
    required this.seeking,
    required this.uploads,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'],
      image: json['image'],
      name: json['name'],
      address: json['address'],
      age: json['age'],
      gender: json['gender'],
      bio: json['bio'],
      interests: json['interests'],
      seeking: json['seeking'] != null
          ? Map<String, String>.from(json['seeking'])
          : {},
      uploads: json['uploads'] != null
          ? List<Upload>.from(json['uploads'].map((x) => Upload.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'image': image,
      'name': name,
      'address': address,
      'age': age,
      'gender': gender,
      'bio': bio,
      'interests': interests,
      'seeking': seeking,
      'uploads': uploads.map((upload) => upload.toJson()).toList(),
    };
  }
}

class Upload {
  final String id;
  final String file;
  final String name;
  final String uploadDate;

  Upload({
    required this.id,
    required this.file,
    required this.name,
    required this.uploadDate,
  });

  factory Upload.fromJson(Map<String, dynamic> json) {
    return Upload(
      id: json['id'],
      file: json['file'],
      name: json['name'],
      uploadDate: json['uploadDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file': file,
      'name': name,
      'uploadDate': uploadDate,
    };
  }
}
