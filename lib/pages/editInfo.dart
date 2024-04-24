import 'package:dating/pages/chatMobileOnly/chatscreen.dart';
import 'package:dating/pages/myprofile.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:dating/widgets/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  // for name
  TextEditingController _controllerName = TextEditingController();
  String _textName = 'Pankaj subedi';
  bool _isEditingName = false;

  // for address
  TextEditingController _controllerAddress = TextEditingController();
  String _textAddress = 'Nepal, Kathmandu';
  bool _isEditingAddress = false;

// for address
  TextEditingController _controllerBio = TextEditingController();
  String _textBio = 'I value honesty,\nkindness, and a good\nsense of humor.';
  bool _isEditingBio = false;

// for address
  TextEditingController _controllerInterests = TextEditingController();
  String _textInterests = 'Singing, Dancing, Cooking';
  bool _isEditingInterests = false;

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
    List<String> photoAssetPaths = [
      AppImages.profile, // Main photo
      AppImages.loginimage,
      AppImages.profile,
      AppImages.profile,
      // Small photo 3
    ];

    return Scaffold(
      body: ListView(children: [
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
                'Edit Profile',
                style: AppTextStyles().primaryStyle,
              ),

              // view icon

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MyProfilePage(),
                    ),
                  );
                },
                child: Text(
                  'View',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF707070),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
        SizedBox(
          height: 200,
          width: 200,
          child: Center(
            child: Neumorphic(
              style: NeumorphicStyle(
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(1000)),
                depth: 10,
                intensity: 0.5,
              ),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  image: DecorationImage(
                    image: AssetImage(AppImages.profile),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: EdgeInsets.all(60),
                child: SvgPicture.asset(
                  AppIcons.editphoto,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
// details

        SizedBox(
          height: 25,
        ),

        // details edit

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Basics',
                style: AppTextStyles().primaryStyle.copyWith(
                      color: AppColors.black.withOpacity(0.75),
                    ),
              ),

              SizedBox(
                height: 10,
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
              SizedBox(
                height: 6,
              ),
              // text about

              Text(
                'Your Name',
                style: AppTextStyles().secondaryStyle.copyWith(
                      color: AppColors.black,
                    ),
              ),

              // edit name

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: _isEditingName
                        ? TextField(
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            )),
                            style: AppTextStyles().secondaryStyle,
                            controller: _controllerName,
                            autofocus: true,
                          )
                        : Text(_textName,
                            style: AppTextStyles().secondaryStyle),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.secondaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditingName = true;
                        _controllerName.text = _textName;
                      });
                    },
                  ),
                  if (_isEditingName)
                    IconButton(
                      icon: Icon(
                        Icons.save,
                        size: 20,
                        color: AppColors.secondaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _textName = _controllerName.text;
                          _isEditingName = false;
                        });
                      },
                    ),
                ],
              ),

// location

              Text(
                'Your Address',
                style: AppTextStyles().secondaryStyle.copyWith(
                      color: AppColors.black,
                    ),
              ),

              // edit name

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: _isEditingAddress
                        ? TextField(
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            )),
                            style: AppTextStyles().secondaryStyle,
                            controller: _controllerAddress,
                            autofocus: true,
                          )
                        : Text(_textAddress,
                            style: AppTextStyles().secondaryStyle),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.secondaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditingAddress = true;
                        _controllerAddress.text = _textAddress;
                      });
                    },
                  ),
                  if (_isEditingAddress)
                    IconButton(
                      icon: Icon(
                        Icons.save,
                        size: 20,
                        color: AppColors.secondaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _textAddress = _controllerAddress.text;
                          _isEditingAddress = false;
                        });
                      },
                    ),
                ],
              ),

