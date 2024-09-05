import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memphisbjj/screens/Home/index.dart';
import 'package:memphisbjj/screens/SignUp/UploadGeneralDetails/index.dart';
import 'package:memphisbjj/screens/SignUp/VerifyEmail/index.dart';
import 'package:memphisbjj/services/authentication.dart';
import 'package:memphisbjj/services/logger.dart';
import 'package:memphisbjj/theme/style.dart' as Theme;
import 'package:memphisbjj/utils/UserInformation.dart';
import 'package:memphisbjj/utils/UserItem.dart';
import 'package:memphisbjj/utils/bubble_indication_painter.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserAuth userAuth = UserAuth();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();
  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

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
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void showInSnackBar(String value, {Color? color}) {
    FocusScope.of(context).requestFocus(FocusNode());
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: color ?? Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: screenHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.LoginColors.loginGradientStart,
                  Theme.LoginColors.loginGradientEnd
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: _buildLogo(screenHeight),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: _buildMenuBar(context),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) {
                      if (i == 0) {
                        setState(() {
                          right = Colors.white;
                          left = Colors.black;
                        });
                      } else if (i == 1) {
                        setState(() {
                          right = Colors.black;
                          left = Colors.white;
                        });
                      }
                    },
                    children: <Widget>[
                      _buildSignIn(context),
                      _buildSignUp(context),
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

  Widget _buildLogo(double screenHeight) {
    return screenHeight > 600
        ? Container(
            height: screenHeight > 750 ? 200 + (screenHeight - 800) : 100,
            width: screenHeight > 750 ? 200 + (screenHeight - 800) : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.white, blurRadius: 55, spreadRadius: 55)
              ],
              image: DecorationImage(
                image: AssetImage("assets/memphisbjj-large.jpg"),
              ),
            ),
          )
        : Container(
            child: Text(
              "MEMPHIS JUDO & JIU-JITSU",
              style: TextStyle(color: Colors.white),
            ),
          );
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Existing",
                  style: TextStyle(
                      color: left,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "New",
                  style: TextStyle(
                      color: right,
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              _buildSignInCard(),
              _buildSignInButton(),
            ],
          ),
          _buildForgotPassword(),
          _buildOrSeparator(),
          _buildSocialLogin(),
        ],
      ),
    );
  }

  Widget _buildSignInCard() {
    return Card(
      elevation: 2.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: 300.0,
        height: 190.0,
        child: Column(
          children: <Widget>[
            _buildEmailField(loginEmailController, myFocusNodeEmailLogin),
            _buildSeparator(),
            _buildPasswordField(
              controller: loginPasswordController,
              focusNode: myFocusNodePasswordLogin,
              obscureText: _obscureTextLogin,
              toggleVisibility: _toggleLogin,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(
      TextEditingController controller, FocusNode focusNode) {
    return Padding(
      padding:
          EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
            fontFamily: "WorkSansSemiBold",
            fontSize: 16.0,
            color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon:
              Icon(FontAwesomeIcons.envelope, color: Colors.black, size: 22.0),
          hintText: "Email Address",
          hintStyle: TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 17.0),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    String? hintText, // Add the 'hintText' named parameter
  }) {
    return Padding(
      padding:
          EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
      child: TextField(
        focusNode: focusNode,
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(
            fontFamily: "WorkSansSemiBold",
            fontSize: 16.0,
            color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(FontAwesomeIcons.lock, size: 22.0, color: Colors.black),
          hintText: hintText, // Use the 'hintText' parameter
          hintStyle: TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 17.0),
          suffixIcon: GestureDetector(
            onTap: toggleVisibility,
            child: Icon(FontAwesomeIcons.eye, size: 15.0, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Container(
      margin: EdgeInsets.only(top: 170.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        boxShadow: [
          BoxShadow(
            color: Theme.LoginColors.loginGradientStart,
            offset: Offset(1.0, 6.0),
            blurRadius: 20.0,
          ),
          BoxShadow(
            color: Theme.LoginColors.loginGradientEnd,
            offset: Offset(1.0, 6.0),
            blurRadius: 20.0,
          ),
        ],
        gradient: LinearGradient(
          colors: [Color(0xFF333b72), Color(0xFF333b72)],
          begin: FractionalOffset(0.2, 0.2),
          end: FractionalOffset(1.0, 1.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: MaterialButton(
        splashColor:
            Colors.transparent, // Add the 'splashColor' named parameter
        highlightColor: Colors.transparent,
        color: Theme.LoginColors.loginGradientEnd,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
          child: Text(
            "LOGIN",
            style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                fontFamily: "WorkSansBold"),
          ),
        ),
        onPressed: _loginWithEmailAndPassword,
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: TextButton(
        onPressed: () {}, //TODO: Set up "Forgot password"
        child: Text(
          "Forgot Password?",
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: "WorkSansMedium"),
        ),
      ),
    );
  }

  Widget _buildOrSeparator() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildHorizontalLine(Colors.white10, Colors.white, 100.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              "Or",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontFamily: "WorkSansMedium"),
            ),
          ),
          _buildHorizontalLine(Colors.white, Colors.white10, 100.0),
        ],
      ),
    );
  }

  Widget _buildHorizontalLine(Color startColor, Color endColor, double width) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 1.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      width: width,
      height: 1.0,
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildSocialButton(FontAwesomeIcons.facebookF,
            "Coming soon! :P"), //TODO: Implement Facebook login
        _buildSocialButton(FontAwesomeIcons.google, _signInWithGoogle),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, dynamic onTap) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, right: 40.0),
      child: GestureDetector(
        onTap: () => onTap is String ? showInSnackBar(onTap) : onTap(),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(icon, color: Color(0xFF0084ff)),
        ),
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              _buildSignUpCard(),
              _buildSignUpButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpCard() {
    return Card(
      elevation: 2.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: 300.0,
        height: 280.0,
        child: Column(
          children: <Widget>[
            _buildEmailField(signupEmailController, myFocusNodeEmail),
            _buildSeparator(),
            _buildPasswordField(
              controller: signupPasswordController,
              focusNode: myFocusNodePassword,
              obscureText: _obscureTextSignup,
              toggleVisibility: _toggleSignup,
            ),
            _buildSeparator(),
            _buildPasswordField(
              controller: signupConfirmPasswordController,
              focusNode: FocusNode(),
              obscureText: _obscureTextSignupConfirm,
              toggleVisibility: _toggleSignupConfirm,
              hintText: "Confirmation",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 250.0,
      height: 1.0,
      color: Colors.grey[400],
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      margin: EdgeInsets.only(top: 260.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        boxShadow: [
          BoxShadow(
            color: Theme.LoginColors.loginGradientStart,
            offset: Offset(1.0, 6.0),
            blurRadius: 20.0,
          ),
          BoxShadow(
            color: Theme.LoginColors.loginGradientEnd,
            offset: Offset(1.0, 6.0),
            blurRadius: 20.0,
          ),
        ],
        gradient: LinearGradient(
          colors: [Color(0xFF333b72), Color(0xFF333b72)],
          begin: FractionalOffset(0.2, 0.2),
          end: FractionalOffset(1.0, 1.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: MaterialButton(
        highlightColor: Colors.transparent,
        splashColor: Theme.LoginColors.loginGradientEnd,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
          child: Text(
            "SIGN UP",
            style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                fontFamily: "WorkSansBold"),
          ),
        ),
        onPressed: _signUpWithEmailAndPassword,
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }

  Future<void> _loginWithEmailAndPassword() async {
    var email = loginEmailController.text;
    var password = loginPasswordController.text;
    userAuth.signInWithEmail(email, password).then((user) {
      if (user == null) {
        showInSnackBar("Invalid email or password", color: Colors.redAccent);
        return;
      }
      FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((doc) {
        Navigator.pop(context);
        Roles _roles = Roles.fromSnapshot(doc["roles"]);
        var _user = UserItem(roles: _roles, fbUser: user);

        Logger.log("LOGIN", message: _user.toString());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(user: _user),
          ),
        );
      });
    });
  }

  Future<void> _signUpWithEmailAndPassword() async {
    var email = signupEmailController.text;
    var password = signupPasswordController.text;
    var confirmPassword = signupConfirmPasswordController.text;

    if (password != confirmPassword) {
      showInSnackBar("Passwords do not match!", color: Colors.redAccent);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 4),
      content: Row(
        children: <Widget>[CircularProgressIndicator(), Text("  Loading...")],
      ),
    ));

    userAuth.createUserFromEmail(email, password).then((signedIn) {
      signedIn?.sendEmailVerification().then((_) {
        FirebaseFirestore.instance.collection("users").doc(signedIn.uid).set({
          "email": signedIn.email,
          "emailVerified": signedIn.emailVerified,
          "isOnboardingComplete": false,
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => VerifyEmailScreen(),
          ),
        );
      });
    }).catchError((onError) {
      showInSnackBar(onError.message);
    });
  }

  Future<void> _signInWithGoogle() async {
    Logger.log("AUTH", message: "Signed in with Google called");
    userAuth.signInWithGoogle().then((user) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((doc) {
        Navigator.pop(context);
        Roles _roles = Roles.fromSnapshot(doc["roles"]);
        var _user = UserItem(roles: _roles, fbUser: user);

        UserInformation userInfo = UserInformation(
          phoneNumber: "",
          address1: "",
          address2: "",
          city: "",
          state: "",
          zip: "",
        );

        Logger.log("LOGIN", message: _user.toString());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                UploadGeneralDetailsScreen(info: userInfo, isEdit: false),
          ),
        );
      });
    });
  }
}
