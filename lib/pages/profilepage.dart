import 'package:dating/pages/settingpage.dart';
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';

  int _selectedPhotoIndex = 0;

  void _selectPhoto(int index) {
    setState(() {
      _selectedPhotoIndex = index;
    });
  }

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
                'Profile',
                style: AppTextStyles().primaryStyle,
              ),

              // settings icon

              ButtonWithLabel(
                text: null,
                onPressed: () {},
                icon: SvgPicture.asset(
                  AppIcons.threedots,
                ),
                labelText: null,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Expanded(
          child: ListView(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: AssetImage(AppImages.loginimage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Colors.black.withOpacity(0.75),
                            ),
                            child: Icon(
                              Icons.report_gmailerrorred,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.white.withOpacity(0.5),
                              )
                            ],
                          ),
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Colors.black.withOpacity(0.75),
                            ),
                            child: Icon(
                              Icons.fullscreen,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),

              // details
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Sekar Lia, 25',
                              style: AppTextStyles().primaryStyle,
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.female)
                          ],
                        ),

                        // active status

                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 10,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              'Online',
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        )
                      ],
                    ),

                    // location and other details
                    SizedBox(
                      height: 10,
                    ),

                    Column(
                      children: [
                        // location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: AppColors.secondaryColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Malang, Jawa Timur,",
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        // relationship status

                        Row(
                          children: [
                            Icon(
                              Icons.female,
                              color: AppColors.secondaryColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Female / Single",
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        ),

                        // seeking
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: AppColors.secondaryColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Seeking Male 21-39",
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // about
              SizedBox(
                height: 25,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Me',
                      style: AppTextStyles().primaryStyle.copyWith(
                            color: AppColors.black.withOpacity(0.75),
                          ),
                    ),

                    // seperator
                    Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.50,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ),

// text about

                    Text(
                      'Caring and hard working',
                      style: AppTextStyles().secondaryStyle,
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    Text(
                      'Overview',
                      style: AppTextStyles().primaryStyle.copyWith(
                            color: AppColors.black.withOpacity(0.75),
                          ),
                    ),

                    // seperator
                    Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.50,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ),

// text about

                    Text(
                      'Caring and hard working',
                      style: AppTextStyles().secondaryStyle,
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 200,
              ),
            ],
          ),
        ),
      ]),
      bottomSheet: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // heart
            Neumorphic(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                depth: 5,
                intensity: 0.75,
              ),
              child: NeumorphicButton(
                child: Container(
                  height: 50,
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SvgPicture.asset(
                      AppIcons.heartfilled,
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              ),
            ),

            // chat
            Neumorphic(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                depth: 5,
                intensity: 0.75,
              ),
              child: NeumorphicButton(
                child: Container(
                  height: 65,
                  width: 65,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SvgPicture.asset(
                      AppIcons.chatfilled,
                      height: 20,
                      width: 20,
                    ),
                  ),
                ),
              ),
            ),

            // star
            Neumorphic(
              style: NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                depth: 5,
                intensity: 0.75,
              ),
              child: NeumorphicButton(
                child: Container(
                  height: 50,
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SvgPicture.asset(
                      AppIcons.starfilled,
                      height: 20,
                      width: 20,
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

  Widget DesktopProfile() {
    List<String> photoAssetPaths = [
      AppImages.profile, // Main photo
      AppImages.loginimage,
      AppImages.profile,
      AppImages.profile,
      // Small photo 3
    ];

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
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
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
                          'Profile',
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
                                // profilr photos selector

                                GestureDetector(
                                  onTap: () => _selectPhoto(0),
                                  child: Neumorphic(
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(10)),
                                      depth: 5,
                                      intensity: 0.75,
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        photoAssetPaths[_selectedPhotoIndex],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 20,
                                ),
                                //

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 500,
                                    width: 200,
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 20.0,
                                        mainAxisSpacing: 8.0,
                                      ),
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () => _selectPhoto(index + 1),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Opacity(
                                                opacity: _selectedPhotoIndex ==
                                                        index + 1
                                                    ? 1.0
                                                    : 0.5,
                                                child: Image.asset(
                                                  photoAssetPaths[index + 1],
                                                  width: 500,
                                                  height: 300,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
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
                child: ListView(
                  children: [
                    // like chat
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // chat
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // heart
                              Neumorphic(
                                style: NeumorphicStyle(
                                  boxShape: NeumorphicBoxShape.circle(),
                                  depth: 5,
                                  intensity: 0.75,
                                ),
                                child: NeumorphicButton(
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(
                                        AppIcons.heartfilled,
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // chat
                              Neumorphic(
                                style: NeumorphicStyle(
                                  boxShape: NeumorphicBoxShape.circle(),
                                  depth: 5,
                                  intensity: 0.75,
                                ),
                                child: NeumorphicButton(
                                  child: Container(
                                    height: 55,
                                    width: 55,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(
                                        AppIcons.chatfilled,
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // star
                              Neumorphic(
                                style: NeumorphicStyle(
                                  boxShape: NeumorphicBoxShape.circle(),
                                  depth: 5,
                                  intensity: 0.75,
                                ),
                                child: NeumorphicButton(
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: SvgPicture.asset(
                                        AppIcons.starfilled,
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // report

                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1000),
                              color: Colors.black.withOpacity(0.75),
                            ),
                            child: Icon(
                              Icons.report_gmailerrorred,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Sekar Lia, 25',
                                    style: AppTextStyles().primaryStyle,
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.female)
                                ],
                              ),

// active status

                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 10,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    'Online',
                                    style: AppTextStyles().secondaryStyle,
                                  )
                                ],
                              )
                            ],
                          ),

// location and other details
                          SizedBox(
                            height: 10,
                          ),

                          Column(
                            children: [
                              // location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.secondaryColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Malang, Jawa Timur, Indonesia",
                                    style: AppTextStyles().secondaryStyle,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
// relationship status

                              Row(
                                children: [
                                  Icon(
                                    Icons.female,
                                    color: AppColors.secondaryColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Female / Single",
                                    style: AppTextStyles().secondaryStyle,
                                  )
                                ],
                              ),

// seeking
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: AppColors.secondaryColor,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Seeking Male 21-39",
                                    style: AppTextStyles().secondaryStyle,
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    // about
                    SizedBox(
                      height: 25,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Me',
                            style: AppTextStyles().primaryStyle.copyWith(
                                  color: AppColors.black.withOpacity(0.75),
                                ),
                          ),

                          // seperator
                          Container(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 0.50,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                            ),
                          ),

// text about

                          Text(
                            'Caring and hard working',
                            style: AppTextStyles().secondaryStyle,
                          ),

                          SizedBox(
                            height: 20,
                          ),

                          Text(
                            'Overview',
                            style: AppTextStyles().primaryStyle.copyWith(
                                  color: AppColors.black.withOpacity(0.75),
                                ),
                          ),

                          // seperator
                          Container(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 0.50,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                            ),
                          ),

// text about

                          Text(
                            'Hi there!  i’m Ghina. Just ordinary girl. Looking for a time traveler so i can meet you in the future inshaAllah ^^   Not interested in short term, so lets know each other well first, dont be hurry.   Be polite pls :)',
                            style: AppTextStyles().secondaryStyle,
                          ),
                        ],
                      ),
                    ),
// container

                    Container(
                      height: 300,
                    )
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
