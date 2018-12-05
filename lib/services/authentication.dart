import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class UserData {
  String firstName;
  String lastName;
  String email;
  String uid;
  String password;
  String phoneNumber;
  String address1;
  String address2;
  String city;
  String state;
  String zip;

  UserData({
    this.firstName,
    this.lastName,
    this.email,
    this.uid,
    this.password,
    this.phoneNumber,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zip,
  });
}

class UserAuth {
  String statusMsg = "Account Created Successfully";
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAnalytics _analytics = new FirebaseAnalytics();

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await auth.signInWithGoogle(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    Map<String, dynamic> newUser = Map.from({
      "displayName": user.displayName,
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
        "type": user.providerData[0].providerId,
        "uid": user.providerData[0].uid,
      })
    });

    await Firestore.instance
        .collection("users")
        .document(user.uid)
        .setData(newUser);
    _analytics.logLogin();

    return user;
  }

  Future<FirebaseUser> signInAnonymously() async {
    final FirebaseUser user = await auth.signInAnonymously();
    _analytics.logEvent(name: "anonymous-user-login");
    return user;
  }

  Future<FirebaseUser> getLoggedInUser() async {
    var test = await auth.currentUser();
    return test;
  }

  Future<FirebaseUser> createUserFromEmail(String email, String password) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return await firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<FirebaseUser> signInWithEmail(String username, String password) async {
    FirebaseAuth user = FirebaseAuth.instance;
    return await user.signInWithEmailAndPassword(email: username, password: password);
  }
}
