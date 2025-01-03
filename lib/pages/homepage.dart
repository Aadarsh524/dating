import 'dart:convert';
import 'dart:typed_data';

import 'package:dating/datamodel/dashboard_response_model.dart' as d;
import 'package:dating/datamodel/dashboard_response_model.dart';
import 'package:dating/datamodel/interaction/user_interaction_model.dart';

import 'package:dating/helpers/notification_services.dart';

import 'package:dating/pages/chatpage.dart';
import 'package:dating/pages/components/profile_button.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');
  User? user = FirebaseAuth.instance.currentUser;
  bool isUserVerified = false;

  String seeking = 'SEEKING';

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  @override
  void initState() {
    super.initState();

    NotificationServices notificationServices = NotificationServices();
    _initializeNotifications(notificationServices);

    _loadDashboard();
  }

  void _loadDashboard() {
    final userprofileProvider =
        Provider.of<UserProfileProvider>(context, listen: false)
            .currentUserProfile;

    if (userprofileProvider != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final dashboardProvider = context.read<DashboardProvider>();
        if (userprofileProvider.gender.toString() == 'female') {
          dashboardProvider.dashboard(1, context, 'male');
        } else if (userprofileProvider.gender.toString() == 'male') {
          dashboardProvider.dashboard(1, context, 'female');
        }
      });
    }
  }

  Future<void> _initializeNotifications(
      NotificationServices notificationServices) async {
    // Check and request notification permission
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      notificationServices.requestNotificationPermission(context);
    }

    // Set up notifications
    await notificationServices.getDeviceToken();
    notificationServices.firebaseInit(context);
    notificationServices.setUpInteractMessage(context);
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
                  child: ProfileImage()),

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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SettingPage()));
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
          child: Consumer<DashboardProvider>(
            builder: (context, dashboardProvider, _) {
              if (dashboardProvider.isDashboardLoading) {
                return const ShimmerSkeleton(count: 1, height: 250);
              }

              List<DashboardResponseModel>? data =
                  dashboardProvider.dashboardList;

              if (data.isEmpty) {
                return const Center(child: Text("No data available"));
              }

              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final alluploads = data[index].uploads;
                  if (alluploads != null && alluploads.isNotEmpty) {
                    return UserPost(
                      post: data[index],
                      currentUserId: user!.uid,
                      onLike: (postId) {
                        final userInteraction =
                            context.read<UserInteractionProvider>();
                        userInteraction.likeUser(user!.uid, "likedUserId");
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          ),
        )
      ]),
      bottomSheet: const NavBar(),
    );
  }

  Widget DesktopHome() {
    final userprofileProvider =
        Provider.of<UserProfileProvider>(context, listen: false)
            .currentUserProfile;
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
                      child: ProfileImage(),
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
                                      builder: (context) => ChatPage()));
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
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyProfilePage()));
                            },
                            icon: const Icon(Icons.photo_library_sharp),
                          ),

                          const SizedBox(
                            width: 15,
                          ),
                          // add friemd
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

                                // Call the dashboard method with different parameters based on the selection
                                if (newValue == 'Male' ||
                                    newValue == 'Female') {
                                  context.read<DashboardProvider>().dashboard(
                                        1,
                                        context,
                                        newValue!, // Pass the selected value (male/female)
                                      );
                                } else {
                                  context.read<DashboardProvider>().dashboard(
                                        1,
                                        context,
                                        userprofileProvider!.gender
                                            .toString(), // Default to user's gender if 'SEEKING' is selected
                                      );
                                }
                              },
                              items: <String>[
                                'SEEKING',
                                'Male',
                                'Female',
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
                              ? const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                        width: 300,
                                        child: ShimmerSkeleton(
                                            count: 1, height: 350)),
                                    SizedBox(
                                        width: 300,
                                        child: ShimmerSkeleton(
                                            count: 1, height: 350)),
                                  ],
                                )
                              : Consumer<DashboardProvider>(
                                  builder: (context, snapshot, _) {
                                  List<d.DashboardResponseModel>? data =
                                      Provider.of<DashboardProvider>(context,
                                              listen: false)
                                          .dashboardList;

                                  return GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4, // Number of columns
                                        childAspectRatio: .8,

                                        crossAxisSpacing:
                                            10.0, // Spacing between columns
                                        mainAxisSpacing:
                                            10.0, // Spacing between rows
                                      ),
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        final alluploads = data[index].uploads;
                                        if (alluploads!.isNotEmpty) {
                                          return UserPost(
                                            post: data[index],
                                            currentUserId: user!.uid,
                                            onLike: (postId) {
                                              final userInteraction =
                                                  context.read<
                                                      UserInteractionProvider>();
                                              userInteraction.likeUser(
                                                  user!.uid, "likedUserId");
                                            },
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

extension UserInteractionModelExtension on UserInteractionModel {
  bool hasUserLikedPost(String userId, String postId) {
    return likedUsers?.any((likedUser) => likedUser.uid == userId) ?? false;
  }
}
