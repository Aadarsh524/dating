import 'dart:convert';
import 'dart:io';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/chat/chat_message_model.dart' as chatmessage;
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/pages/ring_screen.dart';
import 'package:http/http.dart' as http;

import 'package:dating/datamodel/chat/send_message_model.dart';
import 'package:dating/pages/chatpage.dart';
import 'package:dating/providers/chat_provider/chat_message_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatScreemMobile extends StatefulWidget {
  final String chatID;
  final EndUserDetails chatRoomModel;
  final String recieverId;
  User? user = FirebaseAuth.instance.currentUser;

  ChatScreemMobile(
      {Key? key,
      required this.chatID,
      required this.chatRoomModel,
      required this.recieverId})
      : super(key: key);

  @override
  State<ChatScreemMobile> createState() => _ChatScreemMobileState();
}

class _ChatScreemMobileState extends State<ChatScreemMobile> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  User? user = FirebaseAuth.instance.currentUser;

  late bool _isNewChat;

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  Future<String>? imageUrl;

  @override
  void initState() {
    super.initState();
    _isNewChat = widget.chatID == '' && widget.chatRoomModel.message == null;

    if (!_isNewChat) {
      final chatMessageProvider = context.read<ChatMessageProvider>();
      chatMessageProvider.getMessage(widget.chatID, 1, user!.uid);
    }
    imageUrl =
        Provider.of<ChatMessageProvider>(context, listen: false).fetchImage();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void pickImage() async {
    try {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        throw Exception('Storage permission is required to upload the image.');
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        File imageFile = File(result.files.single.path!);

        final chatProvider = context.read<ChatMessageProvider>();

        await chatProvider.sendChat(
          SendMessageModel(
            file: imageFile,
            senderId: user!.uid,
            receiverId: widget.recieverId,
          ),
          widget.chatID,
          user!.uid,
        );
      } else {
        print('No image selected.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String convertIntoBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64File = base64Encode(imageBytes);
    return base64File;
  }

  String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      ButtonWithLabel(
                        text: null,
                        labelText: null,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: widget.chatRoomModel.profileImage != null
                                ? MemoryImage(base64ToImage(
                                    widget.chatRoomModel.profileImage!))
                                : MemoryImage(
                                    base64ToImage(defaultBase64Avatar)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chatRoomModel.name ?? 'New Chat',
                            style: AppTextStyles()
                                .primaryStyle
                                .copyWith(fontSize: 14),
                          ),
                        ],
                      )
                    ],
                  ),
                  ButtonWithLabel(
                    text: null,
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RingScreen(
                                    roomId: "null",
                                    endUserDetails: widget.chatRoomModel,
                                    clientID: widget.recieverId,
                                  )));
                    },
                    icon: const Icon(Icons.call),
                    labelText: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: const ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 0.50,
                    strokeAlign: BorderSide.strokeAlignCenter,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ),
            Expanded(
                child:
                    _isNewChat ? _buildNewChatContent() : _buildChatContent()),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ButtonWithLabel(
                    text: null,
                    labelText: null,
                    onPressed: () {
                      pickImage();
                    },
                    icon: const Icon(Icons.image),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: AppTextField(
                      hintText: 'Type your message',
                      inputcontroller: _messageController,
                    ),
                  ),
                  const SizedBox(width: 5),
                  ButtonWithLabel(
                    text: null,
                    labelText: null,
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                  ),
                  const SizedBox(width: 5),
                  ButtonWithLabel(
                    text: null,
                    labelText: null,
                    onPressed: () async {
                      if (_messageController.text.isNotEmpty) {
                        final chatProvider =
                            context.read<ChatMessageProvider>();

                        await chatProvider.sendChat(
                          SendMessageModel(
                            senderId: user!.uid,
                            messageContent: _messageController.text,
                            type: "Text",
                            receiverId: widget.recieverId,
                          ),
                          widget.chatID,
                          user!.uid,
                        );
                        _messageController.clear();
                        _scrollToBottom();
                      }
                      if (_isNewChat) {
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const ChatPage()));
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatContent() {
    return Center(
      child: Text(
        'Start a new chat',
        style: AppTextStyles().primaryStyle.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _buildChatContent() {
    return Consumer<ChatMessageProvider>(
      builder: (context, chatMessageProvider, child) {
        chatmessage.ChatMessageModel? chatRoomModel =
            chatMessageProvider.userChatMessageModel;
        if (chatMessageProvider.isMessagesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (chatRoomModel == null) {
            return const Center(child: Text(""));
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: chatRoomModel.messages!.length,
            itemBuilder: (context, index) {
              var reversedMessages = chatRoomModel.messages!.reversed.toList();
              var message = reversedMessages[index];
              bool isCurrentUser = message.senderId == user!.uid;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: isCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          color: isCurrentUser ? Colors.blue : Colors.white,
                          depth: 2,
                          intensity: 0.8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          child: _buildMessageContent(message, isCurrentUser),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMessageContent(
      chatmessage.Messages message, bool isCurrentUser) {
    switch (message.type) {
      case 'Text':
        return Text(
          message.messageContent!,
          style: AppTextStyles().secondaryStyle.copyWith(
                color: isCurrentUser ? Colors.white : Colors.black,
                fontSize: 14,
              ),
        );
      case 'Audio':
        return _buildImageContent(message.fileName!, isCurrentUser);
      // case 'Audio':
      //   return AudioPlayerWidget(audioUrl: message.audioUrl!);
      // case 'Call':
      //   return CallInfoWidget(callInfo: message.callInfo!);
      default:
        return Container();
    }
  }

  Widget _buildImageContent(List<String> imageName, bool isCurrentUser) {
    print(imageName);
    return SizedBox(
      height: 50,
      width: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageName.length,
        itemBuilder: (context, index) {
          String imageUrl =
              'http://10.0.2.2:8001/api/Communication/FileView/${imageName[index]}';

          print(imageUrl);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCurrentUser ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes!)
                              : null,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
