import 'dart:convert';
import 'dart:typed_data';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/interaction/user_interaction_model.dart';
import 'package:dating/datamodel/interaction/user_match_model.dart';
import 'package:dating/pages/components/profile_button.dart';
import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0; // Default to 'Liked Me' tab
  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  @override
  void initState() {
    super.initState();
    Provider.of<UserInteractionProvider>(context, listen: false)
        .getUserInteraction(user!.uid);
    Provider.of<UserInteractionProvider>(context, listen: false)
        .getUserMatches(user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // For smaller screen sizes (e.g., mobile)
              return MobileLikePage();
            } else {
              // For larger screen sizes (e.g., tablet or desktop)
              return DesktopLikePage();
            }
          },
        ),
      ),
    );
  }

  Widget MobileLikePage() {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                // Title
                const Text(
                  'Likes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Menu button (dots)
                IconButton(
                  onPressed: () {
                    // Handle menu button press
                  },
                  icon: SvgPicture.asset('assets/icons/threedots.svg'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Tab bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Liked Me tab
                TabButton(
                  text: 'Liked Me',
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // My Likes tab
                TabButton(
                  text: 'My Likes',
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // Mutual Likes tab
                TabButton(
                  text: 'Mutual Likes',
                  isSelected: _selectedIndex == 2,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<UserInteractionProvider>(
              builder: (context, provider, _) {
                bool isLoading = provider.isInteractionLoading;
                List<UserMatchesModel>? userMatchModel =
                    provider.getUserMatchModel;

                if (isLoading) {
                  return const ShimmerSkeleton(count: 1, height: 250);
                } else {
                  switch (_selectedIndex) {
                    case 0:
                      return likedMeList(provider);
                    case 1:
                      return myLikesList(provider);
                    case 2:
                      return userMatchModel != null
                          ? mutualLikesList(userMatchModel)
                          : const Center(child: Text('No data available'));
                    default:
                      return Container();
                  }
                }
              },
            ),
          ),
        ],
      ),
      bottomSheet: const NavBar(),
    );
  }

  Widget likedMeList(UserInteractionProvider provider) {
    List<LikedByUsers>? allUsers = provider.userInteractionModel?.likedByUsers;

    if (allUsers == null || allUsers.isEmpty) {
      return const Center(child: Text('You have not liked anyone yet.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate item dimensions
          double gridItemWidth =
              (constraints.maxWidth - 30) / 2; // Adjust spacing
          double gridItemHeight = gridItemWidth * 1.4; // Maintain aspect ratio

          return GridView.builder(
            clipBehavior: Clip.none,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth < 600
                  ? 2
                  : 3, // Adjust for larger screens
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              LikedByUsers user = allUsers[index];

              return Container(
                width: gridItemWidth,
                height: gridItemHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: user.userDetail!.image!.isNotEmpty
                        ? MemoryImage(base64ToImage(user.userDetail!.image!))
                        : MemoryImage(base64ToImage(defaultBase64Avatar)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0), // Transparent at top
                            Colors.black.withOpacity(0.6), // Darker at bottom
                          ],
                        ),
                      ),
                    ),
                    // Like and Chat Icons
                    Positioned(
                      top: 10,
                      right: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Add like functionality
                            },
                            child: SvgPicture.asset(
                              'assets/icons/heartfilled.svg',
                              color: Colors.white,
                              height: 20,
                              width: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // User Info
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name and Age with Gender Icon
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${user.userDetail!.name!}, ${user.userDetail!.age!}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Address
                          Text(
                            user.userDetail!.address!,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Liked Date
                          Text(
                            'Sent: ${user.likedDate}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget myLikesList(UserInteractionProvider provider) {
    List<LikedUsers>? allUsers = provider.userInteractionModel?.likedUsers;

    if (allUsers == null || allUsers.isEmpty) {
      return const Center(child: Text('You have not liked anyone yet.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate item dimensions
          double gridItemWidth =
              (constraints.maxWidth - 30) / 2; // Adjust spacing
          double gridItemHeight = gridItemWidth * 1.4; // Maintain aspect ratio

          return GridView.builder(
            clipBehavior: Clip.none,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth < 600
                  ? 2
                  : 3, // Adjust for larger screens
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              LikedUsers user = allUsers[index];

              return Container(
                width: gridItemWidth,
                height: gridItemHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: user.userDetail!.image!.isNotEmpty
                        ? MemoryImage(base64ToImage(user.userDetail!.image!))
                        : MemoryImage(base64ToImage(defaultBase64Avatar)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0), // Transparent at top
                            Colors.black.withOpacity(0.6), // Darker at bottom
                          ],
                        ),
                      ),
                    ),
                    // Like and Chat Icons
                    Positioned(
                      top: 10,
                      right: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Add like functionality
                            },
                            child: SvgPicture.asset(
                              'assets/icons/heartfilled.svg',
                              color: Colors.white,
                              height: 20,
                              width: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    // User Info
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name and Age with Gender Icon
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${user.userDetail!.name!}, ${user.userDetail!.age!}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Address
                          Text(
                            user.userDetail!.address!,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Liked Date
                          Text(
                            'Sent: ${user.likedDate}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Widget for displaying users who have mutual likes with the current user
  Widget mutualLikesList(List<UserMatchesModel> userMatchesModel) {
    if (userMatchesModel.isEmpty) {
      return const Center(child: Text('You have not liked anyone yet.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate grid item size
          double gridItemWidth = (constraints.maxWidth - 30) / 2;
          double gridItemHeight = gridItemWidth * 1.5;

          return GridView.builder(
            clipBehavior: Clip.none,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: constraints.maxWidth < 600
                  ? 2
                  : 3, // Adjust grid for responsiveness
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: userMatchesModel.length,
            itemBuilder: (context, index) {
              UserMatchesModel user = userMatchesModel[index];

              return Container(
                height: gridItemHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: user.userDetail!.image!.isNotEmpty
                        ? MemoryImage(base64ToImage(user.userDetail!.image!))
                        : MemoryImage(base64ToImage(defaultBase64Avatar)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                    ),
                    // Icons (like and chat)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Add like functionality
                            },
                            child: SvgPicture.asset(
                              'assets/icons/heartoutline.svg',
                              color: Colors.white,
                              height: 20,
                              width: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              // Add chat functionality
                            },
                            child: SvgPicture.asset(
                              'assets/icons/chatoutline.svg',
                              color: Colors.white,
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // User info
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${user.userDetail!.name!}, ${user.userDetail!.age!}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            user.userDetail!.address!,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Sent: ${user.likedDate}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget mutualLikesListDesktop(List<UserMatchesModel> userMatchesModel) {
    if (userMatchesModel.isEmpty) {
      return const Center(child: Text('No users have liked you yet.'));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 900,
        child: GridView.builder(
          clipBehavior: Clip.none,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Number of columns in the grid
            crossAxisSpacing: 15, // Horizontal spacing between items
            mainAxisSpacing: 15, // Vertical spacing between items
          ),
          itemCount:
              userMatchesModel.length, // Total number of containers in the grid
          itemBuilder: (context, index) {
            UserMatchesModel user = userMatchesModel[index];
            return Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: MemoryImage(base64ToImage(user.userDetail!.image!)),
                  fit: BoxFit
                      .cover, // Adjust how the image should fit inside the container
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withOpacity(0), // Transparent black at the top
                      Colors.black
                          .withOpacity(0.75), // Solid black at the bottom
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // like and chat
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgPicture.asset(AppIcons.heartoutline),
                          const SizedBox(
                            width: 8,
                          ),
                          SvgPicture.asset(AppIcons.chatoutline),
                        ],
                      ),
                    ),

// name address
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // name
                          Row(
                            children: [
                              Text(
                                '${user.userDetail!.name!}, ${user.userDetail!.age!}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),

                              // male female
                              const Icon(
                                Icons.male,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          // address

                          Text(
                            '${user.userDetail!.address}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),

                          Text(
                            'Sent: ${user.likedDate} ',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget myLikesListDesktop(UserInteractionProvider provider) {
    List<LikedUsers>? myLikesUsers = provider.userInteractionModel?.likedUsers;
    if (myLikesUsers == null || myLikesUsers.isEmpty) {
      return const Center(child: Text('No users have liked you yet.'));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 900,
        child: GridView.builder(
          clipBehavior: Clip.none,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Number of columns in the grid
            crossAxisSpacing: 15, // Horizontal spacing between items
            mainAxisSpacing: 15, // Vertical spacing between items
          ),
          itemCount:
              myLikesUsers.length, // Total number of containers in the grid
          itemBuilder: (context, index) {
            LikedUsers user = myLikesUsers[index];
            return Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: MemoryImage(base64ToImage(user.userDetail!.image!)),
                  fit: BoxFit
                      .cover, // Adjust how the image should fit inside the container
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withOpacity(0), // Transparent black at the top
                      Colors.black
                          .withOpacity(0.75), // Solid black at the bottom
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // like and chat
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgPicture.asset(AppIcons.heartoutline),
                          const SizedBox(
                            width: 8,
                          ),
                          SvgPicture.asset(AppIcons.chatoutline),
                        ],
                      ),
                    ),

// name address
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // name
                          Row(
                            children: [
                              Text(
                                '${user.userDetail!.name!}, ${user.userDetail!.age!}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),

                              // male female
                              const Icon(
                                Icons.male,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          // address

                          Text(
                            '${user.userDetail!.address}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),

                          Text(
                            'Sent: ${user.likedDate}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget likedMeListDesktop(UserInteractionProvider provider) {
    List<LikedByUsers>? likedMeUsers =
        provider.userInteractionModel?.likedByUsers;
    if (likedMeUsers == null || likedMeUsers.isEmpty) {
      return const Center(child: Text('No users have liked you yet.'));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 900,
        child: GridView.builder(
          clipBehavior: Clip.none,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Number of columns in the grid
            crossAxisSpacing: 15, // Horizontal spacing between items
            mainAxisSpacing: 15, // Vertical spacing between items
          ),
          itemCount:
              likedMeUsers.length, // Total number of containers in the grid
          itemBuilder: (context, index) {
            LikedByUsers user = likedMeUsers[index];
            return Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: MemoryImage(base64ToImage(user.userDetail!.image!)),
                  fit: BoxFit
                      .cover, // Adjust how the image should fit inside the container
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withOpacity(0), // Transparent black at the top
                      Colors.black
                          .withOpacity(0.75), // Solid black at the bottom
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // like and chat
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgPicture.asset(AppIcons.heartoutline),
                          const SizedBox(
                            width: 8,
                          ),
                          SvgPicture.asset(AppIcons.chatoutline),
                        ],
                      ),
                    ),

// name address
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // name
                          Row(
                            children: [
                              Text(
                                '${user.userDetail!.name!}, ${user.userDetail!.age!}',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),

                              // male female
                              const Icon(
                                Icons.male,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          // address

                          Text(
                            '${user.userDetail!.address}'.isEmpty
                                ? 'N/A'
                                : '${user.userDetail!.address}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),

                          Text(
                            'Sent: ${user.likedDate}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget DesktopLikePage() {
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
                  GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     CupertinoPageRoute(
                        //         builder: (context) => ProfilePage()));
                      },
                      child: ProfileImage()),
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
                        // ButtonWithLabel(
                        //   text: null,
                        //   labelText: 'Popular',
                        //   onPressed: () {},
                        //   icon: const Icon(Icons.star),
                        // ),
                        // const SizedBox(
                        //   width: 15,
                        // ),
                        // // photos
                        // ButtonWithLabel(
                        //   text: null,
                        //   labelText: 'Photos',
                        //   onPressed: () {},
                        //   icon: const Icon(Icons.photo_library_sharp),
                        // ),

                        // const SizedBox(
                        //   width: 15,
                        // ),
                        // // add friemd
                        // ButtonWithLabel(
                        //   text: null,
                        //   labelText: 'Add Friend',
                        //   onPressed: () {},
                        //   icon: const Icon(Icons.add),
                        // ),

                        // const SizedBox(
                        //   width: 15,
                        // ),
                        // // online
                        // ButtonWithLabel(
                        //   text: null,
                        //   labelText: 'Online',
                        //   onPressed: () {},
                        //   icon: const Icon(
                        //     Icons.circle_outlined,
                        //     color: Colors.green,
                        //   ),
                        // ),
                      ],
                    ),

                    const SizedBox(
                      width: 100,
                    ),

                    // age seeking

                    Row(
                      children: [
                        // seeking

                        // Neumorphic(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 2),
                        //   child: DropdownButton<String>(
                        //     underline: Container(),
                        //     style: AppTextStyles().secondaryStyle,
                        //     value: seeking,
                        //     icon: const Icon(
                        //         Icons.arrow_drop_down), // Dropdown icon
                        //     onChanged: (String? newValue) {
                        //       setState(() {
                        //         seeking = newValue!;
                        //       });
                        //     },
                        //     items: <String>[
                        //       'SEEKING',
                        //       'English',
                        //       'Spanish',
                        //       'French',
                        //       'German'
                        //     ] // Language options
                        //         .map<DropdownMenuItem<String>>((String value) {
                        //       return DropdownMenuItem<String>(
                        //         value: value,
                        //         child: Text(
                        //           value,
                        //           style: AppTextStyles().secondaryStyle,
                        //         ),
                        //       );
                        //     }).toList(),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   width: 50,
                        // ),

                        // // country

                        // Neumorphic(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 2),
                        //   child: DropdownButton<String>(
                        //     underline: Container(),
                        //     style: AppTextStyles().secondaryStyle,
                        //     value: country,
                        //     icon: const Icon(
                        //         Icons.arrow_drop_down), // Dropdown icon
                        //     onChanged: (String? newValue) {
                        //       setState(() {
                        //         country = newValue!;
                        //       });
                        //     },
                        //     items: <String>[
                        //       'COUNTRY',
                        //       'English',
                        //       'Spanish',
                        //       'French',
                        //       'German'
                        //     ] // Language options
                        //         .map<DropdownMenuItem<String>>((String value) {
                        //       return DropdownMenuItem<String>(
                        //         value: value,
                        //         child: Text(
                        //           value,
                        //           style: AppTextStyles().secondaryStyle,
                        //         ),
                        //       );
                        //     }).toList(),
                        //   ),
                        // ),
                        // const SizedBox(
                        //   width: 50,
                        // ),

                        // // age

                        // Neumorphic(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 20, vertical: 2),
                        //   child: DropdownButton<String>(
                        //     underline: Container(),
                        //     style: AppTextStyles().secondaryStyle,
                        //     value: age,
                        //     icon: const Icon(
                        //         Icons.arrow_drop_down), // Dropdown icon
                        //     onChanged: (String? newValue) {
                        //       setState(() {
                        //         age = newValue!;
                        //       });
                        //     },
                        //     items: <String>[
                        //       'AGE',
                        //       'English',
                        //       'Spanish',
                        //       'French',
                        //       'German'
                        //     ] // Language options
                        //         .map<DropdownMenuItem<String>>((String value) {
                        //       return DropdownMenuItem<String>(
                        //         value: value,
                        //         child: Text(
                        //           value,
                        //           style: AppTextStyles().secondaryStyle,
                        //         ),
                        //       );
                        //     }).toList(),
                        //   ),
                        // ),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Likes',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),

// tab bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: NeumorphicToggle(
                            padding: EdgeInsets.zero,
                            style: NeumorphicToggleStyle(
                              borderRadius: BorderRadius.circular(100),
                              depth: 10,
                              disableDepth: false,
                              backgroundColor: AppColors.backgroundColor,
                            ),
                            height: 40,
                            width: 300,
                            selectedIndex: _selectedIndex,
                            children: [
                              // Billing

                              ToggleElement(
                                background: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 202, 215, 225),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'Liked Me',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                  )),
                                ),
                                foreground: Center(
                                  child: Text(
                                    'Liked Me',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                  ),
                                ),
                              ),

                              // profile

                              ToggleElement(
                                background: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 202, 215, 225),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'My Likes',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                  )),
                                ),
                                foreground: Center(
                                  child: Text(
                                    'My Likes',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                  ),
                                ),
                              ),
                              ToggleElement(
                                background: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 202, 215, 225),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Mutual Likes',
                                      style: AppTextStyles()
                                          .secondaryStyle
                                          .copyWith(
                                            color: Colors.black,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                ),
                                foreground: Center(
                                  child: Text(
                                    'Mutual Likes',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                  ),
                                ),
                              )
                            ],
                            onChanged: (index) {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            thumb: const Text(''),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        children: [
                          Expanded(
                            child: Consumer<UserInteractionProvider>(
                                builder: (context, provider, _) {
                              final userMatchModel = provider.getUserMatchModel;

                              return ListView(
                                scrollDirection: Axis.vertical,
                                children: [
                                  // profile pic

                                  IndexedStack(
                                    index: _selectedIndex,
                                    children: [
                                      provider.isInteractionLoading
                                          ? const Row(
                                              children: [
                                                SizedBox(
                                                  width: 350,
                                                  child: ShimmerSkeleton(
                                                    height: 300,
                                                    count: 1,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: 350,
                                                  child: ShimmerSkeleton(
                                                    height: 300,
                                                    count: 1,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: 350,
                                                  child: ShimmerSkeleton(
                                                    height: 300,
                                                    count: 1,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : likedMeListDesktop(provider),
                                      provider.isInteractionLoading
                                          ? const Row(
                                              children: [
                                                SizedBox(
                                                  width: 350,
                                                  child: ShimmerSkeleton(
                                                    height: 300,
                                                    count: 1,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: 350,
                                                  child: ShimmerSkeleton(
                                                    height: 300,
                                                    count: 1,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                SizedBox(
                                                  width: 350,
                                                  child: ShimmerSkeleton(
                                                    height: 300,
                                                    count: 1,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : myLikesListDesktop(provider),
                                      userMatchModel != null
                                          ? mutualLikesListDesktop(
                                              userMatchModel)
                                          : Center(
                                              child: Text('No Matches yet.'))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),

                                  // details
                                  const SizedBox(
                                    height: 15,
                                  ),

                                  // edit
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
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

class InteractedUser {
  final String id;
  final String name;
  final String profileImageUrl;
  final int age;
  final String location;

  InteractedUser({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.age,
    required this.location,
  });
}

class TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
