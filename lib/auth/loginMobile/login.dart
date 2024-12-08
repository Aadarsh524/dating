import 'package:dating/auth/signup_screen.dart';
import 'package:dating/helpers/device_token.dart';
import 'package:dating/helpers/notification_services.dart';
import 'package:dating/pages/state_loader.dart';
import 'package:dating/providers/authentication_provider.dart';
import 'package:dating/utils/colors.dart';
import 'package:dating/utils/images.dart';
import 'package:dating/utils/textStyles.dart';
import 'package:dating/widgets/buttons.dart';
import 'package:dating/widgets/text_field.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isChecked = false;

  /// Saves the login state in shared preferences
  Future<void> _saveLoginState(bool isSavedToLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSavedToLoggedIn', isSavedToLoggedIn);
  }

  /// Handles user login with email and password
  Future<void> _handleLogin(BuildContext context) async {
    final authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final result = await authenticationProvider.signInWithEmailAndPassword(
          email, password, context);

      if (result != null) {
        // Save the device token and navigate to the next page
        final deviceToken = await NotificationServices().getDeviceToken();
        await postDeviceToken(result, deviceToken!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StateLoaderPage()),
        );
      } else {
        _showSnackBar('Login failed: User not found');
      }
    } catch (e) {
      _showSnackBar('Login failed: ${e.toString()}');
    }
  }

  /// Displays a snackbar with the given message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Builds the login button
  Widget _buildLoginButton(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authenticationProvider, _) {
        return GestureDetector(
          onTap: authenticationProvider.isAuthLoading
              ? null
              : () {
                  _saveLoginState(_isChecked);
                  _handleLogin(context);
                },
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade500,
                  offset: const Offset(4, 4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: authenticationProvider.isAuthLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      'Login',
                      style: AppTextStyles()
                          .primaryStyle
                          .copyWith(fontSize: 14, color: Colors.black),
                    ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a text field with label
  Widget _buildTextField(String label, String hint,
      TextEditingController controller, TextInputType keyboardType,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles().authLabelStyle),
          const SizedBox(height: 6),
          AppTextField(
            inputcontroller: controller,
            hintText: hint,
            keyboardType: keyboardType,
            obscureText: obscureText,
          ),
        ],
      ),
    );
  }

  /// Builds the "Keep me logged in" switch
  Widget _buildKeepLoggedInSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeumorphicSwitch(
            height: 20,
            value: _isChecked,
            onChanged: (value) {
              setState(() {
                _isChecked = value;
              });
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep me logged in',
                  style: AppTextStyles().authLabelStyle.copyWith(fontSize: 14),
                ),
                Text(
                  "Don't check this box if you're at a public or shared computer",
                  style: AppTextStyles().authLabelStyle.copyWith(
                        fontSize: 14,
                        color: AppColors.secondaryColor,
                      ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        Image.asset(AppImages.login, height: 200),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Find your match', style: AppTextStyles().authMainStyle),
        ),
        const SizedBox(height: 15),
        _buildTextField(
          'Email Address',
          'Enter Email',
          _emailController,
          TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          'Password',
          'Enter Your Password',
          _passwordController,
          TextInputType.visiblePassword,
          obscureText: true,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Forgot Password?',
                style: AppTextStyles().secondaryStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 35),
        _buildKeepLoggedInSwitch(),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildLoginButton(context),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Or',
            style: AppTextStyles()
                .authLabelStyle
                .copyWith(color: AppColors.secondaryColor),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Button(
            onPressed: () {
              _saveLoginState(_isChecked);
              Provider.of<AuthenticationProvider>(context, listen: false)
                  .signInWithGoogle(context)
                  .then((user) {
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const StateLoaderPage()),
                  );
                } else {
                  _showSnackBar('Google Sign-In canceled or failed.');
                }
              });
            },
            text: 'Login With',
            imagePath: 'assets/images/google.png',
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: AppTextStyles().secondaryStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: Text(
                'Register',
                style: AppTextStyles().primaryStyle.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
