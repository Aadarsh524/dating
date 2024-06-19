import 'dart:io';

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
  List<File>? fileName;
  String? timeStamp;
  String? type;

  Messages({
    this.messageId,
    this.senderId,
    this.messageContent,
    this.recieverId,
    this.fileName,
    this.timeStamp,
    this.type,
  });

  Messages.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    senderId = json['senderId'];
    messageContent = json['messageContent'];
    recieverId = json['recieverId'];
    fileName = json['fileName'];
    timeStamp = json['timeStamp'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['messageId'] = messageId;
    data['senderId'] = senderId;
    data['messageContent'] = messageContent;
    data['recieverId'] = recieverId;
    data['fileName'] = fileName;
    data['timeStamp'] = timeStamp;
    data['type'] = type;
    return data;
  }
}
