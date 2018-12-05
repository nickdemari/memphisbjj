import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'package:memphisbjj/screens/Home/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memphisbjj/screens/Login/index.dart';
import 'package:memphisbjj/utils/UserItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SplashScreenPage extends StatefulWidget {
  final int seconds;
  SplashScreenPage({Key key, this.seconds});

  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> {
  final FirebaseAnalytics _analytics = new FirebaseAnalytics();

  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: widget.seconds),
            () {
             _handleCurrentScreen();
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: new InkWell(
        child: new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Container(
              decoration: BoxDecoration(color: Colors.white),
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Expanded(
                  flex: 2,
                  child: new Container(
                      child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: new AssetImage('assets/memphisbjj-large.jpg'),
                        radius: 150.0,
                      ),
                      new Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                      ),
                    ],
                  )),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.black12),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                      ),
                      Text("Loading", style: new TextStyle()),
                      new Center(
                        child: Text("Now", style: new TextStyle()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleCurrentScreen() async {
    var currentUser = await FirebaseAuth.instance.currentUser();
    print(currentUser.toString());
    if (currentUser == null) {
      _analytics.logLogin();
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
    } else {
      QuerySnapshot fbUsers = await Firestore.instance.collection("users").where("firebaseUid", isEqualTo: currentUser.uid).getDocuments();
      if (fbUsers.documents.length == 0) {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
      } else {
        DocumentSnapshot doc = fbUsers.documents[0];
        Roles _roles = Roles.fromSnapshot(doc["roles"]);
        var _user = UserItem(roles: _roles, fbUser: currentUser);

        _analytics.logLogin();
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => HomeScreen(user: _user)));
      }
    }
  }
}
