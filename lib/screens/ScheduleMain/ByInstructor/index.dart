import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/screens/ScheduleMain/SelectedSchedule/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/index.dart';
import 'package:memphisbjj/utils/ListItem.dart';

Builder buildByInstructorTab(DateTime lastMidnight, ScheduleMainScreen widget,
    StreamSubscription<Map<String, dynamic>> msg) {
  return Builder(
    builder: (BuildContext context) {
      final Stream<QuerySnapshot> instructorsRef = Firestore.instance
          .collection("instructors")
          .orderBy("name")
          .snapshots();
      final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
      return Scaffold(
          key: _globalKey,
          body: StreamBuilder(
              stream: instructorsRef,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                return _byInstructorListBuilder(
                  snapshot,
                  _globalKey,
                  lastMidnight,
                  widget,
                  msg,
                );
              }));
    },
  );
}

ListView _byInstructorListBuilder(
    AsyncSnapshot<QuerySnapshot> snapshot,
    GlobalKey<ScaffoldState> _globalKey,
    DateTime lastMidnight,
    ScheduleMainScreen widget,
    StreamSubscription<Map<String, dynamic>> msg) {
  return ListView.builder(
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, int index) {
        DocumentSnapshot document = snapshot.data.documents[index];
        String name = document["name"];
        return ListTile(
          title: Text(name),
          onTap: () => _globalKey.currentState.showBottomSheet(
                (context) => StreamBuilder(
                      stream: Firestore.instance
                          .collection("schedules")
                          .document("bartlett")
                          .collection("dates")
                          .where("instructor.name", isEqualTo: name)
                          .where('date', isGreaterThanOrEqualTo: lastMidnight)
                          .orderBy("date")
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData)
                          return Center(child: CircularProgressIndicator());

                        final int documentCount =
                            snapshot.data.documents.length;
                        return Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                color: Colors.black12,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(name),
                                      Icon(Icons.drag_handle)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _expandedInstructorItem(
                              snapshot,
                              widget,
                              documentCount,
                              msg,
                            )
                          ],
                        );
                      },
                    ),
              ),
        );
      });
}

Expanded _expandedInstructorItem(
  AsyncSnapshot<QuerySnapshot> snapshot,
  ScheduleMainScreen widget,
  int documentCount,
  StreamSubscription<Map<String, dynamic>> msg,
) {
  return Expanded(
    child: ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        final DocumentSnapshot doc = snapshot.data.documents[index];
        final ListItem item = !doc.data.containsKey("class")
            ? HeadingItem(doc['date'])
            : ScheduleItem(
                doc['date'],
                new Map<String, dynamic>.from(
                  doc['instructor'],
                ),
                new Map<String, dynamic>.from(doc['class']),
                doc.documentID,
                doc['endDate'],
                doc['capacity'],
                doc['id']);
        final CollectionReference classParticipants =
            doc.reference.collection("class-participants");
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
          var formatter = new DateFormat('EEEE');
          var day = formatter.format(item.rawDateTime);
          Widget row = GestureDetector(
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
            child: ListTile(
                leading: CircleAvatar(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(item.displayDateTime),
                      Text(
                        day,
                        style: TextStyle(fontSize: 10.0),
                      ),
                    ],
                  ),
                  radius: 28.0,
                ),
                title: new Text(item.className),
                subtitle: Text(item.instructor)),
          );
          return row;
        }
      },
      itemCount: documentCount,
    ),
  );
}
