import 'package:flutter/material.dart';
import 'package:memphisbjj/components/Buttons/googleSignInButton.dart';
import 'package:memphisbjj/screens/SignUp/index.dart';
import 'package:memphisbjj/services/authentication.dart';
import 'package:memphisbjj/services/logger.dart';
import 'package:memphisbjj/screens/Home/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memphisbjj/utils/UserItem.dart';
import 'dart:core';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  final distanceToMjj;

  const LoginScreen({Key key, this.distanceToMjj}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  BuildContext context;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserAuth userAuth = UserAuth();
  bool autoValidate = false;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(duration: Duration(milliseconds: 8000), content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
                    child: SizedBox(
                      height: 48.0,
                      child: RaisedButton(
                        onPressed: () => _signInAnonymously(),
                        child: Text('Explore'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
                    child: SizedBox(
                      height: 48.0,
                      child: GoogleSignInButton(
                        onPressed: () => _signInWithGoogle(),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: double.infinity),
                    child: SizedBox(
                      height: 48.0,
                      child: RaisedButton(
                        color: Color(0xff031D44),
                        onPressed: () => _signUpWithEmail(),
                        child: Text('Sign Up', style: TextStyle(color: Colors.white),),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        key: _scaffoldKey,
        body: Container(
          padding: EdgeInsets.fromLTRB(16.0, 72.0, 16.0, 16.0),
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: <Widget>[
              Container(
                height: screenSize.height / 2.18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: CircleAvatar(
                        backgroundImage:
                            AssetImage("assets/memphisbjj-large.jpg"),
                        radius: 150.0,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  static const String TAG = "AUTH";

  Future<Null> _signInWithGoogle() async {
    Logger.log(TAG, message: "Signed in with google called");
    userAuth.signInWithGoogle().then((user) {
      var bottomSheet = _scaffoldKey.currentState.showBottomSheet(
        (BuildContext context) => Row(
              children: [
                new CircularProgressIndicator(),
                new Text("Loading"),
              ],
            ),
      );
      Timer(Duration(seconds: 2), () {
        Future<QuerySnapshot> fbUser = Firestore.instance
            .collection("users")
            .where("firebaseUid", isEqualTo: user.uid)
            .getDocuments();
        fbUser.then((u) {
          bottomSheet.close();
          DocumentSnapshot doc = u.documents[0];
          Roles _roles = Roles.fromSnapshot(doc["roles"]);
          var _user = UserItem(roles: _roles, fbUser: user);

          Logger.log("LOGIN", message: _user.toString());
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen(user: _user)));
        });
      });
    });
  }

  Future<Null> _signInAnonymously() async {
    Logger.log(TAG, message: "Signed in anonymously called");
    userAuth.signInAnonymously().then((user) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(
                    anonymousUser: user,
                  )));
    });
  }

  Future<Null> _signUpWithEmail() async {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => SignUpScreen()));
  }
}
