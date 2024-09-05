class RegisteredClass {
  final String uid;
  final DateTime addedOn;
  final bool onSchedule;
  final bool checkedIn;
  final DateTime lastUpdatedOn;
  final String className;
  final String displayDateTime;
  final DateTime rawDateTime;
  final String instructor;
  final bool visible;

  RegisteredClass({
    required this.uid,
    required this.addedOn,
    required this.onSchedule,
    required this.checkedIn,
    required this.lastUpdatedOn,
    required this.className,
    required this.displayDateTime,
    required this.rawDateTime,
    required this.instructor,
    required this.visible,
  });

  // Method to convert a RegisteredClass instance to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'addedOn': addedOn,
      'onSchedule': onSchedule,
      'checkedIn': checkedIn,
      'lastUpdatedOn': lastUpdatedOn,
      'className': className,
      'displayDateTime': displayDateTime,
      'rawDateTime': rawDateTime,
      'instructor': instructor,
      'visible': visible,
    };
  }

  // Method to create a RegisteredClass instance from a map
  factory RegisteredClass.fromMap(Map<String, dynamic> map) {
    return RegisteredClass(
      uid: map['uid'],
      addedOn: map['addedOn'],
      onSchedule: map['onSchedule'],
      checkedIn: map['checkedIn'],
      lastUpdatedOn: map['lastUpdatedOn'],
      className: map['className'],
      displayDateTime: map['displayDateTime'],
      rawDateTime: map['rawDateTime'],
      instructor: map['instructor'],
      visible: map['visible'],
    );
  }
}
