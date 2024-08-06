class DocumentVerificationModel {
  String? uid;
  String? documentType;
  List<String>? document;

  DocumentVerificationModel({this.uid, this.documentType, this.document});

  DocumentVerificationModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    documentType = json['documentType'];
    document = json['file'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    data['documentType'] = documentType;
    data['file'] = document;
    return data;
  }
}
