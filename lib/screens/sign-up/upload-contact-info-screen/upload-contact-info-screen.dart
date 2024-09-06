import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/components/buttons/rounded-button.dart';
import 'package:memphisbjj/components/text-fields/branded-input-field.dart';
import 'package:memphisbjj/screens/sign-up/upload-general-details-screen/upload-general-details-screen.dart';
import 'package:memphisbjj/services/authentication.dart';
import 'package:memphisbjj/services/validations.dart';
import 'package:memphisbjj/utils/user-information.dart';

class UploadContactInfoScreen extends StatefulWidget {
  const UploadContactInfoScreen({Key? key}) : super(key: key);

  @override
  _UploadContactInfoScreenState createState() =>
      _UploadContactInfoScreenState();
}

class _UploadContactInfoScreenState extends State<UploadContactInfoScreen> {
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
  bool _autovalidate = false;
  final Validations _validations = Validations();

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  void _handleSubmitted() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      setState(() {
        _autovalidate = true; // Start validating on every change.
      });
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.updateProfile(
        displayName: '${newUser.firstName.trim()} ${newUser.lastName.trim()}',
      );

      Map<String, dynamic> userDetails = {
        'displayName': user.displayName,
        'email': user.email,
        'emailVerified': user.emailVerified,
        'firebaseUid': user.uid,
        'photoUrl': user.photoURL,
        'roles': {
          'admin': false,
          'guardian': false,
          'member': false,
          'instructor': false,
          'subscriber': true,
        },
        'socialData': {
          'type': 'email',
          'uid': user.email,
        },
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userDetails, SetOptions(merge: true));

      UserInformation userInfo = UserInformation(
        phoneNumber: '',
        address1: '',
        address2: '',
        city: '',
        state: '',
        zip: '',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              UploadGeneralDetailsScreen(info: userInfo, isEdit: false),
        ),
      );
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
                      "What's your name?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
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
                            hintText: 'First Name',
                            obscureText: false,
                            textInputType: TextInputType.text,
                            icon: Icons.perm_identity,
                            iconColor: Colors.black54,
                            bottomMargin: 20.0,
                            textStyle:
                                const TextStyle(), // Add the required 'textStyle' argument
                            hintStyle:
                                const TextStyle(), // Add the required 'hintStyle' argument
                            validateFunction: (String? value) =>
                                _validations.validateField(value!),
                            onSaved: (String? first) {
                              newUser.copy(firstName: first);
                            },
                          ),
                          BrandedInputField(
                            hintText: 'Last Name',
                            obscureText: false,
                            textInputType: TextInputType.text,
                            icon: Icons.perm_identity,
                            iconColor: Colors.black54,
                            bottomMargin: 40.0,
                            textStyle:
                                const TextStyle(), // Add the required 'textStyle' argument
                            hintStyle:
                                const TextStyle(), // Add the required 'hintStyle' argument
                            validateFunction: (String? value) =>
                                _validations.validateField(value!),
                            onSaved: (String? last) {
                              newUser.copy(lastName: last);
                            },
                          ),
                          RoundedButton(
                            buttonName: 'Continue',
                            onTap: _handleSubmitted,
                            width: screenSize.width,
                            height: 50.0,
                            bottomMargin: 10.0,
                            borderWidth: 1.0,
                            buttonColor: const Color(0xFF1a256f),
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
