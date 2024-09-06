import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class UserData {
  final String firstName;
  final String lastName;
  final String email;
  final String uid;
  final String password;
  final String phoneNumber;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String zip;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.uid,
    required this.password,
    required this.phoneNumber,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.zip,
  });

  // copy
  UserData copy({
    String? firstName,
    String? lastName,
    String? email,
    String? uid,
    String? password,
    String? phoneNumber,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zip,
  }) {
    return UserData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
    );
  }
}

class UserAuth {
  String statusMsg = 'Account Created Successfully';
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null; // The user canceled the sign-in
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    final UserCredential userCredential =
        await auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      final Map<String, dynamic> newUser = {
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
          'type': user.providerData[0].providerId,
          'uid': user.providerData[0].uid,
        },
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(newUser);

      await _analytics.logLogin();
    }

    return user;
  }

  Future<User?> signInAnonymously() async {
    final UserCredential userCredential = await auth.signInAnonymously();
    final User? user = userCredential.user;

    if (user != null) {
      await _analytics.logEvent(name: 'anonymous_user_login');
    }

    return user;
  }

  Future<User?> getLoggedInUser() async {
    return auth.currentUser;
  }

  Future<User?> createUserFromEmail(String email, String password) async {
    final UserCredential userCredential =
        await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }
}
