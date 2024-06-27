import 'dart:convert';
import 'dart:developer';

import 'package:dating/pages/myprofile.dart';
import 'package:dating/pages/settingpage.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/icons.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment(String amount) async {
    log("make payment");
    try {
      // Step 1: Create Payment Intent
      paymentIntent = await createPaymentIntent(amount);

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          merchantDisplayName: "Your Company Name",
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: "US",
            currencyCode: "USD",
            testEnv: true,
          ),
          style: ThemeMode.light,
          // Additional configuration can be added here
        ),
      );

      // Step 3: Display Payment Sheet
      await displayPaymentSheet();
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      log("not executed");
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
    } catch (e) {
      log("executed");
      if (e is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error from Stripe: ${e.error.localizedMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unforeseen error: ${e.toString()}')),
        );
      }
    }
  }

  createPaymentIntent(String amount) async {
    try {
      Map<String, dynamic> body = {
        "amount": amount,
        "currency": "USD",
        "payment_method_types[]": "card",
      };
      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payments_intents"),
          body: body,
          headers: {
            "Authorization": "Bearer sk_test_4eC39HqLyjWDarjtT1zdp7dc",
            "Content-Type": "application/x-www-form-urlencoded"
          });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  final List<Subscription> subscriptions = [
    Subscription(
      type: 'Basic',
      pricePerWeek: '\$5',
      description:
          'Description of the tier list will go here, copy should be concise and impactful.',
      subTitle: 'Get started with basic features',
      features: ['Feature 1', 'Feature 2', 'Feature 3'],
    ),
    Subscription(
      type: 'Plus',
      pricePerWeek: '\$10',
      description: 'An intermediate plan for regular users.',
      subTitle: 'Enjoy more features and flexibility',
      features: ['Feature 1', 'Feature 2', 'Feature 3', 'Feature 4'],
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
        'Feature 5'
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
      body: Column(children: [
        SizedBox(
          height: 10,
        ),

        // icons

        // post
        SizedBox(
          height: 30,
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Adjust to show 2 cards per row
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
                    makePayment(subscription.pricePerWeek);
                  },
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 25,
        ),
      ]),
      // bottomSheet: NavBar(),
    );
  }

  Widget DesktopHome() {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // profile
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyProfilePage()));
                        },
                        child: profileButton()),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Dating App',
                      style: GoogleFonts.poppins(
                        color: AppColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // search icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_isSearchFieldVisible)
                      Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 10.0),
                        child: Neumorphic(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ButtonWithLabel(
                      text: null,
                      onPressed: () {
                        _toggleSearchField();
                      },
                      icon: Icon(
                        Icons.search,
                      ),
                      labelText: null,
                    ),

                    // settings icon

                    ButtonWithLabel(
                      text: null,
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => SettingPage()));
                      },
                      icon: Icon(
                        Icons.settings,
                      ),
                      labelText: null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(
            height: 40,
          ),

          // icons
          // Container(
          //   height: 90,
          //   decoration: BoxDecoration(
          //     color: AppColors.backgroundColor,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.grey.withOpacity(0.25),
          //         // spreadRadius: 5,
          //         blurRadius: 20,
          //         offset: Offset(0, 25), // horizontal and vertical offset
          //       ),
          //     ],
          //   ),
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 20),
          //     child: ListView(
          //       // physics: NeverScrollableScrollPhysics(),
          //       scrollDirection: Axis.horizontal,
          //       children: [
          //         // matches
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Row(
          //               children: [
          //                 ButtonWithLabel(
          //                   text: null,
          //                   labelText: 'Matches',
          //                   onPressed: () {},
          //                   icon: Icon(Icons.people),
          //                 ),
          //                 SizedBox(
          //                   width: 15,
          //                 ),
          //                 // messages
          //                 ButtonWithLabel(
          //                   text: null,
          //                   labelText: 'Messages',
          //                   onPressed: () {
          //                     Navigator.push(
          //                         context,
          //                         CupertinoPageRoute(
          //                             builder: (context) => ChatPage()));
          //                   },
          //                   icon: Icon(Icons.messenger_outline),
          //                 ),

          //                 SizedBox(
          //                   width: 15,
          //                 ),
          //                 // popular
          //                 ButtonWithLabel(
          //                   text: null,
          //                   labelText: 'Popular',
          //                   onPressed: () {},
          //                   icon: Icon(Icons.star),
          //                 ),
          //                 SizedBox(
          //                   width: 15,
          //                 ),
          //                 // photos
          //                 ButtonWithLabel(
          //                   text: null,
          //                   labelText: 'Photos',
          //                   onPressed: () {},
          //                   icon: Icon(Icons.photo_library_sharp),
          //                 ),

          //                 SizedBox(
          //                   width: 15,
          //                 ),
          //                 // add friemd
          //                 ButtonWithLabel(
          //                   text: null,
          //                   labelText: 'Add Friend',
          //                   onPressed: () {},
          //                   icon: Icon(Icons.add),
          //                 ),

          //                 SizedBox(
          //                   width: 15,
          //                 ),
          //                 // online
          //                 ButtonWithLabel(
          //                   text: null,
          //                   labelText: 'Online',
          //                   onPressed: () {},
          //                   icon: Icon(
          //                     Icons.circle_outlined,
          //                     color: Colors.green,
          //                   ),
          //                 ),
          //               ],
          //             ),

          //             SizedBox(
          //               width: 100,
          //             ),

          //             // age seeking

          //             Row(
          //               children: [
          //                 // seeking

          //                 Neumorphic(
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: 20, vertical: 2),
          //                   child: DropdownButton<String>(
          //                     underline: Container(),
          //                     style: AppTextStyles().secondaryStyle,
          //                     value: seeking,
          //                     icon:
          //                         Icon(Icons.arrow_drop_down), // Dropdown icon
          //                     onChanged: (String? newValue) {
          //                       setState(() {
          //                         seeking = newValue!;
          //                       });
          //                     },
          //                     items: <String>[
          //                       'SEEKING',
          //                       'English',
          //                       'Spanish',
          //                       'French',
          //                       'German'
          //                     ] // Language options
          //                         .map<DropdownMenuItem<String>>(
          //                             (String value) {
          //                       return DropdownMenuItem<String>(
          //                         value: value,
          //                         child: Text(
          //                           value,
          //                           style: AppTextStyles().secondaryStyle,
          //                         ),
          //                       );
          //                     }).toList(),
          //                   ),
          //                 ),
          //                 SizedBox(
          //                   width: 50,
          //                 ),

          //                 // country

          //                 Neumorphic(
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: 20, vertical: 2),
          //                   child: DropdownButton<String>(
          //                     underline: Container(),
          //                     style: AppTextStyles().secondaryStyle,
          //                     value: country,
          //                     icon:
          //                         Icon(Icons.arrow_drop_down), // Dropdown icon
          //                     onChanged: (String? newValue) {
          //                       setState(() {
          //                         country = newValue!;
          //                       });
          //                     },
          //                     items: <String>[
          //                       'COUNTRY',
          //                       'English',
          //                       'Spanish',
          //                       'French',
          //                       'German'
          //                     ] // Language options
          //                         .map<DropdownMenuItem<String>>(
          //                             (String value) {
          //                       return DropdownMenuItem<String>(
          //                         value: value,
          //                         child: Text(
          //                           value,
          //                           style: AppTextStyles().secondaryStyle,
          //                         ),
          //                       );
          //                     }).toList(),
          //                   ),
          //                 ),
          //                 SizedBox(
          //                   width: 50,
          //                 ),

          //                 // age

          //                 Neumorphic(
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: 20, vertical: 2),
          //                   child: DropdownButton<String>(
          //                     underline: Container(),
          //                     style: AppTextStyles().secondaryStyle,
          //                     value: age,
          //                     icon:
          //                         Icon(Icons.arrow_drop_down), // Dropdown icon
          //                     onChanged: (String? newValue) {
          //                       setState(() {
          //                         age = newValue!;
          //                       });
          //                     },
          //                     items: <String>[
          //                       'AGE',
          //                       'English',
          //                       'Spanish',
          //                       'French',
          //                       'German'
          //                     ] // Language options
          //                         .map<DropdownMenuItem<String>>(
          //                             (String value) {
          //                       return DropdownMenuItem<String>(
          //                         value: value,
          //                         child: Text(
          //                           value,
          //                           style: AppTextStyles().secondaryStyle,
          //                         ),
          //                       );
          //                     }).toList(),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          //

          // post
          // SizedBox(
          //   height: 30,
          // ),

          Expanded(
            child: Row(
              children: [
// side bar
                // NavBarDesktop(),

// posts
                SizedBox(
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
                          Spacer(),
// switch
                          Neumorphic(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 2),
                              child: DropdownButton<String>(
                                underline: Container(),
                                style: AppTextStyles().secondaryStyle,
                                value: duration,
                                icon: Icon(
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
                          Spacer(),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                  subscription: subscription);
                            },
                          ),
                        ),
                      ),
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
      style: NeumorphicStyle(
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

  VoidCallback? onTap;

  SubscriptionCard({required this.subscription, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        depth: 5,
        intensity: 0.75,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.type,
              style: GoogleFonts.poppins(
                color: Color(0xFF1A1A1A),
                fontSize: 27,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.54,
              ),
            ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  subscription.pricePerWeek,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF1A1A1A),
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.54,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
//  per week
                Text(
                  '/ week',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF1A1A1A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            Text(
              subscription.description,
              style: GoogleFonts.poppins(
                color: Color(0xFF667085),
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 1,
              decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
            ),
            SizedBox(height: 15),
            Text(
              subscription.subTitle,
              style: GoogleFonts.poppins(
                color: Color(0xFF667085),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16),
            ...subscription.features.map((feature) => Row(
                  children: [
                    SvgPicture.asset(AppIcons.check),
                    SizedBox(width: 8),
                    Text(
                      feature,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )),
            // subscribe button
            Spacer(),

            GestureDetector(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                decoration: ShapeDecoration(
                  color: Color(0xFF5400FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
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
  }
}
