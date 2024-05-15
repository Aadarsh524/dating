import 'dart:convert';

import 'dart:io';
import 'dart:typed_data';

import 'package:dating/auth/db_client.dart';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/pages/myprofile.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:dating/providers/user_profile_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  User? user = FirebaseAuth.instance.currentUser;

  String? fileName;
  PlatformFile? imagefile;

  // for name
  final TextEditingController _controllerName = TextEditingController();
  String _textName = 'Enter Name';
  bool _isEditingName = false;

  // for address
  final TextEditingController _controllerAddress = TextEditingController();
  String _textAddress = 'Your Address';
  bool _isEditingAddress = false;

// for address
  final TextEditingController _controllerBio = TextEditingController();
  String _textBio = 'Write about yourself';
  bool _isEditingBio = false;

// for address
  final TextEditingController _controllerInterests = TextEditingController();
  String _textInterests = 'list your hobbies';
  bool _isEditingInterests = false;

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';

  Uint8List? _imageBytes;
  List<Uploads> allUploads = [];

  void deletePost(String? postId) async {
    print(postId);
    await context.read<LoadingProvider>().setLoading(true);

    try {
      await context.read<UserProfileProvider>().deletePost(postId!);
    } catch (e) {
      return;
    } finally {
      context.read<LoadingProvider>().setLoading(false);
    }
  }

  @override
  void initState() {
    UserProfileModel? userProfileModel =
        Provider.of<UserProfileProvider>(context, listen: false)
            .currentUserProfile;

    if (userProfileModel?.name != null && userProfileModel!.name!.isNotEmpty) {
      _textName = userProfileModel.name!;
      _controllerName.text = _textName;
    } else {
      _textName = "Enter Name";
    }

    if (userProfileModel?.address != null &&
        userProfileModel!.address!.isNotEmpty) {
      _textAddress = userProfileModel.address!;
      _controllerAddress.text = _textAddress;
    } else {
      _textAddress = 'Enter Address';
    }

    if (userProfileModel?.bio != null && userProfileModel!.bio!.isNotEmpty) {
      _textBio = userProfileModel.bio!;
      _controllerBio.text = _textBio;
    } else {
      _textBio = 'Enter Bio';
    }

    if (userProfileModel?.interests != null &&
        userProfileModel!.interests!.isNotEmpty) {
      _textInterests = userProfileModel.interests!;
      _controllerInterests.text = _textInterests;
    } else {
      _textInterests = 'Enter Interests';
    }

    if (userProfileModel?.image != null &&
        userProfileModel!.image!.isNotEmpty) {
      _imageBytes = base64ToImage(userProfileModel.image);
    } else {
      _imageBytes = base64ToImage(defaultBase64Avatar);
    }

    _controllerName.text = _textName;
    _controllerAddress.text = _textAddress;
    _controllerBio.text = _textBio;
    _controllerInterests.text = _textInterests;

    super.initState();
  }

  Future<void> _saveChanges() async {
    // Update data in the provider
    UserProfileModel? userProfileModel =
        Provider.of<UserProfileProvider>(context, listen: false)
            .currentUserProfile;

    _textName = _controllerName.text;
    _textAddress = _controllerAddress.text;
    _textBio = _controllerBio.text;
    _textInterests = _controllerInterests.text;

    final UserProfileModel newUser = UserProfileModel(
      uid: user!.uid,
      name: _textName,
      email: userProfileModel!.email ?? '',
      gender: userProfileModel.gender ?? '',
      image: userProfileModel.image ?? '',
      age: userProfileModel.age ?? '',
      bio: _textBio,
      address: _textAddress,
      interests: _textInterests,
      seeking: Seeking(age: '', gender: ''),
      uploads: [],
    );

    await context
        .read<UserProfileProvider>()
        .updateUserProfile(context, newUser);
    await DbClient().setData(dbKey: "userName", value: newUser.name ?? '');

    // Exit editing mode
    setState(() {
      _isEditingName = false;
      _isEditingAddress = false;
      _isEditingBio = false;
      _isEditingInterests = false;
    });
  }

  void _cancelChanges() {
    // Discard changes and exit editing mode
    setState(() {
      _isEditingName = false;
      _isEditingAddress = false;
      _isEditingBio = false;
      _isEditingInterests = false;
      // Reset text fields to previous values
      _controllerName.text = _textName;
      _controllerAddress.text = _textAddress;
      _controllerBio.text = _textBio;
      _controllerInterests.text = _textInterests;
    });
  }

  void pickImage() async {
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
      _imageBytes = base64ToImage(base64);
      await context
          .read<UserProfileProvider>()
          .updateProfileImage(context, base64, user!.uid);
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

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
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
      body: Stack(
        children: [
          ListView(children: [
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
                    'Edit Profile',
                    style: AppTextStyles().primaryStyle,
                  ),

                  // view icon

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const MyProfilePage(),
                        ),
                      );
                    },
                    child: Text(
                      'View',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF707070),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 200,
              width: 200,
              child: Center(
                child: GestureDetector(
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(1000)),
                      depth: 10,
                      intensity: 0.5,
                    ),
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1000),
                        image: DecorationImage(
                          image: MemoryImage(_imageBytes!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      padding: const EdgeInsets.all(60),
                      child: SvgPicture.asset(
                        AppIcons.editphoto,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // details

            const SizedBox(
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

                  const SizedBox(
                    height: 10,
                  ),
                  // seperator
                  Container(
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 0.50,
                          strokeAlign: BorderSide.strokeAlignCenter,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
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
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: AppTextStyles().secondaryStyle,
                                controller: _controllerName,
                                autofocus: true,
                              )
                            : Consumer<UserProfileProvider>(
                                builder: (context, userProfileProvider, child) {
                                return Text(
                                  _textName,
                                  style: AppTextStyles().secondaryStyle,
                                );
                              }),
                      ),
                      IconButton(
                        icon: Icon(
                          _isEditingName ? Icons.save : Icons.edit,
                          size: 20,
                          color: AppColors.secondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isEditingName) {
                              // Save changes
                              if (_controllerBio.text != _textName) {
                                _textName = _controllerName.text;
                                // context.read<UserProvider>().updateName(textName);
                              }
                            }
                            _isEditingName = !_isEditingName;
                            if (_isEditingName) {
                              // Start editing
                              _controllerName.text = _textName;
                            }
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
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: AppTextStyles().secondaryStyle,
                                controller: _controllerAddress,
                                autofocus: true,
                              )
                            : Text(
                                _textAddress,
                                style: AppTextStyles().secondaryStyle,
                              ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isEditingAddress ? Icons.save : Icons.edit,
                          size: 20,
                          color: AppColors.secondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isEditingAddress) {
                              // Save changes
                              if (_controllerAddress.text != _textAddress) {
                                _textAddress = _controllerAddress.text;
                                // context.read<UserProvider>().updateName(textName);
                                DbClient().resetData(dbKey: 'userName');
                                DbClient().setData(
                                    dbKey: 'userName',
                                    value: _controllerName.text);
                              }
                            }
                            _isEditingAddress = !_isEditingAddress;
                            if (_isEditingAddress) {
                              // Start editing
                              _controllerAddress.text = _textAddress;
                            }
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
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: AppTextStyles().secondaryStyle,
                                controller: _controllerBio,
                                autofocus: true,
                              )
                            : Text(
                                _textBio,
                                style: AppTextStyles().secondaryStyle,
                              ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isEditingBio ? Icons.save : Icons.edit,
                          size: 20,
                          color: AppColors.secondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isEditingBio) {
                              // Save changes
                              if (_controllerBio.text != _textBio) {
                                _textBio = _controllerAddress.text;
                                // context.read<UserProvider>().updateName(textName);
                              }
                            }
                            _isEditingBio = !_isEditingBio;
                            if (_isEditingBio) {
                              // Start editing
                              _controllerBio.text = _textBio;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // mored details
            const SizedBox(
              height: 25,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'More',
                      style: AppTextStyles().primaryStyle.copyWith(
                            color: AppColors.black.withOpacity(0.75),
                          ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    // seperator
                    Container(
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.50,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
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
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: AppTextStyles().secondaryStyle,
                                  controller: _controllerInterests,
                                  autofocus: true,
                                )
                              : Text(
                                  _textInterests,
                                  style: AppTextStyles().secondaryStyle,
                                ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isEditingInterests ? Icons.save : Icons.edit,
                            size: 20,
                            color: AppColors.secondaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isEditingInterests) {
                                // Save changes
                                if (_controllerInterests.text !=
                                    _textInterests) {
                                  _textInterests = _controllerAddress.text;
                                  // context.read<UserProvider>().updateName(textName);
                                }
                              }
                              _isEditingInterests = !_isEditingInterests;
                              if (_isEditingInterests) {
                                // Start editing
                                _controllerInterests.text = _textInterests;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ]),
            ),
            const SizedBox(
              height: 50,
            ),
            // images

            SizedBox(
              width: double.infinity,
              height: 400,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<UserProfileProvider>(
                  builder: (context, photoProvider, _) {
                    UserProfileModel? userProfileModel =
                        Provider.of<UserProfileProvider>(context, listen: false)
                            .currentUserProfile;
                    final alluploads = userProfileModel!.uploads;

                    if (alluploads != null) {
                      List<Uploads> reversedUploads =
                          alluploads.reversed.toList();
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of items per row
                          crossAxisSpacing:
                              15, // Horizontal spacing between items
                          mainAxisSpacing: 15, // Vertical spacing between rows
                        ),
                        itemCount: alluploads.length,
                        itemBuilder: (context, index) {
                          final upload = reversedUploads[index];
                          print(upload.file);
                          print(upload.name);
                          print(upload.id);
                          print(upload.uploadDate);

                          return Stack(
                            children: [
                              Neumorphic(
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
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  onPressed: () {
                                    print(upload.id);
                                    deletePost(upload.id);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),

            // about
            const SizedBox(
              height: 25,
            ),
          ]),
          Consumer<LoadingProvider>(
            builder: (context, loadingProvider, _) {
              return loadingProvider.isLoading
                  ? Container(
                      color: Colors.black.withOpacity(
                          0.5), // Add background color with opacity
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container();
            },
          ),
        ],
      ),
      bottomSheet: Container(
        height: 60,
        width: double.infinity,
        decoration: const BoxDecoration(
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
                onPressed: () {
                  _cancelChanges();
                },
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
                  _saveChanges();
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
          ],
        ),
      ),
    );
  }

  Widget DesktopProfile() {
    return Scaffold(
      body: Stack(
        children: [
          Column(children: [
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
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                        ),
                        labelText: null,
                      ),

                      // settings icon

                      ButtonWithLabel(
                        text: null,
                        onPressed: () {},
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
                    offset:
                        const Offset(0, 25), // horizontal and vertical offset
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

                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      pickImage();
                                                    },
                                                    child: Neumorphic(
                                                      style: NeumorphicStyle(
                                                        boxShape: NeumorphicBoxShape
                                                            .roundRect(
                                                                BorderRadius
                                                                    .circular(
                                                                        1000)),
                                                        depth: 10,
                                                        intensity: 0.5,
                                                      ),
                                                      child: Container(
                                                        height: 200,
                                                        width: 200,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      1000),
                                                          image:
                                                              DecorationImage(
                                                            image: MemoryImage(
                                                                _imageBytes!),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(60),
                                                        child: SvgPicture.asset(
                                                          AppIcons.editphoto,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 100,
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                height: 900,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20),
                                                  child: Consumer<
                                                      UserProfileProvider>(
                                                    builder: (context,
                                                        photoProvider, _) {
                                                      UserProfileModel?
                                                          userProfileModel =
                                                          Provider.of<UserProfileProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .currentUserProfile;
                                                      final alluploads =
                                                          userProfileModel!
                                                              .uploads;

                                                      if (alluploads != null) {
                                                        List<Uploads>
                                                            reversedUploads =
                                                            alluploads.reversed
                                                                .toList();
                                                        return GridView.builder(
                                                          gridDelegate:
                                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount:
                                                                4, // Number of items per row
                                                            crossAxisSpacing:
                                                                15, // Horizontal spacing between items
                                                            mainAxisSpacing:
                                                                15, // Vertical spacing between rows
                                                          ),
                                                          itemCount:
                                                              alluploads.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final upload =
                                                                reversedUploads[
                                                                    index];
                                                            print(upload.file);
                                                            print(upload.name);
                                                            print(upload.id);
                                                            print(upload
                                                                .uploadDate);

                                                            return Stack(
                                                              children: [
                                                                Neumorphic(
                                                                  style:
                                                                      NeumorphicStyle(
                                                                    boxShape:
                                                                        NeumorphicBoxShape
                                                                            .roundRect(
                                                                      BorderRadius
                                                                          .circular(
                                                                              16),
                                                                    ),
                                                                    depth: 5,
                                                                    intensity:
                                                                        0.75,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    height: 500,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
                                                                      image:
                                                                          DecorationImage(
                                                                        image: MemoryImage(
                                                                            base64ToImage(upload.file)), // Using NetworkImage for network images
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  top: 10,
                                                                  right: 10,
                                                                  child:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      print(upload
                                                                          .id);
                                                                      deletePost(
                                                                          upload
                                                                              .id);
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        return Container();
                                                      }
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
                                            padding: const EdgeInsets.symmetric(
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

                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                // seperator
                                                Container(
                                                  decoration:
                                                      const ShapeDecoration(
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
                                                const SizedBox(
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Expanded(
                                                      child: _isEditingName
                                                          ? TextField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                ),
                                                              ),
                                                              style: AppTextStyles()
                                                                  .secondaryStyle,
                                                              controller:
                                                                  _controllerName,
                                                              autofocus: true,
                                                            )
                                                          : Consumer<
                                                                  UserProfileProvider>(
                                                              builder: (context,
                                                                  userProfileProvider,
                                                                  child) {
                                                              return Text(
                                                                _textName,
                                                                style: AppTextStyles()
                                                                    .secondaryStyle,
                                                              );
                                                            }),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        _isEditingName
                                                            ? Icons.save
                                                            : Icons.edit,
                                                        size: 20,
                                                        color: AppColors
                                                            .secondaryColor,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (_isEditingName) {
                                                            // Save changes
                                                            if (_controllerBio
                                                                    .text !=
                                                                _textName) {
                                                              _textName =
                                                                  _controllerName
                                                                      .text;
                                                              // context.read<UserProvider>().updateName(textName);
                                                            }
                                                          }
                                                          _isEditingName =
                                                              !_isEditingName;
                                                          if (_isEditingName) {
                                                            // Start editing
                                                            _controllerName
                                                                    .text =
                                                                _textName;
                                                          }
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Expanded(
                                                      child: _isEditingAddress
                                                          ? TextField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                ),
                                                              ),
                                                              style: AppTextStyles()
                                                                  .secondaryStyle,
                                                              controller:
                                                                  _controllerAddress,
                                                              autofocus: true,
                                                            )
                                                          : Text(
                                                              _textAddress,
                                                              style: AppTextStyles()
                                                                  .secondaryStyle,
                                                            ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        _isEditingAddress
                                                            ? Icons.save
                                                            : Icons.edit,
                                                        size: 20,
                                                        color: AppColors
                                                            .secondaryColor,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (_isEditingAddress) {
                                                            // Save changes
                                                            if (_controllerAddress
                                                                    .text !=
                                                                _textAddress) {
                                                              _textAddress =
                                                                  _controllerAddress
                                                                      .text;
                                                              // context.read<UserProvider>().updateName(textName);
                                                              DbClient().resetData(
                                                                  dbKey:
                                                                      'userName');
                                                              DbClient().setData(
                                                                  dbKey:
                                                                      'userName',
                                                                  value:
                                                                      _controllerName
                                                                          .text);
                                                            }
                                                          }
                                                          _isEditingAddress =
                                                              !_isEditingAddress;
                                                          if (_isEditingAddress) {
                                                            // Start editing
                                                            _controllerAddress
                                                                    .text =
                                                                _textAddress;
                                                          }
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Expanded(
                                                      child: _isEditingBio
                                                          ? TextField(
                                                              decoration:
                                                                  const InputDecoration(
                                                                border:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                ),
                                                              ),
                                                              style: AppTextStyles()
                                                                  .secondaryStyle,
                                                              controller:
                                                                  _controllerBio,
                                                              autofocus: true,
                                                            )
                                                          : Text(
                                                              _textBio,
                                                              style: AppTextStyles()
                                                                  .secondaryStyle,
                                                            ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        _isEditingBio
                                                            ? Icons.save
                                                            : Icons.edit,
                                                        size: 20,
                                                        color: AppColors
                                                            .secondaryColor,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          if (_isEditingBio) {
                                                            // Save changes
                                                            if (_controllerBio
                                                                    .text !=
                                                                _textBio) {
                                                              _textBio =
                                                                  _controllerAddress
                                                                      .text;
                                                              // context.read<UserProvider>().updateName(textName);
                                                            }
                                                          }
                                                          _isEditingBio =
                                                              !_isEditingBio;
                                                          if (_isEditingBio) {
                                                            // Start editing
                                                            _controllerBio
                                                                    .text =
                                                                _textBio;
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
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
          Consumer<LoadingProvider>(
            builder: (context, loadingProvider, _) {
              return loadingProvider.isLoading
                  ? Container(
                      color: Colors.black.withOpacity(
                          0.5), // Add background color with opacity
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container();
            },
          ),
        ],
      ),
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
                onPressed: () {
                  _cancelChanges();
                },
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
                  _saveChanges();
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
