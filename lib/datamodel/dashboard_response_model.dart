class DashboardResponseModel {
  String? uid;
  String? image;
  String? name;
  String? address;
  String? age;
  String? gender;
  Upload? upload;

  DashboardResponseModel(
      {this.uid,
      this.image,
      this.name,
      this.address,
      this.age,
      this.gender,
      this.upload});

  DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    image = json['image'];
    name = json['name'];
    address = json['address'];
    age = json['age'];
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