import 'dart:convert';
import 'dart:typed_data';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/providers/interaction_provider/favourite_provider.dart';
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

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';

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
              return MobileFavorite();
            } else {
              // For larger screen sizes (e.g., tablet or desktop)
              return DesktopFavorite();
            }
          },
        ),
      ),
    );
  }

  Widget MobileFavorite() {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
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
                  'Favourites',
                  style: AppTextStyles().primaryStyle,
                ),

                // View icon
                ButtonWithLabel(
                  text: null,
                  onPressed: () {
                    // Handle three dots button action
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

          // Show favourite list
          Expanded(
            child: favListCardMobile(),
          ),
        ],
      ),
      bottomSheet: const NavBar(),
    );
  }

  Widget favListCardMobile() {
    return ChangeNotifierProvider(
      create: (_) => FavouritesProvider()..getFavourites(user!.uid, 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:
            Consumer<FavouritesProvider>(builder: (context, provider, child) {
          if (provider.isFavoriteLoading) {
            return Center(child: CircularProgressIndicator());
          }
          final favourites = provider.favourites;

          if (favourites == null || favourites.isEmpty) {
            return Center(child: Text('No favourites found.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Adjust grid item size based on screen size
              double gridItemWidth = (constraints.maxWidth - 30) / 2;
              double gridItemHeight = gridItemWidth * 1.5;

              return GridView.builder(
                clipBehavior: Clip.none,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth < 600
                      ? 2
                      : 3, // Responsive grid for different screen sizes
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: favourites.length,
                itemBuilder: (context, index) {
                  final favourite = favourites[index];
                  return Container(
                    height: gridItemHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: favourite.image!.isNotEmpty
                            ? MemoryImage(base64ToImage(favourite.image!))
                            : MemoryImage(base64ToImage(defaultBase64Avatar)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gradient overlay for text readability
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
                        // Content: Name, Age, Address
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Name and Age
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${favourite.name ?? 'Unknown'}, ${favourite.age ?? 'N/A'}',
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
                              // Address
                              Text(
                                favourite.address ?? 'Unknown location',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
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
          );
        }),
      ),
    );
  }

  Widget favListCardDesktop() {
    return ChangeNotifierProvider(
      create: (_) => FavouritesProvider()..getFavourites(user!.uid, 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:
            Consumer<FavouritesProvider>(builder: (context, provider, child) {
          if (provider.isFavoriteLoading) {
            return Center(child: CircularProgressIndicator());
          }
          final favourites = provider.favourites;

          if (favourites == null || favourites.isEmpty) {
            return Center(child: Text('No favourites found.'));
          }
          return Container(
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
                  favourites.length, // Total number of containers in the grid
              itemBuilder: (context, index) {
                final favourite = favourites[index];
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: favourite.image!.isNotEmpty
                          ? MemoryImage(base64ToImage(favourite.image!))
                          : MemoryImage(base64ToImage(
                              defaultBase64Avatar)), // Image asset path
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
                                    '${favourite.name ?? 'Unknown'}, ${favourite.age ?? 'N/A'}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),

                                  // male female
                                ],
                              ),
                              // address

                              Text(
                                favourite.address ?? 'Unknown location',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),

                              // Text(
                              //   'Added: 1 hour ago',
                              //   style: GoogleFonts.poppins(
                              //     color: Colors.white.withOpacity(0.75),
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.w400,
                              //     height: 0,
                              //   ),
                              // ),
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

  Widget DesktopFavorite() {
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
                          'Favorites',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),

// tab bar
                        //
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
                            child: favListCardDesktop(),
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
