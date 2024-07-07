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
  String? userStatus;
  String? createdTimestamp;
  String? interests;
  bool? isVerified;
  int? documentStatus;
  Seeking? seeking;
  List<Uploads>? uploads;
  UserSubscription? userSubscription;

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
      this.userStatus,
      this.createdTimestamp,
      this.interests,
      this.isVerified,
      this.documentStatus,
      this.seeking,
      this.uploads,
      this.userSubscription});

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
    userStatus = json['userStatus'];
    createdTimestamp = json['createdTimestamp'];
    interests = json['interests'];
    isVerified = json['isVerified'];
    documentStatus = json['documentStatus'];
    seeking =
        json['seeking'] != null ? new Seeking.fromJson(json['seeking']) : null;
    if (json['uploads'] != null) {
      uploads = <Uploads>[];
      json['uploads'].forEach((v) {
        uploads!.add(new Uploads.fromJson(v));
      });
    }
    userSubscription = json['userSubscription'] != null
        ? new UserSubscription.fromJson(json['userSubscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['image'] = this.image;
    data['address'] = this.address;
    data['age'] = this.age;
    data['bio'] = this.bio;
    data['userStatus'] = this.userStatus;
    data['createdTimestamp'] = this.createdTimestamp;
    data['interests'] = this.interests;
    data['isVerified'] = this.isVerified;
    data['documentStatus'] = this.documentStatus;
    if (this.seeking != null) {
      data['seeking'] = this.seeking!.toJson();
    }
    if (this.uploads != null) {
      data['uploads'] = this.uploads!.map((v) => v.toJson()).toList();
    }
    if (this.userSubscription != null) {
      data['userSubscription'] = this.userSubscription!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fromAge'] = this.fromAge;
    data['toAge'] = this.toAge;
    data['gender'] = this.gender;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['file'] = this.file;
    data['name'] = this.name;
    data['uploadDate'] = this.uploadDate;
    return data;
  }
}

class UserSubscription {
  String? id;
  String? uid;
  String? transactionId;
  String? productId;
  String? subscriptionDate;
  String? expirationDate;
  String? duration;
  String? planType;

  UserSubscription(
      {this.id,
      this.uid,
      this.transactionId,
      this.productId,
      this.subscriptionDate,
      this.expirationDate,
      this.duration,
      this.planType});

  UserSubscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    transactionId = json['transactionId'];
    productId = json['productId'];
    subscriptionDate = json['subscriptionDate'];
    expirationDate = json['expirationDate'];
    duration = json['duration'];
    planType = json['planType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['transactionId'] = this.transactionId;
    data['productId'] = this.productId;
    data['subscriptionDate'] = this.subscriptionDate;
    data['expirationDate'] = this.expirationDate;
    data['duration'] = this.duration;
    data['planType'] = this.planType;
    return data;
  }
}
