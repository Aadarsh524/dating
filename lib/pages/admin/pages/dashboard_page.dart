import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dating/backend/MongoDB/constants.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/providers/admin_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
// for date picker
  String _fromDate = 'From';
  String _toDate = 'To';

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = "${picked.toLocal()}".split(' ')[0];
        } else {
          _toDate = "${picked.toLocal()}".split(' ')[0];
        }
      });
    }
  }

  // for status
  String? _selectedStatus = 'Status';

  final List<String> _statuses = [
    'Active',
    'Inactive',
    'Blocked',
  ];

//  // Sample user data

  @override
  void initState() {
    super.initState();
    // Fetch the profile data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardProvider>(context, listen: false)
          .fetchUsers(1, context);
    });
  }

  Uint8List base64ToImage(String? base64String) {
    return base64Decode(base64String!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          // top filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              // for filterr icon and statuses
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // status
// filter
                Row(
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2, color: Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF7879F1),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          value: _selectedStatus,
                          icon: SvgPicture.asset(
                            AppIcons
                                .chevronoutline, // Replace with your SVG path
                            height: 14,
                            color: const Color.fromARGB(255, 120, 120, 241),
                          ),
                          elevation: 0,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStatus = newValue!;
                            });
                          },
                          items: <String>['Status', ..._statuses]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),
                    // date bick rom

                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2, color: Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fromDate,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF868690),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.20,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              AppIcons.calendar,
                              height: 14,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // swap icon
                    SvgPicture.asset(AppIcons.swap),

                    // to date picker

                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 2, color: Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _toDate,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF868690),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.20,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SvgPicture.asset(
                              AppIcons.calendar,
                              height: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

// filter icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(AppIcons.filter),
                      Text(
                        'Filter',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

// users

          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: Consumer<AdminDashboardProvider>(
                builder: (context, adminProvider, _) {
              return adminProvider.isAdminDataLoading
                  ? const ShimmerSkeleton(count: 4, height: 80)
                  : Consumer<AdminDashboardProvider>(
                      builder: (context, adminProvider, _) {
                      List<UserProfileModel>? data = adminProvider.usersList;

                      if (data == null || data.isEmpty) {
                        return const Center(child: Text('No data available'));
                      }
                      log("${data.length}");
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final user = data[index];
                          // for subscription color
                          Color textColor;
                          switch (user.subscriptionStatus) {
                            case '+Basic':
                              textColor = Colors.green;
                              break;
                            case '+Plus':
                              textColor = Colors.blue;
                              break;
                            case '+Gold':
                              textColor =
                                  Colors.amber; // Or any shade of gold color
                              break;
                            default:
                              textColor = Colors.black;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, bottom: 10),
                            child: Container(
                              //  padding
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: Color(0xFFEAE7FF),
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // profile pic and user name
                                    SizedBox(
                                      width: 200,
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              image: DecorationImage(
                                                image: MemoryImage(
                                                  base64ToImage(user.image ??
                                                      defaultBase64Avatar),
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          // user name
                                          const SizedBox(
                                            width: 30,
                                          ),
                                          Text(
                                            user.name!,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF04103B),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    //

                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        user.uid!,
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF797D8C),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // SizedBox(
                                    //   width: 50,
                                    //   child: Image.network(
                                    //     user.countryFlagUrl,
                                    //     height: 20,
                                    //     width: 20,
                                    //   ),
                                    // ),

                                    SizedBox(
                                      width: 50,
                                      child: user.isVerified!
                                          ? SvgPicture.asset(AppIcons.verified)
                                          : SvgPicture.asset(
                                              AppIcons.unverified),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        user.subscriptionStatus!,
                                        style: GoogleFonts.poppins(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    // three dots icon
                                    PopupMenuButton<int>(
                                      icon: SvgPicture.asset(AppIcons.dots),
                                      onSelected: (int result) {
                                        switch (result) {
                                          case 0:
                                            _showUserBlockDialog(
                                                user.uid!, context);
                                            break;
                                          case 1:
                                            _showSendMessageDialog(context);
                                            break;
                                          case 2:
                                            // Handle alert action
                                            break;
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<int>>[
                                        PopupMenuItem<int>(
                                          value: 0,
                                          child: ListTile(
                                            leading: const Icon(Icons.block,
                                                color: AppColors.blue),
                                            title: Text(
                                              'Block',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF1F192F),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem<int>(
                                          value: 1,
                                          child: ListTile(
                                            leading: const Icon(Icons.message,
                                                color: AppColors.blue),
                                            title: Text(
                                              'Send Message',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF1F192F),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem<int>(
                                          value: 2,
                                          child: ListTile(
                                            leading: const Icon(Icons.warning,
                                                color: AppColors.blue),
                                            title: Text(
                                              'Alert',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF1F192F),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    });
            }),
          ),
        ],
      ),
    );
  }
}

// Define a User data model
class User {
  final String name;
  final String id;
  final String photoUrl;
  final String countryFlagUrl;
  final bool isVerified;
  final String subscriptionPlan;

  User({
    required this.name,
    required this.id,
    required this.photoUrl,
    required this.countryFlagUrl,
    required this.isVerified,
    required this.subscriptionPlan,
  });
}

// for send message

void _showUserBlockDialog(String uid, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Block User',
          style: GoogleFonts.poppins(
            color: const Color(0xFF343C6A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to block this user?',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2C2C2C),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AdminDashboardProvider>(context, listen: false)
                  .banUser(uid);
              Navigator.pop(context);
            },
            child: Text(
              'Block',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void _showSendMessageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Send Message',
          style: GoogleFonts.poppins(
            color: const Color(0xFF343C6A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColors.blue.withOpacity(0.5),
                        strokeAlign: BorderSide.strokeAlignInside,
                      )),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppColors.blue.withOpacity(0.5),
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignInside,
                      )),
                  hintText: "Title",
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF2C2C2C),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
// message
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        width: 1,
                        color: AppColors.blue.withOpacity(0.5),
                        strokeAlign: BorderSide.strokeAlignInside,
                      )),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppColors.blue.withOpacity(0.5),
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignInside,
                      )),
                  hintText: "Message here",
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF2C2C2C),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // send button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          // send icon
                          SvgPicture.asset(AppIcons.send),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
