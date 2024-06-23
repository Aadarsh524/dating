import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintsPage extends StatefulWidget {
  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
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
  // Sample complaints data
  final List<Complaint> complaints = [
    Complaint(
      title: 'Performance Issues',
      text:
          'The app is too slow and takes a long time to load. It crashes frequently and I lose my progress.',
      userProfilePicUrl: AppImages.profile,
      userName: 'John Doe',
      userId: '4wtsdrt5',
      publishDate: DateTime.now().subtract(Duration(days: 1)),
    ),

    Complaint(
      title: 'Performance Issues',
      text:
          'The app is too slow and takes a long time to load. It crashes frequently and I lose my progress.',
      userProfilePicUrl: AppImages.profile,
      userName: 'John Doe',
      userId: 'ute88',
      publishDate: DateTime.now().subtract(Duration(days: 1)),
    ),

    Complaint(
      title: 'Internet Access',
      text: 'This is the text of complaint 2.',
      userProfilePicUrl: AppImages.profile,
      userName: 'Jane Smith',
      userId: 'y567yg',
      publishDate: DateTime.now().subtract(Duration(days: 2)),
    ),

    Complaint(
      title: 'UI Glitches',
      text:
          'There are multiple UI glitches that make it difficult to navigate through the app.',
      userProfilePicUrl: AppImages.loginimage,
      userName: 'Jane Smith',
      userId: '5gyserte',
      publishDate: DateTime.now().subtract(Duration(days: 2)),
    ),
    Complaint(
      title: 'Login Problems',
      text:
          'I am unable to log in to the app using my credentials. It keeps saying incorrect password.',
      userProfilePicUrl: AppImages.loginimage,
      userName: 'Alice Johnson',
      userId: '6trsgteh',
      publishDate: DateTime.now().subtract(Duration(days: 3)),
    ),
    Complaint(
      title: 'Feature Requests',
      text:
          'It would be great to have dark mode and offline access features in the next update.',
      userProfilePicUrl: AppImages.loginimage,
      userName: 'Bob Williams',
      userId: '7uiysrtj',
      publishDate: DateTime.now().subtract(Duration(days: 4)),
    ),

    // Add more complaints here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
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
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 2, color: Color(0xFFE5E5E5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          padding: EdgeInsets.zero,
                          style: GoogleFonts.poppins(
                            color: Color(0xFF7879F1),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          value: _selectedStatus,
                          icon: SvgPicture.asset(
                            AppIcons
                                .chevronoutline, // Replace with your SVG path
                            height: 14,
                            color: Color.fromARGB(255, 120, 120, 241),
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

                    SizedBox(
                      width: 10,
                    ),
                    // date bick rom

                    Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 2, color: Color(0xFFE5E5E5)),
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
                                color: Color(0xFF868690),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.20,
                              ),
                            ),
                            SizedBox(
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
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 2, color: Color(0xFFE5E5E5)),
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
                                color: Color(0xFF868690),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.20,
                              ),
                            ),
                            SizedBox(
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
                  padding: EdgeInsets.symmetric(horizontal: 20),
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

// Complaintss

          SizedBox(
            height: 15,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 2 items per row
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15,
                  childAspectRatio: 19 / 9, // Adjust the aspect ratio as needed
                ),
                itemCount: complaints.length,
                itemBuilder: (BuildContext context, int index) {
                  final complaint = complaints[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 20),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // title and desc
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // title
                                Text(
                                  complaint.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // icon three dots
                                SvgPicture.asset(
                                  AppIcons.threedots,
                                  color: Colors.black.withOpacity(0.5),
                                )
                              ],
                            ),

                            //  desc
                            SizedBox(height: 4.0),
                            Text(
                              complaint.text,
                              style: GoogleFonts.poppins(
                                color: Color(0xFF514F6E),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(complaint.userProfilePicUrl),
                              radius: 20.0,
                            ),
                            SizedBox(width: 8.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  complaint.userName,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${complaint.userId}',
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF514F6E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Text(
                              '${complaint.publishDate.day}-${complaint.publishDate.month}-${complaint.publishDate.year}',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF514F6E),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Define a Complaint data model
class Complaint {
  final String title;
  final String text;
  final String userProfilePicUrl;
  final String userName;
  final String userId;
  final DateTime publishDate;

  Complaint({
    required this.title,
    required this.text,
    required this.userProfilePicUrl,
    required this.userName,
    required this.userId,
    required this.publishDate,
  });
}
