import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 2 items per row
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15,
          childAspectRatio: 19 / 9, // Adjust the aspect ratio as needed
        ),
        itemCount: subscriptions.length,
        itemBuilder: (context, index) {
          return SubscriptionCard(subscription: subscriptions[index]);
        },
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    Color subscriptionColor;
    switch (subscription.subscriptionType) {
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
          subscription.userName,
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
              subscription.subscriptionType,
              style: GoogleFonts.poppins(
                color: subscriptionColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Start Date: ${subscription.startDate.toLocal().toString().split(' ')[0]}',
              style: GoogleFonts.poppins(
                color: Color(0xFF514F6E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'End Date: ${subscription.endDate.toLocal().toString().split(' ')[0]}',
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
