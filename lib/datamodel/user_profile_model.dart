class UserProfileModel {
  String? uid;
  String? image;
  String? name;
  String? email;

  String? address;
  String? age;
  String? gender;
  String? bio;
  String? interests;
  String? userStatus;
  String? subscriptionStatus;
  String? createdTimestamp;
  bool? isVerified;
  int? documentStatus;
  Seeking? seeking;
  List<Uploads>? uploads;

  UserProfileModel(
      {this.uid,
      this.image,
      this.name,
      this.email,
      this.address,
      this.age,
      this.gender,
      this.bio,
      this.interests,
      this.userStatus,
      this.subscriptionStatus,
      this.createdTimestamp,
      this.isVerified,
      this.documentStatus,
      this.seeking,
      this.uploads});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    image = json['image'];
    name = json['name'];
    email = json['email'];
    address = json['address'];
    age = json['age'];
    gender = json['gender'];
    bio = json['bio'];
    interests = json['interests'];
    userStatus = json['userStatus'];
    subscriptionStatus = json['subscriptionStatus'];
    createdTimestamp = json['createdTimestamp'];
    isVerified = json['isVerified'];
    documentStatus = json['documentStatus'];
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    data['image'] = image;
    data['name'] = name;
    data['email'] = email;
    data['address'] = address;
    data['age'] = age;
    data['gender'] = gender;
    data['bio'] = bio;
    data['interests'] = interests;
    data['userStatus'] = userStatus;
    data['subscriptionStatus'] = subscriptionStatus;
    data['createdTimestamp'] = createdTimestamp;
    data['isVerified'] = isVerified;
    data['documentStatus'] = documentStatus;
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
  String? fromAge;
  String? toAge;
  String? gender;

  Seeking({this.fromAge, this.toAge, this.gender});

  Seeking.fromJson(Map<String, dynamic> json) {
    fromAge = json['fromAge'];
    toAge = json['toAge'];
    gender = json['gender'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['fromAge'] = fromAge;
    data['toAge'] = toAge;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['file'] = file;
    data['name'] = name;
    data['uploadDate'] = uploadDate;
    return data;
  }
}
