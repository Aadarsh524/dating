import 'dart:convert';

import 'dart:io';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/datamodel/chat/send_message_model.dart';
import 'package:dating/helpers/signaling.dart';
import 'package:dating/providers/chat_provider/chat_message_provider.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ChatScreemMobile extends StatefulWidget {
  final String chatID;
  final EndUserDetails chatRoomModel;

  ChatScreemMobile(
      {Key? key, required this.chatID, required this.chatRoomModel})
      : super(key: key);

  @override
  State<ChatScreemMobile> createState() => _ChatScreemMobileState();
}

class _ChatScreemMobileState extends State<ChatScreemMobile> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  User? user = FirebaseAuth.instance.currentUser;
  String recieverId = '';

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  @override
  void initState() {
    super.initState();
    final chatMessageProvider = context.read<ChatMessageProvider>();
    chatMessageProvider.getMessage(widget.chatID, user!.uid);
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

        // String base64Image = convertIntoBase64(imageFile);
        final chatProvider = context.read<ChatMessageProvider>();

        await chatProvider.sendChat(
          SendMessageModel(
            file: imageFile,
            senderId: user!.uid,
            receiverId: recieverId,
          ),
          widget.chatID,
          user!.uid,
        );
      } else {
        print('No image selected.');
      }
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      context.read<LoadingProvider>().setLoading(false);
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
                            widget.chatRoomModel.name!,
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
                      //Signaling().createRoom(remoteRenderer, roomIdd)

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
            Expanded(child: Consumer<ChatMessageProvider>(
              builder: (context, chatMessageProvider, child) {
                ChatMessageModel? chatRoomModel =
                    chatMessageProvider.userChatMessageModel;

                if (chatRoomModel == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: chatRoomModel.messages!.length,
                  itemBuilder: (context, index) {
                    var reversedMessages =
                        chatRoomModel.messages!.reversed.toList();
                    var message = reversedMessages[index];
                    bool isCurrentUser = message.senderId == user!.uid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                color:
                                    isCurrentUser ? Colors.blue : Colors.white,
                                depth: 2,
                                intensity: 0.8,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: _buildMessageContent(
                                    message, isCurrentUser),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            )),
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
                            receiverId: recieverId,
                          ),
                          widget.chatID,
                          user!.uid,
                        );
                        _messageController.clear();
                        _scrollToBottom();
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
}

Widget _buildMessageContent(Messages message, bool isCurrentUser) {
  switch (message.type) {
    case 'Text':
      return Text(
        message.messageContent!,
        style: AppTextStyles().secondaryStyle.copyWith(
              color: isCurrentUser ? Colors.white : Colors.black,
              fontSize: 14,
            ),
      );
    case 'Image':
      return _buildImageContent(message.fileName!, isCurrentUser);
    // case 'Audio':
    //   return AudioPlayerWidget(audioUrl: message.audioUrl!);
    // case 'Call':
    //   return CallInfoWidget(callInfo: message.callInfo!);
    default:
      return Container();
  }
}

Widget _buildImageContent(List<File> imageFiles, bool isCurrentUser) {
  return SizedBox(
    height: 50,
    width: 50,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imageFiles.length,
      itemBuilder: (context, index) {
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
            child: Image.file(
              imageFiles[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ),
  );
}
