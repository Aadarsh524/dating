import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dating/auth/db_client.dart';
import 'package:dating/auth/loginScreen.dart';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/pages/editInfo.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/backend/firebase_auth/firebase_auth.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/user_profile_provider.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');
  final AuthService _authService = AuthService();
  User? user = FirebaseAuth.instance.currentUser;

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';

  // int _selectedPhotoIndex = 0;

  // void _selectPhoto(int index) {
  //   setState(() {
  //     _selectedPhotoIndex = index;
  //   });
  // }

  Uint8List? _imageBytes;
  List<Uploads> allUploads = [];

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
  }

  late UserProfileModel userProfileModel;
  String? username;
  String? gender;
  String? address;

  pickImage() async {
    DateTime today = DateTime.now();
    DateTime currentDate = DateTime(today.year, today.month, today.day);
    // Request storage permission if needed
    final storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      throw Exception('Storage permission is required to upload the image.');
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    // Handle result
    if (result != null && result.files.isNotEmpty) {
      File imageFile = File(result.files.single.path!);

      String base64 = convertIntoBase64(imageFile);

      final newUpload = Uploads(
          userId: user!.uid.toString(),
          file: base64.toString(),
          name: 'Post',
          uploadDate: currentDate.toString());

      await context
          .read<UserProfileProvider>()
          .uploadPost(newUpload, user!.uid);
    } else {
      // Handle cases like user canceling the selection or errors
      print('No image selected.');
    }
  }

  String convertIntoBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64File = base64Encode(imageBytes);
    return base64File;
  }

  String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  @override
  void initState() {
    super.initState();

    UserProfileModel? userProfileModel =
        Provider.of<UserProfileProvider>(context, listen: false)
            .currentUserProfile;
    if (userProfileModel?.image != null &&
        userProfileModel!.image!.isNotEmpty) {
      _imageBytes = base64ToImage(userProfileModel.image);
    } else {
      _imageBytes = base64ToImage(defaultBase64Avatar);
    }
    if (userProfileModel?.name != null && userProfileModel!.name!.isNotEmpty) {
      username = userProfileModel.name;
    } else {
      username = "Add Name";
    }
    if (userProfileModel?.address != null &&
        userProfileModel!.address!.isNotEmpty) {
      address = userProfileModel.address;
    } else {
      address = "Add aaddress";
    }
    if (userProfileModel?.image != null &&
        userProfileModel!.gender!.isNotEmpty) {
      gender = userProfileModel.gender;
    } else {
      gender = "Select your gender";
    }
    if (userProfileModel?.uploads != null) {
      for (var upload in userProfileModel!.uploads!) {
        if (upload.file != null &&
            upload.name != null &&
            upload.uploadDate != null) {
          allUploads.add(Uploads(
              userId: user!.uid,
              file: upload.file,
              name: upload.name,
              uploadDate: upload.uploadDate));
          print(allUploads);
        }
      }
    } else {}
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
                'My Profile',
                style: AppTextStyles().primaryStyle,
              ),

              // settings icon

              ButtonWithLabel(
                text: null,
                onPressed: () {
                  _authService.signOut().then((value) {
                    DbClient().clearAllData();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  });
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
        Expanded(
          child: ListView(
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: Neumorphic(
                        style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(1000)),
                          depth: 10,
                          intensity: 0.5,
                        ),
                        // ignore: unnecessary_null_comparison
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              ),
              // details
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          username!,
                          style: AppTextStyles().primaryStyle,
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.female)
                      ],
                    ),

                    // location and other details
                    const SizedBox(
                      height: 10,
                    ),

                    Column(
                      children: [
                        // location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.secondaryColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              address!,
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        // relationship status

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.female,
                              color: AppColors.secondaryColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              gender!,
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        ),

                        // seeking
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppColors.secondaryColor,
                            ),
                            const SizedBox(
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

              // edit

              const SizedBox(
                height: 25,
              ),

              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.backgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // heart
                      Column(
                        children: [
                          Neumorphic(
                            style: const NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: 5,
                              intensity: 0.75,
                            ),
                            child: NeumorphicButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SettingPage()));
                              },
                              padding: EdgeInsets.zero,
                              child: SizedBox(
                                height: 60,
                                width: 60,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: SvgPicture.asset(
                                    AppIcons.setting,
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'SETTINGS',
                            style: GoogleFonts.poppins(
                              color: AppColors.secondaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      // chat
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Neumorphic(
                            style: const NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: 5,
                              intensity: 0.75,
                            ),
                            child: NeumorphicButton(
                              onPressed: () {
                                pickImage();
                              },
                              padding: EdgeInsets.zero,
                              child: Container(
                                height: 70,
                                width: 70,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 33, 39, 93),
                                      Color.fromARGB(255, 255, 0, 123),
                                    ], // Adjust gradient colors as needed
                                    begin: Alignment
                                        .topLeft, // Adjust the gradient begin alignment as needed
                                    end: Alignment
                                        .bottomRight, // Adjust the gradient end alignment as needed
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: SvgPicture.asset(
                                    AppIcons.camera,
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'ADD MEDIA',
                            style: GoogleFonts.poppins(
                              color: AppColors.secondaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      // star
                      Column(
                        children: [
                          Neumorphic(
                            style: const NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.circle(),
                              depth: 5,
                              intensity: 0.75,
                            ),
                            child: NeumorphicButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditInfo()));
                              },
                              padding: EdgeInsets.zero,
                              child: SizedBox(
                                height: 60,
                                width: 60,
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: SvgPicture.asset(
                                    AppIcons.edit,
                                    height: 20,
                                    width: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            'EDIT INFO',
                            style: GoogleFonts.poppins(
                              color: AppColors.secondaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              //

              // images
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<UserProfileProvider>(
                    builder: (context, userProfileProvider, _) {
                      UserProfileModel? userProfileModel =
                          Provider.of<UserProfileProvider>(context,
                                  listen: false)
                              .currentUserProfile;
                      final alluploads = userProfileModel!.uploads;
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of items per row
                          crossAxisSpacing:
                              15, // Horizontal spacing between items
                          mainAxisSpacing: 15, // Vertical spacing between rows
                        ),
                        itemCount: alluploads!.length,
                        itemBuilder: (context, index) {
                          final upload = alluploads[index];
                          return Neumorphic(
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(16),
                              ),
                              depth: 5,
                              intensity: 0.75,
                            ),
                            child: Container(
                              height: 500,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: MemoryImage(base64ToImage(upload
                                      .file)), // Using NetworkImage for network images
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // about
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ]),
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
                  const profileButton(),
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
                    onPressed: () {
                      _authService
                          .signOut()
                          .then((value) => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              ));
                    },
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
                      children: [
                        Text(
                          'My Profile',
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
                        children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              children: [
                                // profile pic

                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      width: 200,
                                      child: Center(
                                        child: Container(
                                          height: 200,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(1000),
                                          ),
                                          child: Neumorphic(
                                            style: NeumorphicStyle(
                                              boxShape:
                                                  NeumorphicBoxShape.roundRect(
                                                      BorderRadius.circular(
                                                          1000)),
                                              depth: 10,
                                              intensity: 0.5,
                                            ),
                                            child: Image.asset(
                                              AppImages.profile,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

// details

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // name
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Sekar Lia, 25',
                                                style: AppTextStyles()
                                                    .primaryStyle,
                                              ),
                                              const SizedBox(width: 5),
                                              const Icon(Icons.female)
                                            ],
                                          ),

// location and other details
                                          const SizedBox(
                                            height: 10,
                                          ),

                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // location
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    color: AppColors
                                                        .secondaryColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Malang, Jawa Timur, Indonesia",
                                                    style: AppTextStyles()
                                                        .secondaryStyle,
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
// relationship status

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.female,
                                                    color: AppColors
                                                        .secondaryColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Male / Single",
                                                    style: AppTextStyles()
                                                        .secondaryStyle,
                                                  )
                                                ],
                                              ),

// seeking
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.search,
                                                    color: AppColors
                                                        .secondaryColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Seeking Male 21-39",
                                                    style: AppTextStyles()
                                                        .secondaryStyle,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
// details
                                const SizedBox(
                                  height: 15,
                                ),

// edit

                                const SizedBox(
                                  height: 25,
                                ),

                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: AppColors.backgroundColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        // heart
                                        Column(
                                          children: [
                                            Neumorphic(
                                              style: const NeumorphicStyle(
                                                boxShape:
                                                    NeumorphicBoxShape.circle(),
                                                depth: 5,
                                                intensity: 0.75,
                                              ),
                                              child: NeumorphicButton(
                                                padding: EdgeInsets.zero,
                                                child: SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: SvgPicture.asset(
                                                      AppIcons.setting,
                                                      height: 20,
                                                      width: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              'SETTINGS',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.secondaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // chat
                                        Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Neumorphic(
                                              style: const NeumorphicStyle(
                                                boxShape:
                                                    NeumorphicBoxShape.circle(),
                                                depth: 5,
                                                intensity: 0.75,
                                              ),
                                              child: NeumorphicButton(
                                                padding: EdgeInsets.zero,
                                                child: Container(
                                                  height: 70,
                                                  width: 70,
                                                  decoration:
                                                      const BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color.fromARGB(
                                                            255, 33, 39, 93),
                                                        Color.fromARGB(
                                                            255, 255, 0, 123),
                                                      ], // Adjust gradient colors as needed
                                                      begin: Alignment
                                                          .topLeft, // Adjust the gradient begin alignment as needed
                                                      end: Alignment
                                                          .bottomRight, // Adjust the gradient end alignment as needed
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: SvgPicture.asset(
                                                      AppIcons.camera,
                                                      height: 20,
                                                      width: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              'ADD MEDIA',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.secondaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // star
                                        Column(
                                          children: [
                                            Neumorphic(
                                              style: const NeumorphicStyle(
                                                boxShape:
                                                    NeumorphicBoxShape.circle(),
                                                depth: 5,
                                                intensity: 0.75,
                                              ),
                                              child: NeumorphicButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const EditInfo()));
                                                },
                                                padding: EdgeInsets.zero,
                                                child: SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: SvgPicture.asset(
                                                      AppIcons.edit,
                                                      height: 20,
                                                      width: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              'EDIT INFO',
                                              style: GoogleFonts.poppins(
                                                color: AppColors.secondaryColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                //

                                // images

                                SizedBox(
                                  width: double.infinity,
                                  height: 900,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            4, // Number of items per row
                                        crossAxisSpacing:
                                            15, // Horizontal spacing between items
                                        mainAxisSpacing:
                                            15, // Vertical spacing between rows
                                      ),
                                      itemCount: photoAssetPaths.length,
                                      itemBuilder: (context, index) {
                                        return Neumorphic(
                                          style: NeumorphicStyle(
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(16)),
                                            depth: 5,
                                            intensity: 0.75,
                                          ),
                                          child: Container(
                                            height: 500,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    photoAssetPaths[index]),
                                                fit: BoxFit.cover,
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
      child: SizedBox(
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
