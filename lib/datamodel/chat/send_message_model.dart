class SendMessageModel {
  String? senderId;
  String? messageContent;
  String? receiverId;
  List<String>? fileName;
  String? file;
  String? type;

  SendMessageModel({
    this.senderId,
    this.messageContent,
    this.receiverId,
    this.fileName,
    this.file,
    this.type,
  });
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['senderId'] = senderId;
    data['messageContent'] = messageContent;
    data['receiverId'] = receiverId;
    data['fileName'] = fileName;
    data['file'] = file;
    data['type'] = type;
    return data;
  }
}
