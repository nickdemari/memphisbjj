import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/selected-schedule-screen.dart';
import 'package:memphisbjj/screens/schedule-feature/schedule-screen.dart';
import 'package:memphisbjj/utils/list-item.dart';

class InstructorTabBuilder extends StatelessWidget {
  final DateTime lastMidnight;
  final ScheduleScreen widget;

  InstructorTabBuilder({
    required this.lastMidnight,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> instructorsRef = FirebaseFirestore.instance
        .collection("instructors")
        .orderBy("name")
        .snapshots();
    final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _globalKey,
      body: StreamBuilder<QuerySnapshot>(
        stream: instructorsRef,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return InstructorList(
            snapshot: snapshot,
            globalKey: _globalKey,
            lastMidnight: lastMidnight,
            widget: widget,
          );
        },
      ),
    );
  }
}

class InstructorList extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final GlobalKey<ScaffoldState> globalKey;
  final DateTime lastMidnight;
  final ScheduleScreen widget;

  InstructorList({
    required this.snapshot,
    required this.globalKey,
    required this.lastMidnight,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        final DocumentSnapshot document = snapshot.data!.docs[index];
        final String name = document["name"];

        return ListTile(
          title: Text(name),
          onTap: () => globalKey.currentState!.showBottomSheet(
            (context) => InstructorScheduleBottomSheet(
              name: name,
              lastMidnight: lastMidnight,
              widget: widget,
            ),
          ),
        );
      },
    );
  }
}

class InstructorScheduleBottomSheet extends StatelessWidget {
  final String name;
  final DateTime lastMidnight;
  final ScheduleScreen widget;

  InstructorScheduleBottomSheet({
    required this.name,
    required this.lastMidnight,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> scheduleStream = FirebaseFirestore.instance
        .collection("schedules")
        .doc("bartlett")
        .collection("dates")
        .where("instructor.name", isEqualTo: name)
        .where('date', isGreaterThanOrEqualTo: lastMidnight)
        .orderBy("date")
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: scheduleStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final int documentCount = snapshot.data!.docs.length;
        return Column(
          children: [
            Container(
              color: Colors.black12,
              child: ListTile(
                leading: Text(name),
                trailing: Icon(Icons.drag_handle),
              ),
            ),
            Expanded(
              child: InstructorScheduleList(
                snapshot: snapshot,
                widget: widget,
                documentCount: documentCount,
              ),
            ),
          ],
        );
      },
    );
  }
}

class InstructorScheduleList extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final ScheduleScreen widget;
  final int documentCount;

  InstructorScheduleList({
    required this.snapshot,
    required this.widget,
    required this.documentCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documentCount,
      itemBuilder: (context, index) {
        final DocumentSnapshot doc = snapshot.data!.docs[index];
        final ListItem item =
            (doc.data() as Map<String, dynamic>).containsKey("class")
                ? ScheduleItem.fromMap(doc.data() as Map<String, dynamic>)
                : HeadingItem(doc['date'].toDate());

        final CollectionReference classParticipants =
            doc.reference.collection("class-participants");

        if (item is HeadingItem) {
          return HeadingItemWidget(item: item);
        } else if (item is ScheduleItem) {
          return ScheduleItemWidget(
            context: context,
            widget: widget,
            item: item,
            classParticipants: classParticipants,
          );
        }

        return Container(); // Fallback for unexpected cases
      },
    );
  }
}

class HeadingItemWidget extends StatelessWidget {
  final HeadingItem item;

  HeadingItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(10.0),
      child: Text(
        item.day,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }
}

class ScheduleItemWidget extends StatelessWidget {
  final BuildContext context;
  final ScheduleScreen widget;
  final ScheduleItem item;
  final CollectionReference classParticipants;

  ScheduleItemWidget({
    required this.context,
    required this.widget,
    required this.item,
    required this.classParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('EEEE');
    final String day = formatter.format(item.rawDateTime);

    return GestureDetector(
      onTap: () {
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
          radius: 28.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.displayDateTime),
              Text(day, style: TextStyle(fontSize: 10.0)),
            ],
          ),
        ),
        title: Text(item.className),
        subtitle: Text(item.instructor),
      ),
    );
  }
}
