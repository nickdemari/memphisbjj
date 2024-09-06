import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/instructors/selected-instructors/selected-instructers-screen.dart';

class InstructorsScreen extends StatefulWidget {
  @override
  _InstructorsScreenState createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
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
          stream:
              FirebaseFirestore.instance.collection("instructors").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final int collectionCount = snapshot.data!.docs.length;
            if (collectionCount == 0) {
              return Center(
                child: Text("No instructors available"),
              );
            }

            return ListView.builder(
              itemCount: collectionCount,
              itemBuilder: (BuildContext context, int index) {
                final DocumentSnapshot doc = snapshot.data!.docs[index];
                if (doc["name"] == "None") return SizedBox.shrink();

                return ListTile(
                  onTap: () {
                    String uid = doc.id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectedInstructorScreen(
                          instructorId: uid,
                          name: doc['name'],
                        ),
                      ),
                    );
                  },
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
