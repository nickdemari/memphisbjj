import 'package:android_intent_plus/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/onboarding/screens/upload-profile-picture-screen/upload-profile-picture-screen.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void showInSnackBar(String value, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        backgroundColor: color,
      ),
    );
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
    if (state == AppLifecycleState.resumed) {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      User? reloadedUser = FirebaseAuth.instance.currentUser;
      if (reloadedUser?.emailVerified ?? false) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(reloadedUser!.uid)
            .update({'emailVerified': reloadedUser.emailVerified});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const UploadProfilePicScreen(),
          ),
        );
      } else {
        showInSnackBar('Email is not verified', Colors.redAccent);
      }
    }
  }

  void _openEmail() {
    if (Theme.of(context).platform == TargetPlatform.android) {
      const AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.APP_EMAIL',
      );
      intent.launch();
    } else {
      launch('message:');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(14.0),
          child: const Text(
            'Tap the button below to open your default email app and verify your email',
            style: TextStyle(fontSize: 24.0),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEmail,
        child: const Icon(Icons.email),
      ),
    );
  }
}
