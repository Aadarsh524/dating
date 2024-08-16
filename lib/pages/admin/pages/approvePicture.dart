import 'dart:convert';

import 'package:dating/datamodel/admin/approve_document_model.dart';
import 'package:dating/datamodel/user_profile_model.dart';
import 'package:dating/providers/admin_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ApprovePicturesPage extends StatefulWidget {
  @override
  State<ApprovePicturesPage> createState() => _ApprovePicturesPageState();
}

class _ApprovePicturesPageState extends State<ApprovePicturesPage> {
  String _fromDate = 'From';
  String _toDate = 'To';
  String? _selectedStatus = 'Status';
  final List<String> _statuses = ['Status', 'Active', 'Inactive', 'Blocked'];
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

  List<UserProfileModel> _applyFilters(List<UserProfileModel> users) {
    DateTime fromDate =
        _fromDate == 'From' ? DateTime(2000) : DateTime.parse(_fromDate);
    DateTime toDate =
        _toDate == 'To' ? DateTime(2101) : DateTime.parse(_toDate);

    return users.where((user) {
      bool matchesStatus = _selectedStatus == 'Status' ||
          user.userStatus.toString() == _selectedStatus;

      bool matchesDate = true;
      if (user.createdTimestamp != null) {
        DateTime userDate = DateTime.parse(user.createdTimestamp.toString());
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardProvider>(context, listen: false)
          .fetchUsers(1, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                    SvgPicture.asset(AppIcons.swap),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<AdminDashboardProvider>(
                builder: (context, adminProvider, _) {
                  if (adminProvider.isAdminDataLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  List<UserProfileModel>? users =
                      _isFilterApplied ? filteredData : adminProvider.usersList;

                  if (users == null || users.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  return adminProvider.isAdminDataLoading
                      ? const ShimmerSkeleton(count: 4, height: 80)
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: MemoryImage(
                                  base64Decode(user.image!),
                                ),
                              ),
                              title: Text(user.name!),
                              subtitle: Text(
                                  'Status: ${user.isVerified == true ? "Verified" : "Not Verified"}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () async {
                                  _showImageDialog(context, user.uid!);
                                },
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('User Document'),
            content: FutureBuilder<ApproveDocumentModel?>(
              future:
                  Provider.of<AdminDashboardProvider>(context, listen: false)
                      .fetchDocumentById(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Text('Error loading document');
                } else if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.documents == null ||
                    snapshot.data!.documents!.isEmpty) {
                  return const Text('No document available');
                } else {
                  final document = snapshot.data!;
                  String imageUrl =
                      'http://localhost:8001/api/Communication/FileView/${document.documents!.first.fileName}';

                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes!)
                                : null,
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Provider.of<AdminDashboardProvider>(context, listen: false)
                      .sendApprovalStatus(uid, 2); // Approve
                  Navigator.pop(context);
                },
                child: const Text('Approve'),
              ),
              ElevatedButton(
                onPressed: () {
                  Provider.of<AdminDashboardProvider>(context, listen: false)
                      .sendApprovalStatus(uid, 3); // Reject
                  Navigator.pop(context);
                },
                child: const Text('Reject'),
              ),
            ]);
      },
    );
  }
}
