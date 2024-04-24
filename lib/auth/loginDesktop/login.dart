import 'package:dating/auth/signupScreen.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginDesktop extends StatefulWidget {
  const LoginDesktop({super.key});

  @override
  State<LoginDesktop> createState() => _LoginDesktopState();
}

class _LoginDesktopState extends State<LoginDesktop> {
  String _selectedLanguage = 'English'; // Initial selected language
  bool _isChecked = false;
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // space above
        const SizedBox(height: 15),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dating App',
                style: GoogleFonts.poppins(
                  color: AppColors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Image.asset("assets/images/heart.png"),

              // change language

              Neumorphic(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: DropdownButton<String>(
                  underline: Container(),
                  style: AppTextStyles().secondaryStyle,
                  value: _selectedLanguage,
                  icon: const Icon(Icons.arrow_drop_down), // Dropdown icon
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                  items: <String>[
                    'English',
                    'Spanish',
                    'French',
                    'German'
                  ] // Language options
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: AppTextStyles().secondaryStyle,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // end top bar
        const SizedBox(
          height: 30,
        ),
        // login

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Neumorphic(
                      child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.amberAccent,
                          ),
                          child: const Image(
                              image: AssetImage('assets/images/login.png'))),
                    )
                  ],
                ),
              ),

              const SizedBox(width: 50),
// login fields

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Members Login',
                      style: GoogleFonts.poppins(
                        color: AppColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),

                    //

                    // fields

                    // space betn find your match and text field
                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: AppTextStyles().authLabelStyle,
                          )
                        ],
                      ),
                    ),

                    // label email
                    const SizedBox(
                      height: 6,
                    ),

                    SizedBox(
                      child: AppTextField(
                        inputcontroller: _emailcontroller,
                        hintText: 'Enter Email',
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        suffixIcon: null,
                      ),
                    ),

                    // password

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            'Password',
                            style: AppTextStyles().authLabelStyle,
                          )
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    AppTextField(
                      inputcontroller: _passwordController,
                      hintText: 'Enter Your Password',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forgot Password ?',
                            style: AppTextStyles().secondaryStyle.copyWith(
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                    ),

// spacer
                    const SizedBox(height: 35),

// checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 35,
                          child: NeumorphicSwitch(
                            height: 20,
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value;
                                // Do something when the switch is toggled
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        // space
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Keep me logged in',
                                      style: AppTextStyles()
                                          .authLabelStyle
                                          .copyWith(
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Don't check this box if you're at a public or shared computer",
                                  style:
                                      AppTextStyles().authLabelStyle.copyWith(
                                            fontSize: 14,
                                            color: AppColors.secondaryColor,
                                          ),
                                ),
                              ]),
                        )
                      ],
                    ),

// button
                    const SizedBox(
                      height: 35,
                    ),
                    SizedBox(
                      height: 55,
                      child: Button(
                        onPressed: () {},
                        text: 'Login',
                      ),
                    ),
// or
                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Or',
                          style: AppTextStyles()
                              .authLabelStyle
                              .copyWith(color: AppColors.secondaryColor),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),

// sign in with

                    SizedBox(
                      height: 55,
                      child: Button(
                        onPressed: () {},
                        text: 'Login With',
                        imagePath: 'assets/images/google.png',
                      ),
                    ),

// dont have an account
                    const SizedBox(
                      height: 15,
                    ),

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        "Don't have an account?",
                        style: AppTextStyles()
                            .secondaryStyle
                            .copyWith(fontSize: 14),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()));
                        },
                        child: Text(
                          'Register',
                          style: AppTextStyles()
                              .primaryStyle
                              .copyWith(fontSize: 14),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),

        // login text

        // space betn find your match and text field

// password
      ],
    );
  }
}
