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

  UserProfileModel({
    this.id,
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
    this.userSubscription,
  });

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
        json['seeking'] != null ? Seeking.fromJson(json['seeking']) : null;
    if (json['uploads'] != null) {
      uploads = <Uploads>[];
      json['uploads'].forEach((v) {
        uploads!.add(Uploads.fromJson(v));
      });
    }
    userSubscription = json['userSubscription'] != null
        ? UserSubscription.fromJson(json['userSubscription'])
        : null;
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
    data['userStatus'] = userStatus;
    data['createdTimestamp'] = createdTimestamp;
    data['interests'] = interests;
    data['isVerified'] = isVerified;
    data['documentStatus'] = documentStatus;
    if (seeking != null) {
      data['seeking'] = seeking!.toJson();
    }
    if (uploads != null) {
      data['uploads'] = uploads!.map((v) => v.toJson()).toList();
    }
    if (userSubscription != null) {
      data['userSubscription'] = userSubscription!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['file'] = file;
    data['name'] = name;
    data['uploadDate'] = uploadDate;
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

  UserSubscription({
    this.id,
    this.uid,
    this.transactionId,
    this.productId,
    this.subscriptionDate,
    this.expirationDate,
    this.duration,
    this.planType,
  });

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uid'] = uid;
    data['transactionId'] = transactionId;
    data['productId'] = productId;
    data['subscriptionDate'] = subscriptionDate;
    data['expirationDate'] = expirationDate;
    data['duration'] = duration;
    data['planType'] = planType;
    return data;
  }
}
