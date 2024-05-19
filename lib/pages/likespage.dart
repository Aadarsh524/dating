import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
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

              // search icon
              ButtonWithLabel(
                text: null,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                ),
                labelText: null,
              ),

              Text(
                'Likes',
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
        SizedBox(
          height: 30,
        ),

        // details

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
              // Billing

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
                    'Liked Me',
                    style: AppTextStyles().secondaryStyle.copyWith(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                  )),
                ),
                foreground: Center(
                  child: Text(
                    'Liked Me',
                    style: AppTextStyles().secondaryStyle.copyWith(
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
                    color: const Color.fromARGB(255, 202, 215, 225),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                      child: Text(
                    'My Likes',
                    style: AppTextStyles().secondaryStyle.copyWith(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                  )),
                ),
                foreground: Center(
                  child: Text(
                    'My Likes',
                    style: AppTextStyles().secondaryStyle.copyWith(
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
                    color: const Color.fromARGB(255, 202, 215, 225),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      'Mutual Likes',
                      style: AppTextStyles().secondaryStyle.copyWith(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
                foreground: Center(
                  child: Text(
                    'Mutual Likes',
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
            thumb: Text(''),
          ),
        ),

        SizedBox(
          height: 30,
        ),

        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: [
                  // fav tab
                  likeListMobile(),
                  likeListMobile(),
                  likeListMobile(),
                ],
              ),
            ],
          ),
        ),

        // details edit
      ]),
      bottomSheet: NavBar(),
    );
  }

  Padding likeListMobile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 900,
        child: GridView.builder(
          clipBehavior: Clip.none,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 15, // Horizontal spacing between items
            mainAxisSpacing: 15, // Vertical spacing between items
          ),
          itemCount: 12, // Total number of containers in the grid
          itemBuilder: (context, index) {
            return Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
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
                          SizedBox(
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
                              Icon(
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
                            'Sent: 13 hour ago',
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

  Padding likeListDesktop() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 900,
        child: GridView.builder(
          clipBehavior: Clip.none,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                image: DecorationImage(
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
                          SizedBox(
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
                              Icon(
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
                  GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     CupertinoPageRoute(
                        //         builder: (context) => ProfilePage()));
                      },
                      child: profileButton()),
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
                            thumb: Text(''),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
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
                                SizedBox(
                                  height: 30,
                                ),

// details
                                SizedBox(
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
