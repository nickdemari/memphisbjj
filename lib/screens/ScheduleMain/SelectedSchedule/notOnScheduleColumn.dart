import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/Instructors/Selected/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/SelectedSchedule/index.dart';

Column notOnScheduleColumn(
  BuildContext context,
  double cWidth,
  SelectedScheduleScreen widget,
  Text _getClassSubtitle,
  GlobalKey<ScaffoldState> scaffoldKey,
) {
  return Column(
    children: <Widget>[
      _buildClassCard(widget, _getClassSubtitle),
      _buildInstructorCard(context, widget),
      _buildDependentsCard(context, widget, scaffoldKey),
      _buildDescription(widget, cWidth),
    ],
  );
}

Widget _buildClassCard(SelectedScheduleScreen widget, Text subtitle) {
  return Card(
    child: ListTile(
      title: Text(
        widget.scheduleItem.className,
        style: TextStyle(fontSize: 18.0),
      ),
      leading: CircleAvatar(
        radius: 27.0,
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
    BuildContext context, SelectedScheduleScreen widget) {
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
      subtitle: Text("Tap here to read more about your coach"),
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
          .collection("users")
          .doc(widget.user.uid)
          .collection("dependents")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final int collectionSize = snapshot.data!.docs.length;

        if (collectionSize == 0) {
          return ListTile(
            title: Text("No Dependents"),
            subtitle: Text("Tap here to add dependents"),
          );
        }

        return Container(
          height: 180,
          child: ListView.builder(
            itemCount: collectionSize,
            itemBuilder: (_, int index) {
              var doc = snapshot.data!.docs[index];
              return ListTile(
                title: Text(doc["displayName"]),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent),
                  onPressed: () {
                    final snackBar = SnackBar(
                      backgroundColor: Colors.greenAccent,
                      content:
                          Text("${doc["displayName"]} has been registered"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Text("CHECK-IN"),
                ),
              );
            },
          ),
        );
      },
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
    child: Container(
      width: cWidth,
      child: Text(
        widget.scheduleItem.description,
        style: TextStyle(fontSize: 22.0),
      ),
    ),
  );
}
