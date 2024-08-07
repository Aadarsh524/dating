import 'dart:convert';

import 'package:dating/datamodel/subscription_model.dart';

import 'package:dating/providers/subscription_provider.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
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

  bool _isSearchFieldVisible = false;
  final TextEditingController _searchController = TextEditingController();

  void _toggleSearchField() {
    setState(() {
      _isSearchFieldVisible = !_isSearchFieldVisible;
    });
  }

  void _hideSearchField() {
    setState(() {
      _isSearchFieldVisible = false;
    });
  }

  Future<void> makePayment(BuildContext context, String amount) async {
    try {
      // Step 1: Create Payment Intent
      final paymentIntent = await createPaymentIntent(amount);
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
      await displayPaymentSheet(context, clientSecret);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> displayPaymentSheet(
      BuildContext context, String paymentIntentToken) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await Stripe.instance.presentPaymentSheet();

      final subscriptionProvider = context.read<SubscriptionProvider>();

      final subscriptionModel = SubscriptionModel(
        userId: user!.uid,
        duration: "weekly",
        planType: 'basic',
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
      pricePerWeek: '\$5',
      description: '.',
      subTitle: 'Get started with basic features',
      features: [
        'Feature 1',
      ],
    ),
    Subscription(
      type: 'Plus',
      pricePerWeek: '\$10',
      description: 'An intermediate plan for regular users.',
      subTitle: 'Enjoy more features and flexibility',
      features: [
        'Feature 1',
        'Feature 2',
        'Feature 3',
      ],
    ),
    Subscription(
      type: 'Gold',
      pricePerWeek: '\$20',
      description: 'A premium plan for professionals.',
      subTitle: 'Unlock all features and priority support',
      features: [
        'Feature 1',
        'Feature 2',
        'Feature 3',
        'Feature 4',
      ],
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
          return Column(children: [
            const SizedBox(
              height: 10,
            ),

            // icons

            // post
            const SizedBox(
              height: 30,
            ),

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, // Adjust to show 2 cards per row
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    return SubscriptionCard(
                      subscription: subscriptions[index],
                      onTap: () {
                        makePayment(context,
                            subscriptions[index].pricePerWeek.toString());
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
          ]);
        },
      ),
      // bottomSheet: NavBar(),
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
                                  'Daily',
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
                      const SizedBox(
                        height: 30,
                      ),
                      Consumer<SubscriptionProvider>(
                          builder: (context, subscription, _) {
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 100),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    3, // Adjust to show 2 cards per row
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                childAspectRatio: 3 / 4,
                              ),
                              itemCount: subscriptions.length,
                              itemBuilder: (context, index) {
                                final subscription = subscriptions[index];
                                return SubscriptionCard(
                                  subscription: subscription,
                                  onTap: () {
                                    makePayment(
                                        context,
                                        subscriptions[index]
                                            .pricePerWeek
                                            .toString());
                                  },
                                );
                              },
                            ),
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

// profile button
class profileButton extends StatelessWidget {
  const profileButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: const NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
      ),
      child: Container(
        height: 50,
        width: 50,
        child: Image.asset(
          AppImages.loginimage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// subscription

class Subscription {
  final String type;
  final String pricePerWeek;
  final String description;
  final String subTitle;
  final List<String> features;

  Subscription({
    required this.type,
    required this.pricePerWeek,
    required this.description,
    required this.subTitle,
    required this.features,
  });
}

// ignore: must_be_immutable
class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  SubscriptionCard({required this.subscription, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Neumorphic(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
            depth: 5,
            intensity: 0.75,
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.type,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1A1A1A),
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      subscription.pricePerWeek,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1A1A1A),
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.54,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '/ week',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1A1A1A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subscription.description,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF667085),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  height: 1,
                  color: const Color(0xFFD9D9D9),
                ),
                const SizedBox(height: 15),
                Text(
                  subscription.subTitle,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF667085),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: subscription.features
                      .map((feature) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SvgPicture.asset(AppIcons.check),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF1A1A1A),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
