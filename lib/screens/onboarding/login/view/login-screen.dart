import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memphisbjj/screens/home/home-screen.dart';
import 'package:memphisbjj/screens/onboarding/screens/verify-email-screen/verify-email-screen.dart';
import 'package:memphisbjj/services/authentication.dart';
import 'package:memphisbjj/services/logger.dart';
import 'package:memphisbjj/utils/user-item.dart';
import 'package:memphisbjj/utils/bubble-indication-painter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final UserAuth userAuth = UserAuth();

  // Controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupPasswordController =
      TextEditingController();
  final TextEditingController signupConfirmPasswordController =
      TextEditingController();

  late PageController _pageController;
  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupEmailController.dispose();
    signupNameController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    super.dispose();
  }

  // Show SnackBar
  void showInSnackBar(String value, {Color? color}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: color ?? Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(26, 37, 111, 1),
                  Color.fromRGBO(19, 58, 148, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
              ),
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 80),
                _LogoWidget(screenHeight: screenHeight),
                const SizedBox(height: 20),
                _MenuBar(
                  pageController: _pageController,
                  onSignInButtonPress: _onSignInButtonPress,
                  onSignUpButtonPress: _onSignUpButtonPress,
                  left: left,
                  right: right,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) {
                      setState(() {
                        left = i == 0 ? Colors.black : Colors.white;
                        right = i == 0 ? Colors.white : Colors.black;
                      });
                    },
                    children: <Widget>[
                      _SignInForm(
                        emailController: loginEmailController,
                        passwordController: loginPasswordController,
                        obscureText: _obscureTextLogin,
                        toggleVisibility: _toggleLoginVisibility,
                        onLogin: _loginWithEmailAndPassword,
                      ),
                      _SignUpForm(
                        emailController: signupEmailController,
                        nameController: signupNameController,
                        passwordController: signupPasswordController,
                        confirmPasswordController:
                            signupConfirmPasswordController,
                        obscureText: _obscureTextSignup,
                        obscureConfirmText: _obscureTextSignupConfirm,
                        toggleVisibility: _toggleSignupVisibility,
                        toggleConfirmVisibility: _toggleSignupConfirmVisibility,
                        onSignUp: _signUpWithEmailAndPassword,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handle Sign-In button press
  void _onSignInButtonPress() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  // Handle Sign-Up button press
  void _onSignUpButtonPress() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.decelerate,
    );
  }

  // Toggle visibility of login password field
  void _toggleLoginVisibility() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  // Toggle visibility of signup password field
  void _toggleSignupVisibility() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  // Toggle visibility of signup confirm password field
  void _toggleSignupConfirmVisibility() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  // Login with Email and Password
  Future<void> _loginWithEmailAndPassword() async {
    try {
      var email = loginEmailController.text;
      var password = loginPasswordController.text;
      final user = await userAuth.signInWithEmail(email, password);
      if (user == null) {
        showInSnackBar('Invalid email or password', color: Colors.redAccent);
        return;
      }
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) return;

      Roles roles = Roles.fromSnapshot(userDoc['roles']);
      var gymUser = UserItem(roles: roles, fbUser: user);

      Logger.log('LOGIN', message: gymUser.toString());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: gymUser)),
      );
    } catch (e) {
      Logger.log('LOGIN_ERROR', message: e.toString());
      showInSnackBar('Error: $e', color: Colors.redAccent);
    }
  }

  // Sign-Up with Email and Password
  Future<void> _signUpWithEmailAndPassword() async {
    try {
      var email = signupEmailController.text;
      var password = signupPasswordController.text;
      var confirmPassword = signupConfirmPasswordController.text;

      if (password != confirmPassword) {
        showInSnackBar('Passwords do not match!', color: Colors.redAccent);
        return;
      }

      final newUser = await userAuth.createUserFromEmail(email, password);
      if (newUser != null) {
        await newUser.sendEmailVerification();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .set({
          'email': newUser.email,
          'emailVerified': newUser.emailVerified,
          'isOnboardingComplete': false,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
        );
      } else {
        showInSnackBar('Error: User not created', color: Colors.redAccent);
      }
    } catch (e) {
      Logger.log('SIGNUP_ERROR', message: e.toString());
      showInSnackBar('Error: $e', color: Colors.redAccent);
    }
  }
}

class _LogoWidget extends StatelessWidget {
  final double screenHeight;

  const _LogoWidget({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    double size = screenHeight > 750 ? 200 + (screenHeight - 800) : 100;
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
        image: DecorationImage(
          image: AssetImage('assets/memphisbjj-large.jpg'),
        ),
      ),
    );
  }
}

