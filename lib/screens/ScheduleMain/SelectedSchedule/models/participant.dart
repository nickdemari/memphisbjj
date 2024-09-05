import 'package:cloud_firestore/cloud_firestore.dart';

class Participant {
  final String userUid;
  final String classUid;
  final DateTime addedOn;
  final bool onSchedule;
  final bool checkedIn;
  final DateTime lastUpdatedOn;
  final String fullName;
  final String? photoUrl;

  Participant({
    required this.userUid,
    required this.classUid,
    required this.addedOn,
    required this.onSchedule,
    required this.checkedIn,
    required this.lastUpdatedOn,
    required this.fullName,
    this.photoUrl,
  });

  // Method to convert a Participant instance to a map
  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'classUid': classUid,
      'addedOn': addedOn,
      'onSchedule': onSchedule,
      'checkedIn': checkedIn,
      'lastUpdatedOn': lastUpdatedOn,
      'fullName': fullName,
      'photoUrl': photoUrl,
    };
  }

  // Method to create a Participant instance from a map
  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      userUid: map['userUid'],
      classUid: map['classUid'],
      addedOn: (map['addedOn'] as Timestamp).toDate(),
      onSchedule: map['onSchedule'],
      checkedIn: map['checkedIn'],
      lastUpdatedOn: (map['lastUpdatedOn'] as Timestamp).toDate(),
      fullName: map['fullName'],
      photoUrl: map['photoUrl'],
    );
  }
}
