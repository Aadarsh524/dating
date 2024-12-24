import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/chat/chat_message_model.dart'
    as chatmessageModel;
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/datamodel/chat/send_message_model.dart' as sendModel;

import 'package:dating/pages/ring_screen.dart';
import 'package:dating/providers/chat_provider/socket_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void pickImage() async {
    try {
      // Request storage permission
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

        // Read the image as bytes (for web platforms)
        Uint8List imageBytes = await imageFile.readAsBytes();

        final chatProvider = context.read<SocketMessageProvider>();
        chatProvider.sendChatViaAPI(
          sendModel.SendMessageModel(
            files: [imageFile], // Send list of files for non-web platforms
            fileBytes: [imageBytes], // Send list of bytes for web platforms
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
                          sendModel.SendMessageModel(
                              senderId: user!.uid,
                              receiverId: widget.receiverId,
                              callDetails: sendModel.CallDetails(
                                  duration: "10", status: "Received"),
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
                    child: CustomTextField(
                      hintText: "Enter your text",
                      controller: _messageController,
                      keyboardType: TextInputType.text,
                      prefixIcon: Icons.text_fields,
                      obscureText: false, // Set to true for password fields
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

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final double borderRadius;
  final double minHeight;
  final double maxHeight;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    required this.controller,
    this.focusNode,
    this.borderRadius = 20.0,
    this.minHeight = 55.0,
    this.maxHeight = 150.0,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late KeyboardVisibilityController _keyboardVisibilityController;
  late StreamSubscription<bool> _keyboardSubscription;
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;

    _keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription =
        _keyboardVisibilityController.onChange.listen((visible) {
      setState(() {
        isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    _keyboardSubscription.cancel(); // Cancel the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.circular(widget.borderRadius),
            ),
            depth: -5,
            intensity: 1,
            surfaceIntensity: 0.5,
            lightSource: LightSource.topLeft,
          ),
          drawSurfaceAboveChild: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: widget.minHeight,
              maxHeight: widget.maxHeight,
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              keyboardType: widget.keyboardType,
              obscureText: _obscureText,
              decoration: InputDecoration(
                prefixIcon:
                    widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
                suffixIcon: widget.obscureText
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                      )
                    : widget.suffixIcon != null
                        ? IconButton(
                            onPressed: () {
                              // Custom suffix icon action
                            },
                            icon: Icon(widget.suffixIcon),
                          )
                        : null,
                hintText: widget.hintText,
                hintStyle: AppTextStyles().secondaryStyle,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
        if (isKeyboardVisible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Keyboard is visible",
              style: AppTextStyles().secondaryStyle,
            ),
          ),
      ],
    );
  }
}
