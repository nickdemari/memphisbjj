import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart' as device;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:memphisbjj/components/buttons/animated-floating-action-button.dart';
import 'package:memphisbjj/screens/error/error-screen.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/models/participant.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/models/registered-class.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/not-on-schedule-column-widget.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/on-schedule-column-widget.dart';
import 'package:memphisbjj/services/messaging.dart';
import 'package:memphisbjj/utils/list-item.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SelectedScheduleScreen extends StatefulWidget {
  final String locationName;
  final User user;
  final ScheduleItem scheduleItem;
  final CollectionReference classParticipants;

  const SelectedScheduleScreen({
    Key? key,
    required this.locationName,
    required this.user,
    required this.scheduleItem,
    required this.classParticipants,
  }) : super(key: key);

  @override
  _SelectedScheduleScreenState createState() => _SelectedScheduleScreenState();
}

class _SelectedScheduleScreenState extends State<SelectedScheduleScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  StreamSubscription<Map<String, dynamic>>? _msgStream;
  late CollectionReference _registered;
  DocumentSnapshot? usersClass;
  double? _meters = 0.0;
  double? _onScheduleDistance;
  final device.DeviceCalendarPlugin _deviceCalendarPlugin =
      device.DeviceCalendarPlugin();
  bool _addedToSchedule = false;
  bool _checkedIn = false;
  String status = "REGISTERED!";

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initLocationAndSubscribe();
  }

  @override
  void dispose() {
    _msgStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocationAndSubscribe() async {
    await _initPlatformState();
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    Messaging.subscribeToTopic("testing");
    _msgStream = Messaging.onFcmMessage.listen((data) {
      var alert = Messaging.getAlert(data);
      showSnackBar(alert, Colors.deepOrange);
      _msgStream?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text(widget.scheduleItem.className,
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: _buildColumn(context),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        checkInToClass: _checkIntoClass,
        addToSchedule: _addToSchedule,
        removeFromSchedule: _removeFromSchedule,
        meters: _onScheduleDistance ?? _meters!,
        onSchedule: _addedToSchedule,
        checkedIn: _checkedIn,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildColumn(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    _registered = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.uid)
        .collection("registeredClasses");

    return StreamBuilder<QuerySnapshot>(
      stream: _getClassParticipantsStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return ListTile(
            leading: CircularProgressIndicator(),
            title: Text("Loading..."),
          );
        }

        if (snapshot.data!.docs.isNotEmpty) {
          _setAddToClassIndicator(true);
          usersClass = snapshot.data!.docs.first;
          return onScheduleColumn(
              context, cWidth, widget, _getClassSubtitle(), status, _globalKey);
        } else {
          _setAddToClassIndicator(false);
          return notOnScheduleColumn(
              context, cWidth, widget, _getClassSubtitle(), _globalKey);
        }
      },
    );
  }

  Stream<QuerySnapshot> _getClassParticipantsStream() {
    return widget.classParticipants
        .where("userUid", isEqualTo: widget.user.uid)
        .where("classUid", isEqualTo: widget.scheduleItem.uid)
        .snapshots();
  }

  void _setAddToClassIndicator(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _addedToSchedule = value;
        });
      }
    });
  }

  Text _getClassSubtitle() {
    return widget.scheduleItem.capacity == null
        ? Text("No sign up limits")
        : Text("${widget.scheduleItem.capacity} Spots Left");
  }

  Future<void> _initPlatformState() async {
    try {
      Position position = await _determinePosition();
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        35.20373,
        -89.8007544,
      );
      if (mounted) {
        setState(() {
          _meters = distance;
        });
      }
    } catch (e) {
      _meters = null;
      _navigateToErrorScreen(e.toString());
    }
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw 'Location permissions are denied.';
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void _checkIntoClass() {
    double meters = 200; // replace with actual calculation
    if (meters <= 275.0) {
      usersClass!.reference.update({
        "checkedIn": true,
        "lastUpdatedOn": DateTime.now(),
      });
      setState(() {
        _checkedIn = true;
        status = "CHECKED-IN!";
      });
      showSnackBar(
          "Checked into ${widget.scheduleItem.className}.", Colors.greenAccent);
    } else {
      showSnackBar(
          "You must be at Memphis Judo and Jiu-Jitsu to check into this class. Try again at the gym.",
          Colors.red);
    }
  }

  Future<void> _removeFromSchedule() async {
    setState(() {
      _onScheduleDistance = null;
      _addedToSchedule = false;
    });

    final test = await _getClassParticipantDoc();
    if (test != null) {
      await test.delete();
    }
    await _registered.doc(widget.scheduleItem.uid).update({
      "visible": false,
      "lastUpdatedOn": DateTime.now(),
    });

    _updateClassCapacity(false);
    showSnackBar(
        "${widget.scheduleItem.className} removed from ${widget.user.displayName}'s schedule",
        Colors.blueAccent);
  }

  Future<DocumentReference?> _getClassParticipantDoc() async {
    QuerySnapshot doc = await widget.classParticipants
        .where("userUid", isEqualTo: widget.user.uid)
        .where("classUid", isEqualTo: widget.scheduleItem.uid)
        .get();
    return doc.docs.isNotEmpty ? doc.docs.first.reference : null;
  }

  Future<void> _addToSchedule() async {
    await _initPlatformState();
    setState(() {
      _onScheduleDistance = _meters;
      status = "REGISTERED!";
    });

    final Participant participant = Participant(
      userUid: widget.user.uid,
      classUid: widget.scheduleItem.uid,
      addedOn: DateTime.now(),
      lastUpdatedOn: DateTime.now(),
      checkedIn: false,
      onSchedule: true,
      fullName: widget.user.displayName!,
      photoUrl: widget.user.photoURL,
    );

    final RegisteredClass registeredClass = RegisteredClass(
      uid: widget.scheduleItem.uid,
      addedOn: DateTime.now(),
      lastUpdatedOn: DateTime.now(),
      checkedIn: false,
      onSchedule: true,
      className: widget.scheduleItem.className,
      displayDateTime: widget.scheduleItem.displayDateTime,
      rawDateTime: widget.scheduleItem.rawDateTime,
      instructor: widget.scheduleItem.instructor,
      visible: true,
    );

    await widget.classParticipants.add(participant);
    await _registered.doc(widget.scheduleItem.uid).set(registeredClass);

    _updateClassCapacity(true);
    _addToCalendar();
  }

  Future<void> _updateClassCapacity(bool isAdded) async {
    if (widget.scheduleItem.capacity == null) return;

    int newCapacity = widget.scheduleItem.capacity! + (isAdded ? -1 : 1);
    if (newCapacity < 0) {
      showSnackBar("This class is full", Colors.red);
      return;
    }

    await FirebaseFirestore.instance
        .collection("schedules")
        .doc("bartlett")
        .collection("dates")
        .doc(widget.scheduleItem.classId)
        .update({
      "capacity": newCapacity,
    });

    setState(() {
      widget.scheduleItem.capacity = newCapacity;
    });
  }

  Future<void> _addToCalendar() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      var calendars = calendarsResult.data;

      var homeCalendar = calendars!.firstWhere(
        (calendar) => calendar.name == "Home",
        orElse: () => calendars.first,
      );

      var event = device.Event(
        homeCalendar.id,
        title: widget.scheduleItem.className,
        start: tz.TZDateTime.from(widget.scheduleItem.rawDateTime, tz.local),
        end: tz.TZDateTime.from(widget.scheduleItem.rawEndDateTime, tz.local),
      );

      await _deviceCalendarPlugin.createOrUpdateEvent(event);
    } on PlatformException catch (e) {
      showSnackBar(e.message!, Colors.red);
    }
  }

  void showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      backgroundColor: color,
      content: Text(message),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _navigateToErrorScreen(String? message) {
    if (message == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ErrorScreen(title: "Error on Event Details", message: message),
      ),
    );
  }
}
