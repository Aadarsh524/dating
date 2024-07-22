class ChatMessageModel {
  String? id;
  String? chatId;
  List<String>? participants;
  List<Messages>? messages;

  ChatMessageModel({this.id, this.chatId, this.participants, this.messages});

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    chatId = json['chatId'];
    participants = List<String>.from(json['participants']);
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
  List<dynamic>? file;
  String? timeStamp;
  String? type;
  CallDetails? callDetails;

  Messages(
      {this.messageId,
      this.senderId,
      this.messageContent,
      this.recieverId,
      this.fileName,
      this.file,
      this.timeStamp,
      this.type,
      this.callDetails});

  Messages.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    senderId = json['senderId'];
    messageContent = json['messageContent'];
    recieverId = json['recieverId'];
    fileName =
        json['fileName'] != null ? List<String>.from(json['fileName']) : null;
    file = json['file'] != null ? List<dynamic>.from(json['file']) : null;
    timeStamp = json['timeStamp'];
    type = json['type'];
    callDetails = json['callDetails'] != null
        ? CallDetails.fromJson(json['callDetails'])
        : null;
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
    return data;
  }
}

class CallDetails {
  String? id;
  String? roomId;
  Offer? offer;
  Offer? answer;
  String? callerCandidateUid;
  String? calleeCandidateUid;
  List<CallerCandidates>? callerCandidates;
  List<CalleeCandidates>? calleeCandidates;
  String? createdAt;
  String? updatedAt;

  CallDetails(
      {this.id,
      this.roomId,
      this.offer,
      this.answer,
      this.callerCandidateUid,
      this.calleeCandidateUid,
      this.callerCandidates,
      this.calleeCandidates,
      this.createdAt,
      this.updatedAt});

  CallDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    roomId = json['roomId'];
    offer = json['offer'] != null ? Offer.fromJson(json['offer']) : null;
    answer = json['answer'] != null ? Offer.fromJson(json['answer']) : null;
    callerCandidateUid = json['callerCandidateUid'];
    calleeCandidateUid = json['calleeCandidateUid'];
    if (json['callerCandidates'] != null) {
      callerCandidates = <CallerCandidates>[];
      json['callerCandidates'].forEach((v) {
        callerCandidates!.add(CallerCandidates.fromJson(v));
      });
    }
    if (json['calleeCandidates'] != null) {
      calleeCandidates = <CalleeCandidates>[];
      json['calleeCandidates'].forEach((v) {
        calleeCandidates!.add(CalleeCandidates.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['roomId'] = roomId;
    if (offer != null) {
      data['offer'] = offer!.toJson();
    }
    if (answer != null) {
      data['answer'] = answer!.toJson();
    }
    data['callerCandidateUid'] = callerCandidateUid;
    data['calleeCandidateUid'] = calleeCandidateUid;
    if (callerCandidates != null) {
      data['callerCandidates'] =
          callerCandidates!.map((v) => v.toJson()).toList();
    }
    if (calleeCandidates != null) {
      data['calleeCandidates'] =
          calleeCandidates!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class Offer {
  String? sdp;
  String? type;

  Offer({this.sdp, this.type});

  Offer.fromJson(Map<String, dynamic> json) {
    sdp = json['sdp'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['sdp'] = sdp;
    data['type'] = type;
    return data;
  }
}

class CallerCandidates {
  String? candidate;
  String? sdpMid;
  int? sdpMLineIndex;

  CallerCandidates({this.candidate, this.sdpMid, this.sdpMLineIndex});

  CallerCandidates.fromJson(Map<String, dynamic> json) {
    candidate = json['candidate'];
    sdpMid = json['sdpMid'];
    sdpMLineIndex = json['sdpMLineIndex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['candidate'] = candidate;
    data['sdpMid'] = sdpMid;
    data['sdpMLineIndex'] = sdpMLineIndex;
    return data;
  }
}

class CalleeCandidates {
  String? candidate;
  String? sdpMid;
  int? sdpMLineIndex;

  CalleeCandidates({this.candidate, this.sdpMid, this.sdpMLineIndex});

  CalleeCandidates.fromJson(Map<String, dynamic> json) {
    candidate = json['candidate'];
    sdpMid = json['sdpMid'];
    sdpMLineIndex = json['sdpMLineIndex'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['candidate'] = candidate;
    data['sdpMid'] = sdpMid;
    data['sdpMLineIndex'] = sdpMLineIndex;
    return data;
  }
}
