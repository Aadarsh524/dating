import 'dart:io';

import 'package:dating/datamodel/chat/chat_message_model.dart';

class SendMessageModel {
  String? senderId;
  String? messageContent;
  String? receiverId;
  String? type;
  List<String>? fileName;
  File? file; // For non-web platforms
  List<int>? fileBytes; // For web platforms
  CallDetails? callDetails;

  SendMessageModel({
    this.senderId,
    this.messageContent,
    this.receiverId,
    this.type,
    this.fileName,
    this.file,
    this.fileBytes,
    this.callDetails,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderId'] = senderId;
    data['messageContent'] = messageContent;
    data['receiverId'] = receiverId;
    data['type'] = type;
    data['fileName'] = fileName;
    if (callDetails != null) {
      data['callDetails'] = callDetails!.toJson();
    }
    // Convert file to bytes if it's available and assign it to fileBytes
    if (file != null) {
      data['fileBytes'] = file?.readAsBytesSync();
    } else if (fileBytes != null) {
      data['fileBytes'] = fileBytes;
    }

    return data;
  }
}
