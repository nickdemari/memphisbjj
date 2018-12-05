import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/screens/Admin/UserClassesAdmin/index.dart';
import 'package:memphisbjj/utils/ListItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAdminScreen extends StatefulWidget {
  final String userUid;
  final String displayName;

  UserAdminScreen({Key key, this.userUid, this.displayName});

  @override
  _UserAdminScreenState createState() => _UserAdminScreenState();
}

class _UserAdminScreenState extends State<UserAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin"),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection("users").orderBy("displayName").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, int index) {
                  final DocumentSnapshot document = snapshot.data.documents[index];
                  return StreamBuilder(
                    stream: document.reference.collection("registeredClasses").snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();
                      List<DocumentSnapshot> userClasses = snapshot.data.documents;
                      return ListTile(
                        leading: CircleAvatar(
                          child: ClipOval(
                              child: Image.network(
                                document["photoUrl"],
                                fit: BoxFit.cover,
                                width: 90.0,
                                height: 90.0,
                              )),
                          radius: 27.0,
                        ),
                        title: Text(document["displayName"]),
                        subtitle: Text(document["email"]),
                        trailing: Text(userClasses.length.toString()),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UserClassesScreen(userUid: document["firebaseUid"], displayName: document["displayName"],))),
                      );
                    },
                  );
                });
          }),
    );
  }
}

/*floatingActionButton: FloatingActionButton(onPressed: () {
  var datesCollection = Firestore.instance.collection("schedules").document("bartlett").collection("dates");
  final now = DateTime.now();
  var lastMidnight = new DateTime(now.year, now.month, now.day);
  for (var i = 0; i < 4023; i++) {
    lastMidnight = lastMidnight.add(Duration(days: 1));
    datesCollection.add(Map.from({"date": lastMidnight}));
  }
  print("done");
}),*/