import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/components/Buttons/animatedFloatingActionButton.dart';
import 'package:memphisbjj/utils/ListItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:memphisbjj/screens/Error/index.dart';
import 'package:device_calendar/device_calendar.dart' as device;

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
  CollectionReference _registered;
  DocumentSnapshot usersClass;
  double _meters;
  double _onScheduleDistance;
  device.DeviceCalendarPlugin _deviceCalendarPlugin;
  bool _addedToSchedule = false;
  bool _checkedIn = false;

  _SelectedScheduleScreenState() {
    _deviceCalendarPlugin = new device.DeviceCalendarPlugin();
    this._addedToSchedule = false;
  }

  @override
  void initState() {
    _initPlateformState();
    print(this._meters);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text("Event Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildColumn(context),
          ],
        ),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        checkInToClass: _checkIntoClass,
        addToSchedule: _addToSchedule,
        removeFromSchedule: _removeFromSchedule,
        meters: this._onScheduleDistance,
        onSchedule: this._addedToSchedule,
        checkedIn: this._checkedIn,
      ),
    );
  }

  void _setAddToClassIndicator(bool value) {
    this._addedToSchedule = value;
  }

  void _checkIntoClass() {
    double meters = this._onScheduleDistance ?? this._meters;
    debugPrint(meters.toStringAsFixed(2));

    if (meters <= 275.0) {
      this.usersClass.reference.updateData(
          Map.from({"checkedIn": true, "lastUpdatedOn": DateTime.now()}));
      final snackBar = SnackBar(
        backgroundColor: Colors.greenAccent,
        content: Text(
          "Checked into ${widget.scheduleItem.className} at this location: $meters",
        ),
      );
      _globalKey.currentState.showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "You must be at Memphis Judo and Jiu-Jitsu to check into this class: feet ${meters.toStringAsFixed(2)}",
        ),
      );
      _globalKey.currentState.showSnackBar(snackBar);
      setState(() {
        this._checkedIn = true;
      });
    }
  }

  void _removeFromSchedule() async {
    setState(() {
      this._onScheduleDistance = null;
      _setAddToClassIndicator(false);
    });
    await widget.classParticipants.document(widget.user.uid).delete();
    await this._registered.document(widget.scheduleItem.uid).delete();

    await _updateClassCapacity(false);

    final snackBar = SnackBar(
      content: Text(
          "${widget.scheduleItem.className} removed from ${widget.user.displayName}'s schedule"),
    );
    _globalKey.currentState.showSnackBar(snackBar);
  }

  void _addToSchedule() async {
    setState(() {
      this._onScheduleDistance = this._meters;
    });
    final Map<String, dynamic> participant = Map.from({
      "uid": widget.user.uid,
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
      "instructor": widget.scheduleItem.instructor
    });
    await widget.classParticipants
        .document(widget.user.uid)
        .setData(participant);
    await this
        ._registered
        .document(widget.scheduleItem.uid)
        .setData(registeredClass);
    await _updateClassCapacity(true);

    _addToCalender();

    final snackBar = SnackBar(
      content: Text(
        "${widget.scheduleItem.className} added to ${widget.user.displayName}'s schedule",
      ),
    );
    _globalKey.currentState.showSnackBar(snackBar);
  }

  Future _updateClassCapacity(bool isAdded) async {
    if(isAdded) {
      if(widget.scheduleItem.capacity.runtimeType != Null && widget.scheduleItem.capacity > 0) {
        final Map<String, dynamic> classCapacity = Map.from({
          "capacity": widget.scheduleItem.capacity - 1
        });
        await Firestore.instance.collection("schedules").document("bartlett").collection("dates").document(widget.scheduleItem.classId).updateData(classCapacity);
        setState(() {
          widget.scheduleItem.capacity -= 1;
        });
      } else {
        final snackBar = SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "This class is full",
          ),
        );
        _globalKey.currentState.showSnackBar(snackBar);
      }
    } else {
      if(widget.scheduleItem.capacity.runtimeType != Null && widget.scheduleItem.capacity > 0) {
        final Map<String, dynamic> classCapacity = Map.from({
          "capacity": widget.scheduleItem.capacity + 1
        });
        await Firestore.instance.collection("schedules").document("bartlett").collection("dates").document(widget.scheduleItem.classId).updateData(classCapacity);
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
      Iterable<device.Calendar> first = calenders.where((i) => i.name == "Home" && !i.isReadOnly);
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
      final snackBar = SnackBar(
        content: Text(
          e.message,
        ),
      );
      _globalKey.currentState.showSnackBar(snackBar);
    }
  }

  Widget _buildColumn(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    this._registered = Firestore.instance
        .collection("users")
        .document(widget.user.uid)
        .collection("registeredClasses");
    return StreamBuilder(
        stream: widget.classParticipants.where("uid", isEqualTo: widget.user.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return ListTile(
              leading: CircularProgressIndicator(),
              title: Text("Loading..."),
            );

          if (snapshot.data.documents.length > 0) {
            this.usersClass = snapshot.data.documents[0];
            _setAddToClassIndicator(true);
            return Column(
              children: <Widget>[
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          widget.scheduleItem.className,
                          style: TextStyle(fontSize: 18.0),
                        ),
                        trailing: AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 500),
                          child: Icon(Icons.schedule),
                        ),
                        leading: CircleAvatar(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(widget.scheduleItem.displayDateTime)
                            ],
                          ),
                          radius: 28.0,
                        ),
                        subtitle: widget.scheduleItem.capacity.runtimeType == Null ? Text("No sign up limits") : Text("${widget.scheduleItem.capacity.toString()} Spots Left"),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 20.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: cWidth,
                              child: Text(
                                widget.scheduleItem.description,
                                style: TextStyle(fontSize: 22.0),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            _setAddToClassIndicator(false);
            return Column(
              children: <Widget>[
                Card(
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text(
                          widget.scheduleItem.className,
                          style: TextStyle(fontSize: 18.0),
                        ),
                        leading: CircleAvatar(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(widget.scheduleItem.displayDateTime)
                            ],
                          ),
                          radius: 27.0,
                        ),
                        subtitle: widget.scheduleItem.capacity.runtimeType == Null ? Text("No sign up limits") : Text("${widget.scheduleItem.capacity.toString()} Spots Left"),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0, bottom: 20.0, left: 20.0),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: cWidth,
                              child: Text(
                                widget.scheduleItem.description,
                                style: TextStyle(fontSize: 22.0),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        });
  }

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
