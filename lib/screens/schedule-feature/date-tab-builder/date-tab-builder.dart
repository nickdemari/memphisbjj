import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/selected-schedule-screen.dart';
import 'package:memphisbjj/utils/list-item.dart';

class DateTabBuilder extends StatelessWidget {
  final DateTime lastMidnight;
  final String locationName;
  final User user;

  const DateTabBuilder({
    super.key,
    required this.lastMidnight,
    required this.locationName,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final classParticipants =
        FirebaseFirestore.instance.collection('class-participants');

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('schedules')
          .doc('bartlett')
          .collection('dates')
          .where('date', isGreaterThanOrEqualTo: lastMidnight)
          .orderBy('date')
          .limit(600)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            if (data.containsKey('class')) {
              final item = ScheduleItem.fromMap(data);
              return _buildScheduleItem(context, item, classParticipants);
            } else {
              final item = HeadingItem.fromMap(data);
              return _buildHeadingItem(item);
            }
          },
        );
      },
    );
  }

  Widget _buildHeadingItem(HeadingItem item) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(10.0),
      child: Text(
        item.day,
        style: const TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    ScheduleItem item,
    CollectionReference classParticipants,
  ) {
    final userQuery = classParticipants
        .where('userUid', isEqualTo: user.uid)
        .where('classUid', isEqualTo: item.uid);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedScheduleScreen(
              locationName: locationName,
              user: user,
              scheduleItem: item,
              classParticipants: classParticipants,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 27.0,
        backgroundColor: const Color.fromARGB(255, 180, 207, 230),
        child: Text(item.displayDateTime),
      ),
      title: Text(item.className),
      subtitle: Text(item.instructor),
      trailing: FutureBuilder<QuerySnapshot>(
        future: userQuery.get(),
        builder: (context, snapshot) {
          final opacity =
              (snapshot.hasData && snapshot.data!.docs.isNotEmpty) ? 1.0 : 0.0;
          return AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 500),
            child: const Icon(Icons.schedule),
          );
        },
      ),
    );
  }
}

class HeadingItemWidget extends StatelessWidget {
  final String day;

  const HeadingItemWidget({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.all(10.0),
      child: Text(
        day,
        style: const TextStyle(color: Colors.white, fontSize: 18.0),
      ),
    );
  }
}

class ScheduleItemWidget extends StatelessWidget {
  final ScheduleItem item;
  final CollectionReference classParticipants;
  final String locationName;
  final User user;

  Query get userQuery => classParticipants
      .where('userUid', isEqualTo: user.uid)
      .where('classUid', isEqualTo: item.uid);

  const ScheduleItemWidget({
    super.key,
    required this.item,
    required this.classParticipants,
    required this.locationName,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedScheduleScreen(
              locationName: locationName,
              user: user,
              scheduleItem: item,
              classParticipants: classParticipants,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 27.0,
        backgroundColor: const Color.fromARGB(255, 180, 207, 230),
        child: Text(item.displayDateTime),
      ),
      title: Text(item.className),
      subtitle: Text(item.instructor),
      trailing: FutureBuilder<QuerySnapshot>(
        future: userQuery.get(),
        builder: (context, snapshot) {
          final opacity =
              (snapshot.hasData && snapshot.data!.docs.isNotEmpty) ? 1.0 : 0.0;
          return AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 500),
            child: const Icon(Icons.schedule),
          );
        },
      ),
    );
  }
}
