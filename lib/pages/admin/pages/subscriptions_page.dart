import 'package:dating/datamodel/admin/admin_subscription_model.dart';
import 'package:dating/providers/admin_provider.dart';
import 'package:dating/utils/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscriptionsPage extends StatefulWidget {
  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  // for date picker
  String _fromDate = 'From';
  String _toDate = 'To';
  bool _isFilterApplied = false;
  List<AdminSubscriptionModel>? filteredData;

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
  final List<String> _statuses = ['Status', '+Basic', '+Plus', '+Gold'];

  @override
  void initState() {
    super.initState();
    // Fetch the profile data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardProvider>(context, listen: false)
          .fetchUserSubscription(1);
    });
  }

  List<AdminSubscriptionModel> _applyFilters(
      List<AdminSubscriptionModel> subscriptions) {
    DateTime fromDate =
        _fromDate == 'From' ? DateTime(2000) : DateTime.parse(_fromDate);
    DateTime toDate =
        _toDate == 'To' ? DateTime(2101) : DateTime.parse(_toDate);

    return subscriptions.where((subscription) {
      bool matchesStatus = _selectedStatus == 'Status' ||
          subscription.userSubscription!.planType == _selectedStatus;

      bool matchesDate = true;
      if (subscription.userSubscription!.subscriptionDate != null) {
        DateTime subscriptionDate =
            DateTime.parse(subscription.userSubscription!.subscriptionDate!);
        matchesDate = subscriptionDate.isAfter(fromDate) &&
            subscriptionDate.isBefore(toDate);
      }

      return matchesStatus && matchesDate;
    }).toList();
  }

  void _filterData() {
    final adminProvider =
        Provider.of<AdminDashboardProvider>(context, listen: false);
    final allSubscriptions = adminProvider.userSubscriptionList ?? [];
    setState(() {
      filteredData = _applyFilters(allSubscriptions);
      _isFilterApplied = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
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
                            icon: Icon(
                              Icons.arrow_drop_down,
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
                              Icon(Icons.calendar_today, size: 14),
                            ],
                          ),
                        ),
                      ),
                      // swap icon
                      Icon(Icons.swap_horiz),
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
                              Icon(Icons.calendar_today, size: 14),
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
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list, color: Colors.white),
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
            Expanded(child: Consumer<AdminDashboardProvider>(
                builder: (context, adminProvider, _) {
              return adminProvider.isAdminDataLoading
                  ? const ShimmerSkeleton(count: 4, height: 80)
                  : Consumer<AdminDashboardProvider>(
                      builder: (context, adminProvider, _) {
                      List<AdminSubscriptionModel>? data = _isFilterApplied
                          ? filteredData
                          : adminProvider.userSubscriptionList;

                      if (data == null || data.isEmpty) {
                        return const Center(child: Text('No data available'));
                      }
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 2 items per row
                          crossAxisSpacing: 15.0,
                          mainAxisSpacing: 15,
                          childAspectRatio:
                              19 / 9, // Adjust the aspect ratio as needed
                        ),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return SubscriptionCard(subscription: data[index]);
                        },
                      );
                    });
            })),
          ],
        ));
  }
}

class SubscriptionCard extends StatelessWidget {
  final AdminSubscriptionModel subscription;

  const SubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    Color subscriptionColor;
    switch (subscription.userSubscription!.planType) {
      case '+Basic':
        subscriptionColor = Colors.green;
        break;
      case '+Gold':
        subscriptionColor = Colors.amber;
        break;
      case '+Plus':
        subscriptionColor = Colors.blue;
        break;
      default:
        subscriptionColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2, color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: ListTile(
        title: Text(
          subscription.miniProfile!.name!,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.userSubscription!.planType.toString(),
              style: GoogleFonts.poppins(
                color: subscriptionColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Start Date: ${subscription.userSubscription!.subscriptionDate.toString().split(' ')[0]}',
              style: GoogleFonts.poppins(
                color: Color(0xFF514F6E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'End Date: ${subscription.userSubscription!.expirationDate.toString().split(' ')[0]}',
              style: GoogleFonts.poppins(
                color: Color(0xFF514F6E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Subscription {
  final String userName;
  final String subscriptionType;
  final DateTime startDate;
  final DateTime endDate;

  Subscription({
    required this.userName,
    required this.subscriptionType,
    required this.startDate,
    required this.endDate,
  });
}
