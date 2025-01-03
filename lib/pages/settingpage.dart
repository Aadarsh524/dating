import 'package:dating/auth/db_client.dart';
import 'package:dating/auth/login_screen.dart';

import 'package:dating/pages/components/profile_button.dart';
import 'package:dating/pages/subscriptionPage.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isSwitched = false;

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // For smaller screen sizes (e.g., mobile)
              return MobileProfile();
            } else {
              // For larger screen sizes (e.g., tablet or desktop)
              return DesktopProfile();
            }
          },
        ),
      ),
    );
  }

  Widget MobileProfile() {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWithLabel(
                  text: null,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  labelText: null,
                ),
                Text('Settings', style: AppTextStyles().primaryStyle),
                const SizedBox(width: 30),
              ],
            ),
          ),
          const SizedBox(height: 30),
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
                ToggleElement(
                  background: toggleBackground('Billing'),
                  foreground: toggleForeground('Billing'),
                ),
                ToggleElement(
                  background: toggleBackground('Profile'),
                  foreground: toggleForeground('Profile'),
                ),
                ToggleElement(
                  background: toggleBackground('Email'),
                  foreground: toggleForeground('Email'),
                ),
              ],
              onChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              thumb: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                Consumer<UserProfileProvider>(
                  builder: (context, provider, _) {
                    final userProfile = provider.currentUserProfileModel;

                    if (userProfile != null &&
                        userProfile.userSubscription != null) {
                      final expirationDateString =
                          userProfile.userSubscription!.expirationDate;

                      if (expirationDateString != null) {
                        // Convert the string to DateTime
                        final expirationDate =
                            DateTime.parse(expirationDateString);

                        if (expirationDate.isAfter(DateTime.now())) {
                          // Subscription is still valid
                          return subscriptionDetails(provider);
                        }
                      }

                      // Subscription expired or invalid expiration date
                      return const SubscriptionPage();
                    } else {
                      // No subscription or user profile available
                      return const SubscriptionPage();
                    }
                  },
                ),
                profileTab(),
                Container(
                  color: Colors.orange,
                  child: const Center(child: Text('Email')),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet:
          _selectedIndex == 0 ? const SizedBox(height: 0) : BottomActionSheet(),
    );
  }

  Widget toggleBackground(String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 202, 215, 225),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles().secondaryStyle.copyWith(color: Colors.black),
        ),
      ),
    );
  }

  Widget toggleForeground(String label) {
    return Center(
      child: Text(
        label,
        style: AppTextStyles().secondaryStyle.copyWith(color: Colors.black),
      ),
    );
  }

  Widget subscriptionDetails(UserProfileProvider provider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Current Subscription',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10.0),
            subscriptionRow(
              icon: Icons.subscriptions,
              color: Colors.greenAccent,
              label: 'Plan Type:',
              value:
                  provider.currentUserProfileModel!.userSubscription!.planType!,
            ),
            subscriptionRow(
              icon: Icons.timer,
              color: Colors.orangeAccent,
              label: 'Duration:',
              value:
                  provider.currentUserProfileModel!.userSubscription!.duration!,
            ),
            subscriptionRow(
              icon: Icons.calendar_today,
              color: Colors.redAccent,
              label: 'Expiration Date:',
              value: provider
                  .currentUserProfileModel!.userSubscription!.expirationDate!,
            ),
          ],
        ),
      ),
    );
  }

  Widget BottomActionSheet() {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          neumorphicButton('Cancel', Colors.red, () {}),
          neumorphicButton('Save', Colors.blue, () {}),
        ],
      ),
    );
  }

  Widget neumorphicButton(String text, Color color, VoidCallback onPressed) {
    return NeumorphicButton(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        depth: 5,
        intensity: 0.75,
      ),
      onPressed: onPressed,
      child: SizedBox(
        height: 50,
        width: 100,
        child: Center(
          child: Text(
            text,
            style: AppTextStyles().secondaryStyle.copyWith(color: color),
          ),
        ),
      ),
    );
  }

  Widget subscriptionRow(
      {required IconData icon,
      required Color color,
      required String label,
      required String value}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ],
    );
  }

  Column profileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Update your profile display options and localization.',
              style: AppTextStyles().secondaryStyle),
        ),
        const SizedBox(
          height: 25,
        ),

        // online options

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Online Options',
            style: AppTextStyles().primaryStyle.copyWith(
                  color: AppColors.black,
                ),
          ),
        ),

        const SizedBox(height: 5),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Online Status', style: AppTextStyles().secondaryStyle),
        ),

        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                child: NeumorphicSwitch(
                  height: 20,
                  value: _isSwitched,
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                      // Do something when the switch is toggled
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text('Show me as online',
                  style: AppTextStyles().secondaryStyle.copyWith(
                        fontSize: 14,
                      )),
            ],
          ),
        ),

        // show busy

        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                child: NeumorphicSwitch(
                  height: 20,
                  value: _isSwitched,
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                      // Do something when the switch is toggled
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text('Show me as busy',
                  style: AppTextStyles().secondaryStyle.copyWith(
                        fontSize: 14,
                      )),
            ],
          ),
        ),

        const SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Display Profile', style: AppTextStyles().secondaryStyle),
        ),

        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                child: NeumorphicSwitch(
                  height: 20,
                  value: _isSwitched,
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                      // Do something when the switch is toggled
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text('Display my profile to users',
                  style: AppTextStyles().secondaryStyle.copyWith(
                        fontSize: 14,
                      )),
            ],
          ),
        ),

        // show busy

        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                child: NeumorphicSwitch(
                  height: 20,
                  value: _isSwitched,
                  onChanged: (value) {
                    setState(() {
                      _isSwitched = value;
                      // Do something when the switch is toggled
                    });
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text('Hide my profile from users',
                  style: AppTextStyles().secondaryStyle.copyWith(
                        fontSize: 14,
                      )),
            ],
          ),
        ),
      ],
    );
  }

  Widget DesktopProfile() {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
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
                        //   Navigator.push(
                        //       context,
                        //       CupertinoPageRoute(
                        //           builder: (context) => const ProfilePage()));
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
                          'Setting',
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
                                    'Billing',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                            ),
                                  )),
                                ),
                                foreground: Center(
                                  child: Text(
                                    'Billing',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
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
                                    'Profile',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
                                            ),
                                  )),
                                ),
                                foreground: Center(
                                  child: Text(
                                    'Profile',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
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
                                      'Email',
                                      style: AppTextStyles()
                                          .secondaryStyle
                                          .copyWith(
                                            color: Colors.black,
                                          ),
                                    ),
                                  ),
                                ),
                                foreground: Center(
                                  child: Text(
                                    'Email',
                                    style:
                                        AppTextStyles().secondaryStyle.copyWith(
                                              color: Colors.black,
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

                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 1.01,
                                  child: IndexedStack(
                                    index: _selectedIndex,
                                    children: [
                                      //for billing
                                      Consumer<UserProfileProvider>(
                                          builder: (context, provider, _) {
                                        // Check if userProfileModel or userSubscription is null
                                        if (provider.currentUserProfileModel ==
                                                null ||
                                            provider.currentUserProfileModel!
                                                    .userSubscription ==
                                                null) {
                                          // If userSubscription is null, show the SubscriptionPage
                                          return const SubscriptionPage();
                                        } else {
                                          // If userSubscription exists, display the subscription details
                                          return Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 20.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Your Current Subscription',
                                                    style: TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blueAccent,
                                                    ),
                                                  ),
                                                  const Divider(
                                                      color: Colors
                                                          .grey), // Divider for separation
                                                  const SizedBox(height: 10.0),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.subscriptions,
                                                          color: Colors
                                                              .greenAccent),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        'Plan Type:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        provider
                                                            .currentUserProfileModel!
                                                            .userSubscription!
                                                            .planType
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.timer,
                                                          color: Colors
                                                              .orangeAccent),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        'Duration:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        provider
                                                            .currentUserProfileModel!
                                                            .userSubscription!
                                                            .duration
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10.0),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.calendar_today,
                                                          color:
                                                              Colors.redAccent),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        'Expiration Date:',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        provider
                                                            .currentUserProfileModel!
                                                            .userSubscription!
                                                            .expirationDate
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      }),

                                      // Container(
                                      //     color: Colors.green,
                                      //     child: const Center(
                                      //         child: Text('Billing'))),
                                      // Profile tab
                                      profileTab(),

                                      Container(
                                          color: Colors.orange,
                                          child: const Center(
                                              child: Text('Email'))),
                                    ],
                                  ),
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
      bottomSheet: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // cancel
            Neumorphic(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(16),
                ),
                depth: 5,
                intensity: 0.75,
              ),
              child: NeumorphicButton(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 50,
                  width: 100,
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: AppTextStyles().secondaryStyle.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 40,
            ),

            // save
            Neumorphic(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(16),
                ),
                depth: 5,
                intensity: 0.75,
              ),
              child: NeumorphicButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                padding: EdgeInsets.zero,
                child: Container(
                  height: 50,
                  width: 100,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Save',
                      style: AppTextStyles().secondaryStyle.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            //signout
            Neumorphic(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(16),
                ),
                depth: 5,
                intensity: 0.75,
              ),
              child: NeumorphicButton(
                onPressed: () {
                  authenticationProvider.signOut();
                  DbClient().clearAllData();
                  authenticationProvider.clearData(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                padding: EdgeInsets.zero,
                child: Container(
                  height: 50,
                  width: 100,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Sign out',
                      style: AppTextStyles().secondaryStyle.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
