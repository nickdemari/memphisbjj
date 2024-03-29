
import 'package:intl/intl.dart';
// The base class for the different types of items the List can contain
abstract class ListItem {}

// A ListItem that contains data to display a heading
class HeadingItem implements ListItem {
  String day;

  HeadingItem(DateTime date) {
    var formatter = new DateFormat('EEEE, MMMM d, ''yyyy');
    this.day = formatter.format(date);
  }
}

// A ListItem that contains data to display a message
class ScheduleItem implements ListItem {
  String className;
  String instructor;
  String instructorId;
  String displayDateTime;
  String description;
  String uid;
  DateTime rawDateTime;
  DateTime rawEndDateTime;
  int capacity;
  String classId;

  ScheduleItem(DateTime d, Map<String, dynamic> l, Map<String, dynamic> event, String _uid, DateTime _rawEndDateTime, int _capacity, String _classId) {
    // Handle Time
    this.displayDateTime = convertTime(d);
    this.rawDateTime = d;
    this.rawEndDateTime = _rawEndDateTime;
    this.className = event['name'];
    this.instructor = l["name"];
    this.instructorId = l["id"];
    this.description = event['description'];
    this.uid = _uid;
    this.capacity = _capacity;
    this.classId = _classId;
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
}

class Event {
  String name;
  String description;

  Event({this.name, this.description});
}