import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/utils/ListItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewScheduleScreen extends StatefulWidget {
  final String locationName;
  final FirebaseUser user;
  final ScheduleItem scheduleItem;
  final CollectionReference usersInClassCollection;

  ViewScheduleScreen(
      {this.locationName, this.user, this.scheduleItem, this.usersInClassCollection});

  @override
  _ViewScheduleScreenState createState() => _ViewScheduleScreenState();
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Schedule"),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection("users").document(widget.user.uid).collection("registeredClasses").orderBy("rawDateTime").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(!snapshot.hasData) return CircularProgressIndicator();
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, int index) {
                  final DocumentSnapshot document = snapshot.data.documents[index];
                  var formatter = new DateFormat('MM-dd-yy h:mm a');
                  var displayDateTime = formatter.format(document["rawDateTime"]);
                  return ListTile(title: Text(document["className"]), trailing: Text(displayDateTime), subtitle: Text(document["instructor"]),);
                }
            );
          }
      ),
    );
  }
}