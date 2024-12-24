import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating/datamodel/chat/chat_message_model.dart'
    as chatmessageModel;
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/datamodel/chat/send_message_model.dart' as sendModel;
import 'package:dating/pages/components/profile_button.dart';
import 'package:dating/pages/ring_screen.dart';
import 'package:dating/providers/chat_provider/socket_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:dating/widgets/text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChatPageDesktop extends StatefulWidget {
  final String chatID;
  final EndUserDetails chatRoomModel;
  final String receiverId;

  const ChatPageDesktop(
      {super.key,
      required this.chatID,
      required this.chatRoomModel,
      required this.receiverId});

  @override
  State<ChatPageDesktop> createState() => _ChatPageDesktopState();
}

class _ChatPageDesktopState extends State<ChatPageDesktop> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');
  late SocketMessageProvider _socketMessageProvider;
  bool isMessageEmpty = true;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socketMessageProvider = context.read<SocketMessageProvider>();
      try {
        _socketMessageProvider.initializeSocket(user!.uid, widget.receiverId);
      } catch (e) {
        print('Error initializing socket: $e');
      }

      _socketMessageProvider.getMessage(widget.chatID, 1, user!.uid);

      _messageController.addListener(() {
        setState(() {
          isMessageEmpty = _messageController.text.isEmpty;
        });
      });
    });
  }
  // Future<void> addImage(
  //     List<Uint8List> fileBytes, List<String> fileName) async {
  //   final chatProvider = context.read<SocketMessageProvider>();
  //   final sendMessage = SendMessageModel(
  //     fileBytes: fileBytes,
  //     fileName: fileName,
  //     senderId: user!.uid,
  //     receiverId: widget.receiverId,
  //   );

  //   await chatProvider.sendChatViaAPI(
  //     sendMessage,
  //     chat!,
  //     user!.uid,
  //   );
  // }
  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
  }

  void sendMessage(String message) {
    if (message.isNotEmpty && mounted) {
      _socketMessageProvider.sendChatViaAPI(
        sendModel.SendMessageModel(
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

  void pickImage(BuildContext context) async {
    try {
      log("pick image is tapped");
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        if (!await Permission.storage.request().isGranted) {
          throw Exception(
              'Storage permission is required to upload the image.');
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      if (result?.files.isNotEmpty ?? false) {
        final fileBytes = result!.files.single.bytes;

        final chatProvider = context.read<SocketMessageProvider>();
        chatProvider.sendChatViaAPI(
          sendModel.SendMessageModel(
            fileBytes: [fileBytes]
                as List<Uint8List>, // Send list of bytes for web platforms
            senderId: user!.uid,
            receiverId: widget.receiverId,
            type: 'Image',
          ),
          widget.chatID,
          user!.uid,
        );
      } else {
        print('No image selected.');
      }
    } catch (e, stacktrace) {
      log('Exception caught: ${e.toString()}');
      log('Stacktrace: $stacktrace');
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // profile
                Row(
                  children: [
                    ProfileImage(),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Dating App',
                      style: GoogleFonts.poppins(
                        color: AppColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // search icon
                Row(
                  children: [
                    ButtonWithLabel(
                      text: null,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                      ),
                      labelText: null,
                    ),

                    // settings icon

                    ButtonWithLabel(
                      text: null,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.settings,
                      ),
                      labelText: null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 40,
          ),

          // icons
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.25),
                  // spreadRadius: 5,
                  blurRadius: 20,
                  offset: const Offset(0, 25), // horizontal and vertical offset
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                // physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  // matches
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ButtonWithLabel(
                            text: null,
                            labelText: 'Matches',
                            onPressed: () {},
                            icon: const Icon(Icons.people),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          // messages
                          ButtonWithLabel(
                            text: null,
                            labelText: 'Messages',
                            onPressed: () {},
                            icon: const Icon(Icons.messenger_outline),
                          ),

                          const SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 100,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 30,
          ),
          Expanded(
            child: Row(
              children: [
                const NavBarDesktop(),
                const SizedBox(
                  width: 30,
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Neumorphic(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: Neumorphic(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Profile pic with name
                                          Row(
                                            children: [
                                              Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: MemoryImage(
                                                        base64ToImage(widget
                                                            .chatRoomModel
                                                            .profileImage!)),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.chatRoomModel.name!,
                                                    style: AppTextStyles()
                                                        .primaryStyle
                                                        .copyWith(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // Video and audio call
                                          Row(
                                            children: [
                                              Icon(Icons.circle,
                                                  color: Colors.green,
                                                  size: 12),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {
                                                  final chatProvider =
                                                      context.read<
                                                          SocketMessageProvider>();
                                                  chatProvider.sendChatViaAPI(
                                                      sendModel.SendMessageModel(
                                                          senderId: user!.uid,
                                                          receiverId:
                                                              widget.receiverId,
                                                          callDetails: sendModel
                                                              .CallDetails(
                                                                  duration:
                                                                      "10",
                                                                  status:
                                                                      "Received"),
                                                          type: 'Call'),
                                                      widget.chatID,
                                                      user!.uid);
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => RingScreen(
                                                              roomId: "null",
                                                              endUserDetails: widget
                                                                  .chatRoomModel,
                                                              clientID: widget
                                                                  .receiverId)));
                                                },
                                                child: const Icon(
                                                    Icons.call_outlined),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () {},
                                                child: const Icon(
                                                    Icons.video_call),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _buildChatContent(),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ButtonWithLabel(
                                        text: null,
                                        labelText: null,
                                        onPressed: () {
                                          pickImage(context);
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                      Expanded(
                                        child: AppTextField(
                                          hintText: 'Type your message',
                                          inputcontroller: _messageController,
                                        ),
                                      ),
                                      ButtonWithLabel(
                                        text: null,
                                        labelText: null,
                                        onPressed: () {},
                                        icon: const Icon(Icons.mic),
                                      ),
                                      // Send button
                                      ButtonWithLabel(
                                        text: null,
                                        labelText: null,
                                        onPressed: () {
                                          if (_messageController
                                              .text.isNotEmpty) {
                                            sendMessage(
                                                _messageController.text);
                                            _messageController.clear();
                                            _scrollToBottom();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Center(
                                                    child: Text(
                                                        'Please enter text message')),
                                                duration: Duration(
                                                    seconds:
                                                        2), // Duration the Snackbar is visible
                                              ),
                                            );
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Consumer<SocketMessageProvider>(
      builder: (context, chatMessageProvider, child) {
        chatmessageModel.ChatMessageModel? chatRoomModel =
            chatMessageProvider.userChatMessageModel;

        if (chatMessageProvider.isMessagesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatRoomModel == null || chatRoomModel.messages!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }

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
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildMessageContent(message, isCurrentUser),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageContent(
      chatmessageModel.Messages message, bool isCurrentUser) {
    switch (message.type) {
      case 'Text':
        return _buildTextMessage(message, isCurrentUser);
      case 'Call':
        return _buildCallContent(
            message.callDetails!.status!, message.callDetails!.status!, true);
      case 'Image':
        return _buildImageContent(message, isCurrentUser);
      case 'Audio':
        return _buildImageContent(message, isCurrentUser);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextMessage(
      chatmessageModel.Messages message, bool isCurrentUser) {
    return Text(
      message.messageContent ?? '',
      style: AppTextStyles().secondaryStyle.copyWith(
            color: isCurrentUser ? Colors.white : Colors.black,
            fontSize: 14,
          ),
    );
  }

  Widget _buildCallContent(
      String callStatus, String callDuration, bool isOngoing) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOngoing
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon with background circle
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isOngoing ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOngoing ? Icons.call : Icons.call_end,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // Status and duration text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callStatus,
                  style: TextStyle(
                    color: isOngoing ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: $callDuration',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Action icon (optional, like a replay button)
          if (!isOngoing)
            IconButton(
              icon: const Icon(Icons.replay, color: Colors.grey),
              onPressed: () {}, // Define action here
            ),
        ],
      ),
    );
  }

  Widget _buildImageContent(
      chatmessageModel.Messages messages, bool isCurrentUser) {
    // Check if fileBytes is null and use fileName otherwise
    bool showImageFromBytes = messages.fileBytes != null;

    // When showImageFromBytes is true, we display images from fileBytes
    if (showImageFromBytes) {
      return SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:
              messages.fileBytes?.length ?? 0, // Only one image from fileBytes
          itemBuilder: (context, index) {
            // Use MemoryImage to display the image from fileBytes
            ImageProvider imageProvider =
                MemoryImage(messages.fileBytes![index]);

            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: InteractiveViewer(
                      child: Image(image: imageProvider, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
              child: Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    } else {
      // When showImageFromBytes is false, we display images from fileName (URL or file path)
      return SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: messages.fileName?.length ?? 0, // Number of images
          itemBuilder: (context, index) {
            // Use fileName to construct image URL and load with CachedNetworkImageProvider
            String imageUrl =
                'http://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/api/Communication/FileView/Azure/${messages.fileName![index]}';

            // Use CachedNetworkImageProvider to load the image from the URL
            ImageProvider imageProvider = CachedNetworkImageProvider(
              imageUrl,
            );

            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: InteractiveViewer(
                      child: Image(image: imageProvider, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
              child: Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Custom error UI for image loading failure
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
