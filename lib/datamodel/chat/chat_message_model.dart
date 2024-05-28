// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChatMessageModel {
  String? senderId;
  String? messageContent;
  String? receiverId;

  String? type;
  ChatMessageModel({
    this.senderId,
    this.messageContent,
    this.receiverId,
   
    this.type,
  });

  ChatMessageModel copyWith({
    String? senderId,
    String? messageContent,
    String? receiverId,
    String? timeStamp,
    String? type,
  }) {
    return ChatMessageModel(
      senderId: senderId ?? this.senderId,
      messageContent: messageContent ?? this.messageContent,
      receiverId: receiverId ?? this.receiverId,
      
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'messageContent': messageContent,
      'receiverId': receiverId,
      
      'type': type,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      messageContent: map['messageContent'] != null ? map['messageContent'] as String : null,
      receiverId: map['receiverId'] != null ? map['receiverId'] as String : null,
     
      type: map['type'] != null ? map['type'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessageModel.fromJson(String source) => ChatMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatMessageModel(senderId: $senderId, messageContent: $messageContent, receiverId: $receiverId,  type: $type)';
  }

  @override
  bool operator ==(covariant ChatMessageModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.senderId == senderId &&
      other.messageContent == messageContent &&
      other.receiverId == receiverId &&
     
      other.type == type;
  }

  @override
  int get hashCode {
    return senderId.hashCode ^
      messageContent.hashCode ^
      receiverId.hashCode ^
    
      type.hashCode;
  }
}
