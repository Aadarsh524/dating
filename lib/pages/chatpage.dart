import 'dart:convert';
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/pages/chatMobileOnly/chatscreen.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';

import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:dating/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');
  User? user = FirebaseAuth.instance.currentUser;

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';
  final TextEditingController _message = TextEditingController();
  List<AllMessages> lastMessage = [];

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
  }

  @override
  void initState() {
    super.initState();

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
                const profileButton(),
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
                              ChatRoomModel? chatRoomModel =
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
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        ChatScreemMobile(
                                                          chatRoomModel:
                                                              endUserDetails,
                                                          chatID: conversation
                                                              .chatId!,
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
                                                      const Icon(
                                                        Icons.circle,
                                                        size: 8,
                                                        color: Colors.green,
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
                  const profileButton(),
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
                        // popular
                        ButtonWithLabel(
                          text: null,
                          labelText: 'Popular',
                          onPressed: () {},
                          icon: const Icon(Icons.star),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        // photos
                        ButtonWithLabel(
                          text: null,
                          labelText: 'Photos',
                          onPressed: () {},
                          icon: const Icon(Icons.photo_library_sharp),
                        ),

                        const SizedBox(
                          width: 15,
                        ),
                        // add friemd
                        ButtonWithLabel(
                          text: null,
                          labelText: 'Add Friend',
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                        ),

                        const SizedBox(
                          width: 15,
                        ),
                        // online
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

                    const SizedBox(
                      width: 100,
                    ),

                    // age seeking

                    Row(
                      children: [
                        // seeking

                        Neumorphic(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 2),
                          child: DropdownButton<String>(
                            underline: Container(),
                            style: AppTextStyles().secondaryStyle,
                            value: seeking,
                            icon: const Icon(
                                Icons.arrow_drop_down), // Dropdown icon
                            onChanged: (String? newValue) {
                              setState(() {
                                seeking = newValue!;
                              });
                            },
                            items: <String>[
                              'SEEKING',
                              'English',
                              'Spanish',
                              'French',
                              'German'
                            ] // Language options
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: AppTextStyles().secondaryStyle,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(
                          width: 50,
                        ),

                        // country

                        Neumorphic(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 2),
                          child: DropdownButton<String>(
                            underline: Container(),
                            style: AppTextStyles().secondaryStyle,
                            value: country,
                            icon: const Icon(
                                Icons.arrow_drop_down), // Dropdown icon
                            onChanged: (String? newValue) {
                              setState(() {
                                country = newValue!;
                              });
                            },
                            items: <String>[
                              'COUNTRY',
                              'English',
                              'Spanish',
                              'French',
                              'German'
                            ] // Language options
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: AppTextStyles().secondaryStyle,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(
                          width: 50,
                        ),

                        // age

                        Neumorphic(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 2),
                          child: DropdownButton<String>(
                            underline: Container(),
                            style: AppTextStyles().secondaryStyle,
                            value: age,
                            icon: const Icon(
                                Icons.arrow_drop_down), // Dropdown icon
                            onChanged: (String? newValue) {
                              setState(() {
                                age = newValue!;
                              });
                            },
                            items: <String>[
                              'AGE',
                              'English',
                              'Spanish',
                              'French',
                              'German'
                            ] // Language options
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: AppTextStyles().secondaryStyle,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
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
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // profile pic
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
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        AppImages
                                                                            .profile),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ))),
                                                    ),

                                                    // profile name and address
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Rehan Ritviz',
                                                          style: AppTextStyles()
                                                              .primaryStyle
                                                              .copyWith(
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'Hi how are you',
                                                          style: AppTextStyles()
                                                              .secondaryStyle
                                                              .copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: AppColors
                                                                      .secondaryColor),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),

                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'online',
                                                      style: AppTextStyles()
                                                          .secondaryStyle
                                                          .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color: AppColors
                                                                  .black),
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
                                  ),
                                ),

                                //  another chat

                                Neumorphic(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // profile pic
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
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        AppImages
                                                                            .profile),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ))),
                                                    ),

                                                    // profile name and address
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Rehan Ritviz',
                                                          style: AppTextStyles()
                                                              .primaryStyle
                                                              .copyWith(
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'Hi how are you',
                                                          style: AppTextStyles()
                                                              .secondaryStyle
                                                              .copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: AppColors
                                                                      .secondaryColor),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),

                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'online',
                                                      style: AppTextStyles()
                                                          .secondaryStyle
                                                          .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color: AppColors
                                                                  .black),
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
                                  ),
                                ),

                                // chat
                                Neumorphic(
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // profile pic
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
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image:
                                                                      DecorationImage(
                                                                    image: AssetImage(
                                                                        AppImages
                                                                            .profile),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ))),
                                                    ),

                                                    // profile name and address
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Rehan Ritviz',
                                                          style: AppTextStyles()
                                                              .primaryStyle
                                                              .copyWith(
                                                                  fontSize: 14),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          'Hi how are you',
                                                          style: AppTextStyles()
                                                              .secondaryStyle
                                                              .copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: AppColors
                                                                      .secondaryColor),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),

                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      'online',
                                                      style: AppTextStyles()
                                                          .secondaryStyle
                                                          .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color: AppColors
                                                                  .black),
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

              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Neumorphic(
                          child: ListView(
                            scrollDirection: Axis.vertical,
                            children: [
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: Neumorphic(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // profile pic with name
                                            Row(
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          AppImages.profile),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Rehan Ritviz',
                                                      style: AppTextStyles()
                                                          .primaryStyle
                                                          .copyWith(
                                                              fontSize: 14),
                                                    ),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 12,
                                                          color: AppColors
                                                              .secondaryColor,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          'Malang, Jawa Timur.....',
                                                          style: AppTextStyles()
                                                              .secondaryStyle
                                                              .copyWith(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                  color: AppColors
                                                                      .secondaryColor),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),

                                            // VIDEO AND AUDIO Cll

                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.circle,
                                                  color: Colors.green,
                                                  size: 12,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Icon(Icons.call_outlined),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Icon(Icons.video_call),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                //
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Neumorphic(
                                        child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Text(
                                        'Hello',
                                        style: AppTextStyles()
                                            .secondaryStyle
                                            .copyWith(color: Colors.black),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              // receievd

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Neumorphic(
                                        child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Text(
                                        'Hello, how are you',
                                        style: AppTextStyles()
                                            .secondaryStyle
                                            .copyWith(color: Colors.black),
                                      ),
                                    )),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 25,
                              ),
                              // receievd

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Neumorphic(
                                        child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Text(
                                        'Thank you and sure. I love rock\nmusic too! What’s your\nfavorite band?',
                                        style: AppTextStyles()
                                            .secondaryStyle
                                            .copyWith(color: Colors.black),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          )),
                          ButtonWithLabel(
                            text: null,
                            labelText: null,
                            onPressed: () {},
                            icon: const Icon(Icons.mic),
                          ),
// send

                          ButtonWithLabel(
                            text: null,
                            labelText: null,
                            onPressed: () {},
                            icon: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

// profile button
class profileButton extends StatelessWidget {
  const profileButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: const NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: Container(
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
