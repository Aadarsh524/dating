import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating/datamodel/chat/chat_room_model.dart' as chatRoom;
import 'package:dating/datamodel/chat/send_message_model.dart';

import 'package:dating/helpers/signaling.dart';
import 'package:dating/pages/chatMobileOnly/chatscreen.dart';
import 'package:dating/pages/chat_page_desktop.dart';
import 'package:dating/pages/components/profile_button.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';
import 'package:dating/providers/chat_provider/socket_provider.dart';

import 'package:dating/utils/colors.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../datamodel/chat/chat_message_model.dart' as chatmessageModel;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');
  User? user = FirebaseAuth.instance.currentUser;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final ScrollController _scrollController = ScrollController();

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';

  List<chatRoom.Message> lastMessage = [];
  final Signaling _signaling = Signaling();

  void _showPopupDialog(BuildContext context) {
    TextEditingController textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: textFieldController,
                decoration: const InputDecoration(hintText: "Enter something"),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Handle button press
                String enteredText = textFieldController.text;
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

  Future<void> addImage(
      List<Uint8List> fileBytes, List<String> fileName) async {
    final chatProvider = context.read<SocketMessageProvider>();
    final sendMessage = SendMessageModel(
      fileBytes: fileBytes,
      fileName: fileName,
      senderId: user!.uid,
      receiverId: reciever,
    );

    await chatProvider.sendChatViaAPI(
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
        addImage([imageBytes!], [fileName]);
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

//
  bool doesChatExists = false;

  chatRoom.EndUserDetails? chatRoomMode;
  chatRoom.Conversations? endUserId;
  String? chat;
  String? reciever;

  void getChat(
      chatRoom.EndUserDetails chatRoomModel, String chatId, String recieverId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        chatRoomMode = chatRoomModel;
        chat = chatId;
        reciever = recieverId;
        doesChatExists = true;
      });
    });

    final chatMessageProvider = context.read<SocketMessageProvider>();
    chatMessageProvider.getMessage(chat!, 1, user!.uid);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatRoomProvider = context.read<ChatRoomProvider>();
      chatRoomProvider.fetchChatRoom(context, user!.uid);
    });
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
                ProfileImage(),
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
                                                        ChatScreenMobile(
                                                          chatRoomModel:
                                                              endUserDetails,
                                                          chatID: conversation
                                                              .chatId!,
                                                          receiverId:
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
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (_) => ChatPageDesktop(
                                                                      chatID: conversation
                                                                          .chatId!,
                                                                      chatRoomModel:
                                                                          endUserDetails,
                                                                      receiverId:
                                                                          conversation
                                                                              .endUserId!)));
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

              //doesChatExists?
              // ? Expanded(
              //     flex: 2,
              //     child: Column(
              //       children: [
              //         Expanded(
              //           child: Padding(
              //             padding: const EdgeInsets.only(right: 20),
              //             child: Neumorphic(
              //               child: Column(
              //                 children: [
              //                   Padding(
              //                     padding: const EdgeInsets.symmetric(
              //                         horizontal: 20, vertical: 20),
              //                     child: Neumorphic(
              //                       child: Padding(
              //                         padding: const EdgeInsets.symmetric(
              //                             horizontal: 20, vertical: 10),
              //                         child: Row(
              //                           mainAxisAlignment:
              //                               MainAxisAlignment.spaceBetween,
              //                           children: [
              //                             // Profile pic with name
              //                             Row(
              //                               children: [
              //                                 Container(
              //                                   height: 50,
              //                                   width: 50,
              //                                   decoration: BoxDecoration(
              //                                     shape: BoxShape.circle,
              //                                     image: DecorationImage(
              //                                       image: MemoryImage(
              //                                           base64ToImage(
              //                                               chatRoomMode!
              //                                                   .profileImage)),
              //                                       fit: BoxFit.cover,
              //                                     ),
              //                                   ),
              //                                 ),
              //                                 const SizedBox(width: 8),
              //                                 Column(
              //                                   crossAxisAlignment:
              //                                       CrossAxisAlignment
              //                                           .start,
              //                                   children: [
              //                                     Text(
              //                                       chatRoomMode!.name!,
              //                                       style: AppTextStyles()
              //                                           .primaryStyle
              //                                           .copyWith(
              //                                               fontSize: 14),
              //                                     ),
              //                                   ],
              //                                 ),
              //                               ],
              //                             ),
              //                             // Video and audio call
              //                             Row(
              //                               children: [
              //                                 Icon(Icons.circle,
              //                                     color: Colors.green,
              //                                     size: 12),
              //                                 const SizedBox(width: 8),
              //                                 GestureDetector(
              //                                   onTap: () {
              //                                     Navigator.pushReplacement(
              //                                         context,
              //                                         MaterialPageRoute(
              //                                             builder: (context) => RingScreen(
              //                                                 roomId:
              //                                                     "null",
              //                                                 endUserDetails:
              //                                                     chatRoomMode,
              //                                                 clientID:
              //                                                     endUserId!
              //                                                         .endUserId!)));
              //                                   },
              //                                   child: const Icon(
              //                                       Icons.call_outlined),
              //                                 ),
              //                                 const SizedBox(width: 8),
              //                                 GestureDetector(
              //                                   onTap: () {
              //                                     _showPopupDialog(context);
              //                                   },
              //                                   child: const Icon(
              //                                       Icons.video_call),
              //                                 ),
              //                               ],
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                   Expanded(
              //                     flex: 2,
              //                     child: _buildChatContent(),
              //                   ),
              //                   const SizedBox(height: 10),
              //                   Padding(
              //                     padding: const EdgeInsets.only(
              //                         left: 10, right: 10),
              //                     child: Row(
              //                       crossAxisAlignment:
              //                           CrossAxisAlignment.center,
              //                       mainAxisAlignment:
              //                           MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         ButtonWithLabel(
              //                           text: null,
              //                           labelText: null,
              //                           onPressed: () {
              //                             pickImage(context);
              //                           },
              //                           icon: const Icon(Icons.add),
              //                         ),
              //                         Expanded(
              //                           child: AppTextField(
              //                             hintText: 'Type your message',
              //                             inputcontroller:
              //                                 _messageController,
              //                           ),
              //                         ),
              //                         ButtonWithLabel(
              //                           text: null,
              //                           labelText: null,
              //                           onPressed: () {},
              //                           icon: const Icon(Icons.mic),
              //                         ),
              //                         // Send button
              //                         ButtonWithLabel(
              //                           text: null,
              //                           labelText: null,
              //                           onPressed: () async {
              //                             if (_messageController
              //                                 .text.isNotEmpty) {
              //                               final chatProvider =
              //                                   context.read<
              //                                       SocketMessageProvider>();

              //                               await chatProvider
              //                                   .sendChatViaAPI(
              //                                 SendMessageModel(
              //                                   senderId: user!.uid,
              //                                   messageContent:
              //                                       _messageController.text,
              //                                   type: "Text",
              //                                   receiverId: reciever,
              //                                 ),
              //                                 chat!,
              //                                 user!.uid,
              //                               );
              //                               _messageController.clear();
              //                               _scrollToBottom();
              //                             }
              //                           },
              //                           icon: const Icon(Icons.send),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                   const SizedBox(height: 25),
              //                 ],
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   )
              //: Container()
            ],
          ),
        )
      ]),
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
