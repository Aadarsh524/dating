import 'dart:io';

class ApproveDocumentModel {
  String? id;
  String? uid;
  int? verificationStatus;
  List<Documents>? documents;

  ApproveDocumentModel(
      {this.id, this.uid, this.verificationStatus, this.documents});

  ApproveDocumentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uid = json['uid'];
    verificationStatus = json['verificationStatus'];
    if (json['documents'] != null) {
      documents = <Documents>[];
      json['documents'].forEach((v) {
        documents!.add(Documents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['uid'] = uid;
    data['verificationStatus'] = verificationStatus;
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Documents {
  File? file;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['file'] = file;
    data['fileName'] = fileName;
    data['documentType'] = documentType;
    data['fileType'] = fileType;
    data['timeStamp'] = timeStamp;
    return data;
  }
}
