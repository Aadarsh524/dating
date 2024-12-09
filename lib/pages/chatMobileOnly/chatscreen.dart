import 'dart:convert';
import 'dart:io';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/chat/chat_message_model.dart' as chatmessage;
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/datamodel/chat/send_message_model.dart';
import 'package:dating/pages/ring_screen.dart';
import 'package:dating/providers/chat_provider/socket_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreenMobile extends StatefulWidget {
  final String chatID;
  final EndUserDetails chatRoomModel;
  final String receiverId;

  const ChatScreenMobile({
    super.key,
    required this.chatID,
    required this.chatRoomModel,
    required this.receiverId,
  });

  @override
  State<ChatScreenMobile> createState() => _ChatScreenMobileState();
}

class _ChatScreenMobileState extends State<ChatScreenMobile> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late SocketMessageProvider _socketMessageProvider;
  User? user = FirebaseAuth.instance.currentUser;
  bool isMessageEmpty = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize socket connection
      _socketMessageProvider = context.read<SocketMessageProvider>();
      _socketMessageProvider.initializeSocket(
          user!.uid, widget.receiverId); // Establish WebSocket connection
      _socketMessageProvider.getMessage(widget.chatID, 1, user!.uid);

      _messageController.addListener(() {
        setState(() {
          isMessageEmpty = _messageController.text.isEmpty;
        });
      });
    });
  }

  @override
  void dispose() {
    _socketMessageProvider.disconnectSocket();
    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage(String message) {
    if (message.isNotEmpty && mounted) {
      _socketMessageProvider.sendChatViaAPI(
        SendMessageModel(
          senderId: user!.uid,
          messageContent: message,
          type: "Text",
          receiverId: widget.receiverId,
        ),
        widget.chatID,
        user!.uid,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void pickImage() async {
    try {
      final storageStatus = await Permission.manageExternalStorage.request();

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
                receiverId: widget.receiverId,
                type: 'Image'),
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
        resizeToAvoidBottomInset: true,
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
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chatRoomModel.name ?? 'New Chat',
                            style: AppTextStyles()
                                .primaryStyle
                                .copyWith(fontSize: 16),
                          ),
                          // Updated Online/Offline status UI
                          Consumer<SocketMessageProvider>(
                            builder: (context, provider, child) {
                              bool isOnline = provider.isUserOnline;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: isOnline
                                            ? Colors.green
                                            : AppColors.secondaryColor,
                                      ),
                                      const SizedBox(
                                          width:
                                              5), // Space between the dot and text
                                      Text(
                                        isOnline ? 'Online' : 'Offline',
                                        style: AppTextStyles()
                                            .secondaryStyle
                                            .copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: AppColors.black,
                                            ),
                                      ),
                                    ],
                                  ),
                                  // Additional details like last seen time can be added here
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  ButtonWithLabel(
                    text: null,
                    onPressed: () {
                      final chatProvider =
                          context.read<SocketMessageProvider>();
                      chatProvider.sendChatViaAPI(
                          SendMessageModel(
                              senderId: user!.uid,
                              receiverId: widget.receiverId,
                              callDetails: chatmessage.CallDetails(
                                  status: "Received", duration: "10"),
                              type: 'Call'),
                          widget.chatID,
                          user!.uid);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RingScreen(
                            roomId: "null",
                            endUserDetails: widget.chatRoomModel,
                            clientID: widget.receiverId,
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
                  // Image picker button
                  IconButton(
                    onPressed: pickImage,
                    icon: const Icon(Icons.image, color: Colors.blue),
                  ),
                  // Message input field
                  Expanded(
                    child: AppTextField(
                      hintText: 'Type your message',
                      inputcontroller: _messageController,
                      focusNode: _focusNode,
                    ),
                  ),
                  // Send button, only enabled if message is not empty
                  IconButton(
                    onPressed: isMessageEmpty
                        ? null // Disable if message is empty
                        : () => sendMessage(_messageController.text),
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: chatRoomModel.messages!.length,
          itemBuilder: (context, index) {
            var message = chatRoomModel.messages![index];

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
    if (message.messageContent == null && message.fileName == null) {
      return const SizedBox(); // Return an empty widget if no content
    }

    switch (message.type) {
      case 'Text':
        return Text(
          message.messageContent ?? '',
          style: AppTextStyles().secondaryStyle.copyWith(
                color: isCurrentUser ? Colors.white : Colors.black,
                fontSize: 14,
              ),
        );
      case 'Image':
        if (message.fileName == null) {
          return const Text("Invalid Image");
        }
        return _buildImageContent(message.fileName!, isCurrentUser);
      default:
        return Container(); // Handle any unknown message types here
    }
  }

  Widget _buildImageContent(List<String> imageName, bool isCurrentUser) {
    return SizedBox(
      height: 70, // Increased height for better visibility
      width: double.infinity, // Make it take full width of its parent
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageName.length,
        itemBuilder: (context, index) {
          String imageUrl =
              'http://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/api/Communication/FileView/Azure/${imageName[index]}';

          return SizedBox(
            height: 60, // Consistent size for each container
            width: 60, // Square container for images
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  5), // Ensure the image fits within rounded borders
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }
}
