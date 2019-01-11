import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/ScheduleMain/SelectedSchedule/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/index.dart';
import 'package:memphisbjj/utils/ListItem.dart';

StreamBuilder buildByDateTab(DateTime lastMidnight, ScheduleMainScreen widget,
    StreamSubscription<Map<String, dynamic>> msg) {
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance
        .collection("schedules")
        .document("bartlett")
        .collection("dates")
        .where('date', isGreaterThanOrEqualTo: lastMidnight)
        .orderBy("date")
        .limit(600)
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

      final int documentCount = snapshot.data.documents.length;
      return ListView.builder(
        itemCount: documentCount,
        itemBuilder: (BuildContext context, int index) {
          final DocumentSnapshot doc = snapshot.data.documents[index];
          final CollectionReference classParticipants =
              Firestore.instance.collection("class-participants");
          final ListItem item = !doc.data.containsKey("class")
              ? HeadingItem(doc['date'])
              : ScheduleItem(
                  doc['date'],
                  new Map<String, dynamic>.from(
                    doc['instructor'],
                  ),
                  new Map<String, dynamic>.from(
                    doc['class'],
                  ),
                  doc.documentID,
                  doc['endDate'],
                  doc['capacity'],
                  doc['id'],
                );

          if (item is HeadingItem) {
            Widget header = Container(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    item.day,
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ));
            return header;
          } else if (item is ScheduleItem) {
            //Get a query of each classes participants to see who's in the class
            Query userQuery = classParticipants
                .where("userUid", isEqualTo: widget.user.uid)
                .where("classUid", isEqualTo: item.uid);

            Widget row = ListTile(
              onTap: () {
                msg.cancel();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectedScheduleScreen(
                          locationName: widget.locationName,
                          user: widget.user,
                          scheduleItem: item,
                          classParticipants: classParticipants,
                        ),
                  ),
                );
              },
              leading: new CircleAvatar(
                child: new Text(
                  item.displayDateTime.toString(),
                ),
                radius: 27.0,
              ),
              title: new Text(item.className),
              subtitle: Text(item.instructor),
              trailing: FutureBuilder(
                future: userQuery.getDocuments(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return AnimatedOpacity(
                    opacity: 0,
                    duration: Duration(milliseconds: 500),
                    child: Icon(Icons.schedule),
                  );

                  if (snapshot.data.documents.length == 0) {
                    return AnimatedOpacity(
                      opacity: 0,
                      duration: Duration(milliseconds: 500),
                      child: Icon(Icons.schedule),
                    );
                  } else {
                    return AnimatedOpacity(
                      opacity: 1,
                      duration: Duration(milliseconds: 500),
                      child: Icon(Icons.schedule),
                    );
                  }
                },
              ),
            );
            return row;
          }
        },
      );
    },
  );
}
