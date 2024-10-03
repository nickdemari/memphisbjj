import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserClassesScreen extends StatefulWidget {
  final String userUid;
  final String displayName;

  const UserClassesScreen({
    super.key,
    required this.userUid,
    required this.displayName,
  });

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userUid)
            .collection('registeredClasses')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final classes = snapshot.data?.docs ?? [];

          if (classes.isEmpty) {
            return const Center(child: Text('No registered classes found.'));
          }

          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classData = classes[index];
              final String className =
                  classData['className'] ?? 'Unknown Class';
              final String instructor =
                  classData['instructor'] ?? 'Unknown Instructor';
              final String displayDateTime =
                  classData['displayDateTime'] ?? 'Unknown Time';
              final bool checkedIn = classData['checkedIn'] ?? false;

              DateTime? rawDateTime = classData['rawDateTime'] != null
                  ? (classData['rawDateTime'] as Timestamp).toDate()
                  : null;

              var displayDay = rawDateTime != null
                  ? DateFormat('MM/dd').format(rawDateTime)
                  : 'Unknown Date';

              return ListTile(
                title: Text(
                  className,
                  style: const TextStyle(fontSize: 18.0),
                ),
                trailing: Icon(
                  checkedIn ? Icons.check_box : Icons.check_box_outline_blank,
                  color: checkedIn ? Colors.green : null,
                ),
                leading: CircleAvatar(
                  radius: 28.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(displayDateTime),
                      Text(
                        displayDay,
                        style: const TextStyle(fontSize: 10.0),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(instructor),
              );
            },
          );
        },
      ),
    );
  }
}
