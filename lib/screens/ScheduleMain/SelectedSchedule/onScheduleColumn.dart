import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/Instructors/Selected/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/SelectedSchedule/index.dart';

Column onScheduleColumn(
  BuildContext context,
  double cWidth,
  SelectedScheduleScreen widget,
  Text _getClassSubtitle,
  String status,
  GlobalKey<ScaffoldState> scaffoldKey,
) {
  return Column(
    children: <Widget>[
      Card(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                widget.scheduleItem.className,
                style: TextStyle(fontSize: 18.0),
              ),
              trailing: AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 500),
                child: Icon(Icons.schedule),
              ),
              leading: CircleAvatar(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text(widget.scheduleItem.displayDateTime)],
                ),
                radius: 28.0,
              ),
              subtitle: _getClassSubtitle,
            ),
          ],
        ),
      ),
      Card(
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
      ),
      Card(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(widget.user.uid)
              .collection("dependents")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            var collectionSize = snapshot.data.documents.length;
            if (collectionSize == 0)
              return ListTile(
                title: Text("No Dependents"),
                subtitle: Text("Tap here to add dependents"),
              );
            return Container(
              height: 180,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: collectionSize,
                      itemBuilder: (_, int index) {
                        var doc = snapshot.data.documents[index];
                        return ListTile(
                          title: Text(doc["displayName"]),
                          trailing: FlatButton(
                            color: Colors.lightBlueAccent,
                            onPressed: () {
                              final snackBar = SnackBar(
                                backgroundColor: Colors.greenAccent,
                                content: Text(
                                  "${doc["displayName"]} has been registered",
                                ),
                              );
                              scaffoldKey.currentState.showSnackBar(snackBar);
                            },
                            child: Text("REGISTER"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      Card(
        color: Colors.green,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(status),
          ),
        ),
      ),
      Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20.0,
              left: 20.0,
            ),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: cWidth,
                    child: Text(
                      widget.scheduleItem.description,
                      style: TextStyle(fontSize: 22.0),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
