import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// The base class for the different types of items the List can contain
abstract class ListItem {}

// A ListItem that contains data to display a heading
class HeadingItem implements ListItem {
  final String day;

  HeadingItem(DateTime date)
      : day = DateFormat('EEEE, MMMM d, yyyy').format(date);
}

// A ListItem that contains data to display a schedule item
class ScheduleItem implements ListItem {
  final String className;
  final String instructor;
  final String instructorId;
  late String displayDateTime;
  final String description;
  final String uid;
  final DateTime rawDateTime;
  final DateTime rawEndDateTime;
  late final int capacity;
  final String classId;

  ScheduleItem({
    required this.className,
    required this.instructor,
    required this.instructorId,
    required this.displayDateTime,
    required this.description,
    required this.uid,
    required this.rawDateTime,
    required this.rawEndDateTime,
    required this.capacity,
    required this.classId,
  });

  ScheduleItem.fromMap(Map<String, dynamic> map)
      : className = map['class']['name'],
        instructor = map['instructor']['name'],
        instructorId = map['instructor']['id'],
        description = map['class']['description'],
        uid = map['id'],
        rawDateTime = DateTime.fromMicrosecondsSinceEpoch(
            map['date'].microsecondsSinceEpoch),
        rawEndDateTime = DateTime.fromMicrosecondsSinceEpoch(
            map['endDate'].microsecondsSinceEpoch),
        capacity = map['capacity'],
        classId = map['class']['id'] {
    displayDateTime = convertTime(DateTime.fromMicrosecondsSinceEpoch(
        map['date'].microsecondsSinceEpoch));
  }

  String convertTime(DateTime date) {
    var hFormatter = new DateFormat('h');
    var hour = hFormatter.format(date);

    var mFormatter = new DateFormat('m');
    var minutes = mFormatter.format(date) == "0" ? "" : mFormatter.format(date);

    var amPmFormatter = new DateFormat('a');
    var amPm = amPmFormatter.format(date).toLowerCase().replaceAll("m", "");

    return "$hour$minutes$amPm";
  }

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'instructor': instructor,
      'instructorId': instructorId,
      'displayDateTime': displayDateTime,
      'description': description,
      'uid': uid,
      'rawDateTime': rawDateTime.toIso8601String(),
      'rawEndDateTime': rawEndDateTime.toIso8601String(),
      'capacity': capacity,
      'classId': classId,
    };
  }

  @override
  String toString() {
    return 'ScheduleItem{className: $className, instructor: $instructor, instructorId: $instructorId, displayDateTime: $displayDateTime, description: $description, uid: $uid, rawDateTime: $rawDateTime, rawEndDateTime: $rawEndDateTime, capacity: $capacity, classId: $classId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleItem &&
          runtimeType == other.runtimeType &&
          className == other.className &&
          instructor == other.instructor &&
          instructorId == other.instructorId &&
          displayDateTime == other.displayDateTime &&
          description == other.description &&
          uid == other.uid &&
          rawDateTime == other.rawDateTime &&
          rawEndDateTime == other.rawEndDateTime &&
          capacity == other.capacity &&
          classId == other.classId;

  @override
  int get hashCode =>
      className.hashCode ^
      instructor.hashCode ^
      instructorId.hashCode ^
      displayDateTime.hashCode ^
      description.hashCode ^
      uid.hashCode ^
      rawDateTime.hashCode ^
      rawEndDateTime.hashCode ^
      capacity.hashCode ^
      classId.hashCode;

  ScheduleItem copyWith({
    String? className,
    String? instructor,
    String? instructorId,
    String? displayDateTime,
    String? description,
    String? uid,
    DateTime? rawDateTime,
    DateTime? rawEndDateTime,
    int? capacity,
    String? classId,
  }) {
    return ScheduleItem(
      className: className ?? this.className,
      instructor: instructor ?? this.instructor,
      instructorId: instructorId ?? this.instructorId,
      displayDateTime: displayDateTime ?? this.displayDateTime,
      description: description ?? this.description,
      uid: uid ?? this.uid,
      rawDateTime: rawDateTime ?? this.rawDateTime,
      rawEndDateTime: rawEndDateTime ?? this.rawEndDateTime,
      capacity: capacity ?? this.capacity,
      classId: classId ?? this.classId,
    );
  }
}

// Event class to represent event data
class Event {
  final String name;
  final String description;

  Event({
    required this.name,
    required this.description,
  });
}
