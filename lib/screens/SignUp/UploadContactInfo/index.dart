import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memphisbjj/components/Buttons/roundedButton.dart';
import 'package:memphisbjj/components/TextFields/inputField.dart';
import 'package:memphisbjj/screens/SignUp/UploadGeneralDetails/index.dart';
import 'package:memphisbjj/services/authentication.dart';
import 'package:memphisbjj/services/validations.dart';
import 'package:memphisbjj/utils/UserInformation.dart';

class UploadContactInfoScreen extends StatefulWidget {
  @override
  _UploadContactInfoScreenState createState() =>
      _UploadContactInfoScreenState();
}

class _UploadContactInfoScreenState extends State<UploadContactInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserData newUser = UserData();
  bool _autovalidate = false;
  Validations _validations = Validations();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      var user = await FirebaseAuth.instance.currentUser();
      UserUpdateInfo info = UserUpdateInfo();
      info.displayName = "${newUser.firstName.trim()} ${newUser.lastName.trim()}";
      user.updateProfile(info);

      Map<String, dynamic> userDetails = Map.from({
        "displayName": info.displayName,
        "email": user.email,
        "emailVerified": user.isEmailVerified,
        "firebaseUid": user.uid,
        "photoUrl": user.photoUrl,
        "roles": Map.from({
          "admin": false,
          "guardian": false,
          "member": false,
          "instructor": false,
          "subscriber": true
        }),
        "socialData": Map.from({
          "type": "email",
          "uid": user.email,
        })
      });
      await Firestore.instance
          .collection("users")
          .document(user.uid)
          .setData(userDetails, merge: true);

      UserInformation userInfo = UserInformation(
        phoneNumber: "",
        address1: "",
        address2: "",
        city: "",
        state: "",
        zip: "",
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => UploadGeneralDetailsScreen(info: userInfo,)));
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    //print(context.widget.toString());
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
                          "What's your name?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
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
                                hintText: "First Name",
                                obscureText: false,
                                textInputType: TextInputType.text,
                                icon: Icons.perm_identity,
                                iconColor: Colors.black54,
                                bottomMargin: 20.0,
                                validateFunction: _validations.validateField,
                                onSaved: (String first) {
                                  newUser.firstName = first;
                                },
                              ),
                              InputField(
                                hintText: "Last Name",
                                obscureText: false,
                                textInputType: TextInputType.text,
                                icon: Icons.perm_identity,
                                iconColor: Colors.black54,
                                bottomMargin: 40.0,
                                validateFunction: _validations.validateField,
                                onSaved: (String last) {
                                  newUser.lastName = last;
                                },
                              ),
                              RoundedButton(
                                buttonName: "Continue",
                                onTap: _handleSubmitted,
                                width: screenSize.width,
                                height: 50.0,
                                bottomMargin: 10.0,
                                borderWidth: 1.0,
                                buttonColor: Color(0xFF1a256f),
                              )
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
