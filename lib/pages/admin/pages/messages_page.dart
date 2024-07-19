import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagesPage extends StatefulWidget {
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  // For date picker
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

  // For status
  String? _selectedStatus = 'Status';
  final List<String> _statuses = ['Status', 'Active', 'Inactive', 'Blocked'];

  // Sample user data
  final List<User> users = [
    User(
      name: 'Pankaj Subedi',
      date: DateTime.now().subtract(Duration(days: 1)),
      photoUrl: AppImages.profile,
      message:
          'Hello Pankaj Your account is in risk. Please add two factor authentication soon.',
      status: 'Active',
    ),
    // Add more user data here
  ];

  // Filtered user data
  List<User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = users;
  }

  List<User> _applyFilters(List<User> users) {
    DateTime fromDate =
        _fromDate == 'From' ? DateTime(2000) : DateTime.parse(_fromDate);
    DateTime toDate =
        _toDate == 'To' ? DateTime(2101) : DateTime.parse(_toDate);

    return users.where((user) {
      bool matchesStatus =
          _selectedStatus == 'Status' || user.status == _selectedStatus;
      bool matchesDate =
          user.date.isAfter(fromDate) && user.date.isBefore(toDate);
      return matchesStatus && matchesDate;
    }).toList();
  }

  void _filterData() {
    setState(() {
      filteredUsers = _applyFilters(users);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20),
          // Top filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter
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
                            AppIcons.chevronoutline,
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
                    SizedBox(width: 10),
                    // From date picker
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
                            SizedBox(width: 10),
                            SvgPicture.asset(
                              AppIcons.calendar,
                              height: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Swap icon
                    SvgPicture.asset(AppIcons.swap),
                    // To date picker
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
                            SizedBox(width: 10),
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
                // Filter icon
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: _filterData,
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
                  ),
                ),
              ],
            ),
          ),
          // Users
          SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (BuildContext context, int index) {
                final user = filteredUsers[index];
                return Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside,
                          color: Color(0xFFEAE7FF),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Profile pic and user name
                          SizedBox(
                            width: 200,
                            child: Row(
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    image: DecorationImage(
                                      image: NetworkImage(user.photoUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 30),
                                Text(
                                  user.name,
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF04103B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              '${user.date.day}-${user.date.month}-${user.date.year}',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF797D8C),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              truncateWithEllipsis(60, user.message),
                              style: GoogleFonts.poppins(
                                color: Color(0xFF3A3949),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Three dots icon
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 30),
                              SvgPicture.asset(AppIcons.dots),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Define a User data model
class User {
  final String name;
  final DateTime date;
  final String photoUrl;
  final String message;
  final String status;

  User({
    required this.name,
    required this.date,
    required this.photoUrl,
    required this.message,
    required this.status,
  });
}

String truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}
