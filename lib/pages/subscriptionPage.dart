import 'dart:convert';

import 'package:dating/datamodel/subscription_model.dart';

import 'package:dating/providers/subscription_provider.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool kIsWeb = const bool.fromEnvironment('dart.library.js_util');

  String seeking = 'SEEKING';
  String country = 'COUNTRY';
  String duration = 'Weekly';

  Future<void> makePayment(
      BuildContext context, Subscription subscription) async {
    try {
      // Step 1: Create Payment Intent
      String? amount;

      switch (duration) {
        case 'Weekly':
          switch (subscription.type) {
            case 'Basic':
              amount = subscription.weeklyPrice.toString();
              break;
            case 'Plus':
              amount = subscription.weeklyPrice.toString();
              break;
            case 'Gold':
              amount = subscription.weeklyPrice.toString();
              break;
            default:
              amount = null; // Handle unexpected plan type
              break;
          }
          break;

        case 'Monthly':
          switch (subscription.type) {
            case 'Basic':
              amount = subscription.monthlyPrice.toString();
              break;
            case 'Plus':
              amount = subscription.monthlyPrice.toString();
              break;
            case 'Gold':
              amount = subscription.monthlyPrice.toString();
              break;
            default:
              amount = null; // Handle unexpected plan type
              break;
          }
          break;

        case 'Yearly':
          switch (subscription.type) {
            case 'Basic':
              amount = subscription.yearlyPrice.toString();
              break;
            case 'Plus':
              amount = subscription.yearlyPrice.toString();
              break;
            case 'Gold':
              amount = subscription.yearlyPrice.toString();
              break;
            default:
              amount = null; // Handle unexpected plan type
              break;
          }
          break;

        default:
          amount = null; // Handle unexpected duration values
          break;
      }
      final paymentIntent = await createPaymentIntent(amount!);
      final clientSecret = paymentIntent['client_secret'];

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Your Company Name",
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: "US",
            currencyCode: "USD",
            testEnv: true,
          ),
          style: ThemeMode.light,
          billingDetails: const BillingDetails(
            email: 'email@example.com',
            phone: '+48888000888',
            address: Address(
              city: 'Houston',
              country: 'US',
              line1: '1459 Circle Drive',
              line2: '',
              state: 'Texas',
              postalCode: '77063',
            ),
          ),
        ),
      );

      // Step 3: Display Payment Sheet
      await displayPaymentSheet(subscription, context, clientSecret);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> displayPaymentSheet(Subscription subscription,
      BuildContext context, String paymentIntentToken) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await Stripe.instance.presentPaymentSheet();

      final subscriptionProvider = context.read<SubscriptionProvider>();

      final subscriptionModel = SubscriptionModel(
        userId: user!.uid,
        duration: duration,
        planType: subscription.type,
        paymentMethod: "stripe",
        paymentId: paymentIntentToken,
      );
      final result =
          await subscriptionProvider.buySubcription(subscriptionModel, context);
      if (result == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
      }
    } catch (e) {
      if (e is StripeException) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error from Stripe: ${e.error.localizedMessage}')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unforeseen error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount) async {
    try {
      final body = {
        "amount": amount,
        "currency": "USD",
      };
      http.Response response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          "Authorization":
              "Bearer sk_test_51PVaJmAL5L5DqNFSUgCjWSSbZXrwyoErFjgdCOQMIrK4FoDG5cz3IikJjnpZ6LOJm8u37JrjUjqDDcKQ9eRqXcO700J2wqRvgK",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  final List<Subscription> subscriptions = [
    Subscription(
      type: 'Basic',
      weeklyPrice: 3,
      monthlyPrice: 6,
      yearlyPrice: 50,
      description: 'Basic plan with essential features.',
      subTitle: 'Get started with basic features',
      features: ['Feature 1', 'Feature 2'],
    ),
    Subscription(
      type: 'Plus',
      weeklyPrice: 3,
      monthlyPrice: 9,
      yearlyPrice: 75,
      description: 'Intermediate plan for regular users.',
      subTitle: 'Enjoy more features and flexibility',
      features: ['Feature 1', 'Feature 2', 'Feature 3'],
    ),
    Subscription(
      type: 'Gold',
      weeklyPrice: 5,
      monthlyPrice: 15,
      yearlyPrice: 120,
      description: 'Premium plan for professionals.',
      subTitle: 'Unlock all features and priority support',
      features: ['Feature 1', 'Feature 2', 'Feature 3', 'Feature 4'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // For smaller screen sizes (e.g., mobile)
              return MobileHome();
            } else {
              // For larger screen sizes (e.g., tablet or desktop)
              return DesktopHome();
            }
          },
        ),
      ),
    );
  }

  Widget MobileHome() {
    return Scaffold(
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, _) {
          if (subscriptionProvider.isSubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SafeArea(
              child: ListView.builder(
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SubscriptionCard(
                      duration: duration,
                      subscription: subscriptions[index],
                      onTap: () {
                        makePayment(context, subscriptions[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget DesktopHome() {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const SizedBox(
            height: 40,
          ),
          Expanded(
            child: Row(
              children: [
// side bar
                // NavBarDesktop(),

// posts
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    // verticalDirection: VerticalDirection.down,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Pricing',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          const Spacer(),
// switch
                          Neumorphic(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 2),
                              child: DropdownButton<String>(
                                underline: Container(),
                                style: AppTextStyles().secondaryStyle,
                                value: duration,
                                icon: const Icon(
                                    Icons.arrow_drop_down), // Dropdown icon
                                onChanged: (String? newValue) {
                                  setState(() {
                                    duration = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Weekly',
                                  'Monthly',
                                  'Yearly',
                                ] // Language options
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: AppTextStyles()
                                          .secondaryStyle
                                          .copyWith(
                                              fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList(),
                              )),
                          const Spacer(),
                        ],
                      ),
                      Consumer<SubscriptionProvider>(
                          builder: (context, subscription, _) {
                        return Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  1, // Adjust to show 2 cards per row
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 20,
                              childAspectRatio: 3 / 4,
                            ),
                            itemCount: subscriptions.length,
                            itemBuilder: (context, index) {
                              final subscription = subscriptions[index];
                              return SubscriptionCard(
                                duration: duration,
                                subscription: subscription,
                                onTap: () {
                                  makePayment(context, subscriptions[index]);
                                },
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Subscription {
  final String type;
  final double weeklyPrice;
  final double monthlyPrice;
  final double yearlyPrice;
  final String description;
  final String subTitle;
  final List<String> features;

  Subscription({
    required this.type,
    required this.weeklyPrice,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.description,
    required this.subTitle,
    required this.features,
  });
}

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final String duration;
  final VoidCallback? onTap;

  SubscriptionCard({
    required this.subscription,
    required this.duration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String price = '';

    // Set the price based on the selected duration
    switch (duration) {
      case 'Weekly':
        price = '\$${subscription.weeklyPrice.toStringAsFixed(2)} / week';
        break;
      case 'Monthly':
        price = '\$${subscription.monthlyPrice.toStringAsFixed(2)} / month';
        break;
      case 'Yearly':
        price = '\$${subscription.yearlyPrice.toStringAsFixed(2)} / year';
        break;
    }

    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        depth: 5,
        intensity: 0.75,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription type
            Text(
              subscription.type,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Price and Duration
            Text(
              price,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1A1A1A),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              subscription.description,
              style: GoogleFonts.poppins(
                color: const Color(0xFF667085),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 15),

            // Divider
            Container(
              height: 1,
              color: const Color(0xFFD9D9D9),
            ),
            const SizedBox(height: 15),

            // Subtitle
            Text(
              subscription.subTitle,
              style: GoogleFonts.poppins(
                color: const Color(0xFF667085),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),

            // Features List
            Column(
              mainAxisSize: MainAxisSize.min,
              children: subscription.features
                  .map((feature) => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AppIcons.check,
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            feature,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF1A1A1A),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Subscribe Button
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: ShapeDecoration(
                  color: const Color(0xFF5400FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Center(
                    child: Text(
                  'Subscribe Now',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle text overflow
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
