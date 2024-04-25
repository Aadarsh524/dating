import 'package:dating/auth/loginScreen.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/services/firebase_auth/firebase_auth.dart';
import 'package:dating/utils/colors.dart';
// import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpDesktop extends StatefulWidget {
  const SignUpDesktop({super.key});

  @override
  State<SignUpDesktop> createState() => _SignUpDesktopState();
}

class _SignUpDesktopState extends State<SignUpDesktop> {
  String _selectedLanguage = 'English';
  bool _isChecked = false;
  String? selectedGender;
  String _selectedAge = '18'; // Initial age
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _register() async {
    String? result = await _auth.registerWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      gender: selectedGender ?? '',
      age: _selectedAge,
    );

    if (result == null) {
      // Registration successful, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
        ),
      );

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Registration failed, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration error: $result'),
        ),
      );
    }
  }

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
                      'Sign Up',
                      style: GoogleFonts.poppins(
                        color: AppColors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),

                    //

                    // fields

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Your Name',
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
                        inputcontroller: _nameController,
                        hintText: 'Enter your name',
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        suffixIcon: null,
                      ),
                    ),

                    // space betn find your match and text field
                    const SizedBox(height: 15),

// gender
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'I am a',
                                    style: AppTextStyles().authLabelStyle,
                                  )
                                ],
                              ),
                            ),

                            // gender sletect
                            // spacer
                            const SizedBox(
                              height: 6,
                            ),

                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGender = 'male';
                                    });
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selectedGender == 'male'
                                            ? Colors
                                                .blue // Border color when selected
                                            : Colors
                                                .transparent, // Border color when not selected
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Neumorphic(
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.concave,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(20)),
                                        depth: 10,
                                        intensity: 0.5,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.male,
                                          color: selectedGender == 'male'
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // female
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGender = 'female';
                                    });
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selectedGender == 'female'
                                            ? Colors
                                                .blue // Border color when selected
                                            : Colors
                                                .transparent, // Border color when not selected
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Neumorphic(
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.concave,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(20)),
                                        depth: 10,
                                        intensity: 0.5,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.female,
                                          color: selectedGender == 'female'
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

// looking for s
                        const Spacer(),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Looking For',
                                    style: AppTextStyles().authLabelStyle,
                                  )
                                ],
                              ),
                            ),

                            // gender sletect
                            // spacer
                            const SizedBox(
                              height: 6,
                            ),

                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGender = 'female';
                                    });
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selectedGender == 'female'
                                            ? Colors
                                                .blue // Border color when selected
                                            : Colors
                                                .transparent, // Border color when not selected
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Neumorphic(
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.concave,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(20)),
                                        depth: 10,
                                        intensity: 0.5,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.male,
                                          color: selectedGender == 'female'
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // female
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedGender = 'male';
                                    });
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: selectedGender == 'male'
                                            ? Colors
                                                .blue // Border color when selected
                                            : Colors
                                                .transparent, // Border color when not selected
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Neumorphic(
                                      style: NeumorphicStyle(
                                        shape: NeumorphicShape.concave,
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(20)),
                                        depth: 10,
                                        intensity: 0.5,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.female,
                                          color: selectedGender == 'male'
                                              ? Colors.blue
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

// age picker
                        const Spacer(),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Age',
                                    style: AppTextStyles().authLabelStyle,
                                  )
                                ],
                              ),
                            ),

                            // gender sletect
                            // spacer
                            const SizedBox(
                              height: 6,
                            ),

                            Neumorphic(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 0),
                              child: DropdownButton<String>(
                                underline: Container(),
                                style: AppTextStyles().secondaryStyle,
                                value: _selectedAge,
                                icon: const Icon(
                                    Icons.arrow_drop_down), // Dropdown icon
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedAge = newValue!;
                                  });
                                },
                                items: <String>[
                                  '18',
                                  '19',
                                  '20',
                                  '21'
                                ] // Language options
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
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
                      ],
                    ),

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
                        inputcontroller: _emailController,
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
                      height: 15,
                    ),

                    // password

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Text(
                            'Confirm Password',
                            style: AppTextStyles().authLabelStyle,
                          )
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    AppTextField(
                      inputcontroller: _confirmpasswordController,
                      hintText: 'Re-Enter Your Password',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

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
                                Text(
                                  "Yes, I confirm that I am over 18 and agree to the Terms of Use and Privacy Statement.",
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
                        onPressed: () {
                          bool passwordsMatch = _passwordController.text ==
                              _confirmpasswordController.text;

                          if (passwordsMatch) {
                            _register();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match!'),
                              ),
                            );
                          }
                        },
                        text: 'Sign Up',
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
                        onPressed: () {
                          _auth.signInWithGoogle().then((user) {
                            if (user != null) {
                              // Sign-in successful, navigate to home page
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomePage()));
                            } else {
                              // Sign-in canceled or failed, show error message (optional)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Google Sign-In canceled or failed.'),
                                ),
                              );
                            }
                          });
                        },
                        text: 'Sign Up With',
                        imagePath: 'assets/images/google.png',
                      ),
                    ),

// dont have an account
                    const SizedBox(
                      height: 15,
                    ),

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        "Already have an account?",
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
                                  builder: (context) => const LoginScreen()));
                        },
                        child: Text(
                          'Login',
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
