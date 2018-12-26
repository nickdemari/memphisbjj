import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/screens/ScheduleMain/SelectedSchedule/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/index.dart';
import 'package:memphisbjj/utils/ListItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Builder buildByClassTab(DateTime lastMidnight, ScheduleMainScreen widget, StreamSubscription<Map<String, dynamic>> msg) {
  return Builder(builder: (BuildContext context) {
    final Stream<QuerySnapshot> eventsRef = Firestore.instance
        .collection("events")
        .orderBy("class.name")
        .snapshots();
    final GlobalKey<ScaffoldState> _classGlobalKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: _classGlobalKey,
        body: StreamBuilder(
            stream: eventsRef,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              return _byClassListBuilder(
                  snapshot, _classGlobalKey, lastMidnight, widget, msg);
            }));
  });
}

ListView _byClassListBuilder(
    AsyncSnapshot<QuerySnapshot> snapshot,
    GlobalKey<ScaffoldState> _classGlobalKey,
    DateTime lastMidnight,
    ScheduleMainScreen widget,
    StreamSubscription<Map<String, dynamic>> msg) {
  return ListView.builder(
      itemCount: snapshot.data.documents.length,
      itemBuilder: (context, int index) {
        DocumentSnapshot document = snapshot.data.documents[index];
        var event = document["class"];
        var eventObj = Map<String, dynamic>.from(event);
        var eventName = eventObj['name'];
        return ListTile(
        title: Text(eventObj['name']),
        onTap: () => _classGlobalKey.currentState.showBottomSheet(
        (context) => StreamBuilder(
        stream: Firestore.instance
            .collection("schedules")
            .document("bartlett")
            .collection("dates")
            .where("class.name", isEqualTo: eventName)
            .where('date', isGreaterThanOrEqualTo: lastMidnight)
            .orderBy("date")
            .snapshots(),
        builder: (BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
        return Center(child: CircularProgressIndicator());

        final int documentCount =
        snapshot.data.documents.length;
        return Container(
        child: Column(
        children: <Widget>[
        Container(
        color: Colors.black12,
        child: ListTile(
        leading: Text(eventName),
        trailing: Icon(Icons.drag_handle),
        ),
        ),
        Expanded(
        child: _byClassListItems(
        snapshot, widget, documentCount, msg),
        ),
        ],
        ),
        );
        },
        ),
        ),
        );
      });
}

ListView _byClassListItems(AsyncSnapshot<QuerySnapshot> snapshot,
    ScheduleMainScreen widget, int documentCount, StreamSubscription<Map<String, dynamic>> msg) {
  return ListView.builder(
    itemBuilder: (BuildContext context, int index) {
      final DocumentSnapshot doc = snapshot.data.documents[index];
      final ListItem item = !doc.data.containsKey("class")
          ? HeadingItem(doc['date'])
          : ScheduleItem(
          doc['date'],
          doc['instructor'],
          new Map<String, dynamic>.from(doc['class']),
          doc.documentID,
          doc['endDate'],
          doc['capacity'],
          doc['classId']
      );
      final CollectionReference classParticipants =
      doc.reference.collection("participants");
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
                    )));
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
            subtitle: Text(item.instructor),
          ),
        );
        return row;
      }
    },
    itemCount: documentCount,
  );
}