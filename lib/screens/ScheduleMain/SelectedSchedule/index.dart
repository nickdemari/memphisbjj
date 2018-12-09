import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/ScheduleMain/ViewSchedule/index.dart';
import 'package:memphisbjj/utils/ListItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:memphisbjj/screens/Error/index.dart';

class SelectedScheduleScreen extends StatefulWidget {
  final String locationName;
  final FirebaseUser user;
  final ScheduleItem scheduleItem;
  final CollectionReference usersInClassCollection;

  SelectedScheduleScreen({this.locationName, this.user, this.scheduleItem, this.usersInClassCollection});

  @override
  _SelectedScheduleScreenState createState() => _SelectedScheduleScreenState();
}

class _SelectedScheduleScreenState extends State<SelectedScheduleScreen> {
  DocumentSnapshot usersClass;
  double _meters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Details"),
      ),
      body: Column(
        children: <Widget>[
          _buildColumn(context),
        ],
      ),
      floatingActionButton: widget.user.isAnonymous || _meters == null
          ? null
          : Builder(builder: (BuildContext context) {
              return Container(
                width: 85.0,
                height: 85.0,
                child: FloatingActionButton(
                  child: Text("CHECK IN"),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  onPressed: () {
                    double meters = _meters;
                    debugPrint(meters.toStringAsFixed(2));

                    if (meters <= 275.0) {
                      this.usersClass.reference.updateData(Map.from({"checkedIn": true, "lastUpdatedOn": DateTime.now()}));
                      final snackBar = SnackBar(backgroundColor: Colors.greenAccent, content: Text("Checked into ${widget.scheduleItem.className} at this location: $meters"));
                      Scaffold.of(context).showSnackBar(snackBar);
                    } else {
                      final snackBar =
                          SnackBar(backgroundColor: Colors.redAccent, content: Text("You must be at Memphis Judo and Jiu-Jitsu to check into this class: feet ${meters.toStringAsFixed(2)}"));
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  },
                ),
              );
            }),
    );
  }

  Widget _buildColumn(BuildContext context) {
    CollectionReference userClassCollection = Firestore.instance.collection("users").document(widget.user.uid).collection("registeredClasses");
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    return StreamBuilder(
        stream: widget.usersInClassCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return ListTile(
              leading: CircularProgressIndicator(),
              title: Text("Loading..."),
            );
          print(snapshot.data.documents.length);
          if (snapshot.data.documents.length > 0) {
            this.usersClass = snapshot.data.documents[0];
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
                        subtitle: Text(widget.scheduleItem.instructor),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0),
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
                widget.user.isAnonymous
                    ? Container(
                        height: 0.0,
                        width: 0.0,
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.red,
                              child: Text("REMOVE"),
                              onPressed: () {
                                setState(() {
                                  _meters = null;
                                });
                                widget.usersInClassCollection.document(widget.user.uid).delete();
                                userClassCollection.document(widget.scheduleItem.uid).delete();

                                final snackBar = SnackBar(content: Text("${widget.scheduleItem.className} removed from ${widget.user.displayName}'s schedule"));
                                Scaffold.of(context).showSnackBar(snackBar);
                              }),
                          SizedBox(width: 24.0),
                          RaisedButton(
                            child: Text("VIEW SCHEDULE"),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewScheduleScreen(
                                            user: widget.user,
                                          )));
                            },
                          )
                        ],
                      )
              ],
            );
          } else {
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
                        subtitle: Text(widget.scheduleItem.instructor),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20.0),
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
                widget.user.isAnonymous
                    ? Container(
                  height: 0.0,
                  width: 0.0,
                )
                    : RaisedButton(
                  color: Color(0xFF1a256f),
                    child: Text("Add to schedule", style: TextStyle(color: Colors.white),),
                    onPressed: () {
                      _initPlateformState();
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
                      widget.usersInClassCollection.document(widget.user.uid).setData(participant);
                      userClassCollection.document(widget.scheduleItem.uid).setData(registeredClass);

                      final snackBar = SnackBar(content: Text("${widget.scheduleItem.className} added to ${widget.user.displayName}'s schedule"));
                      Scaffold.of(context).showSnackBar(snackBar);
                    })
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
      position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      distance = await geolocator.distanceBetween(position.latitude, position.longitude, 35.20373, -89.8007544);
    } on PlatformException catch (e) {
      debugPrint(e.message);
      _meters = null;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(
                    title: "Error on Event Details",
                    message: e.message,
                  )));
    }

    if (!mounted) return;
    setState(() {
      _meters = distance;
    });
  }
}