class _MenuBar extends StatelessWidget {
  final PageController pageController;
  final VoidCallback onSignInButtonPress;
  final VoidCallback onSignUpButtonPress;
  final Color left;
  final Color right;

  const _MenuBar({
    required this.pageController,
    required this.onSignInButtonPress,
    required this.onSignUpButtonPress,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: const BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: onSignInButtonPress,
                child: Text(
                  'Existing',
                  style: TextStyle(
                    color: left,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: onSignUpButtonPress,
                child: Text(
                  'New',
                  style: TextStyle(
                    color: right,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stateless widget for Sign-In form
class _SignInForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final VoidCallback toggleVisibility;
  final VoidCallback onLogin;

  const _SignInForm({
    required this.emailController,
    required this.passwordController,
    required this.obscureText,
    required this.toggleVisibility,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              SignInCard(
                emailController: emailController,
                passwordController: passwordController,
                obscureText: obscureText,
                toggleVisibility: toggleVisibility,
              ),
              SignInButton(onLogin: onLogin),
            ],
          ),
          const ForgotPasswordButton(),
        ],
      ),
    );
  }
}

// Sign-In card with email and password fields
class SignInCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscureText;
  final VoidCallback toggleVisibility;

  const SignInCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscureText,
    required this.toggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SizedBox(
          width: 300.0,
          height: 190.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              EmailField(
                controller: emailController,
                labelText: 'Email',
                icon: FontAwesomeIcons.envelope,
              ),
              const Divider(color: Colors.grey, height: 1.0),
              PasswordField(
                controller: passwordController,
                obscureText: obscureText,
                toggleVisibility: toggleVisibility,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sign-In button widget
class SignInButton extends StatelessWidget {
  final VoidCallback onLogin;

  const SignInButton({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 160.0,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          gradient: const LinearGradient(
            colors: [Color(0xFF333b72), Color(0xFF333b72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: MaterialButton(
          onPressed: onLogin,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
            child: Text(
              'LOGIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Stateless widget for Email Field
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;

  const EmailField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.black, size: 22.0),
          labelText: labelText,
          labelStyle: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}

// Stateless widget for Password Field
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback toggleVisibility;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.toggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: const Icon(
            FontAwesomeIcons.lock,
            size: 22.0,
            color: Colors.black,
          ),
          labelText: 'Password',
          suffixIcon: GestureDetector(
            onTap: toggleVisibility,
            child: Icon(
              obscureText ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
              size: 16.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// Stateless widget for Forgot Password Button
class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextButton(
        onPressed: () {}, // TODO: Implement Forgot Password
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}

// Sign-Up form widget
class _SignUpForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscureText;
  final bool obscureConfirmText;
  final VoidCallback toggleVisibility;
  final VoidCallback toggleConfirmVisibility;
  final VoidCallback onSignUp;

  const _SignUpForm({
    required this.emailController,
    required this.nameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscureText,
    required this.obscureConfirmText,
    required this.toggleVisibility,
    required this.toggleConfirmVisibility,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              SignUpCard(
                emailController: emailController,
                nameController: nameController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                obscureText: obscureText,
                obscureConfirmText: obscureConfirmText,
                toggleVisibility: toggleVisibility,
                toggleConfirmVisibility: toggleConfirmVisibility,
              ),
              SignUpButton(onSignUp: onSignUp),
            ],
          ),
        ],
      ),
    );
  }
}

// Sign-Up card widget
class SignUpCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscureText;
  final bool obscureConfirmText;
  final VoidCallback toggleVisibility;
  final VoidCallback toggleConfirmVisibility;

  const SignUpCard({
    super.key,
    required this.emailController,
    required this.nameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscureText,
    required this.obscureConfirmText,
    required this.toggleVisibility,
    required this.toggleConfirmVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SizedBox(
          width: 300.0,
          height: 280.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              EmailField(
                controller: emailController,
                labelText: 'Email',
                icon: FontAwesomeIcons.envelope,
              ),
              const Divider(color: Colors.grey, height: 1.0),
              PasswordField(
                controller: passwordController,
                obscureText: obscureText,
                toggleVisibility: toggleVisibility,
              ),
              const Divider(color: Colors.grey, height: 1.0),
              PasswordField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmText,
                toggleVisibility: toggleConfirmVisibility,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sign-Up button widget
class SignUpButton extends StatelessWidget {
  final VoidCallback onSignUp;

  const SignUpButton({super.key, required this.onSignUp});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 250.0,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          gradient: const LinearGradient(
            colors: [Color(0xFF333b72), Color(0xFF333b72)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: MaterialButton(
          onPressed: onSignUp,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
            child: Text(
              'SIGN UP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
