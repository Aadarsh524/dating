import 'package:dating/auth/loginScreen.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _selectedCountry = "United States";
  final List<String> countries = [
    'United States',
    'Canada',
    'India',
    'Australia',
    'United Kingdom'
  ];
  String _seekingAgeFrom = '18';
  String _seekingAgeTo = '25';
  Future<void> _register(BuildContext context) async {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    User? user = await authenticationProvider.registerWithEmailAndPassword(
        context,
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        gender: selectedGender ?? '',
        age: _selectedAge,
        seekingAgeFrom: _seekingAgeFrom,
        seekingAgeTo: _seekingAgeTo,
        country: _selectedCountry);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration error: Could not register.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
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
                      ],
                    ),
                    const SizedBox(width: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNeomorphicDropdown(
                            'Age',
                            DropdownButtonFormField<String>(
                              value: _selectedAge,
                              items: List.generate(
                                83,
                                (index) => DropdownMenuItem(
                                  value: (index + 18).toString(),
                                  child: Text((index + 18).toString(),
                                      style: AppTextStyles().authLabelStyle),
                                ),
                              ),
                              onChanged: (value) =>
                                  setState(() => _selectedAge = value!),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: AppTextStyles().authLabelStyle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildNeomorphicDropdown(
                            'Country',
                            DropdownButtonFormField<String>(
                              value: _selectedCountry,
                              items: countries
                                  .map((country) => DropdownMenuItem(
                                        value: country,
                                        child: Text(country,
                                            style:
                                                AppTextStyles().authLabelStyle),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedCountry = value!),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: AppTextStyles().authLabelStyle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNeomorphicDropdown(
                            'Seeking Age From',
                            DropdownButtonFormField<String>(
                              value: _seekingAgeFrom,
                              items: List.generate(
                                83,
                                (index) => DropdownMenuItem(
                                  value: (index + 18).toString(),
                                  child: Text((index + 18).toString(),
                                      style: AppTextStyles().authLabelStyle),
                                ),
                              ),
                              onChanged: (value) =>
                                  setState(() => _seekingAgeFrom = value!),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: AppTextStyles().authLabelStyle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildNeomorphicDropdown(
                            'Seeking Age To',
                            DropdownButtonFormField<String>(
                              value: _seekingAgeTo,
                              items: List.generate(
                                83,
                                (index) => DropdownMenuItem(
                                  value: (index + 18).toString(),
                                  child: Text((index + 18).toString(),
                                      style: AppTextStyles().authLabelStyle),
                                ),
                              ),
                              onChanged: (value) =>
                                  setState(() => _seekingAgeTo = value!),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: AppTextStyles().authLabelStyle,
                            ),
                          ),
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
                      child: Consumer<AuthenticationProvider>(
                        builder: (context, authenticationProvider, _) {
                          return NeumorphicButton(
                            onPressed: authenticationProvider.isAuthLoading
                                ? null
                                : () {
                                    bool passwordsMatch =
                                        _passwordController.text ==
                                            _confirmpasswordController.text;

                                    if (_isChecked) {
                                      if (passwordsMatch) {
                                        _register(context);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Passwords do not match!'),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'You must agree to the terms and conditions!'),
                                        ),
                                      );
                                    }
                                  },
                            style: NeumorphicStyle(
                              depth: 4,
                              color: authenticationProvider.isAuthLoading
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(12)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                              child: authenticationProvider.isAuthLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(
                                      'Sign Up',
                                      style: AppTextStyles()
                                          .primaryStyle
                                          .copyWith(
                                              fontSize: 14,
                                              color: Colors.white),
                                    ),
                            ),
                          );
                        },
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
                          authenticationProvider
                              .signInWithGoogle(context)
                              .then((user) {
                            if (user != null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomePage()),
                              );
                            } else {
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

Widget _buildNeomorphicDropdown(String label, Widget child) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles().authLabelStyle),
      const SizedBox(height: 8),
      Neumorphic(
        style: NeumorphicStyle(
          depth: 8,
          intensity: 0.7,
          surfaceIntensity: 0.5,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        ),
        child: child,
      ),
    ],
  );
}
