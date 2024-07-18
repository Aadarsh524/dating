import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

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
  bool _isFilterApplied = false;
  List<UserProfileModel>? filteredData;

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
  final List<String> _statuses = ['Status', 'active', 'inactive', 'blocked'];

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

  List<UserProfileModel> _applyFilters(List<UserProfileModel> users) {
    DateTime fromDate =
        _fromDate == 'From' ? DateTime(2000) : DateTime.parse(_fromDate);
    DateTime toDate = _toDate == 'To'
        ? DateTime(2101)
        : DateTime.parse(_toDate).add(Duration(days: 1));

    return users.where((user) {
      bool matchesStatus =
          _selectedStatus == 'Status' || user.userStatus == _selectedStatus;

      bool matchesDate = true;
      if (user.createdTimestamp != null) {
        DateTime userDate = DateTime.parse(user.createdTimestamp!);
        matchesDate = userDate.isAfter(fromDate) && userDate.isBefore(toDate);
      }

      return matchesStatus && matchesDate;
    }).toList();
  }

  void _filterData() {
    final adminProvider =
        Provider.of<AdminDashboardProvider>(context, listen: false);
    final allUsers = adminProvider.usersList ?? [];
    setState(() {
      filteredData = _applyFilters(allUsers);
      _isFilterApplied = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          // top filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              // for filter icon and statuses
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // status
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
                            AppIcons.chevronoutline,
                            height: 14,
                            color: const Color.fromARGB(255, 120, 120, 241),
                          ),
                          elevation: 0,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStatus = newValue!;
                            });
                          },
                          items: _statuses
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
                    const SizedBox(width: 10),
                    // date pick from
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
                            const SizedBox(width: 10),
                            SvgPicture.asset(AppIcons.calendar, height: 14),
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
                            const SizedBox(width: 10),
                            SvgPicture.asset(AppIcons.calendar, height: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // filter button
                GestureDetector(
                  onTap: _filterData,
                  child: Container(
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Consumer<AdminDashboardProvider>(
                builder: (context, adminProvider, _) {
              return adminProvider.isAdminDataLoading
                  ? const ShimmerSkeleton(count: 4, height: 80)
                  : Consumer<AdminDashboardProvider>(
                      builder: (context, adminProvider, _) {
                      List<UserProfileModel>? data = _isFilterApplied
                          ? filteredData
                          : adminProvider.usersList;

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
                          switch (user.userSubscription?.planType ?? 'Basic') {
                            case 'Basic':
                              textColor = Colors.green;
                              break;
                            case 'Plus':
                              textColor = Colors.blue;
                              break;
                            case 'Gold':
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 0.50, color: Color(0xFFDDDDDD)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: user.image != null
                                    ? CircleAvatar(
                                        backgroundImage: MemoryImage(
                                            base64ToImage(user.image)),
                                      )
                                    : CircleAvatar(
                                        child: Text(
                                            user.name?.substring(0, 1) ?? ''),
                                      ),
                                title: Text(
                                  user.name ?? 'No name',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  user.email ?? 'No email',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      user.userSubscription?.planType ?? '',
                                      style: GoogleFonts.poppins(
                                        color: textColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.createdTimestamp.toString(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
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
