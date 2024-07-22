class UserMatchesResponseModel {
  List<UserMatchesModel>? userMatches;

  UserMatchesResponseModel({this.userMatches});

  UserMatchesResponseModel.fromJson(List<dynamic> json) {
    userMatches = json.map((e) => UserMatchesModel.fromJson(e)).toList();
  }

  List<dynamic> toJson() {
    return userMatches!.map((v) => v.toJson()).toList();
  }
}

class UserMatchesModel {
  String? uid;
  String? likedDate;
  UserDetail? userDetail;

  UserMatchesModel({this.uid, this.likedDate, this.userDetail});

  UserMatchesModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    likedDate = json['likedDate'];
    userDetail = json['userDetail'] != null
        ? new UserDetail.fromJson(json['userDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['likedDate'] = this.likedDate;
    if (this.userDetail != null) {
      data['userDetail'] = this.userDetail!.toJson();
    }
    return data;
  }
}

class UserDetail {
  String? name;
  String? address;
  String? age;
  String? image;

  UserDetail({this.name, this.address, this.age, this.image});

  UserDetail.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
    age = json['age'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['address'] = this.address;
    data['age'] = this.age;
    data['image'] = this.image;
    return data;
  }
}
