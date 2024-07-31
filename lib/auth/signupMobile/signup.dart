import 'package:dating/auth/loginScreen.dart';
import 'package:dating/pages/homepage.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:dating/providers/loading_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/textField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

class SignUpMobile extends StatefulWidget {
  const SignUpMobile({Key? key}) : super(key: key);

  @override
  State<SignUpMobile> createState() => _SignUpMobileState();
}

class _SignUpMobileState extends State<SignUpMobile> {
  String? selectedGender;
  String? lookingFor;
  String _selectedAge = '18';
  String _seekingAgeFrom = '18';
  String _seekingAgeTo = '25';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
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

  Widget _buildLabeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles().authLabelStyle),
        const SizedBox(height: 6),
        field,
      ],
    );
  }

  Widget _buildGenderSelect(
      String gender, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent, width: 2.0),
        ),
        child: Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.concave,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
            depth: 8,
            intensity: 0.6,
          ),
          child: Center(
              child: Icon(icon, color: isSelected ? Colors.blue : Colors.grey)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(AppImages.login, height: 120),
                            const SizedBox(height: 20),
                            Text('Find your match',
                                style: AppTextStyles().authMainStyle,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            _buildLabeledField(
                                'Your Name',
                                AppTextField(
                                  inputcontroller: _nameController,
                                  hintText: 'Enter your name',
                                  keyboardType: TextInputType.name,
                                )),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLabeledField(
                                    'I am a',
                                    Row(
                                      children: [
                                        _buildGenderSelect(
                                          'male',
                                          Icons.male,
                                          selectedGender == 'male',
                                          () => setState(() {
                                            selectedGender = 'male';
                                            lookingFor =
                                                'female'; // Set lookingFor to the opposite gender
                                          }),
                                        ),
                                        const SizedBox(width: 10),
                                        _buildGenderSelect(
                                          'female',
                                          Icons.female,
                                          selectedGender == 'female',
                                          () => setState(() {
                                            selectedGender = 'female';
                                            lookingFor =
                                                'male'; // Set lookingFor to the opposite gender
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildLabeledField(
                                    'Looking For',
                                    Row(
                                      children: [
                                        _buildGenderSelect(
                                          'male',
                                          Icons.male,
                                          lookingFor == 'male',
                                          () => setState(() {
                                            lookingFor = 'male';
                                            selectedGender =
                                                'female'; // Ensure selectedGender is updated to the opposite gender
                                          }),
                                        ),
                                        const SizedBox(width: 10),
                                        _buildGenderSelect(
                                          'female',
                                          Icons.female,
                                          lookingFor == 'female',
                                          () => setState(() {
                                            lookingFor = 'female';
                                            selectedGender =
                                                'male'; // Ensure selectedGender is updated to the opposite gender
                                          }),
                                        ),
                                      ],
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
                                    'Age',
                                    DropdownButtonFormField<String>(
                                      value: _selectedAge,
                                      items: List.generate(
                                        83,
                                        (index) => DropdownMenuItem(
                                          value: (index + 18).toString(),
                                          child: Text((index + 18).toString(),
                                              style: AppTextStyles()
                                                  .authLabelStyle),
                                        ),
                                      ),
                                      onChanged: (value) =>
                                          setState(() => _selectedAge = value!),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16),
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
                                                    style: AppTextStyles()
                                                        .authLabelStyle),
                                              ))
                                          .toList(),
                                      onChanged: (value) => setState(
                                          () => _selectedCountry = value!),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16),
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
                                              style: AppTextStyles()
                                                  .authLabelStyle),
                                        ),
                                      ),
                                      onChanged: (value) => setState(
                                          () => _seekingAgeFrom = value!),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16),
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
                                              style: AppTextStyles()
                                                  .authLabelStyle),
                                        ),
                                      ),
                                      onChanged: (value) => setState(
                                          () => _seekingAgeTo = value!),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                      ),
                                      style: AppTextStyles().authLabelStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildLabeledField(
                                'Email Address',
                                AppTextField(
                                  inputcontroller: _emailController,
                                  hintText: 'Enter Email',
                                  keyboardType: TextInputType.emailAddress,
                                )),
                            const SizedBox(height: 15),
                            _buildLabeledField(
                                'Password',
                                AppTextField(
                                  inputcontroller: _passwordController,
                                  hintText: 'Enter Your Password',
                                  obscureText: true,
                                )),
                            const SizedBox(height: 15),
                            _buildLabeledField(
                                'Confirm Password',
                                AppTextField(
                                  inputcontroller: _confirmPasswordController,
                                  hintText: 'Re-enter Your Password',
                                  obscureText: true,
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            Consumer<AuthenticationProvider>(
                              builder: (context, authProvider, _) {
                                return ElevatedButton(
                                  onPressed: authProvider.isAuthLoading
                                      ? null
                                      : () {
                                          if (_passwordController.text ==
                                              _confirmPasswordController.text) {
                                            _register(context);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Passwords do not match!')),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 55),
                                  ),
                                  child: authProvider.isAuthLoading
                                      ? const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white))
                                      : Text(
                                          'Sign Up',
                                          style: AppTextStyles()
                                              .primaryStyle
                                              .copyWith(fontSize: 14),
                                        ),
                                );
                              },
                            ),
                            const SizedBox(height: 15),
                            Text('Or',
                                style: AppTextStyles()
                                    .authLabelStyle
                                    .copyWith(color: AppColors.secondaryColor)),
                            const SizedBox(height: 15),
                            Button(
                              onPressed: () {
                                authenticationProvider
                                    .signInWithGoogle(context)
                                    .then((user) {
                                  if (user != null) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const HomePage()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Google Sign-In canceled or failed.')),
                                    );
                                  }
                                });
                              },
                              text: 'Sign Up With',
                              imagePath: 'assets/images/google.png',
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an account?",
                                    style: AppTextStyles()
                                        .secondaryStyle
                                        .copyWith(fontSize: 14)),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen())),
                                  child: Text('LogIn',
                                      style: AppTextStyles()
                                          .primaryStyle
                                          .copyWith(fontSize: 14)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Consumer<LoadingProvider>(
              builder: (context, loadingProvider, _) {
                return loadingProvider.isLoading
                    ? Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : Container();
              },
            ),
          ],
        ),
      ),
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
