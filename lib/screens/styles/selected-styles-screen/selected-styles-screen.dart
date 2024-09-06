import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectedStyleScreen extends StatefulWidget {
  final String name;
  final String styleId;

  SelectedStyleScreen({required this.styleId, required this.name});

  @override
  _SelectedStyleScreenState createState() => _SelectedStyleScreenState();
}

class _SelectedStyleScreenState extends State<SelectedStyleScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("styles")
          .doc(widget.styleId)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final DocumentSnapshot doc = snapshot.data!;
        var description = doc["description"]?.isNotEmpty == true
            ? doc["description"]
            : "No description available...";

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.name),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          description.toString().replaceAll("\\n", "\n"),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
