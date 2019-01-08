import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memphisbjj/screens/Error/index.dart';
import 'package:memphisbjj/screens/Home/index.dart';
import 'package:memphisbjj/screens/Login/index.dart';
import 'package:memphisbjj/screens/SignUp/UploadProfilePic/index.dart';
import 'package:memphisbjj/screens/SignUp/VerifyEmail/index.dart';
import 'package:memphisbjj/services/messaging.dart';
import 'package:memphisbjj/utils/UserItem.dart';
import 'package:package_info/package_info.dart';

class SplashScreenPage extends StatefulWidget {
  final int seconds;
  SplashScreenPage({Key key, this.seconds});

  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final FirebaseAnalytics _analytics = new FirebaseAnalytics();
  FirebaseUser _currentUser;
  PackageInfo _packageInfo = new PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    _initPackageInfo();
    Timer(
        Duration(seconds: widget.seconds),
            () {
          _handleCurrentScreen();
        }
    );
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
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

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _handleCurrentScreen() async {
    try {
      DocumentSnapshot fbVersionObject = await Firestore.instance.collection("versioning").document("XzvMRYCsyDXlxXTEVMac").get();
      if (_packageInfo.version != fbVersionObject["displayVersion"] || _packageInfo.buildNumber != fbVersionObject["build"]) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => ErrorScreen(title: "Update Required", message: "Please update to get the newest content",)));
        return;
      }
      _currentUser = await FirebaseAuth.instance.currentUser();
      if (_currentUser != null) await _currentUser.reload();

      if (_currentUser == null) {
        _analytics.logLogin();

        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
      } else {
        DocumentSnapshot fbUser = await Firestore.instance.collection("users").document(_currentUser.uid).get();
        if (!fbUser.exists) {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
          return;
        } else {
          final msgToken = await Messaging.getMessagingToken();
          final Map<String, dynamic> userVersion = Map.from({
            "usersCurrentApp": Map.from({
              "device": Map.from({
                "android": Map.from({
                  "installed": Platform.isAndroid,
                  "lastOpened": Platform.isAndroid ? DateTime.now() : null,
                  "version": Platform.isAndroid ? "${_packageInfo.version}" : "",
                  "build": Platform.isAndroid ? _packageInfo.buildNumber : "",
                  "fcmToken": Platform.isAndroid ? msgToken : ""
                }),
                "iOS": Map.from({
                  "installed": Platform.isIOS,
                  "lastOpened": Platform.isIOS ? DateTime.now() : null,
                  "version": Platform.isIOS ? _packageInfo.version : "",
                  "build": Platform.isIOS ? _packageInfo.buildNumber : "",
                  "fcmToken": Platform.isIOS ? msgToken : ""
                })
              })
            })
          });
          await fbUser.reference.updateData(userVersion);

          if(!fbUser["emailVerified"]) {
            Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => VerifyEmailScreen()));
            return;
          }

          if (fbUser["isOnboardingComplete"] != null) {
            if (fbUser["isOnboardingComplete"]) {
              Roles _roles = Roles.fromSnapshot(fbUser["roles"]);
              var _user = UserItem(roles: _roles, fbUser: _currentUser);

              _analytics.logLogin();
              Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => HomeScreen(user: _user)));
              return;
            } else {
              Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => UploadProfilePicScreen()));
              return;
            }
          }
        }
      }
    } on PlatformException catch (e) {
      if (e.code == "sign_in_failed") {
        _analytics.logEvent(name: "login-error", parameters: Map.from({
          "code": e.code,
          "message": e.message
        }));
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
        return;
      } else {
        _analytics.logEvent(name: "unknown-error", parameters: Map.from({
          "code": e.code,
          "message": e.message
        }));
        Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
        return;
      }
    }
  }
}
