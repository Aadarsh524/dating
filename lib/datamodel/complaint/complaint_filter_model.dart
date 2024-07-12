class ComplaintFilterModel {
  String? from;
  String? to;
  String? status;
  String? page;

  ComplaintFilterModel({this.from, this.to, this.status, this.page});

  ComplaintFilterModel.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
    status = json['status'];
    page = json['page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from;
    data['to'] = this.to;
    data['status'] = this.status;
    data['page'] = this.page;
    return data;
  }
}
