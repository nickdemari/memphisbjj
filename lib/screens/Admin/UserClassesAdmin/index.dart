import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/utils/ListItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserClassesScreen extends StatefulWidget {
  final String userUid;
  final String displayName;

  UserClassesScreen({Key key, this.userUid, this.displayName});

  @override
  _UserClassesScreenState createState() => _UserClassesScreenState();
}

class _UserClassesScreenState extends State<UserClassesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.displayName}'s Classes"),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection("users").document(widget.userUid).collection("registeredClasses").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, int index) {
                  final DocumentSnapshot document = snapshot.data.documents[index];
                  var formatter = new DateFormat('MM/dd');
                  var displayDay = formatter.format(document["rawDateTime"]);
                  return ListTile(
                    title: Text(
                      document["className"],
                      style: TextStyle(fontSize: 18.0),
                    ),
                    trailing: document["checkedIn"] ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),
                    leading: CircleAvatar(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(document["displayDateTime"]),
                          Text(displayDay, style: TextStyle(fontSize: 10.0),)
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
