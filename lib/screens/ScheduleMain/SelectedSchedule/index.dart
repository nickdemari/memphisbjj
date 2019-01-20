import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart' as device;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:memphisbjj/components/Buttons/animatedFloatingActionButton.dart';
import 'package:memphisbjj/screens/Error/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/SelectedSchedule/notOnScheduleColumn.dart';
import 'package:memphisbjj/screens/ScheduleMain/SelectedSchedule/onScheduleColumn.dart';
import 'package:memphisbjj/services/messaging.dart';
import 'package:memphisbjj/utils/ListItem.dart';

class SelectedScheduleScreen extends StatefulWidget {
  final String locationName;
  final FirebaseUser user;
  final ScheduleItem scheduleItem;
  final CollectionReference classParticipants;

  SelectedScheduleScreen({
    this.locationName,
    this.user,
    this.scheduleItem,
    this.classParticipants,
  });

  @override
  _SelectedScheduleScreenState createState() => _SelectedScheduleScreenState();
}

class _SelectedScheduleScreenState extends State<SelectedScheduleScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  StreamSubscription<Map<String, dynamic>> _msgStream;
  CollectionReference _registered;
  DocumentSnapshot usersClass;
  double _meters;
  double _onScheduleDistance;
  device.DeviceCalendarPlugin _deviceCalendarPlugin;
  bool _addedToSchedule = false;
  bool _checkedIn = false;
  String status = "REGISTERED!";

  _SelectedScheduleScreenState() {
    _deviceCalendarPlugin = new device.DeviceCalendarPlugin();
    this._addedToSchedule = false;
  }

  @override
  void initState() {
    _initPlateformState();
    Messaging.subscribeToTopic("testing");
    _msgStream = Messaging.onFcmMessage.listen((data) {
      print("FCM TRIGGERED in selected schedule");
      var alert = Messaging.getAlert(data);
      showSnackBar(alert, Colors.deepOrange);

      _msgStream.cancel();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(), child: _buildColumn(context)),
      floatingActionButton: AnimatedFloatingActionButton(
        checkInToClass: _checkIntoClass,
        addToSchedule: _addToSchedule,
        removeFromSchedule: _removeFromSchedule,
        meters: this._onScheduleDistance,
        onSchedule: this._addedToSchedule,
        checkedIn: this._checkedIn,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _setAddToClassIndicator(bool value) {
    this._addedToSchedule = value;
  }

  void _checkIntoClass() {
    double meters = this._onScheduleDistance ?? this._meters;
    debugPrint("distance in meters: ${meters.toStringAsFixed(2)}");

    if (meters <= 275.0) {
      this.usersClass.reference.updateData(
          Map.from({"checkedIn": true, "lastUpdatedOn": DateTime.now()}));
      setState(() {
        this._checkedIn = true;
        this.status = "CHECKED-IN!";
      });
      showSnackBar("Checked into ${widget.scheduleItem.className}.", Colors.greenAccent);
    } else {
      showSnackBar("You must be at Memphis Judo and Jiu-Jitsu to check into this class. Try again at the gym.", Colors.red);
    }
  }

  void _removeFromSchedule() async {
    setState(() {
      this._onScheduleDistance = null;
      _setAddToClassIndicator(false);
    });
    QuerySnapshot doc = await widget.classParticipants
        .where("userUid", isEqualTo: widget.user.uid)
        .where("classUid", isEqualTo: widget.scheduleItem.uid)
        .getDocuments();
    doc.documents[0].reference.delete();
    await this._registered.document(widget.scheduleItem.uid).updateData(
        Map.from({"visible": false, "lastUpdatedOn": DateTime.now()}));

    _updateClassCapacity(false);

    showSnackBar("${widget.scheduleItem.className} removed from ${widget.user.displayName}'s schedule", Colors.blueAccent);
  }

  void _addToSchedule() async {
    _initPlateformState();
    setState(() {
      this._onScheduleDistance = this._meters;
      this.status = "REGISTERED!";
    });
    final Map<String, dynamic> participant = Map.from({
      "userUid": widget.user.uid,
      "classUid": widget.scheduleItem.uid,
      "addedOn": DateTime.now(),
      "onSchedule": true,
      "checkedIn": false,
      "lastUpdatedOn": DateTime.now(),
      "fullName": widget.user.displayName,
      "photoUrl": widget.user.photoUrl
    });
    final Map<String, dynamic> registeredClass = Map.from({
      "uid": widget.scheduleItem.uid,
      "addedOn": DateTime.now(),
      "onSchedule": true,
      "checkedIn": false,
      "lastUpdatedOn": DateTime.now(),
      "className": widget.scheduleItem.className,
      "displayDateTime": widget.scheduleItem.displayDateTime,
      "rawDateTime": widget.scheduleItem.rawDateTime,
      "instructor": widget.scheduleItem.instructor,
      "visible": true,
    });
    await widget.classParticipants.add(participant);
    await this
        ._registered
        .document(widget.scheduleItem.uid)
        .setData(registeredClass);

    _updateClassCapacity(true);

    _addToCalender();
  }

  void _updateClassCapacity(bool isAdded) async {
    if (isAdded) {
      if (widget.scheduleItem.capacity.runtimeType == Null) return;
      if (widget.scheduleItem.capacity > 0) {
        final Map<String, dynamic> classCapacity =
            Map.from({"capacity": widget.scheduleItem.capacity - 1});
        await Firestore.instance
            .collection("schedules")
            .document("bartlett")
            .collection("dates")
            .document(widget.scheduleItem.classId)
            .updateData(classCapacity);
        setState(() {
          widget.scheduleItem.capacity -= 1;
        });
      } else {
        showSnackBar("This class is full", Colors.red);
      }
    } else {
      if (widget.scheduleItem.capacity.runtimeType != Null &&
          widget.scheduleItem.capacity > 0) {
        final Map<String, dynamic> classCapacity =
            Map.from({"capacity": widget.scheduleItem.capacity + 1});
        await Firestore.instance
            .collection("schedules")
            .document("bartlett")
            .collection("dates")
            .document(widget.scheduleItem.classId)
            .updateData(classCapacity);
        setState(() {
          widget.scheduleItem.capacity += 1;
        });
      }
    }
  }

  void _addToCalender() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return;
        }
      }

      final result = await _deviceCalendarPlugin.retrieveCalendars();
      var calenders = result?.data;
      Iterable<device.Calendar> first =
          calenders.where((i) => i.name == "Home" && !i.isReadOnly);
      if (first.length == 0) {
        first = calenders.where((i) => !i.isReadOnly);
      }
      var homeCalender = first.first;
      var event = device.Event(
        homeCalender.id,
        title: widget.scheduleItem.className,
        start: widget.scheduleItem.rawDateTime,
        end: widget.scheduleItem.rawEndDateTime,
      );
      print(event.eventId);
      await _deviceCalendarPlugin.createOrUpdateEvent(event);
    } on PlatformException catch (e) {
      showSnackBar(e.message, Colors.red);
    }
  }

  void showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      backgroundColor: color,
      content: Text(
        message,
      ),
    );
    _globalKey.currentState.showSnackBar(snackBar);
  }

  Widget _buildColumn(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    this._registered = Firestore.instance
        .collection("users")
        .document(widget.user.uid)
        .collection("registeredClasses");
    return StreamBuilder(
        stream: widget.classParticipants
            .where("userUid", isEqualTo: widget.user.uid)
            .where("classUid", isEqualTo: widget.scheduleItem.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return ListTile(
              leading: CircularProgressIndicator(),
              title: Text("Loading..."),
            );

          if (snapshot.data.documents.length > 0) {
            _setAddToClassIndicator(true);
            this.usersClass = snapshot.data.documents[0];
            return onScheduleColumn(context, cWidth, widget, _getClassSubtitle(), this.status, _globalKey);
          } else {
            _setAddToClassIndicator(false);
            return notOnScheduleColumn(context, cWidth, widget, _getClassSubtitle(), _globalKey);
          }
        });
  }

  Text _getClassSubtitle() => widget.scheduleItem.capacity.runtimeType == Null
      ? Text("No sign up limits")
      : Text("${widget.scheduleItem.capacity.toString()} Spots Left");

  void _initPlateformState() async {
    Position position;
    double distance;
    try {
      Geolocator geolocator = Geolocator();
      position = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      distance = await geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        35.20373,
        -89.8007544,
      );
    } on PlatformException catch (e) {
      _meters = null;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorScreen(
                title: "Error on Event Details",
                message: e.message,
              ),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _meters = distance;
    });
  }
}
