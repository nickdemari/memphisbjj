import 'package:firebase_auth/firebase_auth.dart';

class UserItem {
  final User fbUser;
  final Roles roles;
  UserItem({required this.roles, required this.fbUser});

  bool get isGuardian => roles.guardian;
  bool get isAdmin => roles.admin;
  bool get isInstructor => roles.instructor;
  bool get isSubscriber => roles.subscriber;
  bool get isMember => roles.subscriber;
  bool get isAnonymous => fbUser.isAnonymous;
  bool get isEmailVerified => fbUser.emailVerified;

  // from json
  UserItem.fromJson(Map<String, dynamic> json)
      : fbUser = json['fbUser'],
        roles = json['roles'];
}

class Roles {
  final bool instructor;
  final bool subscriber;
  final bool guardian;
  final bool admin;
  final Map<dynamic, dynamic> reference;

  Roles.fromMap(Map<dynamic, dynamic> map, {required this.reference})
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