// bio

              Text(
                'Bio',
                style: AppTextStyles().secondaryStyle.copyWith(
                      color: AppColors.black,
                    ),
              ),

              // edit name

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: _isEditingBio
                        ? TextField(
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            )),
                            style: AppTextStyles().secondaryStyle,
                            controller: _controllerBio,
                            autofocus: true,
                          )
                        : Text(_textBio, style: AppTextStyles().secondaryStyle),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.secondaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditingBio = true;
                        _controllerBio.text = _textBio;
                      });
                    },
                  ),
                  if (_isEditingBio)
                    IconButton(
                      icon: Icon(
                        Icons.save,
                        size: 20,
                        color: AppColors.secondaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _textBio = _controllerBio.text;
                          _isEditingBio = false;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),

        // mored details
        SizedBox(
          height: 25,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'More',
              style: AppTextStyles().primaryStyle.copyWith(
                    color: AppColors.black.withOpacity(0.75),
                  ),
            ),

            SizedBox(
              height: 10,
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
            SizedBox(
              height: 6,
            ),
            // text about

            Text(
              'Intersets',
              style: AppTextStyles().secondaryStyle.copyWith(
                    color: AppColors.black,
                  ),
            ),

            // edit name

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: _isEditingInterests
                      ? TextField(
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(
                            borderSide: BorderSide.none,
                          )),
                          style: AppTextStyles().secondaryStyle,
                          controller: _controllerInterests,
                          autofocus: true,
                        )
                      : Text(_textInterests,
                          style: AppTextStyles().secondaryStyle),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    size: 20,
                    color: AppColors.secondaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditingInterests = true;
                      _controllerInterests.text = _textInterests;
                    });
                  },
                ),
                if (_isEditingInterests)
                  IconButton(
                    icon: Icon(
                      Icons.save,
                      size: 20,
                      color: AppColors.secondaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _textInterests = _controllerInterests.text;
                        _isEditingInterests = false;
                      });
                    },
                  ),
              ],
            ),
          ]),
        ),
        SizedBox(
          height: 50,
        ),
        // images

        SizedBox(
          width: double.infinity,
          height: 400,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of items per row
                crossAxisSpacing: 15, // Horizontal spacing between items
                mainAxisSpacing: 15, // Vertical spacing between rows
              ),
              itemCount: photoAssetPaths.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Neumorphic(
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(16)),
                        depth: 5,
                        intensity: 0.75,
                      ),
                      child: Container(
                        height: 500,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(photoAssetPaths[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            photoAssetPaths
                                .removeAt(index); // Remove photo from the list
                          });
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // about
        SizedBox(
          height: 25,
        ),
      ]),
      bottomSheet: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                child: Container(
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
                    onPressed: () {},
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
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        )
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
                                  height: 30,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // profile pic
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 200,
                                            width: 200,
                                            child: Center(
                                              child: Neumorphic(
                                                style: NeumorphicStyle(
                                                  boxShape: NeumorphicBoxShape
                                                      .roundRect(
                                                          BorderRadius.circular(
                                                              1000)),
                                                  depth: 10,
                                                  intensity: 0.5,
                                                ),
                                                child: Container(
                                                  height: 200,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000),
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          AppImages.profile),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.all(60),
                                                  child: SvgPicture.asset(
                                                    AppIcons.editphoto,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 100,
                                          ),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 900,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              child: GridView.builder(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      3, // Number of items per row
                                                  crossAxisSpacing:
                                                      15, // Horizontal spacing between items
                                                  mainAxisSpacing:
                                                      15, // Vertical spacing between rows
                                                ),
                                                itemCount:
                                                    photoAssetPaths.length,
                                                itemBuilder: (context, index) {
                                                  return Stack(
                                                    children: [
                                                      Neumorphic(
                                                        style: NeumorphicStyle(
                                                          boxShape: NeumorphicBoxShape
                                                              .roundRect(
                                                                  BorderRadius
                                                                      .circular(
                                                                          16)),
                                                          depth: 5,
                                                          intensity: 0.75,
                                                        ),
                                                        child: Container(
                                                          height: 500,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  photoAssetPaths[
                                                                      index]),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 10,
                                                        right: 10,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              photoAssetPaths
                                                                  .removeAt(
                                                                      index); // Remove photo from the list
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

// details
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Your Basics',
                                              style: AppTextStyles()
                                                  .primaryStyle
                                                  .copyWith(
                                                    color: AppColors.black
                                                        .withOpacity(0.75),
                                                  ),
                                            ),

                                            SizedBox(
                                              height: 10,
                                            ),
                                            // seperator
                                            Container(
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 0.50,
                                                    strokeAlign: BorderSide
                                                        .strokeAlignCenter,
                                                    color: Color(0xFFAAAAAA),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            // text about

                                            Text(
                                              'Your Name',
                                              style: AppTextStyles()
                                                  .secondaryStyle
                                                  .copyWith(
                                                    color: AppColors.black,
                                                  ),
                                            ),

                                            // edit name

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _isEditingName
                                                    ? Expanded(
                                                        child: TextField(
                                                          decoration:
                                                              InputDecoration(
                                                                  border:
                                                                      UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                          )),
                                                          style: AppTextStyles()
                                                              .secondaryStyle,
                                                          controller:
                                                              _controllerName,
                                                          autofocus: true,
                                                        ),
                                                      )
                                                    : Text(_textName,
                                                        style: AppTextStyles()
                                                            .secondaryStyle),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    size: 20,
                                                    color: AppColors
                                                        .secondaryColor,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isEditingName = true;
                                                      _controllerName.text =
                                                          _textName;
                                                    });
                                                  },
                                                ),
                                                if (_isEditingName)
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.save,
                                                      size: 20,
                                                      color: AppColors
                                                          .secondaryColor,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _textName =
                                                            _controllerName
                                                                .text;
                                                        _isEditingName = false;
                                                      });
                                                    },
                                                  ),
                                              ],
                                            ),

                                            // location

                                            Text(
                                              'Your Address',
                                              style: AppTextStyles()
                                                  .secondaryStyle
                                                  .copyWith(
                                                    color: AppColors.black,
                                                  ),
                                            ),

                                            // edit name

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _isEditingAddress
                                                    ? Expanded(
                                                        child: TextField(
                                                          decoration:
                                                              InputDecoration(
                                                                  border:
                                                                      UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                          )),
                                                          style: AppTextStyles()
                                                              .secondaryStyle,
                                                          controller:
                                                              _controllerAddress,
                                                          autofocus: true,
                                                        ),
                                                      )
                                                    : Text(_textAddress,
                                                        style: AppTextStyles()
                                                            .secondaryStyle),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    size: 20,
                                                    color: AppColors
                                                        .secondaryColor,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isEditingAddress = true;
                                                      _controllerAddress.text =
                                                          _textAddress;
                                                    });
                                                  },
                                                ),
                                                if (_isEditingAddress)
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.save,
                                                      size: 20,
                                                      color: AppColors
                                                          .secondaryColor,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _textAddress =
                                                            _controllerAddress
                                                                .text;
                                                        _isEditingAddress =
                                                            false;
                                                      });
                                                    },
                                                  ),
                                              ],
                                            ),

                                            // bio

                                            Text(
                                              'Bio',
                                              style: AppTextStyles()
                                                  .secondaryStyle
                                                  .copyWith(
                                                    color: AppColors.black,
                                                  ),
                                            ),

                                            // edit name

                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                _isEditingBio
                                                    ? Expanded(
                                                        child: TextField(
                                                          decoration:
                                                              InputDecoration(
                                                                  border:
                                                                      UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                          )),
                                                          style: AppTextStyles()
                                                              .secondaryStyle,
                                                          controller:
                                                              _controllerBio,
                                                          autofocus: true,
                                                        ),
                                                      )
                                                    : Text(_textBio,
                                                        style: AppTextStyles()
                                                            .secondaryStyle),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    size: 20,
                                                    color: AppColors
                                                        .secondaryColor,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _isEditingBio = true;
                                                      _controllerBio.text =
                                                          _textBio;
                                                    });
                                                  },
                                                ),
                                                if (_isEditingBio)
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.save,
                                                      size: 20,
                                                      color: AppColors
                                                          .secondaryColor,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _textBio =
                                                            _controllerBio.text;
                                                        _isEditingBio = false;
                                                      });
                                                    },
                                                  ),
                                              ],
                                            ),

                                            // mored details
                                            SizedBox(
                                              height: 25,
                                            ),

                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'More',
                                                    style: AppTextStyles()
                                                        .primaryStyle
                                                        .copyWith(
                                                          color: AppColors.black
                                                              .withOpacity(
                                                                  0.75),
                                                        ),
                                                  ),

                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  // seperator
                                                  Container(
                                                    decoration: ShapeDecoration(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          width: 0.50,
                                                          strokeAlign: BorderSide
                                                              .strokeAlignCenter,
                                                          color:
                                                              Color(0xFFAAAAAA),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 6,
                                                  ),
                                                  // text about

                                                  Text(
                                                    'Intersets',
                                                    style: AppTextStyles()
                                                        .secondaryStyle
                                                        .copyWith(
                                                          color:
                                                              AppColors.black,
                                                        ),
                                                  ),

                                                  // edit name

                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _isEditingInterests
                                                          ? Expanded(
                                                              child: TextField(
                                                                decoration:
                                                                    InputDecoration(
                                                                        border:
                                                                            UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                )),
                                                                style: AppTextStyles()
                                                                    .secondaryStyle,
                                                                controller:
                                                                    _controllerInterests,
                                                                autofocus: true,
                                                              ),
                                                            )
                                                          : Text(_textInterests,
                                                              style: AppTextStyles()
                                                                  .secondaryStyle),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                          color: AppColors
                                                              .secondaryColor,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _isEditingInterests =
                                                                true;
                                                            _controllerInterests
                                                                    .text =
                                                                _textInterests;
                                                          });
                                                        },
                                                      ),
                                                      if (_isEditingInterests)
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.save,
                                                            size: 20,
                                                            color: AppColors
                                                                .secondaryColor,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              _textInterests =
                                                                  _controllerInterests
                                                                      .text;
                                                              _isEditingInterests =
                                                                  false;
                                                            });
                                                          },
                                                        ),
                                                    ],
                                                  ),
                                                ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
      bottomSheet: Container(
        height: 70,
        decoration: BoxDecoration(
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
                child: Container(
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

            SizedBox(
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
          ],
        ),
      ),
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
