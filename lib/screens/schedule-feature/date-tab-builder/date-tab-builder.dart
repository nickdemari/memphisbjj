import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/selected-schedule-screen.dart';
import 'package:memphisbjj/screens/schedule-feature/schedule-screen.dart';
import 'package:memphisbjj/utils/list-item.dart';

class DateTabBuilder extends StatelessWidget {
  final DateTime lastMidnight;
  final ScheduleScreen widget;

  DateTabBuilder({
    required this.lastMidnight,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("schedules")
          .doc("bartlett")
          .collection("dates")
          .where('date', isGreaterThanOrEqualTo: lastMidnight)
          .orderBy("date")
          .limit(600)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final int documentCount = snapshot.data!.docs.length;
        return ListView.builder(
          itemCount: documentCount,
          itemBuilder: (context, index) {
            final DocumentSnapshot doc = snapshot.data!.docs[index];
            final ListItem item = _getListItem(doc);

            if (item is HeadingItem) {
              return _buildHeadingItem(item);
            } else if (item is ScheduleItem) {
              final CollectionReference classParticipants =
                  FirebaseFirestore.instance.collection("class-participants");
              return _buildScheduleItem(
                  context, widget, item, classParticipants);
            }

            return Container(); // Default fallback in case of unexpected types
          },
        );
      },
    );
  }

  // Helper function to extract ListItem type
  ListItem _getListItem(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return data.containsKey("class")
        ? ScheduleItem.fromMap(data)
        : HeadingItem(doc['date'].toDate());
  }

  // Widget builder for heading items
  Widget _buildHeadingItem(HeadingItem item) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(10.0),
      child: Text(
        item.day,
        style: TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  // Widget builder for schedule items
  Widget _buildScheduleItem(
    BuildContext context,
    ScheduleScreen widget,
    ScheduleItem item,
    CollectionReference classParticipants,
  ) {
    final Query userQuery = classParticipants
        .where("userUid", isEqualTo: widget.user.uid)
        .where("classUid", isEqualTo: item.uid);

    return ListTile(
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
      leading: CircleAvatar(
        child: Text(item.displayDateTime),
        radius: 27.0,
      ),
      title: Text(item.className),
      subtitle: Text(item.instructor),
      trailing: FutureBuilder<QuerySnapshot>(
        future: userQuery.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          final int opacity =
              (snapshot.hasData && snapshot.data!.docs.isNotEmpty) ? 1 : 0;
          return _buildScheduleIcon(opacity);
        },
      ),
    );
  }

  // Widget builder for the schedule icon with opacity animation
  Widget _buildScheduleIcon(int opacity) {
    return AnimatedOpacity(
      opacity: opacity.toDouble(),
      duration: Duration(milliseconds: 500),
      child: Icon(Icons.schedule),
    );
  }
}
