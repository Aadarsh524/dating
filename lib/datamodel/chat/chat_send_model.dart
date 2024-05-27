// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatSendModel {
  String? senderId;
  String? messageContent;
  String? receiverId;
  String? timeStamp;
  String? type;
  ChatSendModel({
    this.senderId,
    this.messageContent,
    this.receiverId,
    this.timeStamp,
    this.type,
  });

  ChatSendModel copyWith({
    String? senderId,
    String? messageContent,
    String? receiverId,
    String? timeStamp,
    String? type,
  }) {
    return ChatSendModel(
      senderId: senderId ?? this.senderId,
      messageContent: messageContent ?? this.messageContent,
      receiverId: receiverId ?? this.receiverId,
      timeStamp: timeStamp ?? this.timeStamp,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'messageContent': messageContent,
      'receiverId': receiverId,
      'timeStamp': timeStamp,
      'type': type,
    };
  }

  factory ChatSendModel.fromMap(Map<String, dynamic> map) {
    return ChatSendModel(
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      messageContent: map['messageContent'] != null ? map['messageContent'] as String : null,
      receiverId: map['receiverId'] != null ? map['receiverId'] as String : null,
      timeStamp: map['timeStamp'] != null ? map['timeStamp'] as String : null,
      type: map['type'] != null ? map['type'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatSendModel.fromJson(String source) => ChatSendModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatSendModel(senderId: $senderId, messageContent: $messageContent, receiverId: $receiverId, timeStamp: $timeStamp, type: $type)';
  }

  @override
  bool operator ==(covariant ChatSendModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.senderId == senderId &&
      other.messageContent == messageContent &&
      other.receiverId == receiverId &&
      other.timeStamp == timeStamp &&
      other.type == type;
  }

  @override
  int get hashCode {
    return senderId.hashCode ^
      messageContent.hashCode ^
      receiverId.hashCode ^
      timeStamp.hashCode ^
      type.hashCode;
  }
}
