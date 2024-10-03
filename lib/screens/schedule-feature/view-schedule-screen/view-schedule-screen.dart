import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/screens/schedule-feature/schedule-screen.dart';
import 'package:memphisbjj/services/messaging.dart';

class ViewScheduleScreen extends StatefulWidget {
  final User user;
  final bool getAll;

  const ViewScheduleScreen({super.key, required this.user, required this.getAll});

  @override
  _ViewScheduleScreenState createState() => _ViewScheduleScreenState();
}

class _ViewScheduleScreenState extends State<ViewScheduleScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  StreamSubscription<Map<String, dynamic>>? _msgStream;

  @override
  void initState() {
    super.initState();
    _subscribeToFCM();
  }

  @override
  void dispose() {
    _msgStream?.cancel();
    super.dispose();
  }

  void _subscribeToFCM() {
    Messaging.subscribeToTopic('testing');
    _msgStream = Messaging.onFcmMessage.listen((data) {
      var alert = Messaging.getAlert(data);
      _showSnackBar(alert, Colors.deepOrange);
    });
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime lastMidnight = DateTime(now.year, now.month, now.day);

    return SafeArea(
      child: Scaffold(
        key: _globalKey,
        appBar: AppBar(
          title: const Text('My Classes'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: widget.getAll
              ? _getAllClassesStream()
              : _getUpcomingClassesStream(lastMidnight),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final documents = snapshot.data!.docs;

            if (documents.isEmpty) {
              return _buildNoClassesTile(context);
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (BuildContext context, int index) {
                final document = documents[index];
                return _buildClassTile(document);
              },
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getAllClassesStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('registeredClasses')
        .orderBy('rawDateTime')
        .snapshots();
  }

  Stream<QuerySnapshot> _getUpcomingClassesStream(DateTime lastMidnight) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .collection('registeredClasses')
        .where('rawDateTime', isGreaterThanOrEqualTo: lastMidnight)
        .orderBy('rawDateTime')
        .snapshots();
  }

  Widget _buildNoClassesTile(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ScheduleScreen(
              user: widget.user,
              locationName: 'Bartlett',
            ),
          ),
        );
      },
      title: const Text('No classes found. Tap here to add a class.'),
    );
  }

  Widget _buildClassTile(DocumentSnapshot document) {
    var displayDate =
        DateFormat('MM/dd').format(document['rawDateTime'].toDate());
    return ListTile(
      title: Text(
        document['className'],
        style: const TextStyle(fontSize: 18.0),
      ),
      trailing: document['checkedIn']
          ? const Icon(Icons.check_box, color: Colors.green)
          : const Icon(Icons.check_box_outline_blank),
      leading: CircleAvatar(
        radius: 28.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(document['displayDateTime']),
            Text(
              displayDate,
              style: const TextStyle(fontSize: 10.0),
            ),
          ],
        ),
      ),
      subtitle: Text(document['instructor']),
    );
  }
}
