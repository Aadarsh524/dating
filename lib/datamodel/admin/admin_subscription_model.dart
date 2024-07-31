class AdminSubscriptionModel {
  MiniProfile? miniProfile;
  UserSubscription? userSubscription;

  AdminSubscriptionModel({this.miniProfile, this.userSubscription});

  AdminSubscriptionModel.fromJson(Map<String, dynamic> json) {
    miniProfile = json['miniProfile'] != null
        ? new MiniProfile.fromJson(json['miniProfile'])
        : null;
    userSubscription = json['userSubscription'] != null
        ? new UserSubscription.fromJson(json['userSubscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.miniProfile != null) {
      data['miniProfile'] = this.miniProfile!.toJson();
    }
    if (this.userSubscription != null) {
      data['userSubscription'] = this.userSubscription!.toJson();
    }
    return data;
  }
}

class MiniProfile {
  String? uid;
  String? image;
  String? name;
  String? address;
  String? age;
  String? country;
  String? countryRiskCode;
  String? gender;
  Upload? upload;

  MiniProfile(
      {this.uid,
      this.image,
      this.name,
      this.address,
      this.age,
      this.country,
      this.countryRiskCode,
      this.gender,
      this.upload});

  MiniProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    image = json['image'];
    name = json['name'];
    address = json['address'];
    age = json['age'];
    country = json['country'];
    countryRiskCode = json['countryRiskCode'];
    gender = json['gender'];
    upload =
        json['upload'] != null ? new Upload.fromJson(json['upload']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['image'] = this.image;
    data['name'] = this.name;
    data['address'] = this.address;
    data['age'] = this.age;
    data['country'] = this.country;
    data['countryRiskCode'] = this.countryRiskCode;
    data['gender'] = this.gender;
    if (this.upload != null) {
      data['upload'] = this.upload!.toJson();
    }
    return data;
  }
}

class Upload {
  String? id;
  String? file;
  String? name;
  String? uploadDate;

  Upload({this.id, this.file, this.name, this.uploadDate});

  Upload.fromJson(Map<String, dynamic> json) {
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
