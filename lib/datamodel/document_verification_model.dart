import 'dart:io';

class DocumentVerificationModel {
  String? uid;
  String? documentType;
  List<File>? file; // Used for non-web platforms
  List<int>? fileBytes; // Used for web platforms
  String? fileName; // Used for web platforms

  DocumentVerificationModel({
    this.uid,
    this.documentType,
    this.file,
    this.fileBytes,
    this.fileName,
  });

  DocumentVerificationModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    documentType = json['documentType'];
    // Assuming `fileBytes` will be a base64 string or byte array in JSON
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    data['documentType'] = documentType;
    return data;
  }
}
