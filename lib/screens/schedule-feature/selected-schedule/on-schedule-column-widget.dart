import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/instructors/selected-instructors/selected-instructers-screen.dart';
import 'package:memphisbjj/screens/schedule-feature/selected-schedule/selected-schedule-screen.dart';

Column onScheduleColumn(
  BuildContext context,
  double cWidth,
  SelectedScheduleScreen widget,
  Text getClassSubtitle,
  String status,
  GlobalKey<ScaffoldState> scaffoldKey,
) {
  return Column(
    children: <Widget>[
      _buildClassCard(widget, getClassSubtitle),
      _buildInstructorCard(context, widget),
      _buildDependentsCard(context, widget, scaffoldKey),
      _buildStatusCard(status),
      _buildDescription(widget, cWidth),
    ],
  );
}

Widget _buildClassCard(SelectedScheduleScreen widget, Text subtitle) {
  return Card(
    child: ListTile(
      title: Text(
        widget.scheduleItem.className,
        style: const TextStyle(fontSize: 18.0),
      ),
      trailing: const AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 500),
        child: Icon(Icons.schedule),
      ),
      leading: CircleAvatar(
        radius: 28.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.scheduleItem.displayDateTime),
          ],
        ),
      ),
      subtitle: subtitle,
    ),
  );
}

Widget _buildInstructorCard(
  BuildContext context,
  SelectedScheduleScreen widget,
) {
  return Card(
    child: ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedInstructorScreen(
              instructorId: widget.scheduleItem.instructorId,
              name: widget.scheduleItem.instructor,
            ),
          ),
        );
      },
      title: Text(widget.scheduleItem.instructor),
      subtitle: const Text('Tap here to read more about your coach'),
    ),
  );
}

Widget _buildDependentsCard(
  BuildContext context,
  SelectedScheduleScreen widget,
  GlobalKey<ScaffoldState> scaffoldKey,
) {
  return Card(
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('dependents')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final int collectionSize = snapshot.data!.docs.length;

        if (collectionSize == 0) {
          return const ListTile(
            title: Text('No Dependents'),
            subtitle: Text('Tap here to add dependents'),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            itemCount: collectionSize,
            itemBuilder: (_, int index) {
              var doc = snapshot.data!.docs[index];
              return ListTile(
                title: Text(doc['displayName']),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                  onPressed: () {
                    final snackBar = SnackBar(
                      backgroundColor: Colors.greenAccent,
                      content:
                          Text("${doc["displayName"]} has been registered"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('REGISTER'),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}

Widget _buildStatusCard(String status) {
  return Card(
    color: Colors.green,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(status),
      ),
    ),
  );
}

Widget _buildDescription(SelectedScheduleScreen widget, double cWidth) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 20.0,
      bottom: 20.0,
      left: 20.0,
    ),
    child: SizedBox(
      width: cWidth,
      child: Text(
        widget.scheduleItem.description,
        style: const TextStyle(fontSize: 22.0),
      ),
    ),
  );
}
