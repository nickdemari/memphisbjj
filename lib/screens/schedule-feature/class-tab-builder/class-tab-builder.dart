import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/selected-schedule-screen.dart';
import 'package:memphisbjj/screens/schedule-feature/schedule-screen.dart';
import 'package:memphisbjj/utils/list-item.dart';

class ClassTabBuilder extends StatelessWidget {
  final DateTime lastMidnight;
  final ScheduleScreen widget;

  const ClassTabBuilder({
    Key? key,
    required this.lastMidnight,
    required this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> eventsRef = FirebaseFirestore.instance
        .collection('events')
        .orderBy('class.name')
        .snapshots();
    final GlobalKey<ScaffoldState> classGlobalKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: classGlobalKey,
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsRef,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ClassList(
            snapshot: snapshot,
            lastMidnight: lastMidnight,
            widget: widget,
            scaffoldKey: classGlobalKey,
          );
        },
      ),
    );
  }
}

class ClassList extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final DateTime lastMidnight;
  final ScheduleScreen widget;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ClassList({
    Key? key,
    required this.snapshot,
    required this.lastMidnight,
    required this.widget,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: snapshot.data?.docs.length ?? 0,
      itemBuilder: (context, index) {
        final DocumentSnapshot document = snapshot.data!.docs[index];
        final Map<String, dynamic> event =
            document['class'] as Map<String, dynamic>;
        final String eventName = event['name'];

        return ListTile(
          title: Text(eventName),
          onTap: () => scaffoldKey.currentState?.showBottomSheet(
            (context) => ClassBottomSheet(
              eventName: eventName,
              lastMidnight: lastMidnight,
              widget: widget,
            ),
          ),
        );
      },
    );
  }
}

class ClassBottomSheet extends StatelessWidget {
  final String eventName;
  final DateTime lastMidnight;
  final ScheduleScreen widget;

  const ClassBottomSheet({
    Key? key,
    required this.eventName,
    required this.lastMidnight,
    required this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> scheduleStream = FirebaseFirestore.instance
        .collection('schedules')
        .doc('bartlett')
        .collection('dates')
        .where('class.name', isEqualTo: eventName)
        .where('date', isGreaterThanOrEqualTo: lastMidnight)
        .orderBy('date')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: scheduleStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final int documentCount = snapshot.data!.docs.length;
        return Column(
          children: [
            Container(
              color: Colors.black12,
              child: ListTile(
                leading: Text(eventName),
                trailing: const Icon(Icons.drag_handle),
              ),
            ),
            Expanded(
              child: ClassScheduleList(
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

class ClassScheduleList extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final ScheduleScreen widget;
  final int documentCount;

  const ClassScheduleList({
    Key? key,
    required this.snapshot,
    required this.widget,
    required this.documentCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documentCount,
      itemBuilder: (context, index) {
        final DocumentSnapshot doc = snapshot.data!.docs[index];
        final ListItem item =
            (doc.data() as Map<String, dynamic>).containsKey('class')
                ? ScheduleItem.fromMap(doc.data() as Map<String, dynamic>)
                : HeadingItem(doc['date'].toDate());

        final CollectionReference classParticipants =
            doc.reference.collection('class-participants');

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

        return Container(); // Return an empty container for any unexpected cases
      },
    );
  }
}

class HeadingItemWidget extends StatelessWidget {
  final HeadingItem item;

  const HeadingItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(10.0),
      child: Text(
        item.day,
        style: const TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }
}

class ScheduleItemWidget extends StatelessWidget {
  final BuildContext context;
  final ScheduleScreen widget;
  final ScheduleItem item;
  final CollectionReference classParticipants;

  const ScheduleItemWidget({
    Key? key,
    required this.context,
    required this.widget,
    required this.item,
    required this.classParticipants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String day = DateFormat('EEEE').format(item.rawDateTime);

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
              Text(day, style: const TextStyle(fontSize: 10.0)),
            ],
          ),
        ),
        title: Text(item.className),
        subtitle: Text(item.instructor),
      ),
    );
  }
}
