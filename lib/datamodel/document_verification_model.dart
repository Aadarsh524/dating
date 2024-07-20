class DocumentVerificationModel {
  String? uid;
  int? verificationStatus;
  List<Document>? document;

  DocumentVerificationModel({this.uid, this.verificationStatus, this.document});

  DocumentVerificationModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    verificationStatus = json['verificationStatus'];
    if (json['document'] != null) {
      document = <Document>[];
      json['document'].forEach((v) {
        document!.add(new Document.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['verificationStatus'] = this.verificationStatus;
    if (this.document != null) {
      data['document'] = this.document!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Document {
  String? file;
  String? fileName;
  String? documentType;
  String? fileType;
  String? timeStamp;

  Document(
      {this.file,
      this.fileName,
      this.documentType,
      this.fileType,
      this.timeStamp});

  Document.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    fileName = json['fileName'];
    documentType = json['documentType'];
    fileType = json['fileType'];
    timeStamp = json['timeStamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file'] = this.file;
    data['fileName'] = this.fileName;
    data['documentType'] = this.documentType;
    data['fileType'] = this.fileType;
    data['timeStamp'] = this.timeStamp;
    return data;
  }
}
