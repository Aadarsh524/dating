class UserInteractionModel {
  String? uid;
  List<LikedUsers>? likedUsers;
  List<LikedByUsers>? likedByUsers;
  List<MutualLikes>? mutualLikes;
  int? totalLikedUsers;
  int? totalLikedByUsers;
  int? totalMutualLikes;

  UserInteractionModel(
      {this.uid,
      this.likedUsers,
      this.likedByUsers,
      this.mutualLikes,
      this.totalLikedUsers,
      this.totalLikedByUsers,
      this.totalMutualLikes});

  UserInteractionModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    if (json['likedUsers'] != null) {
      likedUsers = <LikedUsers>[];
      json['likedUsers'].forEach((v) {
        likedUsers!.add(LikedUsers.fromJson(v));
      });
    }
    if (json['likedByUsers'] != null) {
      likedByUsers = <LikedByUsers>[];
      json['likedByUsers'].forEach((v) {
        likedByUsers!.add(LikedByUsers.fromJson(v));
      });
    }
    if (json['mutualLikes'] != null) {
      mutualLikes = <MutualLikes>[];
      json['mutualLikes'].forEach((v) {
        mutualLikes!.add(MutualLikes.fromJson(v));
      });
    }
    totalLikedUsers = json['totalLikedUsers'];
    totalLikedByUsers = json['totalLikedByUsers'];
    totalMutualLikes = json['totalMutualLikes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    if (likedUsers != null) {
      data['likedUsers'] = likedUsers!.map((v) => v.toJson()).toList();
    }
    if (likedByUsers != null) {
      data['likedByUsers'] = likedByUsers!.map((v) => v.toJson()).toList();
    }
    if (mutualLikes != null) {
      data['mutualLikes'] = mutualLikes!.map((v) => v.toJson()).toList();
    }
    data['totalLikedUsers'] = totalLikedUsers;
    data['totalLikedByUsers'] = totalLikedByUsers;
    data['totalMutualLikes'] = totalMutualLikes;
    return data;
  }
}

class LikedUsers {
  String? uid;
  String? likedDate;
  UserDetail? userDetail;

  LikedUsers({this.uid, this.likedDate, this.userDetail});

  LikedUsers.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    likedDate = json['likedDate'];
    userDetail = json['userDetail'] != null
        ? UserDetail.fromJson(json['userDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    data['likedDate'] = likedDate;
    if (userDetail != null) {
      data['userDetail'] = userDetail!.toJson();
    }
    return data;
  }
}

class LikedByUsers {
  String? uid;
  String? likedDate;
  UserDetail? userDetail;

  LikedByUsers({this.uid, this.likedDate, this.userDetail});

  LikedByUsers.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    likedDate = json['likedDate'];
    userDetail = json['userDetail'] != null
        ? UserDetail.fromJson(json['userDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    data['likedDate'] = likedDate;
    if (userDetail != null) {
      data['userDetail'] = userDetail!.toJson();
    }
    return data;
  }
}

class MutualLikes {
  String? uid;
  String? likedDate;
  UserDetail? userDetail;

  MutualLikes({this.uid, this.likedDate, this.userDetail});

  MutualLikes.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    likedDate = json['likedDate'];
    userDetail = json['userDetail'] != null
        ? UserDetail.fromJson(json['userDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    data['likedDate'] = likedDate;
    if (userDetail != null) {
      data['userDetail'] = userDetail!.toJson();
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['address'] = address;
    data['age'] = age;
    data['image'] = image;
    return data;
  }
}
