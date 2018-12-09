import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memphisbjj/screens/ScheduleMain/index.dart';

class ViewScheduleScreen extends StatefulWidget {
  final FirebaseUser user;

  ViewScheduleScreen({this.user});

  @override
  _ViewScheduleScreenState createState() => _ViewScheduleScreenState();
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Classes"),
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(widget.user.uid)
              .collection("registeredClasses")
              .orderBy("rawDateTime")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            if (snapshot.data.documents.length == 0)
              return ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ScheduleMainScreen(user: widget.user, locationName: "Bartlett",)));
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
