import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dating/datamodel/chat/chat_room_model.dart';
import 'package:dating/datamodel/dashboard_response_model.dart';
import 'package:dating/pages/chatMobileOnly/chatscreen.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/providers/chat_provider/chat_room_provider.dart';
import 'package:dating/providers/interaction_provider/favourite_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/favourite_button.dart';
import 'package:dating/widgets/like_button.dart';
import 'package:dating/widgets/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  DashboardResponseModel dashboardresponsemodel;
  ProfilePage({super.key, required this.dashboardresponsemodel});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String age = 'AGE';
  bool isProfileLiked = false;
  List<String?> photo = [];

  int _selectedPhotoIndex = 0;

  void _selectPhoto(int index) {
    setState(() {
      _selectedPhotoIndex = index;
    });
  }

  void _loadPhoto() async {
    await Future.delayed(Duration(seconds: 2));
    final allUploads = widget.dashboardresponsemodel.uploads;
    List<Uploads> reversedUploads = allUploads!.reversed.toList();

    setState(() {
      photo.clear(); // Clear existing photos if needed
      photo.addAll(reversedUploads.map((upload) => upload.file!));
    });

    log("This is the list of photos: $photo");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadPhoto();
    final favouritesProvider =
        Provider.of<FavouritesProvider>(context, listen: false);

    favouritesProvider
        .checkIfCurrentProfileIsFavourite(widget.dashboardresponsemodel.uid!);
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
    final alluploads = widget.dashboardresponsemodel.uploads;

    List<Uploads> reversedUploads = alluploads!.reversed.toList();

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
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: ListView(
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        enableInfiniteScroll: false,
                        height: 250,
                        viewportFraction: 1.0,
                        autoPlay: false,
                        autoPlayInterval: const Duration(seconds: 3),
                      ),
                      items: reversedUploads.map((imagePath) {
                        return Builder(
                          builder: (BuildContext context) {
                            return InstaImageViewer(
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(
                                      base64ToImage(imagePath.file!),
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                child: const Icon(
                                  Icons.report_gmailerrorred,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              // SizedBox(
                              //   width: MediaQuery.sizeOf(context).width * .40,
                              // ),
                              Positioned(
                                left: 100,
                                child: Expanded(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: reversedUploads.length,
                                      itemBuilder: (context, index) {
                                        log(reversedUploads.length.toString());
                                        return const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ),
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1000),
                                  color: Colors.black.withOpacity(0.75),
                                ),
                                child: const Icon(
                                  Icons.fullscreen,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // details
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${widget.dashboardresponsemodel.name}, ${widget.dashboardresponsemodel.age}",
                              style: AppTextStyles().primaryStyle,
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.female)
                          ],
                        ),

                        // active status

                        Row(
                          children: [
                            widget.dashboardresponsemodel.userStatus == 'active'
                                ? const Icon(Icons.circle,
                                    size: 8, color: Colors.green)
                                : const Icon(Icons.circle,
                                    size: 8, color: AppColors.secondaryColor),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '${widget.dashboardresponsemodel.userStatus}',
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        )
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
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.secondaryColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${widget.dashboardresponsemodel.address}",
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        // relationship status

                        Row(
                          children: [
                            widget.dashboardresponsemodel.gender == 'female'
                                ? const Icon(
                                    Icons.female,
                                    color: AppColors.secondaryColor,
                                  )
                                : const Icon(
                                    Icons.male,
                                    color: AppColors.secondaryColor,
                                  ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${widget.dashboardresponsemodel.gender}"
                                  .toUpperCase(),
                              style: AppTextStyles().secondaryStyle,
                            )
                          ],
                        ),

                        // seeking
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: AppColors.secondaryColor,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Seeking ${widget.dashboardresponsemodel.seeking?.gender} ${widget.dashboardresponsemodel.seeking?.fromAge} ",
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
              const SizedBox(
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

// text about

                    Text(
                      "${widget.dashboardresponsemodel.bio}",
                      style: AppTextStyles().secondaryStyle,
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 200,
              ),
            ],
          ),
        ),
      ]),
      bottomSheet: Container(
        height: 100,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // heart
            LikeButton(
              currentUserId: user!.uid,
              likedUserId: widget.dashboardresponsemodel.uid!,
            ),

            // chat
            Neumorphic(
              style: const NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                depth: 5,
                intensity: 0.75,
              ),
              child: NeumorphicButton(
                onPressed: () {
                  final chatRoomProvider = context.read<ChatRoomProvider>();

                  chatRoomProvider
                      .fetchChatRoomToCheckUser(context, user!.uid,
                          widget.dashboardresponsemodel.uid!)
                      .then((value) {
                    if (value != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatScreemMobile(
                                  chatID: value,
                                  chatRoomModel: EndUserDetails(
                                      name: widget.dashboardresponsemodel.name,
                                      profileImage:
                                          widget.dashboardresponsemodel.image),
                                  recieverId:
                                      widget.dashboardresponsemodel.uid!,
                                )),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatScreemMobile(
                                  chatID: '',
                                  chatRoomModel: EndUserDetails(
                                      name: widget.dashboardresponsemodel.name,
                                      profileImage:
                                          widget.dashboardresponsemodel.image),
                                  recieverId:
                                      widget.dashboardresponsemodel.uid!,
                                )),
                      );
                    }
                  });
                },
                child: Consumer<ChatRoomProvider>(
                  builder: (context, chatRoomProvider, child) {
                    return SizedBox(
                      height: 65,
                      width: 65,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: chatRoomProvider.isChatRoomLoading
                            ? const CircularProgressIndicator()
                            : SvgPicture.asset(
                                AppIcons.chatfilled,
                                height: 20,
                                width: 20,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // star
            FavouriteButton(
                currentUserId: user!.uid,
                favUser: widget.dashboardresponsemodel.uid!),
          ],
        ),
      ),
    );
  }

  Widget DesktopProfile() {
    final alluploads = widget.dashboardresponsemodel.uploads;

    List<Uploads> reversedUploads = alluploads!.reversed.toList();

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
                    onPressed: () {},
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
                          CupertinoPageRoute(
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
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.vertical,
                              children: [
                                // Profile photo selector
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
                                      child: photo.isEmpty
                                          ? ShimmerSkeleton(
                                              count: 1,
                                              height: 300,
                                            )
                                          : Image.memory(
                                              base64ToImage(
                                                  photo[_selectedPhotoIndex]!),
                                              width: 500,
                                              height: 300,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Grid of photos
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 500,
                                    width: 200,
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 20.0,
                                        mainAxisSpacing: 8.0,
                                      ),
                                      itemCount: photo.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            _selectPhoto(index);

                                            log(_selectedPhotoIndex.toString());
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Opacity(
                                                opacity:
                                                    _selectedPhotoIndex == index
                                                        ? 1
                                                        : 0.5,
                                                child: Image.memory(
                                                  base64ToImage(photo[index]!),
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
              const SizedBox(
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
                              LikeButton(
                                currentUserId: user!.uid,
                                likedUserId: widget.dashboardresponsemodel.uid!,
                              ),

                              // chat
                              Neumorphic(
                                style: const NeumorphicStyle(
                                  boxShape: NeumorphicBoxShape.circle(),
                                  depth: 5,
                                  intensity: 0.75,
                                ),
                                child: NeumorphicButton(
                                  child: SizedBox(
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
                              FavouriteButton(
                                  currentUserId: user!.uid,
                                  favUser: widget.dashboardresponsemodel.uid!)
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
                            child: const Icon(
                              Icons.report_gmailerrorred,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${widget.dashboardresponsemodel.name}, ${widget.dashboardresponsemodel.age}',
                                    style: AppTextStyles().primaryStyle,
                                  ),
                                  const SizedBox(width: 5),
                                  widget.dashboardresponsemodel.gender ==
                                          "female"
                                      ? Icon(Icons.female)
                                      : Icon(Icons.male)
                                ],
                              ),

// active status

                              Row(
                                children: [
                                  widget.dashboardresponsemodel.userStatus ==
                                          'active'
                                      ? const Icon(Icons.circle,
                                          size: 8, color: Colors.green)
                                      : const Icon(Icons.circle,
                                          size: 8,
                                          color: AppColors.secondaryColor),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    '${widget.dashboardresponsemodel.userStatus}',
                                    style: AppTextStyles().secondaryStyle,
                                  )
                                ],
                              )
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
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.secondaryColor,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${widget.dashboardresponsemodel.address}"
                                            .isEmpty
                                        ? 'N/A'
                                        : "${widget.dashboardresponsemodel.address}",
                                    style: AppTextStyles().secondaryStyle,
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
// relationship status

                              Row(
                                children: [
                                  widget.dashboardresponsemodel.gender ==
                                          'female'
                                      ? const Icon(
                                          Icons.female,
                                          color: AppColors.secondaryColor,
                                        )
                                      : const Icon(
                                          Icons.male,
                                          color: AppColors.secondaryColor,
                                        ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${widget.dashboardresponsemodel.gender}",
                                    style: AppTextStyles().secondaryStyle,
                                  )
                                ],
                              ),

// seeking
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: AppColors.secondaryColor,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Seeking ${widget.dashboardresponsemodel.seeking!.gender} ${widget.dashboardresponsemodel.seeking!.fromAge}-${widget.dashboardresponsemodel.seeking!.toAge}",
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
                    const SizedBox(
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

// text about

                          Text(
                            '${widget.dashboardresponsemodel.bio}'.isEmpty
                                ? 'User yet to add.'
                                : '${widget.dashboardresponsemodel.bio}',
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
