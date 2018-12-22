import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InstructorsScreen extends StatefulWidget {
  @override
  _InstructorsScreenState createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 125.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("Instructors",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )),
                background: Image.asset(
                  "assets/member-benefits.jpg",
                  fit: BoxFit.cover,
                  color: Color(0xff3e4b60),
                  colorBlendMode: BlendMode.hardLight,
                ),
              ),
            ),
          ];
        },
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("instructors").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );

            final int collectionCount = snapshot.data.documents.length;
            return ListView.builder(
              itemCount: collectionCount,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot doc = snapshot.data.documents[index];
                return ListTile(
                  title: Text(doc['name']),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
