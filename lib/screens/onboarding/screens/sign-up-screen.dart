import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memphisbjj/components/text-fields/branded-input-field.dart';
import 'package:memphisbjj/components/buttons/rounded-button.dart';
import 'package:memphisbjj/screens/onboarding/screens/verify-email-screen/verify-email-screen.dart';
import 'package:memphisbjj/services/validations.dart';
import 'package:memphisbjj/services/authentication.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen>
    with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserData newUser = UserData(
    firstName: '',
    lastName: '',
    email: '',
    uid: '',
    password: '',
    phoneNumber: '',
    address1: '',
    address2: '',
    city: '',
    state: '',
    zip: '',
  );
  UserAuth auth = UserAuth();
  bool _autovalidate = false;
  final Validations _validations = Validations();

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !form.validate()) {
      setState(() {
        _autovalidate = true; // Start validating on every change.
      });
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Loading...'),
            ],
          ),
        ),
      );

      try {
        await auth.createUserFromEmail(newUser.email, newUser.password);
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.sendEmailVerification();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const VerifyEmailScreen(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        showInSnackBar(e.message ?? 'An error occurred, please try again.');
      } on PlatformException catch (e) {
        showInSnackBar(e.message ?? 'An error occurred, please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: screenSize.height / 2,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'CREATE ACCOUNT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenSize.height / 2,
                child: Column(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      autovalidateMode: _autovalidate
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                        children: <Widget>[
                          BrandedInputField(
                            hintText: 'Email',
                            obscureText: false,
                            textInputType: TextInputType.emailAddress,
                            icon: Icons.mail_outline,
                            iconColor: Colors.white,
                            bottomMargin: 20.0,
                            validateFunction: _validations.validateEmail,
                            onSaved: (String? email) {
                              newUser.copy(email: email);
                            },
                            textStyle:
                                const TextStyle(), // Provide a non-null value for textStyle
                            hintStyle: const TextStyle(),
                          ),
                          BrandedInputField(
                            hintText: 'Password',
                            obscureText: true,
                            textInputType: TextInputType.text,
                            icon: Icons.lock_open,
                            iconColor: Colors.white,
                            bottomMargin: 40.0,
                            validateFunction: _validations.validatePassword,
                            onSaved: (String? password) {
                              newUser.copy(password: password);
                            },
                            textStyle:
                                const TextStyle(), // Provide a non-null value for textStyle
                            hintStyle: const TextStyle(),
                          ),
                          RoundedButton(
                            buttonName: 'Continue',
                            onTap: _handleSubmitted,
                            width: screenSize.width,
                            height: 50.0,
                            bottomMargin: 10.0,
                            borderWidth: 1.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
