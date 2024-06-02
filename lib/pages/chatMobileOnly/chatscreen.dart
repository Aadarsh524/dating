import 'dart:convert';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/chat/chat_message_model.dart';
import 'package:dating/providers/chat_provider/chat_message_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ChatScreemMobile extends StatefulWidget {
  String chatID;
  ChatScreemMobile({super.key, required this.chatID});

  @override
  State<ChatScreemMobile> createState() => _ChatScreemMobileState();
}

class _ChatScreemMobileState extends State<ChatScreemMobile> {
  final TextEditingController _message = TextEditingController();
  User? users = FirebaseAuth.instance.currentUser;

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  @override
  void initState() {
    super.initState();
    final chatRoomProvider = context.read<ChatMessageProvider>();
    chatRoomProvider.getMessage(widget.chatID);
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
                            image:
                                MemoryImage(base64ToImage(defaultBase64Avatar)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "",
                            style: AppTextStyles()
                                .primaryStyle
                                .copyWith(fontSize: 14),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.secondaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "",
                                style: AppTextStyles().secondaryStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.secondaryColor,
                                    ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                  ButtonWithLabel(
                    text: null,
                    onPressed: () {},
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
              child: Consumer<ChatMessageProvider>(
                builder: (context, chatMessageProvider, child) {
                  ChatMessageModel? chatRoomModel =
                      chatMessageProvider.userChatMessageModel;

                  if (chatRoomModel == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: chatRoomModel.messages!.length,
                    itemBuilder: (context, index) {
                      var message = chatRoomModel.messages![index];
                      bool isCurrentUser = message.senderId == users!.uid;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Neumorphic(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Text(
                                  message.messageContent!,
                                  style: AppTextStyles()
                                      .secondaryStyle
                                      .copyWith(
                                          color: Colors.black, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ButtonWithLabel(
                    text: null,
                    labelText: null,
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                  ),
                  Expanded(
                    child: AppTextField(
                      hintText: 'Type your message',
                      inputcontroller: _message,
                    ),
                  ),
                  ButtonWithLabel(
                    text: null,
                    labelText: null,
                    onPressed: () {},
                    icon: const Icon(Icons.mic),
                  ),
                  ButtonWithLabel(
                    text: null,
                    labelText: null,
                    onPressed: () {
                      if (_message.text.isNotEmpty) {
                        // Provider.of<ChatMessageProvider>(context, listen: false)
                        // .sendChat(
                        //   ChatMessageModel(
                        //     senderId: users!.uid,
                        //     receiverId: widget.chatID, // Adjust as necessary
                        //     messageContent: _message.text,
                        //     type: "Text",
                        //   ),
                        // );
                        // _message.clear();
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

// profile button
class profileButton extends StatelessWidget {
  const profileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: const NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: SizedBox(
        height: 50,
        width: 50,
        child: Image.asset(
          AppImages.loginimage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
