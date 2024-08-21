class ProfileViewModel {
  String? uid;
  String? name;
  String? address;
  String? age;
  String? image;

  ProfileViewModel({this.uid, this.name, this.address, this.age, this.image});

  ProfileViewModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    address = json['address'];
    age = json['age'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['address'] = this.address;
    data['age'] = this.age;
    data['image'] = this.image;
    return data;
  }
}
