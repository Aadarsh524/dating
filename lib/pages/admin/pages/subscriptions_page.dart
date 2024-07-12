import 'package:dating/datamodel/admin_subscription_model.dart';
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
  final List<Subscription> subscriptions = [
    Subscription(
      userName: 'John Doe',
      subscriptionType: '+Basic',
      startDate: DateTime.now().subtract(Duration(days: 30)),
      endDate: DateTime.now().add(Duration(days: 30)),
    ),
    Subscription(
      userName: 'Jane Smith',
      subscriptionType: '+Gold',
      startDate: DateTime.now().subtract(Duration(days: 60)),
      endDate: DateTime.now().add(Duration(days: 60)),
    ),
    Subscription(
      userName: 'Alice Johnson',
      subscriptionType: '+Plus',
      startDate: DateTime.now().subtract(Duration(days: 90)),
      endDate: DateTime.now().add(Duration(days: 90)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Fetch the profile data when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardProvider>(context, listen: false)
          .fetchUserSubscription(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Consumer<AdminDashboardProvider>(
            builder: (context, adminProvider, _) {
          return adminProvider.isAdminDataLoading
              ? const ShimmerSkeleton(count: 4, height: 80)
              : Consumer<AdminDashboardProvider>(
                  builder: (context, adminProvider, _) {
                    List<AdminSubscriptionModel>? data =
                        adminProvider.userSubscriptionList;

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
                  },
                );
        }));
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
