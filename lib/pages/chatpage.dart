import 'package:dating/pages/chatMobileOnly/chatscreen.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:dating/widgets/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';
  TextEditingController _message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // For smaller screen sizes (e.g., mobile)
              return MobileHome();
            } else {
              // For larger screen sizes (e.g., tablet or desktop)
              return DesktopHome();
            }
          },
        ),
      ),
    );
  }

  Widget MobileHome() {
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // profile
              profileButton(),

              // search icon
              Row(
                children: [
                  ButtonWithLabel(
                    text: null,
                    onPressed: () {},
                    icon: Icon(
                      Icons.search,
                    ),
                    labelText: null,
                  ),

                  // settings icon

                  ButtonWithLabel(
                    text: null,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingPage()));
                    },
                    icon: Icon(
                      Icons.settings,
                    ),
                    labelText: null,
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(
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
                offset: Offset(0, 25), // horizontal and vertical offset
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              // physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                // matches
                ButtonWithLabel(
                  text: null,
                  labelText: 'Matches',
                  onPressed: () {},
                  icon: Icon(Icons.people),
                ),
                SizedBox(
                  width: 15,
                ),

                ButtonWithLabel(
                  text: null,
                  labelText: 'Add Friend',
                  onPressed: () {},
                  icon: Icon(Icons.add),
                ),

                SizedBox(
                  width: 15,
                ),
                // online
                ButtonWithLabel(
                  text: null,
                  labelText: 'Online',
                  onPressed: () {},
                  icon: Icon(
                    Icons.circle_outlined,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),

        //

        // post
        SizedBox(
          height: 30,
        ),

        Expanded(
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreemMobile()));
                },
                child: Neumorphic(
                  child: Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // profile pic
                                Row(
                                  children: [
                                    Neumorphic(
                                      style: NeumorphicStyle(
                                        boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(1000),
                                        ),
                                      ),
                                      child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    AppImages.profile),
                                                fit: BoxFit.cover,
                                              ))),
                                    ),

                                    // profile name and address
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Rehan Ritviz',
                                          style: AppTextStyles()
                                              .primaryStyle
                                              .copyWith(fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          'Hi how are you',
                                          style: AppTextStyles()
                                              .secondaryStyle
                                              .copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                  color:
                                                      AppColors.secondaryColor),
                                        )
                                      ],
                                    )
                                  ],
                                ),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.green,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'online',
                                      style: AppTextStyles()
                                          .secondaryStyle
                                          .copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: AppColors.black),
                                    ),
                                  ],
                                )
                              ]),
                        ),

                        SizedBox(
                          height: 20,
                        ),
                        // image
                      ],
                    ),
                  ),
                ),
              ),

              //  another chat

              Neumorphic(
                child: Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // profile pic
                              Row(
                                children: [
                                  Neumorphic(
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(1000),
                                      ),
                                    ),
                                    child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image:
                                                  AssetImage(AppImages.profile),
                                              fit: BoxFit.cover,
                                            ))),
                                  ),

                                  // profile name and address
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rehan Ritviz',
                                        style: AppTextStyles()
                                            .primaryStyle
                                            .copyWith(fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Hi how are you',
                                        style: AppTextStyles()
                                            .secondaryStyle
                                            .copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    AppColors.secondaryColor),
                                      )
                                    ],
                                  )
                                ],
                              ),

                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'online',
                                    style: AppTextStyles()
                                        .secondaryStyle
                                        .copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.black),
                                  ),
                                ],
                              )
                            ]),
                      ),

                      SizedBox(
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
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // profile pic
                              Row(
                                children: [
                                  Neumorphic(
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(1000),
                                      ),
                                    ),
                                    child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image:
                                                  AssetImage(AppImages.profile),
                                              fit: BoxFit.cover,
                                            ))),
                                  ),

                                  // profile name and address
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rehan Ritviz',
                                        style: AppTextStyles()
                                            .primaryStyle
                                            .copyWith(fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Hi how are you',
                                        style: AppTextStyles()
                                            .secondaryStyle
                                            .copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                                color:
                                                    AppColors.secondaryColor),
                                      )
                                    ],
                                  )
                                ],
                              ),

                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'online',
                                    style: AppTextStyles()
                                        .secondaryStyle
                                        .copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.black),
                                  ),
                                ],
                              )
                            ]),
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      // image
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 50,
              ),
            ],
          ),
        )
      ]),
      bottomSheet: NavBar(),
    );
  }

  Widget DesktopHome() {
    return Scaffold(
      body: Column(children: [
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // profile
              Row(
                children: [
                  profileButton(),
                  SizedBox(
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
                    icon: Icon(
                      Icons.search,
                    ),
                    labelText: null,
                  ),

                  // settings icon

                  ButtonWithLabel(
                    text: null,
                    onPressed: () {},
                    icon: Icon(
                      Icons.settings,
                    ),
                    labelText: null,
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(
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
                offset: Offset(0, 25), // horizontal and vertical offset
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
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
                          icon: Icon(Icons.people),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        // messages
                        ButtonWithLabel(
                          text: null,
                          labelText: 'Messages',
                          onPressed: () {},
                          icon: Icon(Icons.messenger_outline),
                        ),

                        SizedBox(
                          width: 15,
                        ),
                        // popular
                        ButtonWithLabel(
                          text: null,
                          labelText: 'Popular',
                          onPressed: () {},
                          icon: Icon(Icons.star),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        // photos
                        ButtonWithLabel(
                          text: null,
                          labelText: 'Photos',
                          onPressed: () {},
                          icon: Icon(Icons.photo_library_sharp),
                        ),

                        SizedBox(
                          width: 15,
                        ),
                        // add friemd
                        ButtonWithLabel(
                          text: null,
                          labelText: 'Add Friend',
                          onPressed: () {},
                          icon: Icon(Icons.add),
                        ),

                        SizedBox(
                          width: 15,
                        ),
                        // online
                        ButtonWithLabel(
                          text: null,
                          labelText: 'Online',
                          onPressed: () {},
                          icon: Icon(
                            Icons.circle_outlined,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      width: 100,
                    ),

                    // age seeking

                    Row(
                      children: [
                        // seeking

                        Neumorphic(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          child: DropdownButton<String>(
                            underline: Container(),
                            style: AppTextStyles().secondaryStyle,
                            value: seeking,
                            icon: Icon(Icons.arrow_drop_down), // Dropdown icon
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
                        SizedBox(
                          width: 50,
                        ),

                        // country

                        Neumorphic(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          child: DropdownButton<String>(
                            underline: Container(),
                            style: AppTextStyles().secondaryStyle,
                            value: country,
                            icon: Icon(Icons.arrow_drop_down), // Dropdown icon
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
                        SizedBox(
                          width: 50,
                        ),

                        // age

                        Neumorphic(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                          child: DropdownButton<String>(
                            underline: Container(),
                            style: AppTextStyles().secondaryStyle,
                            value: age,
                            icon: Icon(Icons.arrow_drop_down), // Dropdown icon
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
        SizedBox(
          height: 30,
        ),

        Expanded(
          child: Row(
            children: [
// side bar
              NavBarDesktop(),

// posts
              SizedBox(
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
                    SizedBox(
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
                                    padding: EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
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
                                                              BoxDecoration(
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
                                                    SizedBox(
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
                                                        SizedBox(
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
                                                    Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(
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

                                        SizedBox(
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
                                    padding: EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
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
                                                              BoxDecoration(
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
                                                    SizedBox(
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
                                                        SizedBox(
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
                                                    Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(
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

                                        SizedBox(
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
                                    padding: EdgeInsets.only(top: 20),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
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
                                                              BoxDecoration(
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
                                                    SizedBox(
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
                                                        SizedBox(
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
                                                    Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: Colors.green,
                                                    ),
                                                    SizedBox(
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

                                        SizedBox(
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
              SizedBox(
                width: 40,
              ),

              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Neumorphic(
                          child: ListView(
                            scrollDirection: Axis.vertical,
                            children: [
                              Container(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: Neumorphic(
                                    child: Container(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
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
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          AppImages.profile),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
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
                                                        Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 12,
                                                          color: AppColors
                                                              .secondaryColor,
                                                        ),
                                                        SizedBox(
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

                                            Row(
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
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Neumorphic(
                                        child: Padding(
                                      padding: EdgeInsets.symmetric(
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
                              SizedBox(
                                height: 25,
                              ),
                              // receievd

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Neumorphic(
                                        child: Padding(
                                      padding: EdgeInsets.symmetric(
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

                              SizedBox(
                                height: 25,
                              ),
                              // receievd

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Neumorphic(
                                        child: Padding(
                                      padding: EdgeInsets.symmetric(
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
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ButtonWithLabel(
                            text: null,
                            labelText: null,
                            onPressed: () {},
                            icon: Icon(Icons.add),
                          ),
                          Expanded(
                              child:
                                  AppTextField(hintText: 'Type your message',inputcontroller: _message,)),
                          ButtonWithLabel(
                            text: null,
                            labelText: null,
                            onPressed: () {},
                            icon: Icon(Icons.mic),
                          ),
// send

                          ButtonWithLabel(
                            text: null,
                            labelText: null,
                            onPressed: () {},
                            icon: Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
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
      style: NeumorphicStyle(
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
