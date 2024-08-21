import 'dart:convert';
import 'dart:typed_data';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/providers/interaction_provider/profile_view_provider.dart'; // Import ProfileViewProvider
import 'package:dating/providers/user_profile_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';

import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ViewPage extends StatefulWidget {
  const ViewPage({super.key});

  @override
  State<ViewPage> createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';

  int _selectedIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // For smaller screen sizes (e.g., mobile)
              return MobileViewPage();
            } else {
              // For larger screen sizes (e.g., tablet or desktop)
              return DesktopViewPage();
            }
          },
        ),
      ),
    );
  }

  Widget MobileViewPage() {
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

              // search icon
              ButtonWithLabel(
                text: null,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                ),
                labelText: null,
              ),

              Text(
                'Profile View',
                style: AppTextStyles().primaryStyle,
              ),

              // view icon
              ButtonWithLabel(
                text: null,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: SvgPicture.asset(AppIcons.threedots),
                labelText: null,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),

        // tabbar
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
            width: 900,
            selectedIndex: _selectedIndex,
            children: [
              // Viewed My Profile

              ToggleElement(
                background: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 202, 215, 225),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                      child: Text(
                    'Viewed My Profile',
                    style: AppTextStyles().secondaryStyle.copyWith(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                  )),
                ),
                foreground: Center(
                  child: Text(
                    'Viewed My Profile',
                    style: AppTextStyles().secondaryStyle.copyWith(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                  ),
                ),
              ),

              // Profiles I Viewed

              ToggleElement(
                background: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 202, 215, 225),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      'Profiles I Viewed',
                      style: AppTextStyles().secondaryStyle.copyWith(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
                foreground: Center(
                  child: Text(
                    'Profiles I Viewed',
                    style: AppTextStyles().secondaryStyle.copyWith(
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

        const SizedBox(
          height: 30,
        ),

        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: [
                  getWhoVisitedMyProfile(userId: user!.uid),
                  getProfileWhomIViewed(userId: user!.uid),
                ],
              ),
            ],
          ),
        ),
      ]),
      bottomSheet: const NavBar(),
    );
  }

  ChangeNotifierProvider<ProfileViewProvider> getWhoVisitedMyProfile(
      {required String userId}) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewProvider()..getWhoVisitedMyProfile(userId, 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:
            Consumer<ProfileViewProvider>(builder: (context, provider, child) {
          if (provider.isProfileViewLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final profiles = provider.visitedMyProfiles;

          if (profiles == null || profiles.isEmpty) {
            return const Center(child: Text('No profiles found.'));
          }
          return SizedBox(
            width: double.infinity,
            height: 900,
            child: GridView.builder(
              clipBehavior: Clip.none,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns in the grid
                crossAxisSpacing: 15, // Horizontal spacing between items
                mainAxisSpacing: 15, // Vertical spacing between items
              ),
              itemCount:
                  profiles.length, // Total number of containers in the grid
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: profile.image!.isNotEmpty
                          ? MemoryImage(base64ToImage(profile.image!))
                          : MemoryImage(base64ToImage(
                              defaultBase64Avatar)), // Image asset path
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
                                    '${profile.name ?? 'Unknown'}, ${profile.age ?? 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  // male/female icon
                                ],
                              ),
                              // address
                              Text(
                                profile.address ?? 'Unknown location',
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
          );
        }),
      ),
    );
  }

  ChangeNotifierProvider<ProfileViewProvider> getProfileWhomIViewed(
      {required String userId}) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewProvider()..getProfileWhomIViewed(userId, 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:
            Consumer<ProfileViewProvider>(builder: (context, provider, child) {
          if (provider.isProfileViewLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final profiles = provider.viewedProfiles;

          if (profiles == null || profiles.isEmpty) {
            return const Center(child: Text('No profiles found.'));
          }
          return SizedBox(
            width: double.infinity,
            height: 900,
            child: GridView.builder(
              clipBehavior: Clip.none,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns in the grid
                crossAxisSpacing: 15, // Horizontal spacing between items
                mainAxisSpacing: 15, // Vertical spacing between items
              ),
              itemCount:
                  profiles.length, // Total number of containers in the grid
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: profile.image!.isNotEmpty
                          ? MemoryImage(base64ToImage(profile.image!))
                          : MemoryImage(base64ToImage(
                              defaultBase64Avatar)), // Image asset path
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
                                    '${profile.name ?? 'Unknown'}, ${profile.age ?? 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                  // male/female icon
                                ],
                              ),
                              // address
                              Text(
                                profile.address ?? 'Unknown location',
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
          );
        }),
      ),
    );
  }

  ChangeNotifierProvider<ProfileViewProvider> getWhoVisitedMyProfileDesktop({
    required String userId,
  }) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewProvider()..getWhoVisitedMyProfile(userId, 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<ProfileViewProvider>(
          builder: (context, provider, child) {
            if (provider.isProfileViewLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final profiles = provider.visitedMyProfiles;

            if (profiles == null || profiles.isEmpty) {
              return const Center(child: Text('No profiles found.'));
            }
            return SizedBox(
              width: double.infinity,
              height: 900,
              child: GridView.builder(
                clipBehavior: Clip.none,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: profile.image!.isNotEmpty
                            ? MemoryImage(base64ToImage(profile.image!))
                            : MemoryImage(base64ToImage(defaultBase64Avatar)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${profile.name ?? 'Unknown'}, ${profile.age ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              profile.address ?? 'Unknown location',
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
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  ChangeNotifierProvider<ProfileViewProvider> getProfileWhomIViewedDesktop({
    required String userId,
  }) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewProvider()..getProfileWhomIViewed(userId, 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<ProfileViewProvider>(
          builder: (context, provider, child) {
            if (provider.isProfileViewLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final profiles = provider.viewedProfiles;

            if (profiles == null || profiles.isEmpty) {
              return const Center(child: Text('No profiles found.'));
            }
            return SizedBox(
              width: double.infinity,
              height: 900,
              child: GridView.builder(
                clipBehavior: Clip.none,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: profile.image!.isNotEmpty
                            ? MemoryImage(base64ToImage(profile.image!))
                            : MemoryImage(base64ToImage(defaultBase64Avatar)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${profile.name ?? 'Unknown'}, ${profile.age ?? 'N/A'}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              profile.address ?? 'Unknown location',
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
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget DesktopViewPage() {
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
                      child: const ProfileButton()),
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
                          'Profile Views',
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
                                      'Viewed My Profile',
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
                                    'Viewed My Profile',
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
                                    'Profile I Viewed',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                  )),
                                ),
                                foreground: Center(
                                  child: Text(
                                    'Profile I Viewed',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                  ),
                                ),
                              ),
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
                                    getWhoVisitedMyProfileDesktop(
                                        userId: user!.uid),
                                    getProfileWhomIViewedDesktop(
                                        userId: user!.uid),
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
