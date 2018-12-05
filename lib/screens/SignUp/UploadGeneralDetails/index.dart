import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/components/Buttons/roundedButton.dart';
import 'package:memphisbjj/components/TextFields/inputField.dart';
import 'package:memphisbjj/screens/Home/index.dart';
import 'package:memphisbjj/services/authentication.dart';
import 'package:memphisbjj/services/validations.dart';
import 'package:memphisbjj/utils/UserItem.dart';

class UploadGeneralDetailsScreen extends StatefulWidget {
  @override
  _UploadGeneralDetailsState createState() => _UploadGeneralDetailsState();
}

class _UploadGeneralDetailsState extends State<UploadGeneralDetailsScreen> {
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

      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      DocumentSnapshot doc =
          await Firestore.instance.collection("users").document(user.uid).get();

      Map<String, dynamic> userInfo = Map.from({
        "information": Map.from({
          "phoneNumber": newUser.phoneNumber,
          "address1": newUser.address1,
          "address2": newUser.address2,
          "city": newUser.city,
          "state": newUser.state,
          "zip": newUser.zip
        }),
      });
      await Firestore.instance
          .collection("users")
          .document(user.uid)
          .updateData(userInfo);

      //TODO "Add children if guardian" screen
      Roles _roles = Roles.fromSnapshot(doc["roles"]);
      var _user = UserItem(roles: _roles, fbUser: user);
      print(_user.toString());
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(user: _user)));
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
                  )),
              SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Form(
                        key: _formKey,
                        autovalidate: _autovalidate,
                        //onWillPop: _warnUserAboutInvalidData,
                        child: Column(
                          children: <Widget>[
                            InputField(
                                hintText: "Phone",
                                obscureText: false,
                                textInputType: TextInputType.text,
                                icon: Icons.phone,
                                iconColor: Colors.black87,
                                bottomMargin: 40.0,
                                validateFunction:
                                _validations.validatePhoneNumber,
                                onSaved: (String phone) {
                                  newUser.phoneNumber = phone;
                                }),
                            InputField(
                                hintText: "Address 1",
                                obscureText: false,
                                textInputType: TextInputType.text,
                                icon: Icons.location_on,
                                iconColor: Colors.black87,
                                bottomMargin: 20.0,
                                validateFunction: _validations.validateEmpty,
                                onSaved: (String addy1) {
                                  newUser.address1 = addy1;
                                }),
                            InputField(
                                hintText: "Address 2",
                                obscureText: false,
                                textInputType: TextInputType.text,
                                icon: Icons.location_on,
                                iconColor: Colors.black87,
                                bottomMargin: 20.0,
                                onSaved: (String addy2) {
                                  newUser.address2 = addy2;
                                }),
                            InputField(
                                hintText: "City",
                                obscureText: false,
                                textInputType: TextInputType.text,
                                icon: Icons.location_city,
                                iconColor: Colors.black87,
                                bottomMargin: 20.0,
                                validateFunction: _validations.validateField,
                                onSaved: (String city) {
                                  newUser.city = city;
                                }),
                            InputField(
                                hintText: "State",
                                obscureText: false,
                                textInputType: TextInputType.text,
                                icon: Icons.location_city,
                                iconColor: Colors.black87,
                                bottomMargin: 20.0,
                                validateFunction: _validations.validateField,
                                onSaved: (String state) {
                                  newUser.state = state;
                                }),
                            InputField(
                                hintText: "Zip",
                                obscureText: false,
                                textInputType: TextInputType.text,
                                icon: Icons.location_city,
                                iconColor: Colors.black87,
                                bottomMargin: 40.0,
                                validateFunction: _validations.validateZipCode,
                                onSaved: (String zip) {
                                  newUser.zip = zip;
                                }),
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
