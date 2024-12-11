import 'dart:io';
import 'dart:typed_data';

class SendMessageModel {
  String? senderId;
  String? messageContent;
  String? receiverId;
  String? type;
  List<String>? fileName; // List of filenames
  List<File>? files; // For non-web platforms (changed from `file` to `files`)
  List<Uint8List>? fileBytes; // For web platforms
  CallDetails? callDetails;

  SendMessageModel({
    this.senderId,
    this.messageContent,
    this.receiverId,
    this.type,
    this.fileName,
    this.files,
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

    // Add callDetails if it exists
    if (callDetails != null) {
      data['callDetails'] = callDetails!.toJson();
    }

    // Convert files to bytes and assign them to fileBytes
    if (files != null && files!.isNotEmpty) {
      data['fileBytes'] = files!.map((file) => file.readAsBytesSync()).toList();
    } else if (fileBytes != null) {
      data['fileBytes'] = fileBytes;
    }

    return data;
  }
}

class CallDetails {
  String? duration;
  String? status;

  CallDetails({this.duration, this.status});

  CallDetails.fromJson(Map<String, dynamic> json) {
    duration = json['duration'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['duration'] = duration;
    data['status'] = status;
    return data;
  }
}
