import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/SignUp/UploadProfilePic/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent/android_intent.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();

}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void showInSnackBar(String value, Color color) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value), backgroundColor: color,));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if(state == AppLifecycleState.resumed) {
      var user = await FirebaseAuth.instance.currentUser();
      await user.reload();
      var reloadedUser = await FirebaseAuth.instance.currentUser();
      if(reloadedUser.isEmailVerified) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => UploadProfilePicScreen()));
      } else {
        showInSnackBar("Email is not verified", Colors.redAccent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void _openEmail() {
      bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
      if(isAndroid) {
        final AndroidIntent intent = const AndroidIntent(
          action: 'android.intent.action.MAIN', category: "android.intent.category.APP_EMAIL"
        );
        intent.launch();
      } else {
        launch("message:");
      }
    }
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Verify Email"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(14.0),
          child: Text("Tap the button below to open your default email app and verify your email", style: TextStyle(fontSize: 24.0),),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.email),
          onPressed: _openEmail
      ),
    );
  }
}