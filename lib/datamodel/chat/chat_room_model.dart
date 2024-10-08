import 'dart:io';

class ChatRoomModel {
  String? uid;
  List<Conversations>? conversations;
  DailyCount? dailyCount;

  ChatRoomModel({this.uid, this.conversations, this.dailyCount});

  ChatRoomModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    if (json['conversations'] != null) {
      conversations = <Conversations>[];
      json['conversations'].forEach((v) {
        conversations!.add(Conversations.fromJson(v));
      });
    }
    dailyCount = json['dailyCount'] != null
        ? DailyCount.fromJson(json['dailyCount'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['uid'] = uid;
    if (conversations != null) {
      data['conversations'] = conversations!.map((v) => v.toJson()).toList();
    }
    if (dailyCount != null) {
      data['dailyCount'] = dailyCount!.toJson();
    }
    return data;
  }
}

class Conversations {
  String? chatId;
  String? messageId;
  String? endUserId;
  EndUserDetails? endUserDetails;
  bool? seen;

  Conversations(
      {this.chatId,
      this.messageId,
      this.endUserId,
      this.endUserDetails,
      this.seen});

  Conversations.fromJson(Map<String, dynamic> json) {
    chatId = json['chatId'];
    messageId = json['messageId'];
    endUserId = json['endUserId'];
    endUserDetails = json['endUserDetails'] != null
        ? EndUserDetails.fromJson(json['endUserDetails'])
        : null;
    seen = json['seen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['chatId'] = chatId;
    data['messageId'] = messageId;
    data['endUserId'] = endUserId;
    if (endUserDetails != null) {
      data['endUserDetails'] = endUserDetails!.toJson();
    }
    data['seen'] = seen;
    return data;
  }
}

class EndUserDetails {
  String? profileImage;
  String? name;
  Message? message;

  EndUserDetails({this.profileImage, this.name, this.message});

  EndUserDetails.fromJson(Map<String, dynamic> json) {
    profileImage = json['profileImage'];
    name = json['name'];
    message =
        json['message'] != null ? Message.fromJson(json['message']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['profileImage'] = profileImage;
    data['name'] = name;
    if (message != null) {
      data['message'] = message!.toJson();
    }
    return data;
  }
}

class Message {
  String? id;
  String? chatId;
  List<String>? participants;
  List<Messages>? messages;

  Message({this.id, this.chatId, this.participants, this.messages});

  Message.fromJson(Map<String, dynamic> json) {
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
  File? file;
  String? timeStamp;
  String? type;
  CallDetails? callDetails;
  String? call;

  Messages(
      {this.messageId,
      this.senderId,
      this.messageContent,
      this.recieverId,
      this.fileName,
      this.file,
      this.timeStamp,
      this.type,
      this.callDetails,
      this.call});

  Messages.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    senderId = json['senderId'];
    messageContent = json['messageContent'];
    recieverId = json['recieverId'];
    fileName = json['fileName'].cast<String>();
    file = json['file'];
    timeStamp = json['timeStamp'];
    type = json['type'];
    callDetails = json['callDetails'] != null
        ? CallDetails.fromJson(json['callDetails'])
        : null;
    call = json['call'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['messageId'] = messageId;
    data['senderId'] = senderId;
    data['messageContent'] = messageContent;
    data['recieverId'] = recieverId;
    data['fileName'] = fileName;
    data['file'] = file;
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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['duration'] = duration;
    data['status'] = status;
    return data;
  }
}

class DailyCount {
  String? lastMessageSentDate;
  String? messageSentTo;
  int? wordsSentToday;
  int? maximumMessageLimit;

  DailyCount(
      {this.lastMessageSentDate,
      this.messageSentTo,
      this.wordsSentToday,
      this.maximumMessageLimit});

  DailyCount.fromJson(Map<String, dynamic> json) {
    lastMessageSentDate = json['lastMessageSentDate'];
    messageSentTo = json['messageSentTo'];
    wordsSentToday = json['wordsSentToday'];
    maximumMessageLimit = json['maximumMessageLimit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['lastMessageSentDate'] = lastMessageSentDate;
    data['messageSentTo'] = messageSentTo;
    data['wordsSentToday'] = wordsSentToday;
    data['maximumMessageLimit'] = maximumMessageLimit;
    return data;
  }
}
