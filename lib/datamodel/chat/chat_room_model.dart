// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'chat_message_model.dart';

class ChatRoomModel {
  String? uid;
  List<Conversations>? conversations;

  ChatRoomModel({this.uid, this.conversations});

  ChatRoomModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    if (json['conversations'] != null) {
      conversations = <Conversations>[];
      json['conversations'].forEach((v) {
        conversations!.add(new Conversations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    if (this.conversations != null) {
      data['conversations'] =
          this.conversations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Conversations {
  String? chatId;
  String? endUserId;
  String? timeStamp;
  EndUserDetails? endUserDetails;
  bool? seen;

  Conversations(
      {this.chatId,
      this.endUserId,
      this.timeStamp,
      this.endUserDetails,
      this.seen});

  Conversations.fromJson(Map<String, dynamic> json) {
    chatId = json['chatId'];
    endUserId = json['endUserId'];
    timeStamp = json['timeStamp'];
    endUserDetails = json['endUserDetails'] != null
        ? new EndUserDetails.fromJson(json['endUserDetails'])
        : null;
    seen = json['seen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatId'] = this.chatId;
    data['endUserId'] = this.endUserId;
    data['timeStamp'] = this.timeStamp;
    if (this.endUserDetails != null) {
      data['endUserDetails'] = this.endUserDetails!.toJson();
    }
    data['seen'] = this.seen;
    return data;
  }
}

class EndUserDetails {
  String? profileImage;
  String? name;

  List<ChatMessageModel>? message;
  EndUserDetails({
    this.profileImage,
    this.name,
    this.message,
  });

  

  EndUserDetails copyWith({
    String? profileImage,
    String? name,
    List<ChatMessageModel>? message,
  }) {
    return EndUserDetails(
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'profileImage': profileImage,
      'name': name,
      'message': message!.map((x) => x.toMap()).toList(),
    };
  }

  factory EndUserDetails.fromMap(Map<String, dynamic> map) {
    return EndUserDetails(
      profileImage: map['profileImage'] != null ? map['profileImage'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      message: map['message'] != null ? List<ChatMessageModel>.from((map['message'] as List<int>).map<ChatMessageModel?>((x) => ChatMessageModel.fromMap(x as Map<String,dynamic>),),) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory EndUserDetails.fromJson(String source) => EndUserDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'EndUserDetails(profileImage: $profileImage, name: $name, message: $message)';

  @override
  bool operator ==(covariant EndUserDetails other) {
    if (identical(this, other)) return true;
  
    return 
      other.profileImage == profileImage &&
      other.name == name &&
      listEquals(other.message, message);
  }

  @override
  int get hashCode => profileImage.hashCode ^ name.hashCode ^ message.hashCode;
}




