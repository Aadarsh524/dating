class DocumentVerificationModel {
  String? uid;
  int? verificationStatus;
  List<Documents>? documents;

  DocumentVerificationModel(
      {this.uid, this.verificationStatus, this.documents});

  DocumentVerificationModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    verificationStatus = json['verificationStatus'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(new Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['verificationStatus'] = this.verificationStatus;
    if (this.documents != null) {
      data['documents'] = this.documents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Documents {
  String? file;
  String? fileName;
  String? documentType;
  String? fileType;
  String? timeStamp;

  Documents(
      {this.file,
      this.fileName,
      this.documentType,
      this.fileType,
      this.timeStamp});

  Documents.fromJson(Map<String, dynamic> json) {
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
