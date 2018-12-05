import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memphisbjj/components/TextFields/inputField.dart';
import 'package:memphisbjj/components/Buttons/roundedButton.dart';
import 'package:memphisbjj/screens/SignUp/VerifyEmail/index.dart';
import 'package:memphisbjj/services/validations.dart';
import 'package:memphisbjj/services/authentication.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserData newUser = UserData();
  UserAuth Auth = UserAuth();
  bool _autovalidate = false;
  Validations _validations = Validations();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(duration: Duration(seconds: 4), content:
          Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Text("  Loading...")
            ],
          ),
          ));
//      Auth.createUserFromEmail(newUser).then((signedIn) {
//
//        FirebaseAuth.instance.currentUser().then((user) {
//          user.sendEmailVerification().then((value) {
//            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => VerifyEmailScreen()));
//          });
//        });
//      }).catchError((PlatformException onError) {
//        showInSnackBar(onError.message);
//      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    height: screenSize.height / 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "CREATE ACCOUNT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    )),
                SizedBox(
                  height: screenSize.height / 2,
                  child: Column(
                    children: <Widget>[
                      Form(
                          key: _formKey,
                          autovalidate: _autovalidate,
                          //onWillPop: _warnUserAboutInvalidData,
                          child: Column(
                            children: <Widget>[
                              InputField(
                                  hintText: "Email",
                                  obscureText: false,
                                  textInputType: TextInputType.emailAddress,
                                  icon: Icons.mail_outline,
                                  iconColor: Colors.white,
                                  bottomMargin: 20.0,
                                  validateFunction: _validations.validateEmail,
                                  onSaved: (String email) {
                                    newUser.email = email;
                                  }),
                              InputField(
                                  hintText: "Password",
                                  obscureText: true,
                                  textInputType: TextInputType.text,
                                  icon: Icons.lock_open,
                                  iconColor: Colors.white,
                                  bottomMargin: 40.0,
                                  validateFunction:
                                  _validations.validatePassword,
                                  onSaved: (String password) {
                                    newUser.password = password;
                                  }),
                              RoundedButton(
                                  buttonName: "Continue",
                                  onTap: _handleSubmitted,
                                  width: screenSize.width,
                                  height: 50.0,
                                  bottomMargin: 10.0,
                                  borderWidth: 1.0)
                            ],
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}