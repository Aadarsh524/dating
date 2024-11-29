import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/backend/MongoDB/token_manager.dart';
import 'package:dating/datamodel/chat/chat_room_model.dart' as chatRoom;
import 'package:dating/datamodel/chat/send_message_model.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/helpers/signaling.dart';
import 'package:dating/pages/chatMobileOnly/chatscreen.dart';
import 'package:dating/pages/ring_screen.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/providers/chat_provider/chat_message_provider.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';

import 'package:dating/utils/colors.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:dating/widgets/textField.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../datamodel/chat/chat_message_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');
  User? user = FirebaseAuth.instance.currentUser;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final ScrollController _scrollController = ScrollController();

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';
  final TextEditingController _message = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<chatRoom.Message> lastMessage = [];
  Signaling _signaling = Signaling();
  Uint8List? _imageBytes;

  void _showPopupDialog(BuildContext context) {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(hintText: "Enter something"),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Handle button press
                String enteredText = _textFieldController.text;
                _signaling.joinRoom(enteredText, _localRenderer);

                log("Entered text: $enteredText");
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addImage(List<int> fileBytes, List<String> fileName) async {
    final chatProvider = context.read<ChatMessageProvider>();
    final sendMessage = SendMessageModel(
      fileBytes: fileBytes,
      fileName: fileName,
      senderId: user!.uid,
      receiverId: reciever,
    );

    await chatProvider.sendChat(
      sendMessage,
      chat!,
      user!.uid,
    );
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
        final pickedFile = result!.files.single;
        final imageBytes = pickedFile.bytes;
        final fileName = pickedFile.name;
        addImage(imageBytes!, [fileName]);
      } else {
        print('No image selected.');
      }
    } catch (e, stacktrace) {
      log('Exception caught: ${e.toString()}');
      log('Stacktrace: $stacktrace');
      throw Exception(e.toString());
    }
  }

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
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

  bool doesChatExists = false;

  chatRoom.EndUserDetails? chatRoomMode;
  chatRoom.Conversations? endUserId;
  String? chat;
  String? reciever;

  void getChat(
      chatRoom.EndUserDetails chatRoomModel, String chatId, String recieverId) {
    setState(() {
      chatRoomMode = chatRoomModel;
      chat = chatId;
      reciever = recieverId;
      doesChatExists = true;
    });
    final chatMessageProvider = context.read<ChatMessageProvider>();
    chatMessageProvider.getMessage(chat!, 1, user!.uid);
  }

  @override
  void initState() {
    super.initState();

    // final token = TokenManager.getToken();
    // context.read<ChatMessageProvider>().initializeSocket(token as String);

    final chatRoomProvider = context.read<ChatRoomProvider>();
    chatRoomProvider.fetchChatRoom(context, user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return MobileHome();
            } else {
              return DesktopHome();
            }
          },
        ),
      ),
    );
  }

  Widget MobileHome() {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ProfileButton(),
                Row(
                  children: [
                    ButtonWithLabel(
                      text: null,
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                      labelText: null,
                    ),
                    ButtonWithLabel(
                      text: null,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                      labelText: null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ButtonWithLabel(
                    text: null,
                    labelText: 'Matches',
                    onPressed: () {},
                    icon: const Icon(Icons.people),
                  ),
                  const SizedBox(width: 15),
                  ButtonWithLabel(
                    text: null,
                    labelText: 'Add Friend',
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 15),
                  ButtonWithLabel(
                    text: null,
                    labelText: 'Online',
                    onPressed: () {},
                    icon: const Icon(
                      Icons.circle_outlined,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Neumorphic(
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                child: Consumer<ChatRoomProvider>(
                  builder: (context, chatRoomProvider, _) {
                    return chatRoomProvider.isChatRoomLoading
                        ? const ShimmerSkeleton(count: 2, height: 100)
                        : Consumer<ChatRoomProvider>(
                            builder: (context, chatRoomProvider, _) {
                              chatRoom.ChatRoomModel? chatRoomModel =
                                  Provider.of<ChatRoomProvider>(
                                context,
                                listen: false,
                              ).userChatRoomModel;

                              if (chatRoomModel == null) {
                                return const Center(
                                  child: Text("No chats"),
                                );
                              }

                              var conversations = chatRoomModel.conversations;

                              return ListView.builder(
                                  itemCount: conversations!.length,
                                  itemBuilder: (context, index) {
                                    var conversation = conversations[index];
                                    var endUserDetails =
                                        conversation.endUserDetails;
                                    if (endUserDetails?.message?.messages !=
                                            null &&
                                        endUserDetails!
                                            .message!.messages!.isNotEmpty) {
                                      // Reverse the messages list to get the latest message first

                                      var lastMessageContent = '';

                                      for (var message in endUserDetails
                                          .message!.messages!) {
                                        if (message.senderId != user!.uid &&
                                            message.type == "Text" &&
                                            message.messageContent != null) {
                                          lastMessageContent =
                                              message.messageContent!;
                                          break;
                                        }
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        ChatScreemMobile(
                                                          chatRoomModel:
                                                              endUserDetails,
                                                          chatID: conversation
                                                              .chatId!,
                                                          recieverId:
                                                              conversation
                                                                  .endUserId!,
                                                        )));
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Neumorphic(
                                                    style: NeumorphicStyle(
                                                      boxShape:
                                                          NeumorphicBoxShape
                                                              .roundRect(
                                                        BorderRadius.circular(
                                                            1000),
                                                      ),
                                                    ),
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: MemoryImage(
                                                              base64ToImage(
                                                                  endUserDetails
                                                                      .profileImage)),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        endUserDetails.name!,
                                                        style: AppTextStyles()
                                                            .primaryStyle
                                                            .copyWith(
                                                                fontSize: 14),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        lastMessageContent
                                                            .toString(),
                                                        style: AppTextStyles()
                                                            .secondaryStyle
                                                            .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color: AppColors
                                                                  .secondaryColor,
                                                            ),
                                                      )
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  Row(
                                                    children: [
                                                      conversation.seen!
                                                          ? const Icon(
                                                              Icons.circle,
                                                              size: 8,
                                                              color:
                                                                  Colors.green,
                                                            )
                                                          : const Icon(
                                                              Icons.circle,
                                                              size: 8,
                                                              color: AppColors
                                                                  .secondaryColor,
                                                            ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        conversation.seen!
                                                            ? 'online'
                                                            : 'offline',
                                                        style: AppTextStyles()
                                                            .secondaryStyle
                                                            .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color: AppColors
                                                                  .black,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  });
                            },
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: const NavBar(),
    );
  }

  Widget DesktopHome() {
    return Scaffold(
      body: Column(children: [
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
                  const ProfileButton(),
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

        //

        // post
        const SizedBox(
          height: 30,
        ),

        Expanded(
          child: Row(
            children: [
// side bar
              const NavBarDesktop(),

// posts
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  verticalDirection: VerticalDirection.down,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Chats',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              children: [
                                Neumorphic(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Consumer<ChatRoomProvider>(builder:
                                        (context, chatRoomProvider, _) {
                                      return chatRoomProvider.isChatRoomLoading
                                          ? const ShimmerSkeleton(
                                              count: 2, height: 100)
                                          : Consumer<ChatRoomProvider>(
                                              builder: (context, chatRoomP, _) {
                                              chatRoom.ChatRoomModel?
                                                  chatRoomModel =
                                                  Provider.of<ChatRoomProvider>(
                                                context,
                                                listen: false,
                                              ).userChatRoomModel;

                                              if (chatRoomModel == null) {
                                                return const Center(
                                                  child: Text("No chats"),
                                                );
                                              }

                                              var conversations =
                                                  chatRoomModel.conversations;
                                              return ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      conversations!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var conversation =
                                                        conversations[index];
                                                    endUserId =
                                                        conversations[index];
                                                    var endUserDetails =
                                                        conversation
                                                            .endUserDetails;
                                                    if (endUserDetails?.message
                                                                ?.messages !=
                                                            null &&
                                                        endUserDetails!
                                                            .message!
                                                            .messages!
                                                            .isNotEmpty) {
                                                      // Reverse the messages list to get the latest message first

                                                      var lastMessageContent =
                                                          '';

                                                      for (var message
                                                          in endUserDetails
                                                              .message!
                                                              .messages!) {
                                                        if (message.type ==
                                                                "Text" &&
                                                            message.messageContent !=
                                                                null) {
                                                          lastMessageContent =
                                                              message
                                                                  .messageContent!;
                                                          break;
                                                        }
                                                      }

                                                      return GestureDetector(
                                                        onTap: () {
                                                          getChat(
                                                              endUserDetails,
                                                              conversation
                                                                  .chatId!,
                                                              conversation
                                                                  .endUserId!);
                                                        },
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          20),
                                                              child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    // profile pic
                                                                    Row(
                                                                      children: [
                                                                        Neumorphic(
                                                                          style:
                                                                              NeumorphicStyle(
                                                                            boxShape:
                                                                                NeumorphicBoxShape.roundRect(
                                                                              BorderRadius.circular(1000),
                                                                            ),
                                                                          ),
                                                                          child: Container(
                                                                              height: 50,
                                                                              width: 50,
                                                                              decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  image: DecorationImage(
                                                                                    image: MemoryImage(base64ToImage(endUserDetails.profileImage)),
                                                                                    fit: BoxFit.cover,
                                                                                  ))),
                                                                        ),

                                                                        // profile name and address
                                                                        const SizedBox(
                                                                          width:
                                                                              20,
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              endUserDetails.name!,
                                                                              style: AppTextStyles().primaryStyle.copyWith(fontSize: 14),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Text(
                                                                              lastMessageContent,
                                                                              style: AppTextStyles().secondaryStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w300, color: AppColors.secondaryColor),
                                                                            )
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),

                                                                    Row(
                                                                      children: [
                                                                        conversation
                                                                                .seen!
                                                                            ? const Icon(
                                                                                Icons.circle,
                                                                                size: 8,
                                                                                color: Colors.green,
                                                                              )
                                                                            : const Icon(Icons.circle,
                                                                                size: 8,
                                                                                color: AppColors.secondaryColor),
                                                                        const SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          conversation.seen!
                                                                              ? 'online'
                                                                              : 'offline',
                                                                          style: AppTextStyles().secondaryStyle.copyWith(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w300,
                                                                              color: AppColors.black),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ]),
                                                            ),

                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            // image
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                    return null;
                                                  });
                                            });
                                    }),
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
              ),

              // chats
              const SizedBox(
                width: 40,
              ),

              doesChatExists
                  ? Expanded(
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
                                                            base64ToImage(
                                                                chatRoomMode!
                                                                    .profileImage)),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        chatRoomMode!.name!,
                                                        style: AppTextStyles()
                                                            .primaryStyle
                                                            .copyWith(
                                                                fontSize: 14),
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
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => RingScreen(
                                                                  roomId:
                                                                      "null",
                                                                  endUserDetails:
                                                                      chatRoomMode,
                                                                  clientID:
                                                                      endUserId!
                                                                          .endUserId!)));
                                                    },
                                                    child: const Icon(
                                                        Icons.call_outlined),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _showPopupDialog(context);
                                                    },
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
                                              inputcontroller:
                                                  _messageController,
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
                                            onPressed: () async {
                                              if (_messageController
                                                  .text.isNotEmpty) {
                                                final chatProvider =
                                                    context.read<
                                                        ChatMessageProvider>();

                                                await chatProvider.sendChat(
                                                  SendMessageModel(
                                                    senderId: user!.uid,
                                                    messageContent:
                                                        _messageController.text,
                                                    type: "Text",
                                                    receiverId: reciever,
                                                  ),
                                                  chat!,
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
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        )
      ]),
    );
  }

  Widget _buildChatContent() {
    final ScrollController _scrollController = ScrollController();
    User? user = FirebaseAuth.instance.currentUser;
    return Consumer<ChatMessageProvider>(
      builder: (context, chatMessageProvider, child) {
        ChatMessageModel? chatRoomModel =
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
              'http://localhost:8001/api/Communication/FileView/${imageName[index]}';
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
          );
        },
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  const ProfileButton({Key? key}) : super(key: key);

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, _) {
        if (userProfileProvider.isProfileLoading) {
          return const CircularProgressIndicator();
        }

        UserProfileModel? userProfileModel =
            userProfileProvider.currentUserProfile;

        Uint8List imageBytes = userProfileModel!.image != null &&
                userProfileModel.image!.isNotEmpty
            ? base64ToImage(userProfileModel.image!)
            : base64ToImage(defaultBase64Avatar);

        return Neumorphic(
          style: const NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
          ),
          child: SizedBox(
            height: 50,
            width: 50,
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
