class UserProfileModel {
  String? id;
  String? uid;
  String? name;
  String? email;
  String? gender;
  String? image;
  String? address;
  String? age;
  String? bio;
  String? interests;
  Seeking? seeking;
  List<Uploads>? uploads;

  UserProfileModel(
      {this.id,
      this.uid,
      this.name,
      this.email,
      this.gender,
      this.image,
      this.address,
      this.age,
      this.bio,
      this.interests,
      this.seeking,
      this.uploads});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    name = json['name'];
    email = json['email'];
    gender = json['gender'];
    image = json['image'];
    address = json['address'];
    age = json['age'];
    bio = json['bio'];
    interests = json['interests'];
    seeking =
        json['seeking'] != null ? Seeking.fromJson(json['seeking']) : null;
    if (json['uploads'] != null) {
      uploads = <Uploads>[];
      json['uploads'].forEach((v) {
        uploads!.add(Uploads.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['name'] = name;
    data['email'] = email;
    data['gender'] = gender;
    data['image'] = image;
    data['address'] = address;
    data['age'] = age;
    data['bio'] = bio;
    data['interests'] = interests;
    if (seeking != null) {
      data['seeking'] = seeking!.toJson();
    }
    if (uploads != null) {
      data['uploads'] = uploads!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Seeking {
  String? age;
  String? gender;

  Seeking({this.age, this.gender});

  Seeking.fromJson(Map<String, dynamic> json) {
    age = json['age'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['age'] = age;
    data['gender'] = gender;
    return data;
  }
}

class Uploads {
  String? id;
  String? file;
  String? name;
  String? uploadDate;

  Uploads({this.id, this.file, this.name, this.uploadDate});

  Uploads.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    file = json['file'];
    name = json['name'];
    uploadDate = json['uploadDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['file'] = file;
    data['name'] = name;
    data['uploadDate'] = uploadDate;
    return data;
  }
}
