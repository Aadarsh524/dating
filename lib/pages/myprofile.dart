import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dating/auth/db_client.dart';
import 'package:dating/auth/loginScreen.dart';
import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/document_verification_model.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/pages/editInfo.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
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
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');
  User? user = FirebaseAuth.instance.currentUser;

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';
  String selectedFileType = 'Citizenship';

  List<Uploads> allUploads = [];

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
  }

  Future<void> uploadDocument() async {
    try {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        throw Exception('Storage permission is required to upload the image.');
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        File imageFile = File(result.files.single.path!);
        String base64 = base64Encode(imageFile.readAsBytesSync());

        final document = DocumentVerificationModel(
            uid: user!.uid,
            verificationStatus: 1,
            documents: [
              Documents(
                  fileType: '',
                  file: base64,
                  fileName: 'Document',
                  timeStamp: DateTime.now().toString(),
                  documentType: selectedFileType)
            ]);

        await context
            .read<UserProfileProvider>()
            .uploadDocumentsForVerification(document);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> pickImage() async {
    try {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        throw Exception('Storage permission is required to upload the image.');
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        File imageFile = File(result.files.single.path!);
        String base64 = base64Encode(imageFile.readAsBytesSync());

        final newUpload = Uploads(
          id: '',
          file: base64,
          name: 'Post',
          uploadDate: DateTime.now().toString(),
        );

        await context
            .read<UserProfileProvider>()
            .uploadPost(newUpload, user!.uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return MobileProfile();
            } else {
              return DesktopProfile();
            }
          },
        ),
      ),
    );
  }

  Widget MobileProfile() {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // Implement refresh logic here
              await Future.delayed(const Duration(seconds: 1));
              setState(() {});
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  elevation: 0,
                  floating: true,
                  centerTitle: true,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child:
                        Text('My Profile', style: AppTextStyles().primaryStyle),
                  ),
                  backgroundColor: AppColors.backgroundColor,
                  leading: NeumorphicButton(
                    style: const NeumorphicStyle(
                      depth: 5,
                      intensity: 0.7,
                      boxShape: NeumorphicBoxShape.circle(),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  actions: [
                    NeumorphicButton(
                      style: const NeumorphicStyle(
                        depth: 5,
                        intensity: 0.7,
                        boxShape: NeumorphicBoxShape.circle(),
                      ),
                      onPressed: () async {
                        await authenticationProvider.signOut();
                        await DbClient().clearAllData();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: SvgPicture.asset(AppIcons.threedots),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildProfileImage(),
                        const SizedBox(height: 20),
                        _buildUserInfo(),
                        const SizedBox(height: 20),
                        _buildVerificationSection(),
                        const SizedBox(height: 20),
                        _buildQuickActions(),
                        const SizedBox(height: 20),
                        _buildPhotoGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Consumer<UserProfileProvider>(
      builder: (context, imageProvider, _) {
        UserProfileModel? userProfileModel = imageProvider.currentUserProfile;
        return Hero(
          tag: 'profileImage',
          child: GestureDetector(
            onTap: () {
              // Implement image view/edit functionality
            },
            child: Neumorphic(
              style: const NeumorphicStyle(
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.circle(),
                depth: 10,
                intensity: 0.5,
              ),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(
                      base64ToImage(
                          userProfileModel?.image ?? defaultBase64Avatar),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfo() {
    return Consumer<UserProfileProvider>(
      builder: (context, userDataProvider, _) {
        UserProfileModel? userProfileModel =
            userDataProvider.currentUserProfile;
        return Column(
          children: [
            Text(
              userProfileModel?.name ?? 'Add your Name',
              style: AppTextStyles().primaryStyle,
            ),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.location_on_outlined,
                userProfileModel?.address ?? 'Add your address'),
            _buildInfoRow(Icons.person,
                userProfileModel?.gender ?? 'Specify Your Gender'),
            _buildInfoRow(Icons.search, "Seeking Female 21-39"),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.secondaryColor, size: 20),
          const SizedBox(width: 10),
          Text(text, style: AppTextStyles().secondaryStyle),
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify',
            style: AppTextStyles()
                .primaryStyle
                .copyWith(color: AppColors.black.withOpacity(0.75))),
        const Divider(),
        Text('Verify that you are real',
            style: AppTextStyles()
                .secondaryStyle
                .copyWith(color: AppColors.black)),
        Row(
          children: [
            DropdownButton<String>(
              value: selectedFileType,
              items: ['Citizenship', 'Passport'].map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedFileType = newValue!;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: uploadDocument,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
              ),
              child: const Text('Select Image'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
              AppIcons.setting,
              'SETTINGS',
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingPage()))),
          _buildActionButton(AppIcons.camera, 'ADD MEDIA', pickImage,
              isGradient: true),
          _buildActionButton(
              AppIcons.edit,
              'EDIT INFO',
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const EditInfo()))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String icon, String label, VoidCallback onPressed,
      {bool isGradient = false}) {
    return Column(
      children: [
        Neumorphic(
          style: const NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
            depth: 5,
            intensity: 0.75,
          ),
          child: NeumorphicButton(
            onPressed: onPressed,
            padding: EdgeInsets.all(isGradient ? 0 : 15),
            child: Container(
              height: isGradient ? 70 : 60,
              width: isGradient ? 70 : 60,
              decoration: isGradient
                  ? const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF21275D), Color(0xFFFF007B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: SvgPicture.asset(icon,
                    height: 20,
                    width: 20,
                    color: isGradient ? Colors.white : null),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: GoogleFonts.poppins(
                color: AppColors.secondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, _) {
        UserProfileModel? userProfileModel =
            userProfileProvider.currentUserProfile;
        final allUploads = userProfileModel?.uploads?.reversed.toList() ?? [];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: allUploads.length,
          itemBuilder: (context, index) {
            final upload = allUploads[index];
            return GestureDetector(
              onTap: () {
                // Implement full-screen image view
              },
              child: Hero(
                tag: 'photo_${upload.id}',
                child: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                    depth: 5,
                    intensity: 0.75,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: MemoryImage(base64ToImage(upload.file)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfileProvider, _) {
        return userProfileProvider.isProfileLoading
            ? Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget DesktopProfile() {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
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
                        onPressed: () {
                          authenticationProvider.signOut().then((value) {
                            DbClient().clearAllData();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          });
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                              child:
                                                  Consumer<UserProfileProvider>(
                                                builder: (context,
                                                    imageProvider, _) {
                                                  UserProfileModel?
                                                      userProfileModel =
                                                      Provider.of<UserProfileProvider>(
                                                              context,
                                                              listen: false)
                                                          .currentUserProfile;

                                                  return Neumorphic(
                                                    style: NeumorphicStyle(
                                                      boxShape:
                                                          NeumorphicBoxShape
                                                              .roundRect(
                                                        BorderRadius.circular(
                                                            1000),
                                                      ),
                                                      depth: 10,
                                                      intensity: 0.5,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1000),
                                                      child: userProfileModel!
                                                                      .image !=
                                                                  null &&
                                                              userProfileModel
                                                                      .image !=
                                                                  ''
                                                          ? Image.memory(
                                                              base64ToImage(
                                                                  userProfileModel
                                                                      .image),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.memory(
                                                              base64ToImage(
                                                                  defaultBase64Avatar),
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Consumer<UserProfileProvider>(
                                            builder:
                                                (context, userDataProvider, _) {
                                              UserProfileModel?
                                                  userProfileModel =
                                                  Provider.of<UserProfileProvider>(
                                                          context,
                                                          listen: false)
                                                      .currentUserProfile;
                                              String address = '';
                                              if (userProfileModel!.address !=
                                                      null &&
                                                  userProfileModel.address !=
                                                      '') {
                                                address =
                                                    userProfileModel.address!;
                                              } else {
                                                address = 'Add your address';
                                              }
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // name
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        userProfileModel.name ??
                                                            'Add your Name',
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
                                                    children: [
                                                      // location
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            color: AppColors
                                                                .secondaryColor,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            address,
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
                                                            MainAxisAlignment
                                                                .center,
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
                                                            userProfileModel
                                                                    .gender ??
                                                                'Specify Your Gender',
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
                                                            MainAxisAlignment
                                                                .center,
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
                                                            "Seeking Female 21-39",
                                                            style: AppTextStyles()
                                                                .secondaryStyle,
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              );
                                            },
                                          ),
                                        ),

                                        // details
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
                                                    boxShape: NeumorphicBoxShape
                                                        .circle(),
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
                                                            const EdgeInsets
                                                                .all(15),
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
                                                    color: AppColors
                                                        .secondaryColor,
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
                                                    boxShape: NeumorphicBoxShape
                                                        .circle(),
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
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            Color.fromARGB(255,
                                                                33, 39, 93),
                                                            Color.fromARGB(255,
                                                                255, 0, 123),
                                                          ], // Adjust gradient colors as needed
                                                          begin: Alignment
                                                              .topLeft, // Adjust the gradient begin alignment as needed
                                                          end: Alignment
                                                              .bottomRight, // Adjust the gradient end alignment as needed
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
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
                                                    color: AppColors
                                                        .secondaryColor,
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
                                                    boxShape: NeumorphicBoxShape
                                                        .circle(),
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
                                                            const EdgeInsets
                                                                .all(15),
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
                                                    color: AppColors
                                                        .secondaryColor,
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

                                    SizedBox(
                                      width: double.infinity,
                                      height: 900,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Consumer<UserProfileProvider>(
                                          builder: (context,
                                              userProfileProvider, _) {
                                            UserProfileModel? userProfileModel =
                                                Provider.of<UserProfileProvider>(
                                                        context,
                                                        listen: false)
                                                    .currentUserProfile;
                                            final alluploads =
                                                userProfileModel!.uploads;
                                            if (alluploads != null) {
                                              List<Uploads> reversedUploads =
                                                  alluploads.reversed.toList();
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
                                                itemCount: alluploads.length,
                                                itemBuilder: (context, index) {
                                                  final upload =
                                                      reversedUploads[index];
                                                  return Neumorphic(
                                                    style: NeumorphicStyle(
                                                      boxShape:
                                                          NeumorphicBoxShape
                                                              .roundRect(
                                                        BorderRadius.circular(
                                                            16),
                                                      ),
                                                      depth: 5,
                                                      intensity: 0.75,
                                                    ),
                                                    child: Container(
                                                      height: 500,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        image: DecorationImage(
                                                          image: MemoryImage(
                                                              base64ToImage(upload
                                                                  .file)), // Using NetworkImage for network images
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
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

                                    //

                                    // images
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
          Consumer<UserProfileProvider>(
            builder: (context, userProfileProvider, _) {
              return userProfileProvider.isProfileLoading
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
    );
  }
}

// profile button
class profileButton extends StatelessWidget {
  const profileButton({
    super.key,
  });

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: Consumer<UserProfileProvider>(
        builder: (context, imageProvider, _) {
          UserProfileModel? userProfileModel =
              Provider.of<UserProfileProvider>(context, listen: false)
                  .currentUserProfile;

          return Neumorphic(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(1000),
              ),
              depth: 10,
              intensity: 0.5,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: userProfileModel!.image != null &&
                      userProfileModel.image != ''
                  ? Image.memory(
                      base64ToImage(userProfileModel.image),
                      fit: BoxFit.cover,
                    )
                  : Image.memory(
                      base64ToImage(defaultBase64Avatar),
                      fit: BoxFit.cover,
                    ),
            ),
          );
        },
      ),
    );
  }
}
