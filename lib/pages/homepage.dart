import 'dart:convert';
import 'dart:typed_data';

import 'package:dating/backend/MongoDB/apis.dart';
import 'package:dating/backend/MongoDB/constants.dart';

import 'package:dating/datamodel/dashboard_response_model.dart' as d;
import 'package:dating/datamodel/interaction/user_interaction_model.dart';

import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/pages/chatpage.dart';
import 'package:dating/pages/myprofile.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/providers/dashboard_provider.dart';
import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:dating/widgets/user_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  ApiClient apiClient = ApiClient();

  @override
  void initState() {
    super.initState();

    context.read<DashboardProvider>().dashboard(1, context);
  }

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
                  child: const ProfileButton()),

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
                // ButtonWithLabel(
                //   text: null,
                //   labelText: 'Add Friend',
                //   onPressed: () {},
                //   icon: const Icon(Icons.add),
                // ),

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

        Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, _) {
            if (dashboardProvider.isDashboardLoading) {
              return const ShimmerSkeleton(count: 1, height: 250);
            } else {
              return Expanded(
                child: Consumer<DashboardProvider>(
                  builder: (context, snapshot, _) {
                    List<d.DashboardResponseModel>? data =
                        Provider.of<DashboardProvider>(context, listen: false)
                            .dashboardList;

                    return ListView.builder(
                      itemCount: data!.length,
                      itemBuilder: (context, index) {
                        final alluploads = data[index].uploads;
                        if (alluploads!.isNotEmpty) {
                          return UserPost(
                            post: data[index],
                            currentUserId: user!.uid,
                            onLike: (postId) {
                              final userInteraction =
                                  context.read<UserInteractionProvider>();
                              userInteraction.likeUser(
                                  user!.uid, "likedUserId");
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                ),
              );
            }
          },
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
                      child: const ProfileButton(),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Dating app",
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

                      //main dashboard section for desktop
                      Expanded(
                        child: Consumer<DashboardProvider>(
                            builder: (context, dashboardProvider, _) {
                          return dashboardProvider.isDashboardLoading
                              ? const ShimmerSkeleton(count: 1, height: 300)
                              : Consumer<DashboardProvider>(
                                  builder: (context, snapshot, _) {
                                  List<d.DashboardResponseModel>? data =
                                      Provider.of<DashboardProvider>(context,
                                              listen: false)
                                          .dashboardList;

                                  return ListView.builder(
                                      itemCount: data!.length,
                                      itemBuilder: (context, index) {
                                        final alluploads = data[index].uploads;
                                        if (alluploads!.isNotEmpty) {
                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // profile pic
                                                      GestureDetector(
                                                        onTap: () {},
                                                        child: Row(
                                                          children: [
                                                            Neumorphic(
                                                              style:
                                                                  NeumorphicStyle(
                                                                boxShape:
                                                                    NeumorphicBoxShape
                                                                        .roundRect(
                                                                  BorderRadius
                                                                      .circular(
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
                                                                ),
                                                                child: data[index]
                                                                            .image !=
                                                                        ''
                                                                    ? Image.memory(
                                                                        base64ToImage(data[index]
                                                                            .image!),
                                                                        fit: BoxFit
                                                                            .cover)
                                                                    : Image
                                                                        .memory(
                                                                        base64ToImage(
                                                                            defaultBase64Avatar),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                              ),
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
                                                                  data[index]
                                                                      .name!,
                                                                  style: AppTextStyles()
                                                                      .primaryStyle
                                                                      .copyWith(
                                                                          fontSize:
                                                                              14),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .circle,
                                                                      size: 8,
                                                                      color: AppColors
                                                                          .secondaryColor,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text(
                                                                      '${data[index].name}, ${data[index].age}',
                                                                      style: AppTextStyles().secondaryStyle.copyWith(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w300,
                                                                          color:
                                                                              AppColors.secondaryColor),
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
                                                                    fontSize:
                                                                        14,
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
                                              Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .backgroundColor,
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
                                                      SizedBox(
                                                        width: double.infinity,
                                                        height: 300,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      20),
                                                          child: Consumer<
                                                              DashboardProvider>(
                                                            builder: (context,
                                                                dashboard, _) {
                                                              final alluploads =
                                                                  data[index]
                                                                      .uploads;
                                                              if (alluploads !=
                                                                      null &&
                                                                  alluploads
                                                                      .isNotEmpty) {
                                                                List<d.Uploads>
                                                                    reversedUploads =
                                                                    alluploads
                                                                        .reversed
                                                                        .toList();

                                                                final upload =
                                                                    reversedUploads[
                                                                        0];

                                                                return Container(
                                                                  child: Image
                                                                      .memory(
                                                                    base64ToImage(
                                                                        upload
                                                                            .file!),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                );
                                                              } else {
                                                                return Container();
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      // like comment

                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
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
                                            ],
                                          );
                                        } else {
                                          return Container();
                                        }
                                      });
                                });
                        }),
                      )
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
  const ProfileButton({Key? key}) : super(key: key);

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, _) {
        if (userProfileProvider.isProfileLoading) {
          return CircularProgressIndicator();
        }

        UserProfileModel? userProfileModel =
            userProfileProvider.currentUserProfile;

        if (userProfileModel == null) {
          // Return a placeholder if userProfileModel is null
          return Neumorphic(
            style: const NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
            ),
            child: SizedBox(
              height: 50,
              width: 50,
              child: Image.memory(
                base64ToImage(defaultBase64Avatar),
                fit: BoxFit.cover,
              ), // Placeholder for when userProfileModel is null
            ),
          );
        }

        // Check if userProfileModel.image is null or empty
        Uint8List imageBytes =
            userProfileModel.image != null && userProfileModel.image!.isNotEmpty
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

extension UserInteractionModelExtension on UserInteractionModel {
  bool hasUserLikedPost(String userId, String postId) {
    return likedUsers?.any((likedUser) => likedUser.uid == userId) ?? false;
  }
}
