import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dating/auth/db_client.dart';
import 'package:dating/auth/loginScreen.dart';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/backend/firebase_auth/firebase_auth.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/pages/chatpage.dart';
import 'package:dating/pages/myprofile.dart';
import 'package:dating/pages/profilepage.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');
  User? user = FirebaseAuth.instance.currentUser;

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';
  final AuthService _authService = AuthService();
  // late UserProfileModel userProfileModel;

  Future<UserProfileModel> fetchData() async {
    String uid = user!.uid;
    print(uid);
    final url = Uri.parse('$URI/UserProfile/$uid');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var decoded = jsonDecode(response.body);
      log(decoded.toString());
      UserProfileModel userProfileModel = UserProfileModel.fromJson(decoded);
      return userProfileModel;
    } else {
      log('Failed to fetch data: ${response.statusCode}');
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   fetchData();
  // }

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
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
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // profile
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const MyProfilePage()));
                  },
                  child: ProfileButton()),

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
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingPage()));
                    },
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
            padding: const EdgeInsets.only(left: 20),
            child: ListView(
              // physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                // matches
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
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatPage()));
                  },
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
          ),
        ),

        //

        // post
        const SizedBox(
          height: 30,
        ),

        Expanded(
          child: ListView(
            children: [
              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // profile pic
                            GestureDetector(
                              onTap: () {
                                _authService.signOut().then((value) =>
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen())
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => ProfilePage()));
                                        ));
                              },
                              child: Row(
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
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image:
                                                  AssetImage(AppImages.profile),
                                              fit: BoxFit.cover,
                                            ))),
                                  ),

                                  // profile name and address
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Name",
                                        style: AppTextStyles()
                                            .primaryStyle
                                            .copyWith(fontSize: 14),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: AppColors.secondaryColor,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Rehan Ritviz, 25',
                                            style: AppTextStyles()
                                                .secondaryStyle
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w300,
                                                    color: AppColors
                                                        .secondaryColor),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
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
                    Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              // spreadRadius: 5,
                              blurRadius: 20,
                              offset: const Offset(
                                  0, 25), // horizontal and vertical offset
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(AppImages.loginimage),
                            // like comment

                            const SizedBox(
                              height: 10,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up_off_alt,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.mode_comment_outlined,
                                          size: 30,
                                        ),

                                        // share icon
                                      ],
                                    ),
                                    Icon(Icons.ios_share_outlined),
                                  ]),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        )),
                  ],
                ),
              ),

              //  another post

              const SizedBox(
                height: 50,
              ),

              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // profile pic
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfilePage()));
                              },
                              child: Row(
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
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image:
                                                  AssetImage(AppImages.profile),
                                              fit: BoxFit.cover,
                                            ))),
                                  ),

                                  // profile name and address
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Rehan Ritviz",
                                        style: AppTextStyles()
                                            .primaryStyle
                                            .copyWith(fontSize: 14),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: AppColors.secondaryColor,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Rehan Ritviz, 25',
                                            style: AppTextStyles()
                                                .secondaryStyle
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w300,
                                                    color: AppColors
                                                        .secondaryColor),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
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
                    Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              // spreadRadius: 5,
                              blurRadius: 20,
                              offset: const Offset(
                                  0, 25), // horizontal and vertical offset
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(AppImages.loginimage),
                            // like comment

                            const SizedBox(
                              height: 10,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up_off_alt,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.mode_comment_outlined,
                                          size: 30,
                                        ),

                                        // share icon
                                      ],
                                    ),
                                    Icon(Icons.ios_share_outlined),
                                  ]),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        )),

                    //  another post
                  ],
                ),
              ),

              //  another post

              const SizedBox(
                height: 50,
              ),

              Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // profile pic
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfilePage()));
                              },
                              child: Row(
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
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image:
                                                  AssetImage(AppImages.profile),
                                              fit: BoxFit.cover,
                                            ))),
                                  ),

                                  // profile name and address
                                  const SizedBox(
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
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: AppColors.secondaryColor,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Rehan Ritviz, 25',
                                            style: AppTextStyles()
                                                .secondaryStyle
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w300,
                                                    color: AppColors
                                                        .secondaryColor),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
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
                    Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              // spreadRadius: 5,
                              blurRadius: 20,
                              offset: const Offset(
                                  0, 25), // horizontal and vertical offset
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(AppImages.loginimage),
                            // like comment

                            const SizedBox(
                              height: 10,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up_off_alt,
                                          size: 30,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.mode_comment_outlined,
                                          size: 30,
                                        ),

                                        // share icon
                                      ],
                                    ),
                                    Icon(Icons.ios_share_outlined),
                                  ]),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        )),

                    //  another post
                  ],
                ),
              )
            ],
          ),
        )
      ]),
      bottomSheet: const NavBar(),
    );
  }

  Widget DesktopHome() {
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
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyProfilePage()));
                        },
                        child: ProfileButton()),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Name",
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
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const SettingPage()));
                      },
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
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => const ChatPage()));
                            },
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
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
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
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
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
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
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
                    // verticalDirection: VerticalDirection.down,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Home',
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
                        child: GridView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Allow vertical scrolling
                          itemCount: 20, // Total number of children
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 20,
                            crossAxisCount: 3, // 3 items per row
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            // Your item widget
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: 30, bottom: 80, top: 40),
                              child: GridTile(
                                child: SizedBox(
                                  height: 380,
                                  width: 380,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // profile pic
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      CupertinoPageRoute(
                                                          builder: (context) =>
                                                              const ProfilePage()));
                                                },
                                                child: Row(
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
                                                          'Reehan Ritviz',
                                                          style: AppTextStyles()
                                                              .primaryStyle
                                                              .copyWith(
                                                                  fontSize: 14),
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.circle,
                                                              size: 8,
                                                              color: AppColors
                                                                  .secondaryColor,
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Text(
                                                              'Rehan Ritviz, 25',
                                                              style: AppTextStyles()
                                                                  .secondaryStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
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
                                                                FontWeight.w300,
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
                                      Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.backgroundColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.25),
                                                // spreadRadius: 5,
                                                blurRadius: 20,
                                                offset: const Offset(0,
                                                    25), // horizontal and vertical offset
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                AppImages.loginimage,
                                                fit: BoxFit.contain,
                                              ),
                                              // like comment

                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .thumb_up_off_alt,
                                                            size: 30,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .mode_comment_outlined,
                                                            size: 30,
                                                          ),

                                                          // share icon
                                                        ],
                                                      ),
                                                      Icon(Icons
                                                          .ios_share_outlined),
                                                    ]),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )),

                                      //  another post

                                      //  another post
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
}

// profile button
// ignore: must_be_immutable
class ProfileButton extends StatelessWidget {
  UserProfileModel? userProfileModel;
  Uint8List? _imageBytes;

  ProfileButton({
    super.key,
  });

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    userProfileModel = userProfileProvider.currentUserProfile;

    if (userProfileModel?.image != null) {
      _imageBytes = base64ToImage(userProfileModel!.image?? '');
    } else {
      _imageBytes = base64ToImage(defaultBase64Avatar);
    }

    return Neumorphic(
      style: const NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: SizedBox(
          height: 50,
          width: 50,
          child: Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          )),
    );
  }
}
