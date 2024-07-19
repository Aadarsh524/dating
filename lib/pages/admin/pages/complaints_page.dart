import 'package:dating/datamodel/complaint/complaint_filter_model.dart';
import 'package:dating/datamodel/complaint/complaint_model.dart';
import 'package:dating/providers/admin_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ComplaintsPage extends StatefulWidget {
  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  // for date picker
  String _fromDate = 'From';
  String _toDate = 'To';
  bool _isFilterApplied = false;
  List<ComplaintModel>? filteredData;

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
  final List<String> _statuses = ['Status', 'Active', 'Inactive', 'Blocked'];

  @override
  void initState() {
    super.initState();
    // Fetch the profile data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardProvider>(context, listen: false)
          .fetchComplaints(
              ComplaintFilterModel(from: '', to: '', status: '', page: '1'),
              context);
    });
  }

  List<ComplaintModel> _applyFilters(List<ComplaintModel> complaints) {
    DateTime fromDate =
        _fromDate == 'From' ? DateTime(2000) : DateTime.parse(_fromDate);
    DateTime toDate =
        _toDate == 'To' ? DateTime(2101) : DateTime.parse(_toDate);

    return complaints.where((complaint) {
      bool matchesStatus = _selectedStatus == 'Status' ||
          complaint.status.toString() == _selectedStatus;

      bool matchesDate = true;
      if (complaint.timestamp != null) {
        DateTime complaintDate = DateTime.parse(complaint.timestamp.toString());
        matchesDate =
            complaintDate.isAfter(fromDate) && complaintDate.isBefore(toDate);
      }

      return matchesStatus && matchesDate;
    }).toList();
  }

  void _filterData() {
    final adminProvider =
        Provider.of<AdminDashboardProvider>(context, listen: false);
    final allComplaints = adminProvider.usersComplainList ?? [];
    setState(() {
      filteredData = _applyFilters(allComplaints);
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
                    // date picker from
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
                            SvgPicture.asset(
                              AppIcons.calendar,
                              height: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SvgPicture.asset(AppIcons.swap),
                    // date picker to
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
                builder: (context, adminProvider, child) {
                  List<ComplaintModel>? complaints = _isFilterApplied
                      ? filteredData
                      : adminProvider.usersComplainList;

                  if (adminProvider.isAdminDataLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (complaints == null || complaints.isEmpty) {
                    return const Center(child: Text('No complaints available'));
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 items per row
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 15,
                      childAspectRatio:
                          19 / 9, // Adjust the aspect ratio as needed
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // title
                                    Text(
                                      complaint.title!,
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
                                const SizedBox(height: 4.0),
                                Text(
                                  complaint.content!,
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF514F6E),
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
                                      NetworkImage(complaint.image!),
                                  radius: 20.0,
                                ),
                                const SizedBox(width: 8.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      complaint.username!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${complaint.uid}',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF514F6E),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  '${complaint.timestamp}',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF514F6E),
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
