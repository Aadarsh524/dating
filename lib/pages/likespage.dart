import 'dart:convert';
import 'dart:typed_data';

import 'package:dating/datamodel/interaction/user_interaction_model.dart';
import 'package:dating/providers/interaction_provider/user_interaction_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
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
          // List of liked users based on tab selection
          Expanded(
            child: Consumer<UserInteractionProvider>(
              builder: (context, provider, _) {
                switch (_selectedIndex) {
                  case 0:
                    return likedMeList(provider);
                  case 1:
                    return myLikesList(provider);
                  case 2:
                    return mutualLikesList(provider);
                  default:
                    return Container();
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
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 15, // Horizontal spacing between items
            mainAxisSpacing: 15, // Vertical spacing between items
          ),
          itemCount: likedMeUsers.length,
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
                          SvgPicture.asset('assets/icons/heartoutline.svg'),
                          const SizedBox(width: 8),
                          SvgPicture.asset('assets/icons/chatoutline.svg'),
                        ],
                      ),
                    ),
                    // name and address
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
                              // gender
                              const Icon(
                                "male" == 'male' ? Icons.male : Icons.female,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          // address
                          Text(
                            user.userDetail!.address!,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          Text(
                            'Sent: 13 hours ago', // Assuming this is static text; adjust if needed
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget myLikesList(UserInteractionProvider provider) {
    List<LikedUsers>? myLikesUsers = provider.userInteractionModel?.likedUsers;

    if (myLikesUsers == null || myLikesUsers.isEmpty) {
      return const Center(child: Text('You have not liked anyone yet.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 900,
        child: GridView.builder(
          clipBehavior: Clip.none,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 15, // Horizontal spacing between items
            mainAxisSpacing: 15, // Vertical spacing between items
          ),
          itemCount: myLikesUsers.length,
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
                          SvgPicture.asset('assets/icons/heartoutline.svg'),
                          const SizedBox(width: 8),
                          SvgPicture.asset('assets/icons/chatoutline.svg'),
                        ],
                      ),
                    ),
                    // name and address
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
                              // gender
                              const Icon(
                                "male" == 'male' ? Icons.male : Icons.female,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          // address
                          Text(
                            user.userDetail!.address!,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          Text(
                            'Sent: 13 hours ago', // Assuming this is static text; adjust if needed
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget for displaying users who have mutual likes with the current user
  Widget mutualLikesList(UserInteractionProvider provider) {
    List<MutualLikes>? mutualLikesUsers =
        provider.userInteractionModel?.mutualLikes;

    if (mutualLikesUsers == null || mutualLikesUsers.isEmpty) {
      return const Center(child: Text('You have no mutual likes yet.'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 900,
        child: GridView.builder(
          clipBehavior: Clip.none,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 15, // Horizontal spacing between items
            mainAxisSpacing: 15, // Vertical spacing between items
          ),
          itemCount: mutualLikesUsers.length,
          itemBuilder: (context, index) {
            MutualLikes user = mutualLikesUsers[index];
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
                          SvgPicture.asset('assets/icons/heartoutline.svg'),
                          const SizedBox(width: 8),
                          SvgPicture.asset('assets/icons/chatoutline.svg'),
                        ],
                      ),
                    ),
                    // name and address
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
                              // gender
                              const Icon(
                                "male" == 'male' ? Icons.male : Icons.female,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          // address
                          Text(
                            user.userDetail!.address!,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          Text(
                            'Sent: 13 hours ago', // Assuming this is static text; adjust if needed
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Padding likeListDesktop() {
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
          itemCount: 12, // Total number of containers in the grid
          itemBuilder: (context, index) {
            return Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage(AppImages.profile), // Image asset path
                  fit: BoxFit
                      .cover, // Adjust how the image should fit inside the container
                ), // Adjust how the image should fit inside the container
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
                                'John Doe, 25',
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
                            'Malang, Jawa Timur..',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),

                          Text(
                            'Sent: 19 hour ago',
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
                      child: const profileButton()),
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
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              children: [
                                // profile pic

                                IndexedStack(
                                  index: _selectedIndex,
                                  children: [
                                    likeListDesktop(),
                                    likeListDesktop(),
                                    likeListDesktop(),
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
