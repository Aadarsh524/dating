import 'dart:io';
import 'dart:typed_data';

class ChatMessageModel {
  String? id;
  String? chatId;
  List<String>? participants;
  List<Messages>? messages;

  ChatMessageModel({this.id, this.chatId, this.participants, this.messages});

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatId = json['chatId'];
    participants = json['participants'].cast<String>();
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['chatId'] = chatId;
    data['participants'] = participants;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? messageId;
  String? senderId;
  String? messageContent;
  String? recieverId;
  List<String>? fileName;
  List<File>? file; // List of files
  List<Uint8List>? fileBytes; // For byte-based representation
  String? timeStamp;
  String? type;
  CallDetails? callDetails;
  String? call;

  Messages({
    this.messageId,
    this.senderId,
    this.messageContent,
    this.recieverId,
    this.fileName,
    this.file,
    this.fileBytes,
    this.timeStamp,
    this.type,
    this.callDetails,
    this.call,
  });

  Messages.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    senderId = json['senderId'];
    messageContent = json['messageContent'];
    recieverId = json['recieverId'];
    fileName = json['fileName']?.cast<String>();

    // Handling file as a list of File objects
    if (json['file'] != null) {
      file = [];
      for (var filePath in json['file']) {
        file?.add(File(filePath)); // Add each file from the list of file paths
      }
    }

    // Handle fileBytes if available
    if (json['fileBytes'] != null) {
      fileBytes = List<Uint8List>.from(json['fileBytes']);
    }

    timeStamp = json['timeStamp'];
    type = json['type'];

    // Handle CallDetails
    callDetails = json['callDetails'] != null
        ? CallDetails.fromJson(json['callDetails'])
        : null;
    call = json['call'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageId'] = messageId;
    data['senderId'] = senderId;
    data['messageContent'] = messageContent;
    data['recieverId'] = recieverId;
    data['fileName'] = fileName;

    // Handle file and fileBytes serialization
    if (file != null) {
      data['file'] = file
          ?.map((e) => e.path)
          .toList(); // Convert List<File> to List<String> of paths
    }

    data['fileBytes'] = fileBytes; // File bytes (if available)
    data['timeStamp'] = timeStamp;
    data['type'] = type;

    if (callDetails != null) {
      data['callDetails'] = callDetails!.toJson();
    }

    data['call'] = call;
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
