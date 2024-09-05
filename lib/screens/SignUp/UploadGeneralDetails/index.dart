import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memphisbjj/components/Buttons/roundedButton.dart';
import 'package:memphisbjj/components/TextFields/inputField.dart';
import 'package:memphisbjj/screens/Home/index.dart';
import 'package:memphisbjj/services/authentication.dart';
import 'package:memphisbjj/services/validations.dart';
import 'package:memphisbjj/utils/NumberTextInputFormatter.dart';
import 'package:memphisbjj/utils/UserInformation.dart';
import 'package:memphisbjj/utils/UserItem.dart';

class UploadGeneralDetailsScreen extends StatefulWidget {
  final bool isEdit;
  final UserInformation info;

  UploadGeneralDetailsScreen({required this.isEdit, required this.info});

  @override
  _UploadGeneralDetailsState createState() => _UploadGeneralDetailsState();
}

class _UploadGeneralDetailsState extends State<UploadGeneralDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserData newUser = UserData(
    phoneNumber: '',
    address1: '',
    address2: '',
    city: '',
    state: '',
    zip: '',
    firstName: '',
    lastName: '',
    email: '',
    uid: '',
    password: '',
  );
  bool _autovalidate = false;
  Validations _validations = Validations();
  NumberTextInputFormatter _mobileFormatter = NumberTextInputFormatter();

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

      FocusScope.of(context).unfocus();

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      Map<String, dynamic> userInfo = {
        "information": {
          "phoneNumber": newUser.phoneNumber,
          "address1": newUser.address1.trim(),
          "address2": newUser.address2.trim(),
          "city": newUser.city.trim(),
          "state": newUser.state.trim().toUpperCase(),
          "zip": newUser.zip,
        },
        "isOnboardingComplete": true
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update(userInfo);

      // Navigate to the next screen
      Roles roles = Roles.fromSnapshot(doc["roles"]);
      var userItem = UserItem(roles: roles, fbUser: user);

      if (widget.isEdit) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(user: userItem),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: screenSize.height / 15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "How can we contact you?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      autovalidateMode: _autovalidate
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                        children: <Widget>[
                          InputField(
                            hintText: "Phone",
                            obscureText: false,
                            textInputType: TextInputType.phone,
                            icon: Icons.phone,
                            iconColor: Colors.black87,
                            bottomMargin: 40.0,
                            validateFunction: _validations.validatePhoneNumber,
                            formatters: <TextInputFormatter>[
                              _mobileFormatter,
                            ],
                            maxLength: 12,
                            onSaved: (String? phone) {
                              newUser.copy(
                                phoneNumber: phone,
                              );
                            },
                            textStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            hintStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                          ),
                          InputField(
                            hintText: "Address 1",
                            obscureText: false,
                            textInputType: TextInputType.text,
                            icon: Icons.location_on,
                            iconColor: Colors.black87,
                            bottomMargin: 20.0,
                            validateFunction: (String? value) =>
                                _validations.validateEmpty(value ?? ''),
                            onSaved: (String? addy1) {
                              newUser.copy(
                                address1: addy1,
                              );
                            },
                            textStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            hintStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                          ),
                          InputField(
                            hintText: "Address 2",
                            obscureText: false,
                            textInputType: TextInputType.text,
                            icon: Icons.location_on,
                            iconColor: Colors.black87,
                            bottomMargin: 20.0,
                            onSaved: (String? addy2) {
                              newUser.copy(
                                address2: addy2,
                              );
                            },
                            textStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            hintStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            fromProfile: widget.info.address2,
                          ),
                          InputField(
                            hintText: "City",
                            obscureText: false,
                            textInputType: TextInputType.text,
                            icon: Icons.location_city,
                            iconColor: Colors.black87,
                            bottomMargin: 20.0,
                            validateFunction: _validations.validateField,
                            onSaved: (String? city) {
                              newUser.copy(
                                city: city,
                              );
                            },
                            textStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            hintStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            fromProfile: widget.info.city,
                          ),
                          InputField(
                            hintText: "State",
                            obscureText: false,
                            textInputType: TextInputType.text,
                            icon: Icons.location_city,
                            iconColor: Colors.black87,
                            bottomMargin: 20.0,
                            validateFunction: _validations.validateField,
                            onSaved: (String? state) {
                              newUser.copy(
                                state: state,
                              );
                            },
                            textStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            hintStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            fromProfile: widget.info.state,
                          ),
                          InputField(
                            hintText: "Zip",
                            obscureText: false,
                            textInputType: TextInputType.text,
                            icon: Icons.location_city,
                            iconColor: Colors.black87,
                            bottomMargin: 40.0,
                            validateFunction: _validations.validateZipCode,
                            onSaved: (String? zip) {
                              newUser.copy(
                                zip: zip,
                              );
                            },
                            textStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            hintStyle:
                                TextStyle(), // Provide a non-null TextStyle value
                            fromProfile: widget.info.zip,
                          ),
                          RoundedButton(
                            buttonName: "Continue",
                            onTap: _handleSubmitted,
                            width: screenSize.width,
                            height: 50.0,
                            bottomMargin: 0.0,
                            borderWidth: 1.0,
                            buttonColor: Color(0xFF1a256f),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
