class ComplaintModel {
  String? id;
  String? uid;
  String? status;
  String? title;
  String? content;
  String? timestamp;
  String? username;
  String? image;

  ComplaintModel(
      {this.id,
      this.uid,
      this.status,
      this.title,
      this.content,
      this.timestamp,
      this.username,
      this.image});

  ComplaintModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    status = json['status'];
    title = json['title'];
    content = json['content'];
    timestamp = json['timestamp'];
    username = json['username'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uid'] = this.uid;
    data['status'] = this.status;
    data['title'] = this.title;
    data['content'] = this.content;
    data['timestamp'] = this.timestamp;
    data['username'] = this.username;
    data['image'] = this.image;
    return data;
  }
}
