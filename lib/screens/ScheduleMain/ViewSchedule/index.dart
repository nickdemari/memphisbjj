import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/screens/ScheduleMain/index.dart';
import 'package:memphisbjj/services/messaging.dart';

class ViewScheduleScreen extends StatefulWidget {
  final FirebaseUser user;
  final bool getAll;

  ViewScheduleScreen({this.user, this.getAll});

  @override
  _ViewScheduleScreenState createState() => _ViewScheduleScreenState();
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  StreamSubscription<Map<String, dynamic>> _msgStream;

  @override
  void initState() {
    Messaging.subscribeToTopic("testing");
    _msgStream = Messaging.onFcmMessage.listen((data) {
      var alert = Messaging.getAlert(data);
      Messaging.cancelFcmMessaging();
      var snackBar = SnackBar(
        content: Text(alert),
        backgroundColor: Colors.deepOrange,
      );
      _globalKey.currentState.showSnackBar(snackBar);

      _msgStream.cancel();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastMidnight = new DateTime(now.year, now.month, now.day);

    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text("My Classes"),
      ),
      body: StreamBuilder(
          stream: widget.getAll
              ? Firestore.instance
                  .collection("users")
                  .document(widget.user.uid)
                  .collection("registeredClasses")
                  .orderBy("rawDateTime")
                  .snapshots()
              : Firestore.instance
                  .collection("users")
                  .document(widget.user.uid)
                  .collection("registeredClasses")
                  .where("rawDateTime", isGreaterThanOrEqualTo: lastMidnight)
                  .orderBy("rawDateTime")
                  .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            if (snapshot.data.documents.length == 0)
              return ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => ScheduleMainScreen(
                                user: widget.user,
                                locationName: "Bartlett",
                              )));
                },
                title: Text("No classes found. Tap here to add a class."),
              );
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, int index) {
                  final DocumentSnapshot document =
                      snapshot.data.documents[index];
                  var formatter = new DateFormat('MM/dd');
                  var displayDay = formatter.format(document["rawDateTime"]);
                  return ListTile(
                    title: Text(
                      document["className"],
                      style: TextStyle(fontSize: 18.0),
                    ),
                    trailing: document["checkedIn"]
                        ? Icon(Icons.check_box)
                        : Icon(Icons.check_box_outline_blank),
                    leading: CircleAvatar(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(document["displayDateTime"]),
                          Text(
                            displayDay,
                            style: TextStyle(fontSize: 10.0),
                          )
                        ],
                      ),
                      radius: 28.0,
                    ),
                    subtitle: Text(document["instructor"]),
                  );
                });
          }),
    );
  }
}
