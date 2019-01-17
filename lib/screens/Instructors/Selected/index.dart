import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectedInstructorScreen extends StatefulWidget{
  final String name;
  final String instructorId;

  SelectedInstructorScreen({this.instructorId, this.name});

  @override
  _SelectedInstructorScreenState createState() => _SelectedInstructorScreenState();
}

class _SelectedInstructorScreenState extends State<SelectedInstructorScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection("instructors").document(widget.instructorId).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator(),);

        final DocumentSnapshot doc = snapshot.data;
        var bio = doc["bio"] == "" ? "No bio available..." : doc["bio"];
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.name),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Card(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(bio),
                  ),)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}