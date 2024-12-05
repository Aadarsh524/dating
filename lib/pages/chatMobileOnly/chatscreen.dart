import 'dart:convert';
import 'dart:io';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/chat/chat_message_model.dart' as chatmessage;
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/datamodel/chat/send_message_model.dart';
import 'package:dating/pages/ring_screen.dart';
import 'package:dating/providers/chat_provider/socket_message_provider.dart';

import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../providers/chat_provider/chat_message_provider.dart';

class ChatScreemMobile extends StatefulWidget {
  final String chatID;
  final EndUserDetails chatRoomModel;
  final String recieverId;

  ChatScreemMobile({
    Key? key,
    required this.chatID,
    required this.chatRoomModel,
    required this.recieverId,
  }) : super(key: key);

  @override
  State<ChatScreemMobile> createState() => _ChatScreemMobileState();
}

class _ChatScreemMobileState extends State<ChatScreemMobile> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    // Initialize socket connection and fetch initial messages
    final socketService = SocketMessageProvider();
    socketService.initializeSocket(user!.uid); // Establish WebSocket connection

    context
        .read<SocketMessageProvider>()
        .getMessage(widget.chatID, 1, user!.uid); // Replace with your userId
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

  void sendMessage(String message) async {
    if (message.isNotEmpty) {
      final chatProvider = context.read<ChatMessageProvider>();
      chatProvider.sendChat(
          SendMessageModel(
            senderId: user!.uid,
            messageContent: message,
            type: "Text",
            receiverId: widget.recieverId,
          ),
          widget.chatID,
          user!.uid);
      _messageController.clear(); // Clear message input after sending
      _scrollToBottom(); // Scroll to the bottom of the chat
    }
  }

  void pickImage() async {
    try {
      // Request storage permission
      final storageStatus = await Permission.manageExternalStorage.request();
      print('Storage permission status: $storageStatus');

      if (!storageStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please grant manage storage permission to upload images.'),
          ),
        );
        return;
      }

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      // Ensure a valid file is selected
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        File imageFile = File(result.files.single.path!);

        final chatProvider = context.read<SocketMessageProvider>();
        chatProvider.sendChatViaAPI(
            SendMessageModel(
              file: imageFile,
              senderId: user!.uid,
              receiverId: widget.recieverId,
            ),
            widget.chatID,
            user!.uid);
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
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
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: widget.chatRoomModel.profileImage !=
                                null
                            ? MemoryImage(base64Decode(
                                widget.chatRoomModel.profileImage!))
                            : MemoryImage(base64Decode(defaultBase64Avatar)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.chatRoomModel.name ?? 'New Chat',
                        style:
                            AppTextStyles().primaryStyle.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  ButtonWithLabel(
                    text: null,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RingScreen(
                            roomId: "null",
                            endUserDetails: widget.chatRoomModel,
                            clientID: widget.recieverId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.call),
                    labelText: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: Colors.grey[300],
            ),
            Expanded(child: _buildChatContent()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      pickImage();
                    },
                    icon: const Icon(Icons.image, color: Colors.blue),
                  ),
                  Expanded(
                    child: AppTextField(
                      hintText: 'Type your message',
                      inputcontroller: _messageController,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage(_messageController.text);
                    },
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent() {
    return Consumer<SocketMessageProvider>(
      builder: (context, chatMessageProvider, child) {
        chatmessage.ChatMessageModel? chatRoomModel =
            chatMessageProvider.userChatMessageModel;

        if (chatMessageProvider.isMessagesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatRoomModel == null || chatRoomModel.messages!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: chatRoomModel.messages!.length,
          itemBuilder: (context, index) {
            var message = chatRoomModel.messages!.reversed.toList()[index];
            bool isCurrentUser = message.senderId == user!.uid;

            return Align(
              alignment:
                  isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: _buildMessageContent(message, isCurrentUser),
                ),
              ),
            );
          },
        );
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
      case 'Image':
        return _buildImageContent(message.fileName!, isCurrentUser);
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
              'http://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/api/Communication/FileView/Azure/${imageName[index]}';
          print(imageUrl);
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isCurrentUser ? Colors.blue : Colors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
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
          );
        },
      ),
    );
  }
}
