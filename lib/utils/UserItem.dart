import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserItem {
  final FirebaseUser fbUser;
  final Roles roles;
  UserItem({this.roles, this.fbUser});
}

class Roles {
  final bool instructor;
  final bool subscriber;
  final bool guardian;
  final bool admin;
  final Map<dynamic, dynamic> reference;

  Roles.fromMap(Map<dynamic, dynamic> map, {this.reference})
      : assert(map['instructor'] != null),
        assert(map['member'] != null),
        assert(map['guardian'] != null),
        assert(map['admin'] != null),
        instructor = map['instructor'],
        subscriber = map['subscriber'],
        guardian = map['guardian'],
        admin = map['admin'];

  Roles.fromSnapshot(Map<dynamic, dynamic> snapshot)
      : this.fromMap(snapshot, reference: snapshot);
}
