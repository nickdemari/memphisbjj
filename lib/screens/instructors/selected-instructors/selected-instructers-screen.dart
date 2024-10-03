import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectedInstructorScreen extends StatefulWidget {
  final String name;
  final String instructorId;

  const SelectedInstructorScreen(
      {super.key, required this.instructorId, required this.name,});

  @override
  _SelectedInstructorScreenState createState() =>
      _SelectedInstructorScreenState();
}

class _SelectedInstructorScreenState extends State<SelectedInstructorScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('instructors')
          .doc(widget.instructorId)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final doc = snapshot.data;
        var bio = doc != null && doc['bio'] != null && doc['bio'].isNotEmpty
            ? doc['bio']
            : 'No bio available...';

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.name),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(bio),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
