class DocumentVerificationModel {
  String? uid;
  String? documentType;
  List<String>? file;

  DocumentVerificationModel({this.uid, this.documentType, this.file});

  DocumentVerificationModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    documentType = json['documentType'];
    file = json['file'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    data['documentType'] = documentType;
    data['file'] = file;
    return data;
  }
}
